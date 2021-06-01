package com.game.service.airship;

import com.game.constant.*;
import com.game.dataMgr.StaticFunctionPlanDataMgr;
import com.game.dataMgr.StaticHeroDataMgr;
import com.game.dataMgr.StaticVipDataMgr;
import com.game.dataMgr.StaticWorldDataMgr;
import com.game.domain.Member;
import com.game.domain.PartyData;
import com.game.domain.Player;
import com.game.domain.l.PartyJobFree;
import com.game.domain.p.*;
import com.game.domain.p.airship.Airship;
import com.game.domain.p.airship.AirshipGuard;
import com.game.domain.p.airship.AirshipTeam;
import com.game.domain.p.airship.PlayerAirship;
import com.game.domain.s.StaticAirship;
import com.game.domain.s.StaticHero;
import com.game.manager.AirshipDataManager;
import com.game.manager.ArenaDataManager;
import com.game.manager.PartyDataManager;
import com.game.manager.PlayerDataManager;
import com.game.message.handler.ClientHandler;
import com.game.pb.CommonPb;
import com.game.pb.GamePb5;
import com.game.service.*;
import com.game.util.LogLordHelper;
import com.game.util.PbHelper;
import com.game.util.StcHelper;
import com.game.util.TimeHelper;
import org.apache.commons.lang3.RandomUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.*;

/**
 * @author zhangdh
 * @ClassName: AirshipTeamService
 * @Description:飞艇部队服务
 * @date 2017-06-22 6:52
 */
@Service
public class AirshipTeamService {


    @Autowired
    private StaticFunctionPlanDataMgr staticFunctionPlanDataMgr;

    @Autowired
    private StaticHeroDataMgr staticHeroDataMgr;

    @Autowired
    private StaticWorldDataMgr staticWorldDataMgr;

    @Autowired
    private StaticVipDataMgr staticVipDataMgr;

    //********************************************
    @Autowired
    private AirshipDataManager airshipDataManager;

    @Autowired
    private PlayerDataManager playerDataManager;

    @Autowired
    private PartyDataManager partyDataManager;
    @Autowired
    private TacticsService tacticsService;
    @Autowired
    private ArenaDataManager arenaDataManager;

    //********************************************
    @Autowired
    private ChatService chatService;

    @Autowired
    private FightService fightService;

    @Autowired
    private AirshipService airshipService;

    @Autowired
    private WorldService worldService;

    @Autowired
    private GmService gmService;

    /**
     * 获取军团战事集结列表
     *
     * @param handler
     */
    public void getAirshipTeamList(GamePb5.GetAirshipTeamListRq req, ClientHandler handler) {
        if (!staticFunctionPlanDataMgr.isAirshipOpen()) return;

        Player player = playerDataManager.getPlayer(handler.getRoleId());
        Member member = partyDataManager.getMemberById(player.roleId);
        PartyData partyData = member != null ? partyDataManager.getParty(member.getPartyId()) : null;
        //必须是军团成员
        if (partyData == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
            return;
        }
        boolean isSelf = req.getSelf();
        GamePb5.GetAirshipTeamListRs.Builder builder = GamePb5.GetAirshipTeamListRs.newBuilder();
        for (AirshipTeam team : partyData.getAirshipTeamMap().values()) {
            if (team.getLordId() != player.roleId) {
                if (!isSelf) {//获取工会其他成员战事信息
                    builder.addTeams(PbHelper.createAirshipTeam(team, playerDataManager.getPlayer(team.getLordId())));
                }
            } else {
                if (isSelf) {//获取自己的战事信息
                    builder.addTeams(PbHelper.createAirshipTeam(team, player));
                }
            }
        }
        handler.sendMsgToPlayer(GamePb5.GetAirshipTeamListRs.ext, builder.build());
    }

