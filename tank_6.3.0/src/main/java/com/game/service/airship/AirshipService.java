package com.game.service.airship;

import com.game.constant.*;
import com.game.dataMgr.StaticFunctionPlanDataMgr;
import com.game.dataMgr.StaticHeroDataMgr;
import com.game.dataMgr.StaticPropDataMgr;
import com.game.dataMgr.StaticWorldDataMgr;
import com.game.domain.Member;
import com.game.domain.PartyData;
import com.game.domain.Player;
import com.game.domain.p.*;
import com.game.domain.p.airship.*;
import com.game.domain.s.StaticAirship;
import com.game.domain.s.StaticHero;
import com.game.domain.s.StaticProp;
import com.game.manager.*;
import com.game.message.handler.ClientHandler;
import com.game.pb.CommonPb;
import com.game.pb.GamePb2;
import com.game.pb.GamePb5;
import com.game.pb.GamePb5.*;
import com.game.service.*;
import com.game.util.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

/**
 * 飞艇逻辑处理类, 战事|队伍|集结 表示的都是一个玩家对一个飞艇发起进攻序列,本公会的所有玩家都可以加入这个序列
 * 1.同一个工会同一个时间点对同一个飞艇只能有一个进攻序列
 * 2.同一个玩家同一个时间点只能拥有一个进攻序列
 */
@Service
public class AirshipService {

    @Autowired
    private StaticWorldDataMgr staticWorldDataMgr;

    @Autowired
    private StaticHeroDataMgr staticHeroDataMgr;

    @Autowired
    private StaticPropDataMgr staticPropDataMgr;

    @Autowired
    private StaticFunctionPlanDataMgr staticFunctionPlanDataMgr;

    @Autowired
    private AirshipDataManager airshipDataManager;

    @Autowired
    private PlayerDataManager playerDataManager;

    @Autowired
    private PartyDataManager partyDataManager;

    @Autowired
    private WorldDataManager worldDataManager;

    @Autowired
    private StaffingDataManager staffingDataManager;

    @Autowired
    private ChatService chatService;

    @Autowired
    private FightService fightService;

    @Autowired
    private WorldService worldService;

    @Autowired
    private PlayerService playerService;

    @Autowired
    private AirshipFightService airshipFightService;

    @Autowired
    private ActionCenterService actionCenterService;

    @Autowired
    private DataRepairDM dataRepairDM;
    @Autowired
    private TacticsService tacticsService;
    /**
     * 获取玩家参与飞艇信息
     *
     * @param req
     * @param handler
     */
    public void getAirshipPlayerInfo(GetAirshipPlayerRq req, ClientHandler handler) {
        if (!staticFunctionPlanDataMgr.isAirshipOpen()) return;

        Player player = playerDataManager.getPlayer(handler.getRoleId());
        Member member = partyDataManager.getMemberById(player.lord.getLordId());
        PartyData partyData = member != null ? partyDataManager.getParty(member.getPartyId()) : null;
        if (partyData == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
            return;
        }

        Airship airship = airshipDataManager.getAirshipMap().get(req.getAirshipId());
        if (airship == null || airship.getSafeEndTime() < 0) {//飞艇未解锁(低级飞艇被占领过后才能解锁高级飞艇)
            handler.sendErrorMsgToPlayer(GameError.AIRSHIP_UN_LOCK);
            return;
        }
        int nowDay = TimeHelper.getCurrentDay();
        GetAirshipPlayerRs.Builder builder = GetAirshipPlayerRs.newBuilder();
        PlayerAirship pp = airshipDataManager.getPlayerAirshipMap().get(handler.getRoleId());
        int scoutValidTime = pp != null && pp.getScoutMap().containsKey(airship.getId()) ? pp.getScoutMap().get(airship.getId()) : 0;
        //玩家侦查有效时间
        builder.setValidEndTime(scoutValidTime);
        //玩家免费创建集结次数
        int freeCnt = airshipDataManager.getPlayerFreeCrtTeamCnt(airship, player, partyData, member.getJob(), nowDay);
        builder.setRemianFreeCnt(freeCnt);
        handler.sendMsgToPlayer(GetAirshipPlayerRs.ext, builder.build());
    }