    /**
     * 获取队伍详情
     *
     * @param id
     * @param handler
     */
    public void getAirshipTeamDetail(GamePb5.GetAirshipTeamDetailRq req, ClientHandler handler) {
        if (!staticFunctionPlanDataMgr.isAirshipOpen()) return;

        if (!airshipDataManager.getAirshipMap().containsKey(req.getAirshipId())) {
            handler.sendErrorMsgToPlayer(GameError.AIRSHIP_NOT_FOUND_ERR);
            return;
        }
        //必须是军团成员
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        Member member = partyDataManager.getMemberById(player.roleId);
        PartyData partyData = member != null ? partyDataManager.getParty(member.getPartyId()) : null;
        if (partyData == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
            return;
        }

        AirshipTeam airshipTeam = partyData.getAirshipTeamMap().get(req.getAirshipId());
        GamePb5.GetAirshipTeamDetailRs.Builder builder = GamePb5.GetAirshipTeamDetailRs.newBuilder();
        if (airshipTeam != null) {
            for (Army teamArmy : airshipTeam.getArmys()) {
                builder.addArmys(PbHelper.createAirshipTeamArmy(teamArmy, teamArmy.player));
            }
        }
        handler.sendMsgToPlayer(GamePb5.GetAirshipTeamDetailRs.ext, builder.build());
    }

    /**
     * 创建队伍
     *
     * @param req
     * @param handler
     */
    public void createAirshipTeam(GamePb5.CreateAirshipTeamRq req, ClientHandler handler) {
        if (!staticFunctionPlanDataMgr.isAirshipOpen()) return;

        int id = req.getId(); //飞艇ID
        StaticAirship sap = staticWorldDataMgr.getAirshipMap().get(id);
        if (sap == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }

        //飞艇不存在
        Airship airship = airshipDataManager.getAirshipMap().get(id);
        if (airship == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }

        //飞艇保护期
        int safeEndTime = airship.getSafeEndTime();
        if (safeEndTime < 0 || TimeHelper.getCurrentSecond() <= safeEndTime) {
            handler.sendErrorMsgToPlayer(GameError.AIRSHIP_AT_SAFE_TIME);
            return;
        }

        //必须是军团成员
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        Member member = partyDataManager.getMemberById(player.roleId);
        PartyData partyData = member != null ? partyDataManager.getParty(member.getPartyId()) : null;
        if (partyData == null || partyData.getPartyLv() < sap.getPartyLevel()) {
            handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
            return;
        }

        //飞艇已经属于玩家工会
        if (airship.getPartyData() != null && airship.getPartyData() == partyData) {
            handler.sendErrorMsgToPlayer(GameError.AIRSHIP_HAVED);
            return;
        }

        //一个飞艇一个军团只能发起一个集结
        AirshipTeam team = partyData.getAirshipTeamMap().get(id);
        if (team != null) {
            handler.sendErrorMsgToPlayer(GameError.TEAM_CREATED);
            return;
        }

        //已经发起了一个队伍集结(玩家同一时间只能发起一个进攻集结(队伍))
        team = airshipDataManager.getMyTeam(player.roleId, partyData);
        if (team != null) {
            handler.sendErrorMsgToPlayer(GameError.TEAM_CREATED);
            return;
        }

        //判断是否可以免费创建
        int nowDay = TimeHelper.getCurrentDay();
        //消耗道具创建集结队伍
        int job = member.getJob();
        CommonPb.Atom2 atom2 = null;
        int freeCnt = airshipDataManager.getPlayerFreeCrtTeamCnt(airship, player, partyData, job, nowDay);
        Map<Long, PlayerAirship> playerAirshipMap = airshipDataManager.getPlayerAirshipMap();
        PlayerAirship playerAirship = playerAirshipMap.get(player.lord.getLordId());
        if (freeCnt > 0) {//更新玩家免费创建集结队伍次数
            //本次使用的是免费次数
            if (playerAirship == null) {
                playerAirshipMap.put(player.lord.getLordId(), playerAirship = new PlayerAirship());
            }
            boolean isToday = playerAirship.getFreeCrtDay() == nowDay;
            playerAirship.setFreeCrtCount((isToday ? playerAirship.getFreeCrtCount() : 0) + 1);
            playerAirship.setFreeCrtDay(nowDay);
            PartyJobFree jobFree = partyData.getFreeMap().get(job);
            if (jobFree == null) partyData.getFreeMap().put(job, jobFree = new PartyJobFree());
            jobFree.setFree(1 + (jobFree.getFreeDay() == nowDay ? jobFree.getFree() : 0));
            jobFree.setFreeDay(nowDay);
        } else {
            //扣除道具
            if (!playerDataManager.checkPropIsEnougth(player, AwardType.PROP, PropId.AIRSHIP_CREATE_TEAM_PROP, 1)) {
                handler.sendErrorMsgToPlayer(GameError.PROP_NOT_ENOUGH);
                return;
            }
            atom2 = playerDataManager.subProp(player, AwardType.PROP, PropId.AIRSHIP_CREATE_TEAM_PROP, 1, AwardFrom.AIRSHIP_CREATE_TEAM);
        }

        //partyData 增加队伍信息 军团广播
        PartyData defencePartyData = partyDataManager.getParty(airship.getPartyId());
        String defencePartyName = "";
        if (defencePartyData != null) {
            defencePartyName = defencePartyData.getPartyName();
        }

        //世界频道广播发起战事
        chatService.sendPartyChat(chatService.createSysChat(SysChatId.AIRSHIP_ATTACK, player.lord.getNick(),
                defencePartyName, String.valueOf(id)), partyData.getPartyId());

        //创建队伍
        team = new AirshipTeam();
        team.setId(id);
        team.setEndTime(TimeHelper.getCurrentSecond() + AirshipConst.AIRSHIP_BEGAIN_SECOND);
        team.setLordId(player.roleId);
        team.setState(ArmyState.AIRSHIP_BEGAIN);

        airship.getTeamArmy().add(team);
        partyData.getAirshipTeamMap().put(id, team);

        //军团军情
        partyDataManager.addPartyTrend(partyData.getPartyId(), PartyTrendConst.CREATE_ATTACK_AIRSHIP,
                player.lord.getNick(), defencePartyName, String.valueOf(id));

        //通知军团玩家队伍信息发生变化
        StcHelper.syncAirshipTeamChange2Party(partyData.getPartyId(), team.getId(), AirshipConst.TEAM_STATUS_CREATE);

        GamePb5.CreateAirshipTeamRs.Builder builder = GamePb5.CreateAirshipTeamRs.newBuilder();
        builder.setAirshipTeam(PbHelper.createAirshipTeam(team, player));
        if (atom2 != null) builder.addAtom2(atom2);
        handler.sendMsgToPlayer(GamePb5.CreateAirshipTeamRs.ext, builder.build());
    }

    /**
     * 撤销队伍(战事)，行军中的队伍不能被玩家取消，队伍中的所有部队都被玩家撤回后，自动取消
     *
     * @param handler
     */
    public void cancelTeam(ClientHandler handler) {
        if (!staticFunctionPlanDataMgr.isAirshipOpen()) return;

        Player player = playerDataManager.getPlayer(handler.getRoleId());
        //必须是军团成员
        Member member = partyDataManager.getMemberById(player.roleId);
        PartyData partyData = member != null ? partyDataManager.getParty(member.getPartyId()) : null;
        if (partyData == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
            return;
        }
        //一个飞艇一个军团只能发起一个集结
        AirshipTeam team = airshipDataManager.getMyTeam(player.roleId, partyData);
        if (team == null) {
            handler.sendErrorMsgToPlayer(GameError.TEAM_CANCELD);
            return;
        }

        //只有准备状态的队伍才能被玩家取消
        if (team.getState() != ArmyState.AIRSHIP_BEGAIN) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }

        Airship airship = airshipDataManager.getAirshipMap().get(team.getId());
        if (airship == null) {
            handler.sendErrorMsgToPlayer(GameError.AIRSHIP_NOT_FOUND_ERR);
            return;
        }

        //准备中的队伍被取消时,所有部队都将被瞬间撤回
        airshipDataManager.teamCancel(airship, team, partyData, TimeHelper.getCurrentSecond(), 0, false);
        airship.getTeamArmy().remove(team);

        //发送撤销邮件通知玩家
        int nowSec = TimeHelper.getCurrentSecond();
        Set<Player> playerSet = new HashSet<>();
        for (Army army : team.getArmys()) {
            playerSet.add(army.player);
        }
        for (Player armyPlayer : playerSet) {
            playerDataManager.sendNormalMail(armyPlayer, MailType.MOLD_CANCEL_AIRSHIP_TEAM, nowSec, String.valueOf(team.getId()));
        }