    /**
     * 重建飞艇
     *
     * @param handler
     */
    public void rebuildAirship(RebuildAirshipRq req, ClientHandler handler) {
        if (!staticFunctionPlanDataMgr.isAirshipOpen()) return;

        Player player = playerDataManager.getPlayer(handler.getRoleId());
        //没加入工会
        PartyData myParty = partyDataManager.getPartyByLordId(handler.getRoleId());
        if (myParty == null) {
            handler.sendErrorMsgToPlayer(GameError.PARTY_NOT_EXIST);
            return;
        }

        //飞艇不存在
        Airship airship = airshipDataManager.getAirshipMap().get(req.getAirshipId());
        if (airship == null) {
            handler.sendErrorMsgToPlayer(GameError.AIRSHIP_NOT_FOUND_ERR);
            return;
        }

        StaticAirship staticAirship = staticWorldDataMgr.getAirshipMap().get(airship.getId());
        List<List<Integer>> repairCost = staticAirship != null ? staticAirship.getRepair() : null;
        if (repairCost == null) {
            handler.sendErrorMsgToPlayer(GameError.STATIC_DATA_ERROR);
            return;
        }

        //飞艇不属于自己工会
        if (!isMyPartyAirship(airship, myParty)) {
            handler.sendErrorMsgToPlayer(GameError.AIRSHIP_NOT_BELONG_MY_PARTY);
            return;
        }

        //飞艇耐久度已满,不需要修复
        if (airship.getDurability() >= AirshipConst.AIRSHIP_REBUILD_DURABILITY_MAX) {
            handler.sendErrorMsgToPlayer(GameError.AIRSHIP_DURABILITY_FULL);
            return;
        }

        //已经进入生产阶段, 不能再重建飞艇
        if (!airship.isRuins()) {
            handler.sendErrorMsgToPlayer(GameError.AIRSHIP_DURABILITY_FULL);
            return;
        }

        /**
            世界等级,如果编制等级未开启，这不计算世界等级,
         {@link com.game.service.StaffingService#getStaffing(ClientHandler)}
         */
        int worldLv = TimeHelper.isStaffingOpen() ? staffingDataManager.getWorldLv() : 0;

        //资源检测
        for (List<Integer> list : repairCost) {
            int count = FormulaCalcHelper.Airship.calcRebuildResouceCount(worldLv, list.get(2));
            if (!playerDataManager.checkPropIsEnougth(player, list.get(0), list.get(1), count)) {
                LogUtil.error(String.format("nick :%s, ---->  ty:%d, id:%d,worldLv:%d, config count :%d, need count :%d",
                        player.lord.getNick(), list.get(0), list.get(1), worldLv, list.get(2), count));
                handler.sendErrorMsgToPlayer(GameError.PROP_NOT_ENOUGH);
                return;
            }
        }

        List<CommonPb.Atom2> atom2List = new ArrayList<>();
        //扣除资源
        for (List<Integer> list : repairCost) {
            int count = FormulaCalcHelper.Airship.calcRebuildResouceCount(worldLv, list.get(2));
            atom2List.add(playerDataManager.subProp(player, list.get(0), list.get(1), count, AwardFrom.AIRSHIP_REBUILD));
        }

        //增加耐久度
        int durability = airship.getDurability() + AirshipConst.AIRSHIP_REBUILD_DURABILITY;
        airship.setDurability(Math.min(durability, AirshipConst.AIRSHIP_REBUILD_DURABILITY_MAX));

        //第一次耐久度修复满时开始生产道具
        if (airship.isRuins() && durability >= AirshipConst.AIRSHIP_REBUILD_DURABILITY_MAX) {
            airship.setRuins(false); //设置飞艇解除废墟状态，并开始生产道具
            airship.setProduceTime(TimeHelper.getCurrentSecond());
        }

        //返回协议
        RebuildAirshipRs.Builder builder = RebuildAirshipRs.newBuilder();
        builder.setAirshipId(airship.getId());
        builder.setDurability(airship.getDurability());
        builder.addAllAtom(atom2List);
        handler.sendMsgToPlayer(RebuildAirshipRs.ext, builder.build());

        //向工会成员广播飞艇信息发生变化
        StcHelper.syncAirshipChange2Party(airship.getId(), myParty.getPartyId());
    }

    /**
     * 查看本军团所有飞艇指挥官信息
     *
     * @param handler
     */
    public void getPartyAirshipCommander(ClientHandler handler) {
        if (!staticFunctionPlanDataMgr.isAirshipOpen()) return;

        Member member = partyDataManager.getMemberById(handler.getRoleId());
        if (member == null || member.getPartyId() <= 0) return;
        PartyData partData = partyDataManager.getParty(member.getPartyId());
        if (partData == null) return;
        GetPartyAirshipCommanderRs.Builder builder = GetPartyAirshipCommanderRs.newBuilder();
        if (!partData.getAirshipLeaderMap().isEmpty()) {
            CommonPb.KvLong.Builder kvb = CommonPb.KvLong.newBuilder();
            for (Map.Entry<Integer, Long> entry : partData.getAirshipLeaderMap().entrySet()) {
                kvb.setKey(entry.getKey());
                Player commandar = playerDataManager.getPlayer(entry.getValue());
                kvb.setValue(commandar.lord.getLordId());
                builder.addKv(kvb);
                kvb.clear();
            }
        }
        handler.sendMsgToPlayer(GetPartyAirshipCommanderRs.ext, builder.build());
    }

    /**
     * 飞艇指挥官任命
     *
     * @param req
     * @param handler
     */
    public void appointAirshipCommander(GamePb5.AppointAirshipCommanderRq req, ClientHandler handler) {
        if (!staticFunctionPlanDataMgr.isAirshipOpen()) return;

        int airshipId = req.getAirshipId();
        long appointLordId = req.getLordId();
        Player appointPlayer = playerDataManager.getPlayer(appointLordId);
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (appointPlayer == null || player == null) return;

        //飞艇不存在
        Airship airship = airshipDataManager.getAirshipMap().get(airshipId);
        if (airship == null) return;

        //对方已经拥有了至少一个飞艇
        PartyData partyData = partyDataManager.getParty(airship.getPartyId());
        Map<Integer, Long> leaderMap = partyData.getAirshipLeaderMap();
        if (!leaderMap.isEmpty()) {
            for (Map.Entry<Integer, Long> entry : leaderMap.entrySet()) {
                if (appointLordId == entry.getValue()) {
                    handler.sendErrorMsgToPlayer(GameError.ALREADY_HAS_AIRSHIP_ERR);
                    return;
                }
            }
        }

        //飞艇不属于本工会
        Member member = partyDataManager.getMemberById(player.roleId);
        if (member == null || airship.getPartyId() != member.getPartyId()) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }

        //被任命者不是本工会成员
        Member appointMember = partyDataManager.getMemberById(appointPlayer.roleId);
        if (appointMember == null || member.getPartyId() != appointMember.getPartyId()) {
            handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
            return;
        }

        //必须是飞艇指挥官或者副会长以上成员才有任命权限
        Long airshipCommander = partyData.getAirshipLeaderMap().get(airshipId);
        boolean isAirshipCommander = airshipCommander != null && airshipCommander == player.lord.getLordId();
        if (!isAirshipCommander && member.getJob() < PartyType.LEGATUS_CP) {
            handler.sendErrorMsgToPlayer(GameError.AUTHORITY_ERR);
            return;
        }

        Long oldCommander = partyData.getAirshipLeaderMap().get(airshipId);

        //设置飞艇拥有者
        leaderMap.put(airshipId, appointLordId);

        //通知在线玩家飞艇发生变化
        StcHelper.syncAirshipChange2World(airshipId);

        int nowSec = TimeHelper.getCurrentSecond();
        if (oldCommander != null && oldCommander != player.lord.getLordId()) {//原指挥官邮件
            playerDataManager.sendNormalMail(playerDataManager.getPlayer(oldCommander), MailType.MOLD_AIRSHIP_COMMANDER_LOST, nowSec, player.lord.getNick());
        }

        //新指挥官邮件
        playerDataManager.sendNormalMail(appointPlayer, MailType.MOLD_AIRSHIP_APPOINT_COMMANDER, nowSec, player.lord.getNick(), String.valueOf(airship.getId()));


        //通知客户端
        GamePb5.AppointAirshipCommanderRs.Builder builder = GamePb5.AppointAirshipCommanderRs.newBuilder();
        builder.setAirshipId(airshipId);
        builder.setLordId(appointLordId);
        handler.sendMsgToPlayer(GamePb5.AppointAirshipCommanderRs.ext, builder.build());
    }

    /**
     * 获取飞艇信息
     *
     * @param req
     * @param handler
     */
    public void getAirship(GetAirshipRq req, ClientHandler handler) {
        if (!staticFunctionPlanDataMgr.isAirshipOpen()) return;

        int airshipId = req.getAirshipId();//0-请求所有飞艇信息
        GetAirshipRs.Builder builder = GetAirshipRs.newBuilder();
        Map<Integer, Airship> airshipMap = airshipDataManager.getAirshipMap();

        PartyData myParty = partyDataManager.getPartyByLordId(handler.getRoleId());
        int now = TimeHelper.getCurrentSecond();

        if (airshipId == 0) {
            for (Airship airship : airshipMap.values()) {
                builder.addAirship(createPbAirship(myParty, airship, now));
            }
        } else {
            Airship airship = airshipMap.get(airshipId);
            if (airship != null) {
                builder.addAirship(createPbAirship(myParty, airship, now));
            }
        }
        handler.sendMsgToPlayer(GetAirshipRs.ext, builder.build());
    }

    /**
     * 创建Airship的pb信息
     *
     * @param myParty
     * @param airship
     * @param nowSec
     * @return
     */
    private CommonPb.Airship.Builder createPbAirship(PartyData myParty, Airship airship, int nowSec) {
        CommonPb.Airship.Builder pbAirship = CommonPb.Airship.newBuilder();
        //飞艇基础信息
        AirshipTeam team = myParty != null ? myParty.getAirshipTeamMap().get(airship.getId()) : null;//本工会飞艇集结队伍
        long teamLeader = team != null ? team.getLordId() : 0L;
        pbAirship.setBase(PbHelper.createAirshipBase(airship, teamLeader));
        //飞艇占领信息
        PartyData partyData = airship.getPartyData();
        if (partyData != null) {
            Long leader = partyData.getAirshipLeaderMap().get(airship.getId());
            Player player = playerDataManager.getPlayer(leader);
            pbAirship.setOccupy(PbHelper.createAirshipOccupy(airship, partyData, player.lord));
        }
        //飞艇详细信息
        if (isMyPartyAirship(airship, myParty)) {//己方飞艇才需要显示详细信息
            airshipDataManager.produceItem(airship, nowSec);
            CommonPb.AirshipDetail.Builder detail = PbHelper.createAirshipDetail(airship);
            if (airship.getProduceTime() >= 0) {//客户端显示飞艇生产结束时间
                StaticAirship staticAirship = staticWorldDataMgr.getAirshipMap().get(airship.getId());
                if (airship.getProduceNum() >= staticAirship.getCapacity()) {
                    detail.setProduceTime(0);//客户端显示
                } else {
                    detail.setProduceTime(airship.getProduceTime() + staticAirship.getEfficiency());
                }
            }
            pbAirship.setDetail(detail);
        }
        return pbAirship;
    }

    /**
     * 判断飞艇是否己方飞艇
     *
     * @param airship 飞艇
     * @param myParty 己方飞艇
     * @return
     */
    private boolean isMyPartyAirship(Airship airship, PartyData myParty) {
        PartyData partyData = airship.getPartyData();
        return myParty != null && partyData != null && partyData.getPartyId() == myParty.getPartyId();
    }

    /**
     * 侦查飞艇
     */
    public void scoutAirship(int id, ClientHandler handler) {
        if (!staticFunctionPlanDataMgr.isAirshipOpen()) return;

        Player player = playerDataManager.getPlayer(handler.getRoleId());

        //飞艇未配置
        StaticAirship staticAirship = staticWorldDataMgr.getAirshipMap().get(id);
        List<List<Integer>> scoutCost = staticAirship != null ? staticAirship.getSpyCost() : null;
        if (scoutCost == null || scoutCost.isEmpty()) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }

        //飞艇不存在
        Airship airship = airshipDataManager.getAirshipMap().get(id);
        if (airship == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }

        Map<Long, PlayerAirship> playerAirshipMap = airshipDataManager.getPlayerAirshipMap();
        PlayerAirship playerAirship = playerAirshipMap.get(player.roleId);
        int curTime = TimeHelper.getCurrentSecond();
        List<CommonPb.Atom2> atom2List = null;
        Integer souctValidEndTime = playerAirship != null ? playerAirship.getScoutMap().get(airship.getId()) : null;
        //已经过了侦查有效期，再次侦查需要扣除资源
        if (souctValidEndTime == null || souctValidEndTime < curTime) {
            for (List<Integer> cost : scoutCost) {
                if (!playerDataManager.checkPropIsEnougth(player, cost.get(0), cost.get(1), cost.get(2))) {
                    handler.sendErrorMsgToPlayer(GameError.RESOURCE_NOT_ENOUGH);
                    return;
                }
            }
            atom2List = new ArrayList<>();
            for (List<Integer> cost : scoutCost) {
                atom2List.add(playerDataManager.subProp(player, cost.get(0), cost.get(1), cost.get(2), AwardFrom.SCOUT_AIRSHIP));
            }
            if (playerAirship == null) {
                playerAirshipMap.put(player.roleId, playerAirship = new PlayerAirship());
            }
            playerAirship.getScoutMap().put(airship.getId(), TimeHelper.getCurrentSecond() + TimeHelper.HALF_HOUR_S);
        }

        int commanderCount = 0;       // 指挥官数量
        int tankCount = 0;           // 坦克数量
        long fightCount = 0;       // 战力数量

        List<Army> guardArmys = airship.getGuardArmy();
        for (Army army : guardArmys) {
            if (army.getForm().getCommander() > 0) {
                commanderCount++;
            }
            int[] p = army.getForm().p;
            int[] c = army.getForm().c;
            for (int i = 0; i < p.length; i++) {
                if (p[i] != 0) {
                    tankCount += c[i];
                }
            }
            if (army.player != null && army.getForm() != null) {
                fightCount += fightService.calcFormFight(army.player, army.getForm());
            } else {
                fightCount += army.getFight();
            }

        }

        ScoutAirshipRs.Builder builder = ScoutAirshipRs.newBuilder();
        builder.setCommanderCount(commanderCount);
        builder.setTankCount(tankCount);
        builder.setFightCount(fightCount);
        builder.setValidEndTime(playerAirship.getScoutMap().get(airship.getId()));
        if (atom2List != null) builder.addAllAtom2(atom2List);
        handler.sendMsgToPlayer(ScoutAirshipRs.ext, builder.build());
    }

    /**
     * 驻防飞艇
     *
     * @param req
     * @param handler
     */
    public void guardAirship(GuardAirshipRq req, ClientHandler handler) {
        if (!staticFunctionPlanDataMgr.isAirshipOpen()) return;

        int id = req.getId();
        long fight = req.getFight();
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        //必须是军团成员
        Member member = partyDataManager.getMemberById(player.roleId);
        PartyData partyData = member != null ? partyDataManager.getParty(member.getPartyId()) : null;
        if (partyData == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
            return;
        }

        //飞艇未配置
        StaticAirship sap = staticWorldDataMgr.getAirshipMap().get(id);
        if (sap == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }
        Airship airship = airshipDataManager.getAirshipMap().get(id);
        if (airship == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }

        //不是本军团的飞艇不允许驻军
        if (airship.getPartyData() == null) {
            handler.sendErrorMsgToPlayer(GameError.NOT_IN_PARTY);
            return;
        }
        if (airship.getPartyData().getPartyId() != partyData.getPartyId()) {
            handler.sendErrorMsgToPlayer(GameError.NOT_IN_PARTY);
            return;
        }
        int maxCount = playerDataManager.armyCount(player);
        int armyCount = playerDataManager.getPlayArmyCount(player,maxCount);
        for (Army army : player.armys) {
            //一个军团成员一个飞艇只能驻防一只部队
            int armyState = army.getState();
            if (armyState == ArmyState.AIRSHIP_GUARD
                    || armyState == ArmyState.AIRSHIP_GUARD_MARCH) {
                StaticAirship staticAirship = staticWorldDataMgr.getStaticAirshipByPos(army.getTarget());
                if (staticAirship != null && staticAirship.getId() == airship.getId()) {
                    handler.sendErrorMsgToPlayer(GameError.MAX_ARMY_COUNT);
                    return;
                }
            }
//            else if (army.getState() == ArmyState.WAR) {
//                armyCount -= 1;
//                break;
//            }
        }

        if (armyCount >= playerDataManager.armyCount(player)) {
            handler.sendErrorMsgToPlayer(GameError.MAX_ARMY_COUNT);
            return;
        }

        //废墟状态中的飞艇不能派驻军防守
        if (airship.isRuins()) {
            handler.sendErrorMsgToPlayer(GameError.AIRSHIP_DURABILITY_NOT_FULL);
            return;
        }


        Form attackForm = PbHelper.createForm(req.getForm());
        StaticHero staticHero = null;
        int heroId = 0;
        AwakenHero awakenHero = null;
        Hero hero = null;
        if (attackForm.getAwakenHero() != null) {//使用觉醒将领
            awakenHero = player.awakenHeros.get(attackForm.getAwakenHero().getKeyId());
            if (awakenHero == null || awakenHero.isUsed()) {
                handler.sendErrorMsgToPlayer(GameError.NO_HERO);
                return;
            }
            attackForm.setAwakenHero(awakenHero.clone());
            heroId = awakenHero.getHeroId();
        } else if (attackForm.getCommander() > 0) {
            hero = player.heros.get(attackForm.getCommander());
            if (hero == null || hero.getCount() <= 0) {
                handler.sendErrorMsgToPlayer(GameError.NO_HERO);
                return;
            }
            heroId = hero.getHeroId();
        }

        if (heroId != 0) {
            staticHero = staticHeroDataMgr.getStaticHero(heroId);
            if (staticHero == null) {
                handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
                return;
            }

            if (staticHero.getType() != 2) {
                handler.sendErrorMsgToPlayer(GameError.NOT_HERO);
                return;
            }
        }
        //战术验证
        if (!attackForm.getTactics().isEmpty()) {
            boolean checkUseTactics = tacticsService.checkUseTactics(player, attackForm);
            if (!checkUseTactics) {
                handler.sendErrorMsgToPlayer(GameError.USE_TACTICS_ERROR);
                return;
            }
        }
        int maxTankCount = playerDataManager.formTankCount(player, staticHero, awakenHero);
        if (!playerDataManager.checkAndSubTank(player, attackForm, maxTankCount, AwardFrom.GUARD_AIRSHIP)) {
            handler.sendErrorMsgToPlayer(GameError.TANK_COUNT);
            return;
        }

        if (hero != null) {
            playerDataManager.addHero(player, hero.getHeroId(), -1, AwardFrom.GUARD_AIRSHIP);
        }

        if (awakenHero != null) {
            awakenHero.setUsed(true);
            LogLordHelper.awakenHero(AwardFrom.GUARD_AIRSHIP, player.account, player.lord, awakenHero, 0);
        }

        //战术
        if( ! attackForm.getTactics().isEmpty()){
            tacticsService.useTactics(player, attackForm.getTactics());
        }


        int marchTime = AirshipConst.AIRSHIP_GUARD_MARCH_SECOND;
        int now = TimeHelper.getCurrentSecond();
        Army army = new Army(player.maxKey(), sap.getPos(), ArmyState.AIRSHIP_GUARD_MARCH, attackForm, marchTime, now + marchTime, playerDataManager.isRuins(player));
        player.armys.add(army);
        army.setFight(fight);
        army.player = player;
        army.setType(ArmyConst.AIRSHIP);
        GuardAirshipRs.Builder builder = GuardAirshipRs.newBuilder();
        builder.setArmy(PbHelper.createArmyPb(army));
        handler.sendMsgToPlayer(GuardAirshipRs.ext, builder.build());
    }

    /**
     * 查看驻防部队
     *
     * @param req
     * @param handler
     */
    public void getAirshipGuard(GetAirshipGuardRq req, ClientHandler handler) {
        if (!staticFunctionPlanDataMgr.isAirshipOpen()) return;

        int id = req.getId();
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        Member member = partyDataManager.getMemberById(player.roleId);
        PartyData partyData = member != null ? partyDataManager.getParty(member.getPartyId()) : null;
        if (partyData == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
            return;
        }

        //自己只能查看自己工会的飞艇驻防信息
        Airship airship = airshipDataManager.getAirshipMap().get(id);
        if (airship == null || airship.getPartyData() == null || airship.getPartyData() != partyData) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }

        GetAirshipGuardRs.Builder builder = GetAirshipGuardRs.newBuilder();
        for (Army teamArmy : airship.getGuardArmy()) {
            builder.addArmys(PbHelper.createAirshipTeamArmy(teamArmy, teamArmy.player));
        }

        handler.sendMsgToPlayer(GetAirshipGuardRs.ext, builder.build());
    }

    /**
     * 领取生产道具
     *
     * @param req
     * @param handler
     */
    public void recvAirshipProduceAward(RecvAirshipProduceAwardRq req, ClientHandler handler) {
        if (!staticFunctionPlanDataMgr.isAirshipOpen()) return;

        int airshipId = req.getId();//飞艇ID
        boolean useProp = req.getUseProp();
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        //必须是军团成员
        Member member = partyDataManager.getMemberById(player.roleId);
        if (member == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
            return;
        }
        PartyData partyData = partyDataManager.getParty(member.getPartyId());
        if (partyData == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
            return;
        }
        Map<Integer, Airship> airshipMap = airshipDataManager.getAirshipMap();

        Airship airship = airshipMap.get(airshipId);
        if (airship == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }

        if (airship.getPartyData() == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
            return;
        }

        if (airship.getPartyData().getPartyId() != partyData.getPartyId()) {
            handler.sendErrorMsgToPlayer(GameError.NOT_IN_PARTY);
            return;
        }

        int now = TimeHelper.getCurrentSecond();
        airshipDataManager.produceItem(airship, now);

        if (airship.getProduceNum() < 1) {
            handler.sendErrorMsgToPlayer(GameError.AIRSHIP_PRODUCE_ENOUGH);
            return;
        }

        StaticAirship sap = staticWorldDataMgr.getAirshipMap().get(airship.getId());
        List<Integer> award = sap != null ? ListHelper.getRandomAward(sap.getAward()) : null;
        if (award == null) {
            handler.sendErrorMsgToPlayer(GameError.STATIC_DATA_ERROR);
            return;
        }

        int mult = 1;
        int mplt = 0; //消耗军工
        //消耗物资征收令可以多倍获取奖励,并消耗多倍资源
        List<CommonPb.Atom2> atom2List = new ArrayList<>();
        if (useProp) {
            StaticProp staticProp = staticPropDataMgr.getStaticProp(PropId.AIRSHIP_PRODUCT_MULT_RESOUCE);
            List<List<Integer>> effectValue = staticProp != null ? staticProp.getEffectValue() : null;
            if (staticProp == null || effectValue == null || effectValue.isEmpty()) {
                handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
                return;
            }
            if (!playerDataManager.checkPropIsEnougth(player, AwardType.PROP, PropId.AIRSHIP_PRODUCT_MULT_RESOUCE, 1)) {
                handler.sendErrorMsgToPlayer(GameError.PROP_NOT_ENOUGH);
                return;
            }
            mult = staticProp.getEffectValue().get(0).get(0);
            //领取双倍奖励时,会扣除双倍资源(军功)
            for (List<Integer> list : sap.getCost()) {
                if (!playerDataManager.checkPropIsEnougth(player, list.get(0), list.get(1), list.get(2) * mult)) {
                    handler.sendErrorMsgToPlayer(GameError.RESOURCE_NOT_ENOUGH);
                    return;
                }
            }
            //扣除道具
            atom2List.add(playerDataManager.subProp(player, AwardType.PROP, PropId.AIRSHIP_PRODUCT_MULT_RESOUCE, 1, AwardFrom.AIRSHIP_GET_PRODUCT_RESOUCE));
        }

        //扣除资源
        for (List<Integer> list : sap.getCost()) {
            atom2List.add(playerDataManager.subProp(player, list.get(0), list.get(1), list.get(2) * mult, AwardFrom.AIRSHIP_GET_PRODUCT_RESOUCE));
            mplt += list.get(2) * mult;
        }

        //处理飞艇生产的资源次数
        int prevNum = airship.getProduceNum();
        airship.setProduceNum(airship.getProduceNum() - 1);
        if (prevNum >= sap.getCapacity() && airship.getProduceNum() < sap.getCapacity()) {
            airship.setProduceTime(now);//重新开始生产
        }

        //给予奖励
        int count = award.get(2) * mult;
        int keyId = playerDataManager.addAward(player, award.get(0), award.get(1), count, AwardFrom.RECV_AIRSHIP_PRODUCE_AWARD);
        CommonPb.Award pbAward = PbHelper.createAwardPb(award.get(0), award.get(1), count, keyId);

        //记录征收信息
        List<RecvAirshipProduceAwardRecord> recvRecordList = airship.getRecvRecordList();
        RecvAirshipProduceAwardRecord record = new RecvAirshipProduceAwardRecord();
        record.setTimeSec(now);
        record.setLordId(player.roleId);
        record.setType(award.get(0));
        record.setAwardId(award.get(1));
        record.setCount(count);
        record.setMplt(mplt);
		recvRecordList.add(record);
		//最多50条记录
		if(recvRecordList.size() > 50) {
			recvRecordList.remove(0);
		}
        
        //response
        RecvAirshipProduceAwardRs.Builder builder = RecvAirshipProduceAwardRs.newBuilder();
        builder.setProduceTime(airship.getProduceTime());
        builder.setProduceNum(airship.getProduceNum());
        builder.addAward(pbAward);
        builder.addAllAtom2(atom2List);
        handler.sendMsgToPlayer(RecvAirshipProduceAwardRs.ext, builder.build());
    }

    /**
     * 撤销部队
     * 世界地图中撤销飞艇相关的部队
     *
     * @param army
     * @param handler
     * @return
     */
    public boolean retreatArishipTeamArmy(Army army, ClientHandler handler, GamePb2.RetreatRs.Builder builder) {
        Airship airship = worldDataManager.getAirshipMap().get(army.getTarget());
        if (airship == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return false;
        }
        int now = TimeHelper.getCurrentSecond();
        boolean isTeamArmy = true;
        int state = army.getState();
        switch (state) {
            case ArmyState.AIRSHIP_BEGAIN://撤销组队状态中的部队
                airshipDataManager.retreatTeamBegainArmy(army, now);
                break;
            case ArmyState.AIRSHIP_MARCH://撤销行军中的部队
                //消耗一个紧急撤销道具
                if (!playerDataManager.checkPropIsEnougth(army.player, AwardType.PROP, PropId.AIRSHIP_MARCH_RETREA, 1)) {
                    handler.sendErrorMsgToPlayer(GameError.PROP_NOT_ENOUGH);
                    return false;
                }
                playerDataManager.subProp(army.player, AwardType.PROP, PropId.AIRSHIP_MARCH_RETREA, 1, AwardFrom.AIRSHIP_MARCH_RETREA);
                airshipDataManager.retreatTeamMarchArmy(army, now);
                Prop prop = army.player.props.get(PropId.AIRSHIP_MARCH_RETREA);
                builder.addAtom2(PbHelper.createAtom2Pb(AwardType.PROP, PropId.AIRSHIP_MARCH_RETREA, prop != null ? prop.getCount() : 0));
                break;
            case ArmyState.AIRSHIP_GUARD_MARCH:
            case ArmyState.AIRSHIP_GUARD:
                airshipDataManager.retreatGuardArmy(army, now, airship);
                isTeamArmy = false;
                break;
            default:
                break;
        }

        if (isTeamArmy) {
            PartyData partyData = partyDataManager.getPartyByLordId(army.player.lord.getLordId());
            airshipDataManager.afterRetreatTeamArmy(army, airship, partyData, state, now);
        }
        return true;
    }

    public void timerLogic() {
        if (!staticFunctionPlanDataMgr.isAirshipOpen()) return;

        int nowSec = TimeHelper.getCurrentSecond();
        for (Map.Entry<Integer, Airship> entry : airshipDataManager.getAirshipMap().entrySet()) {
            Airship airship = entry.getValue();
            StaticAirship stp = staticWorldDataMgr.getAirshipMap().get(entry.getKey());
            //检测飞艇,如果条件满足则回收飞艇
            airshipDataManager.checkAndRecoveryAirship(stp, airship, nowSec);

            //处理飞艇进攻队伍信息
            dealAirshipTeam(airship, nowSec);
        }
    }

    /**
     * 处理飞艇进攻序列(队伍)信息
     *
     * @param airship
     * @param nowSec
     */
    private void dealAirshipTeam(Airship airship, int nowSec) {
        Iterator<AirshipTeam> iter = airship.getTeamArmy().iterator();
        while (iter.hasNext()) {
            AirshipTeam team = iter.next();
            if (nowSec >= team.getEndTime()) {//部队行军到达
                try {
                    if (team.getState() == ArmyState.AIRSHIP_MARCH) {
                        //开始攻打飞艇
                        dealAirshipTeamMarch(airship, nowSec, team);
                        iter.remove();//移除飞艇中战斗行军队伍
                    } else if (team.getState() == ArmyState.AIRSHIP_BEGAIN) {
                        //组队中
                        if (!dealAirshipTeamBegain(airship, nowSec, team)) {
                            iter.remove();
                        }
                    }
                } catch (Exception e) {
                    LogUtil.error("飞艇行军异常", e);
                }
            }
        }
    }

    /**
     * 攻打飞艇部队行军结束---开始战斗
     *
     * @param airship
     * @param nowSec
     * @param team
     */
    private void dealAirshipTeamMarch(Airship airship, int nowSec, AirshipTeam team) {
        //攻击
        StaticAirship sap = staticWorldDataMgr.getAirshipMap().get(team.getId());
        Player teamPlayer = playerDataManager.getPlayer(team.getLordId());
        PartyData partyData = partyDataManager.getPartyByLordId(team.getLordId());
        try {
            //已经被占领
            if (airship.getSafeEndTime() < 0 || airship.getSafeEndTime() > nowSec) {
                partyDataManager.addPartyTrend(partyData.getPartyId(), PartyTrendConst.ATTACK_AIRSHIP_RETREAT, teamPlayer.lord.getNick(), String.valueOf(airship.getId()));
                chatService.sendPartyChat(chatService.createSysChat(SysChatId.AIRSHIP_ATTACK_LATE, String.valueOf(airship.getId())), partyData.getPartyId());
                return;
            }

            //计算战斗逻辑
            boolean isFightWin = airshipFightService.fightAirship(partyData, team, airship, sap, nowSec, teamPlayer);
            if (isFightWin) {
                //进攻胜利后任命飞艇指挥官
                Member airshipCommander = airshipDataManager.autoAppointCommander(airship, partyData, teamPlayer);
                //清除之前军团数据
                PartyData oldPartyData = airship.getPartyData();
                long oldAirshipCommanderId = 0;
                if (oldPartyData != null) {
                    oldAirshipCommanderId = oldPartyData.getAirshipLeaderMap().remove(airship.getId());
                }
                if (airshipCommander == null) {
                    //攻打胜利但是没有指挥官，则变为中立状态
                    partyDataManager.addPartyTrend(partyData.getPartyId(), PartyTrendConst.ATTACK_AIRSHIP_LOSE_BY_LEADER, String.valueOf(airship.getId()));
                    //我军成功占领了[["",0]],由于没有足够的指挥官管理飞艇,飞艇已经被放弃.
                    chatService.sendPartyChat(chatService.createSysChat(SysChatId.AIRSHIP_NOT_ENOUGH_COMMANDER, String.valueOf(airship.getId())), partyData.getPartyId());
                    //飞艇重新归于中立状态
                    airshipDataManager.clearAirshipData2Npc(sap, airship);
                } else {
                    //设置飞艇占领信息
                    airshipDataManager.clearAirshipData2Party(sap, airship, partyData, nowSec);
                    //给新上任的飞艇指挥官一封任命邮件
                    Player commanderPlayer = playerDataManager.getPlayer(airshipCommander.getLordId());
                    playerDataManager.sendNormalMail(commanderPlayer, MailType.MOLD_AIRSHIP_AUTO_APPOINT_COMMANDER, nowSec, String.valueOf(airship.getId()));
                    
                    //更新兄弟同心活动-占领飞艇任务
                   	actionCenterService.updActBrotherTask(team.getArmys(), 2);
                }

                //开放新的飞艇
                airshipDataManager.checkAndOpenAirship(airship);
                //全服广播飞艇信息变化
                StcHelper.syncAirshipChange2World(airship.getId());
            }
            
            //更新兄弟同心活动-攻打飞艇任务
            actionCenterService.updActBrotherTask(team.getArmys(), 1);
        } catch (Exception e) {
            LogUtil.error("", e);
        } finally {
            //队伍撤退
            airshipDataManager.teamCancel(airship, team, partyData, nowSec, AirshipConst.AIRSHIP_ATTACK_FAIL_RETREAT_SECOND, true);
        }
    }

    /**
     * 队伍准备时间结束，开始行军.<br>
     * 行军时间 = 基础时间 + (竞争队伍数量 * 增量)
     *
     * @param airship
     * @param now
     * @param team
     * @return
     */
    public boolean dealAirshipTeamBegain(Airship airship, int now, AirshipTeam team) {
        PartyData attckPartyData = null;
        try {
            attckPartyData = partyDataManager.getPartyByLordId(team.getLordId());
            if (team.getArmys().size() == 0) {
                airshipDataManager.teamCancel(airship, team, attckPartyData, now, AirshipConst.AIRSHIP_ATTACK_RETREAT_SECOND, false);
                return false;
            }
            //与自己目标相同的行军队伍数量
            int curMarchCount = airshipDataManager.getMarchTeamCount(team.getId());
            //指定时间，开始行军
            int period = AirshipConst.AIRSHIP_ATTACK_MARCH_SECOND + curMarchCount * AirshipConst.AIRSHIP_ATTACK_MARCH_ADD_SECOND;
            team.setEndTime(now + period);
            team.setState(ArmyState.AIRSHIP_MARCH);

            //更新队伍状态，并通知队伍中玩家的部队状态
            airshipDataManager.teamStateChange(team, period);

            Player teamPlayer = playerDataManager.getPlayer(team.getLordId());

            PartyData defencePartyData = airship.getPartyData();
            if (defencePartyData != null) {
                //向飞艇防御军团频道发送被攻击广播
                chatService.sendPartyChat(chatService.createSysChat(SysChatId.AIRSHIP_DEFENCE,
                        String.valueOf(airship.getId()), attckPartyData.getPartyName(),
                        teamPlayer.lord.getNick()), defencePartyData.getPartyId());
                //向飞艇防御军团发送军情
                partyDataManager.addPartyTrend(defencePartyData.getPartyId(), PartyTrendConst.CREATE_DEFENCE_AIRSHIP, String.valueOf(airship.getId()), attckPartyData.getPartyName(), teamPlayer.lord.getNick());
            }
            //通知军团玩家队伍变化
            StcHelper.syncAirshipTeamChange2Party(attckPartyData.getPartyId(), airship.getId(), AirshipConst.TEAM_STATUS_UPDATE);
            //通知全服玩家飞艇(被攻击)变化
            StcHelper.syncAirshipChange2World(airship.getId());
            return true;
        } catch (Exception e) {
            airshipDataManager.teamCancel(airship, team, attckPartyData, now, AirshipConst.AIRSHIP_ATTACK_RETREAT_SECOND, false);
            LogUtil.error("", e);
        }
        return false;
    }

    /**
     * 处理驻防部队行军结束(到达)
     *
     * @param army
     * @param now
     */
    public void dealGuardArmyMarch(Army army, int now) {
        int airshipId = worldDataManager.getAirshipMap().get(army.getTarget()).getId();

        //飞艇已经归于中立状态
        Airship airship = airshipDataManager.getAirshipMap().get(airshipId);
        if (airship == null || airship.getPartyData() == null) {
            airshipDataManager.retreatGuardArmy(army, now, airship);
            return;
        }

        //飞艇已经不是自己军团的飞艇
        PartyData partyData = partyDataManager.getPartyByLordId(army.player.roleId);
        if (partyData == null || airship.getPartyData().getPartyId() != partyData.getPartyId()) {
            airshipDataManager.retreatGuardArmy(army, now, airship);
            return;
        }

        army.setState(ArmyState.AIRSHIP_GUARD);
        airshipDataManager.putGuardArmy(airshipId, army);

        Map<Integer, AirshipGuard> guardMap = partyData.getAirshipGuardMap();
        AirshipGuard guard = guardMap.get(airshipId);
        if (guard == null) guardMap.put(airshipId, guard = new AirshipGuard(airshipId));
        guard.getArmys().add(army);
        StcHelper.syncAirshipTeamArmy2Player(army.player, AirshipConst.TEAM_STATE_ARMY_CHANGE);
    }

    /**
     * 1.飞艇指挥官<br>
     * 2.飞艇集结队长<br>
     * 3.有针对飞艇的行军部队,注意是行军部队不是准备部队<br>
     * 以上3种情况都不允许退出与被踢出军团<br>
     * 离开军团时,集结准备中的队伍将被立即返回,驻防中的队伍将被撤回
     *
     * @param player
     * @param partyData
     * @return
     */
    public GameError quitPartyAirshipCheck(Player player, PartyData partyData) {
        //飞艇指挥官
        for (Map.Entry<Integer, Long> entry : partyData.getAirshipLeaderMap().entrySet()) {
            if (entry.getValue() == player.roleId.longValue()) {
                return GameError.QUIT_PARTY_AIRSHIP_COMMANDER_ERR;
            }
        }

        //飞艇集结队长
        for (Map.Entry<Integer, AirshipTeam> entry : partyData.getAirshipTeamMap().entrySet()) {
            if (entry.getValue().getLordId() == player.roleId) {
                return GameError.QUIT_PARTY_AIRSHIP_TEAM_LEADER_ERR;
            }
        }

        //有部队在进攻飞艇(行军中)
        for (Army army : player.armys) {
            int state = army.getState();
            if (state == ArmyState.AIRSHIP_MARCH) {
                return GameError.QUIT_PARTY_AIRSHIP_ARMY_MARCH;
            }
        }
        return null;
    }

    /**
     * 玩家退出军团飞艇处理
     *
     * @param player
     * @param partyData
     */
    public void afterQuitParty(Player player, PartyData partyData) {
        airshipDataManager.afterQuitParty(player, partyData);
    }

	/**
	 * 获取征收记录
	 * @param airshipId
	 * @param handler
	 */
	public void getRecvAirshipProduceAwardRecord(int airshipId, ClientHandler handler) {
		if (!staticFunctionPlanDataMgr.isAirshipOpen()) return;
		Player player = playerDataManager.getPlayer(handler.getRoleId());
        //必须是军团成员
        Member member = partyDataManager.getMemberById(player.roleId);
        if (member == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
            return;
        }
        PartyData partyData = partyDataManager.getParty(member.getPartyId());
        if (partyData == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
            return;
        }
        Map<Integer, Airship> airshipMap = airshipDataManager.getAirshipMap();

        Airship airship = airshipMap.get(airshipId);
        if (airship == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }

        if (airship.getPartyData() == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
            return;
        }

        if (airship.getPartyData().getPartyId() != partyData.getPartyId()) {
            handler.sendErrorMsgToPlayer(GameError.NOT_IN_PARTY);
            return;
        }
		
        //取征收记录
		List<RecvAirshipProduceAwardRecord> recvRecordList = airship.getRecvRecordList();
		
		GetRecvAirshipProduceAwardRecordRs.Builder builder = GetRecvAirshipProduceAwardRecordRs.newBuilder();
		for(RecvAirshipProduceAwardRecord record : recvRecordList) {
			CommonPb.RecvAirshipProduceAwardRecord.Builder recordBuilder = CommonPb.RecvAirshipProduceAwardRecord.newBuilder();
            long lordId = dataRepairDM.getNewLordId(record.getLordId());
            Player recvPlayer = playerDataManager.getPlayer(lordId);
			recordBuilder.setNick(recvPlayer.lord.getNick());
			recordBuilder.setRecvTime(record.getTimeSec());
			recordBuilder.setType(record.getType());
			recordBuilder.setAwardId(record.getAwardId());
			recordBuilder.setCount(record.getCount());
			recordBuilder.setMplt(record.getMplt());
			
			builder.addRecords(recordBuilder.build());
		}
		
		handler.sendMsgToPlayer(GetRecvAirshipProduceAwardRecordRs.ext, builder.build());
	}
}