        GamePb5.CancelTeamRs.Builder builder = GamePb5.CancelTeamRs.newBuilder();
        handler.sendMsgToPlayer(GamePb5.CancelTeamRs.ext, builder.build());
    }

    /**
     * 加入队伍
     *
     * @param req
     * @param handler
     */
    public void joinAirshipTeam(GamePb5.JoinAirshipTeamRq req, ClientHandler handler) {
        if (!staticFunctionPlanDataMgr.isAirshipOpen()) return;

        int airshipId = req.getAirshipId();
        long teamLeader = req.getTeamLeader();
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        //必须是军团成员
        Member member = partyDataManager.getMemberById(player.roleId);
        PartyData partyData = member != null ? partyDataManager.getParty(member.getPartyId()) : null;
        if (partyData == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
            return;
        }

        //队伍已变更
        AirshipTeam airshipTeam = airshipDataManager.getMyTeam(teamLeader, partyData);
        if (airshipTeam == null || airshipTeam.getLordId() != teamLeader) {
            handler.sendErrorMsgToPlayer(GameError.AIRSHIP_TEAM_CHANGE_ERR);
            return;
        }

        if (airshipTeam.getState() != ArmyState.AIRSHIP_BEGAIN) {
            handler.sendErrorMsgToPlayer(GameError.AIRSHIP_TEAM_CHANGE_ERR);
            return;
        }

        //飞艇不存在
        Map<Integer, Airship> airshipMap = airshipDataManager.getAirshipMap();
        Airship airship = airshipMap.get(airshipTeam.getId());
        if (airship == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }

        StaticAirship staticAirship = staticWorldDataMgr.getAirshipMap().get(airshipId);
        if (staticAirship == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }

        //可设置的部队列表已满
//        int armyCount = player.armys.size();
//        for (Army army : player.armys) {
//            if (army.getState() == ArmyState.WAR) {
//                armyCount -= 1;
//                break;
//            }
//        }

        int maxCount = playerDataManager.armyCount(player);
        if (playerDataManager.getPlayArmyCount(player, maxCount) >= maxCount) {
            handler.sendErrorMsgToPlayer(GameError.MAX_ARMY_COUNT);
            return;
        }

        //一个人一个飞艇只能派出一个战斗部队
        for (Army army : airshipTeam.getArmys()) {
            if (army.player.lord.getLordId() == player.lord.getLordId()) {
                handler.sendErrorMsgToPlayer(GameError.MAX_ARMY_COUNT);
                return;
            }
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
        if (!playerDataManager.checkAndSubTank(player, attackForm, maxTankCount, AwardFrom.AIRSHIP_SET_FORM)) {
            handler.sendErrorMsgToPlayer(GameError.TANK_COUNT);
            return;
        }

        if (hero != null) {
            playerDataManager.addHero(player, hero.getHeroId(), -1, AwardFrom.AIRSHIP_SET_FORM);
        }

        if (awakenHero != null) {
            awakenHero.setUsed(true);
            LogLordHelper.awakenHero(AwardFrom.AIRSHIP_SET_FORM, player.account, player.lord, awakenHero, 0);
        }
        //战术
        if (!attackForm.getTactics().isEmpty()) {
            tacticsService.useTactics(player, attackForm.getTactics());
        }

        int marchTime = AirshipConst.AIRSHIP_BEGAIN_SECOND;
        Army army = new Army(player.maxKey(), staticAirship.getPos(), ArmyState.AIRSHIP_BEGAIN, attackForm, marchTime, airshipTeam.getEndTime(), playerDataManager.isRuins(player));
        player.armys.add(army);
        army.setFight(fightService.calcFormFight(player, attackForm));
        army.player = player;
        army.setType(ArmyConst.AIRSHIP);
        airshipTeam.getArmys().add(army);

        //通知军团玩家队伍发生变化
        StcHelper.syncAirshipTeamChange2Party(partyData.getPartyId(), airshipId, AirshipConst.TEAM_STATUS_UPDATE);

        GamePb5.JoinAirshipTeamRs.Builder builder = GamePb5.JoinAirshipTeamRs.newBuilder();
        builder.setArmy(PbHelper.createArmyPb(army));
        handler.sendMsgToPlayer(GamePb5.JoinAirshipTeamRs.ext, builder.build());
    }

    /**
     * 设置队伍战斗顺序，飞艇驻军战斗顺序
     *
     * @param req
     * @param handler
     */
    public void setPlayerAttackSeq(GamePb5.SetPlayerAttackSeqRq req, ClientHandler handler) {
        if (!staticFunctionPlanDataMgr.isAirshipOpen()) return;

        long lordId = req.getLordId();
        int armyKeyId = req.getArmyKeyId();
        int step = req.getStep();

        Player player = playerDataManager.getPlayer(handler.getRoleId());
        //必须是军团成员
        Member member = partyDataManager.getMemberById(player.roleId);
        PartyData partyData = member != null ? partyDataManager.getParty(member.getPartyId()) : null;
        if (partyData == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
            return;
        }
        //一个飞艇一个军团只能发起一个集结
        AirshipTeam airshipTeam = airshipDataManager.getMyTeam(player.roleId, partyData);
        if (airshipTeam == null) {
            handler.sendErrorMsgToPlayer(GameError.TEAM_NO_CREATE);
            return;
        }

        if (airshipTeam.getState() != ArmyState.AIRSHIP_BEGAIN && airshipTeam.getState() != ArmyState.AIRSHIP_MARCH) {
            handler.sendErrorMsgToPlayer(GameError.ARMY_RETREAT);
            return;
        }

        //飞艇配置不存在
        StaticAirship sap = staticWorldDataMgr.getAirshipMap().get(airshipTeam.getId());
        if (sap == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }
        Airship airship = airshipDataManager.getAirshipMap().get(airshipTeam.getId());
        if (airship == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }


        Army teamArmy = airshipDataManager.getMyArmy(lordId, armyKeyId, airshipTeam);
        if (teamArmy == null) {
            handler.sendErrorMsgToPlayer(GameError.ARMY_RETREAT);
            return;
        }

        int curPos = airshipTeam.getArmys().indexOf(teamArmy);
        if (curPos == -1) {
            handler.sendErrorMsgToPlayer(GameError.ARMY_RETREAT);
            return;
        }

        int newPos = curPos + step;
        if (newPos >= airshipTeam.getArmys().size() || newPos < 0) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }

        airshipTeam.getArmys().remove(teamArmy);
        airshipTeam.getArmys().add(newPos, teamArmy);

        GamePb5.SetPlayerAttackSeqRs.Builder builder = GamePb5.SetPlayerAttackSeqRs.newBuilder();
        handler.sendMsgToPlayer(GamePb5.SetPlayerAttackSeqRs.ext, builder.build());
    }

    /**
     * 设置驻防顺序
     */
    public void setPlayerGuardSeq(GamePb5.SetPlayerAttackSeqRq req, ClientHandler handler) {
        if (!staticFunctionPlanDataMgr.isAirshipOpen()) return;

        long lordId = req.getLordId();
        int armyKeyId = req.getArmyKeyId();
        int step = req.getStep();
        int airshipId = req.getGuardAishipId();

        Player player = playerDataManager.getPlayer(handler.getRoleId());
        //必须是军团成员
        Member member = partyDataManager.getMemberById(player.roleId);
        PartyData partyData = member != null ? partyDataManager.getParty(member.getPartyId()) : null;
        if (partyData == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
            return;
        }

        Airship airship = airshipDataManager.getAirshipMap().get(airshipId);
        if (airship == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }

        //飞艇指挥官才能调整部队顺序
        Long leaderId = partyData.getAirshipLeaderMap().get(airshipId);
        Player leaderPlayer = leaderId != null ? playerDataManager.getPlayer(leaderId) : null;
        if (leaderPlayer == null || leaderPlayer.lord.getLordId() != player.lord.getLordId()) {
            handler.sendErrorMsgToPlayer(GameError.NOT_AIRSHIP_LEADER);
            return;
        }


        //被调整的部队
        Army curArmy = null;
        for (Army army : airship.getGuardArmy()) {
            if (army.player.roleId == lordId && army.getKeyId() == armyKeyId) {
                curArmy = army;
                break;
            }
        }

        int curPos = airship.getGuardArmy().indexOf(curArmy);
        if (curPos == -1) {
            handler.sendErrorMsgToPlayer(GameError.NO_ARMY);
            return;
        }

        int newPos = curPos + step;

        if (newPos >= airship.getGuardArmy().size() || newPos < 0) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }

        airship.getGuardArmy().remove(curArmy);
        airship.getGuardArmy().add(newPos, curArmy);

        GamePb5.SetPlayerAttackSeqRs.Builder builder = GamePb5.SetPlayerAttackSeqRs.newBuilder();
        handler.sendMsgToPlayer(GamePb5.SetPlayerAttackSeqRs.ext, builder.build());
    }

    /**
     * 立即出发
     *
     * @param handler
     */
    public void startAirshipTeamMarch(ClientHandler handler) {
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

        //只有队长才能立即出发
        AirshipTeam team = airshipDataManager.getMyTeam(player.roleId, partyData);
        if (team == null) {
            handler.sendErrorMsgToPlayer(GameError.TEAM_CANCELD);
            return;
        }

        if (team.getState() != ArmyState.AIRSHIP_BEGAIN) {
            handler.sendErrorMsgToPlayer(GameError.TEAM_MARCH);
            return;
        }

        Map<Integer, Airship> airshipMap = airshipDataManager.getAirshipMap();

        Airship airship = airshipMap.get(team.getId());
        if (airship == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }

        int now = TimeHelper.getCurrentSecond();
        team.setEndTime(now);
        if (!airshipService.dealAirshipTeamBegain(airship, now, team)) {
            airship.getTeamArmy().remove(team);
        }

        GamePb5.StartAirshipTeamMarchRs.Builder builder = GamePb5.StartAirshipTeamMarchRs.newBuilder();
        handler.sendMsgToPlayer(GamePb5.StartAirshipTeamMarchRs.ext, builder.build());
    }

    /**
     * 查看部队信息
     *
     * @param req
     * @param handler
     */
    public void getAirshpTeamArmy(GamePb5.GetAirshpTeamArmyRq req, ClientHandler handler) {
        if (!staticFunctionPlanDataMgr.isAirshipOpen()) return;

        int airshipId = req.getAirshipId();
        long lordId = req.getLordId();
        int armyKeyId = req.getArmyKeyId();
        if (airshipId <= 0 || lordId <= 0 || armyKeyId <= 0) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }
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

        //进攻集结(队伍)不存在
        Airship airship = airshipDataManager.getAirshipMap().get(airshipId);
        if (airship == null || airship.getTeamArmy().isEmpty()) {
            handler.sendErrorMsgToPlayer(GameError.TEAM_NO_CREATE);
            return;
        }

        AirshipTeam airshipTeam = partyData.getAirshipTeamMap().get(airshipId);
        if (airshipTeam == null) {
            handler.sendErrorMsgToPlayer(GameError.TEAM_NO_CREATE);
            return;
        }

        //部队不存在
        Army army = null;
        for (Army am : airshipTeam.getArmys()) {
            if (am.getKeyId() == armyKeyId && am.player.roleId == lordId) {
                army = am;
                break;
            }
        }

        if (army == null) {
            handler.sendErrorMsgToPlayer(GameError.AIRSHIP_TEAM_ARMY_NOT_FOUND);
            return;
        }

        GamePb5.GetAirshpTeamArmyRs.Builder builder = GamePb5.GetAirshpTeamArmyRs.newBuilder();
        builder.setArmy(PbHelper.createArmyPb(army));
        handler.sendMsgToPlayer(GamePb5.GetAirshpTeamArmyRs.ext, builder.build());
    }

    /**
     * 获取驻防部队的详细信息
     *
     * @param req
     * @param handler
     */
    public void getAirshipGuardArmyInfo(GamePb5.GetAirshipGuardArmyRq req, ClientHandler handler) {
        if (!staticFunctionPlanDataMgr.isAirshipOpen()) return;

        int airshipId = req.getAirshipId();
        long lordId = req.getLordId();
        int armyKeyId = req.getKeyId();
        if (airshipId <= 0 || lordId <= 0 || armyKeyId <= 0) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }
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

        //飞艇不是本工会
        Airship airship = airshipDataManager.getAirshipMap().get(airshipId);
        if (airship == null || airship.getPartyData() != partyData) {
            handler.sendErrorMsgToPlayer(GameError.AIRSHIP_NOT_BELONG_MY_PARTY);
            return;
        }


        AirshipGuard guard = partyData.getAirshipGuardMap().get(airshipId);
        if (guard == null || guard.getArmys().isEmpty()) {
            handler.sendErrorMsgToPlayer(GameError.AIRSHIP_GUARD_ARMY_NOT_FOUND);
            return;
        }

        //部队不存在
        Army army = null;
        for (Army am : guard.getArmys()) {
            if (am.getKeyId() == armyKeyId && am.player.roleId == lordId) {
                army = am;
                break;
            }
        }

        if (army == null) {
            handler.sendErrorMsgToPlayer(GameError.AIRSHIP_GUARD_ARMY_NOT_FOUND);
            return;
        }

        GamePb5.GetAirshipGuardArmyRs.Builder builder = GamePb5.GetAirshipGuardArmyRs.newBuilder();
        builder.setArmy(PbHelper.createArmyPb(army));
        handler.sendMsgToPlayer(GamePb5.GetAirshipGuardArmyRs.ext, builder.build());
    }

    /**
     * GM创建玩家飞艇部队并加入
     *
     * @param player
     * @param handler
     * @param airshipId void
     */
    public void gmCreateAirshipTeamAndJoin(Player player, ClientHandler handler, int airshipId) {
        //没有集结道具, 就新增一个
        Prop prop = player.props.get(PropId.AIRSHIP_CREATE_TEAM_PROP);
        if (prop == null || prop.getCount() == 0) {
            playerDataManager.addAward(player, AwardType.PROP, PropId.AIRSHIP_CREATE_TEAM_PROP, 1, AwardFrom.DO_SOME);
        }
        GamePb5.CreateAirshipTeamRq.Builder reqBuilder = GamePb5.CreateAirshipTeamRq.newBuilder();
        reqBuilder.setId(airshipId);
        createAirshipTeam(reqBuilder.build(), handler);
        PartyData partyData = partyDataManager.getPartyByLordId(player.roleId);
        AirshipTeam airshipTeam = partyData.getAirshipTeamMap().get(airshipId);

        //把工会玩家加入到队伍中来
        gmJoinTeam(player, airshipId, airshipTeam, handler);
    }

    /**
     * GM加入驻军防守
     *
     * @param player
     * @param handler
     * @param airshipId void
     */
    public void gmJoinGuard(Player player, ClientHandler handler, int airshipId) {
        StaticAirship staticAirship = staticWorldDataMgr.getAirshipMap().get(airshipId);
        PartyData partyData = partyDataManager.getPartyByLordId(player.roleId);
        Airship airship = airshipDataManager.getAirshipMap().get(airshipId);

        //废墟状态中的飞艇不能派驻军防守
        if (airship.isRuins()) {
            handler.sendErrorMsgToPlayer(GameError.AIRSHIP_DURABILITY_NOT_FULL);
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


        //将工会中不是GM的或者坦克数量不足的成员设置为GM并且给予niub资源
        List<Member> memberList = partyDataManager.getMemberList(partyData.getPartyId());
        List<Form> forms = getAreanForm(100);//从竞技场前100名获取阵形
        for (Member member : memberList) {
            Player memberPlayer = playerDataManager.getPlayer(member.getLordId());
            if (memberPlayer.account.getIsGm() == 0 || memberPlayer.tanks.values().iterator().next().getCount() < 99999) {
                memberPlayer.account.setIsGm(2);
                gmService.gmNiub(memberPlayer);
            }

            //可设置的部队列表已满
            boolean isFoundGuard = false;

            int maxCount = playerDataManager.armyCount(player);
            int armyCount = playerDataManager.getPlayArmyCount(player, maxCount);
            for (Army army : memberPlayer.armys) {
                //一个军团成员一个飞艇只能驻防一只部队
                int armyState = army.getState();
                if (armyState == ArmyState.AIRSHIP_GUARD
                        || armyState == ArmyState.AIRSHIP_GUARD_MARCH) {
                    StaticAirship targetStaticAirship = staticWorldDataMgr.getStaticAirshipByPos(army.getTarget());
                    if (targetStaticAirship != null && targetStaticAirship.getId() == airship.getId()) {
                        isFoundGuard = true;
                        break;
                    }
                    return;
                }
//                else if (army.getState() == ArmyState.WAR) {
//                    armyCount -= 1;
//                    break;
//                }
            }
            if (isFoundGuard || armyCount >= playerDataManager.armyCount(memberPlayer)) {
                continue;
            }

            //设置防守部队
            Form attackForm = new Form(forms.get(RandomUtils.nextInt(0, forms.size())));

            int marchTime = AirshipConst.AIRSHIP_GUARD_MARCH_SECOND;
            int now = TimeHelper.getCurrentSecond();
            Army army = new Army(memberPlayer.maxKey(), staticAirship.getPos(), ArmyState.AIRSHIP_GUARD_MARCH, attackForm, marchTime, now + marchTime, playerDataManager.isRuins(player));
            memberPlayer.armys.add(army);
            army.setFight(fightService.calcFormFight(memberPlayer, attackForm));
            army.player = memberPlayer;
            StcHelper.syncAirshipTeamArmy2Player(memberPlayer, AirshipConst.TEAM_STATE_ARMY_CHANGE);
        }
    }

    /**
     * 飞艇加入飞艇部队
     *
     * @param player
     * @param airshipId
     * @param airshipTeam
     * @param handler     void
     */
    private void gmJoinTeam(Player player, int airshipId, AirshipTeam airshipTeam, ClientHandler handler) {
        StaticAirship staticAirship = staticWorldDataMgr.getAirshipMap().get(airshipId);
        PartyData partyData = partyDataManager.getPartyByLordId(player.roleId);
        //将工会中不是GM的或者坦克数量不足的成员设置为GM并且给予niub资源
        List<Member> memberList = partyDataManager.getMemberList(partyData.getPartyId());
        List<Form> forms = getAreanForm(100);//从竞技场前100名获取阵形
        for (Member member : memberList) {
            Player memberPlayer = playerDataManager.getPlayer(member.getLordId());
            if (memberPlayer.account.getIsGm() == 0 || memberPlayer.tanks.values().iterator().next().getCount() < 99999) {
                memberPlayer.account.setIsGm(2);
                gmService.gmNiub(memberPlayer);
            }

            //随机加入1-n只部队
//            StaticVip staticVip = staticVipDataMgr.getStaticVip(mbp.lord.getVip());
//            int totalArmy = staticVip.getArmyCount();
            //部队全部返回(竞技场除外)
//            Iterator<Army> iter = mbp.armys.iterator();
//            while (iter.hasNext()) {
//                Army army = iter.next();
//                worldService.retreatEnd(mbp, army);
//                iter.remove();
//            }
//
//            int armyCount = new Random().nextInt(Math.max(totalArmy - mbp.armys.size(), 1)) + 1;

            //可设置的部队列表已满
//            int armyCount = memberPlayer.armys.size();
//            for (Army army : memberPlayer.armys) {
//                if (army.getState() == ArmyState.WAR) {
//                    armyCount -= 1;
//                    break;
//                }
//            }
            int maxCount = playerDataManager.armyCount(memberPlayer);
            if (playerDataManager.getPlayArmyCount(memberPlayer, maxCount) >= maxCount) {
                continue;
            }


            for (int i = 0; i < 1; i++) {
                Form attackForm = new Form(forms.get(RandomUtils.nextInt(0, forms.size())));

                int marchTime = AirshipConst.AIRSHIP_BEGAIN_SECOND;
                Army army = new Army(memberPlayer.maxKey(), staticAirship.getPos(), ArmyState.AIRSHIP_BEGAIN, attackForm, marchTime,
                        airshipTeam.getEndTime(), playerDataManager.isRuins(player));
                memberPlayer.armys.add(army);
                army.setFight(fightService.calcFormFight(player, attackForm));
                army.player = memberPlayer;

                airshipTeam.getArmys().add(army);
            }
            //通知军团玩家队伍发生变化
            StcHelper.syncAirshipTeamChange2Party(partyData.getPartyId(), airshipId, AirshipConst.TEAM_STATUS_UPDATE);
        }
    }

    /**
     * 从竞技场中获取阵形
     *
     * @param formCount
     * @return
     */
    private List<Form> getAreanForm(int formCount) {
        List<Form> forms = new ArrayList<>();
        for (Map.Entry<Integer, Arena> entry : arenaDataManager.getRankMap().entrySet()) {
            Arena arena = entry.getValue();
            Player arenaPlayer = playerDataManager.getPlayer(arena.getLordId());
            boolean notFound = true;
            for (Map.Entry<Integer, Form> formEntry : arenaPlayer.forms.entrySet()) {
                if (formEntry.getKey() == FormType.ARENA) {
                    Form fm = new Form(formEntry.getValue());
                    for (int i = 0; i < 6; i++) {
                        if (fm.p[i] != 0 && fm.c[i] == 0) {
                            fm.c[i] = RandomUtils.nextInt(100, 1000);
                        }
                    }
                    forms.add(fm);
                    notFound = false;
                    break;
                }
            }
            if (notFound && arenaPlayer.forms.size() > 0) {
                forms.add(arenaPlayer.forms.values().iterator().next());
            }
            if (forms.size() >= formCount) {
                break;
            }
        }
        return forms;
    }

    /**
     * GM 将指定飞艇归于中立NPC
     *
     * @param player
     * @param handler
     * @param airshipId
     */
    public void gmResetAirship2Npc(Player player, ClientHandler handler, int airshipId) {
        Airship airship = airshipDataManager.getAirshipMap().get(airshipId);
        StaticAirship stp = staticWorldDataMgr.getAirshipMap().get(airshipId);
        airshipDataManager.clearAirshipData2Npc(stp, airship);
        StcHelper.syncAirshipChange2World(airshipId);
    }

}
