package com.game.service;

import com.game.actor.role.PlayerEventService;
import com.game.constant.*;
import com.game.dataMgr.*;
import com.game.domain.Member;
import com.game.domain.Player;
import com.game.domain.p.*;
import com.game.domain.s.StaticExplore;
import com.game.domain.s.StaticFortressAttr;
import com.game.domain.s.StaticFortressJob;
import com.game.domain.s.StaticHero;
import com.game.fight.FightLogic;
import com.game.fight.domain.Fighter;
import com.game.fight.domain.Force;
import com.game.fortressFight.domain.*;
import com.game.manager.GlobalDataManager;
import com.game.manager.PartyDataManager;
import com.game.manager.PlayerDataManager;
import com.game.manager.WarDataManager;
import com.game.message.handler.ClientHandler;
import com.game.pb.CommonPb;
import com.game.pb.GamePb4;
import com.game.util.LogLordHelper;
import com.game.util.LogUtil;
import com.game.util.PbHelper;
import com.game.util.TimeHelper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.*;

/**
 * @author zhangdh
 * @ClassName: FortressWarService
 * @Description: 要塞战斗
 * @date 2017/4/10 13:47
 */
@Service
public class FortressWarService {

    @Autowired
    private PlayerDataManager playerDataManager;

    @Autowired
    private WarDataManager warDataManager;

    @Autowired
    private PartyDataManager partyDataManager;

    @Autowired
    private ChatService chatService;

    @Autowired
    private GlobalDataManager globalDataManager;

    @Autowired
    private FightService fightService;

    @Autowired
    private PlayerEventService playerEventService;

    // 静态数据
    @Autowired
    private StaticWarAwardDataMgr staticWarAwardDataMgr;

    @Autowired
    private StaticCombatDataMgr staticCombatDataMgr;

    @Autowired
    private StaticHeroDataMgr staticHeroDataMgr;

    @Autowired
    private StaticFortressDataMgr staticFortressDataMgr;

    @Autowired
    private StaticFunctionPlanDataMgr staticFunctionPlanDataMgr;
    @Autowired
    private TacticsService tacticsService;

    /**
     * Method: fortressBattleLogic
     *
     * @return void @throws
     */
    public void fortressBattleLogic() {
        int nowDay = TimeHelper.getCurrentDay();
        WarLog warLog = warDataManager.getWarLog();
        if (warLog == null || nowDay != warLog.getWarTime()) {
            warLog = new WarLog();
            warLog.setWarTime(nowDay);
            warDataManager.setWarLog(warLog);
            warDataManager.flushWarLog();
        }

        FortressFight fortressFight = warDataManager.getFortressFight();
        if (TimeHelper.isFortressBattlePrepare()) {
            if (fortressFight == null || nowDay != fortressFight.getFightDay()) {
                fortressFight = new FortressFight(nowDay);
                if (warDataManager.getCanFightFortressPartyMap().size() == 0) {
                    // 没有数据要塞战取消
                    fortressFight.setState(FortressFightConst.Fight_Cancel);
                    warDataManager.cancelFortressFight();
                    synFortressState(FortressFightConst.Fight_Cancel);
                    return;
                }

                warDataManager.setFortressFight(fortressFight);
                fortressFight.setState(FortressFightConst.Fight_prepare);
                warDataManager.refulshFortressData();
                synFortressState(FortressFightConst.Fight_prepare);
                fortressFight.init();

                // 预热的时候计算一下本周的积分排名
                warDataManager.calThisWeekWarPartyJiFenRank();

                // 初始化军团统计数据
                warDataManager.initStaticPartyData();

                // 清理要塞战职务
                clearFortressJob();

                // 发系统公告
                chatService.sendWorldChat(chatService.createSysChat(SysChatId.Fortress_Pre));
            }
        } else if (TimeHelper.isFortressBattleBeginFight()) {
            if (fortressFight != null && fortressFight.getState() == FortressFightConst.Fight_prepare) {
                fortressFight.setState(FortressFightConst.Fight_Begin);
                synFortressState(FortressFightConst.Fight_Begin);
                chatService.sendWorldChat(chatService.createSysChat(SysChatId.Fortress_IS_Begin));
            }

        } else if (TimeHelper.isFortressBattleEnd()) {
            // 战斗结束
            if (fortressFight != null) {
                fortressFight.endFortress(true);
            }
        }

        if (fortressFight != null) {
            if (fortressFight.getState() == FortressFightConst.Fight_End) {
                fortressFight.setState(FortressFightConst.Fortress_End);
                // 发奖励
                sendFortressAward();
                // 发帮贡
                sendFortressDonate();

                synFortressState(FortressFightConst.Fortress_End);

                warDataManager.endClearFortress();

                // 发系统公告
                chatService.sendWorldChat(chatService.createSysChat(SysChatId.Fortress_Is_End,
                        partyDataManager.getParty(globalDataManager.gameGlobal.getFortressPartyId()).getPartyName()));
            }
        }
    }

    // 若是第三次军团大战,则计算参加要塞战的军团名额
    public void calCanFightFortressParty() {
        if (TimeHelper.getCurrentDay() != globalDataManager.gameGlobal.getCalCanJoinFortressTime()) {
            warDataManager.calCanFightFortressParty();
            globalDataManager.gameGlobal.setCalCanJoinFortressTime(TimeHelper.getCurrentDay());
        }
    }

    private void synFortressState(int state) {
        GamePb4.SynFortressBattleStateRq.Builder builder = GamePb4.SynFortressBattleStateRq.newBuilder();
        builder.setState(state);
        GamePb4.SynFortressBattleStateRq req = builder.build();

        // 获取参赛的军团
        // 给所有参赛军团的人推送
        Iterator<FortressBattleParty> its = warDataManager.getCanFightFortressPartyMap().values().iterator();
        while (its.hasNext()) {
            FortressBattleParty p = its.next();

            List<Member> members = partyDataManager.getMemberList(p.getPartyId());
            for (Member m : members) {
                playerDataManager.synFortressStateToPlayer(playerDataManager.getPlayer(m.getLordId()), req);
            }
        }
    }

    /**
     * 要塞战发奖励
     */
    private void sendFortressAward() {
        // 获取积分前几名
        LinkedHashMap<Integer, MyPartyStatistics> mp = warDataManager.getPartyStatisticsMap();
        Iterator<MyPartyStatistics> its = mp.values().iterator();

        int rank = 1;
        while (its.hasNext()) {
            MyPartyStatistics my = its.next();
            if (rank <= 10) {
                List<List<Integer>> awards = staticWarAwardDataMgr.getFortressRankAward(rank);
                List<Prop> props = new ArrayList<Prop>();
                for (List<Integer> prop : awards) {
                    props.add(new Prop(prop.get(1), prop.get(2)));
                }

                // 积分超过50才发奖励
                if (my.getJifen() >= 50) {
                    // 发送福利到军团福利院
                    partyDataManager.addAmyProps(my.getPartyId(), props);

                    partyDataManager.addPartyTrend(my.getPartyId(), 16, String.valueOf(rank));

                    // LogHelper.WAR_LOGGER.trace("frotressAward:" +
                    // my.getPartyId() + "|" + " get rank:" + rank);
                    LogUtil.war("frotressAward:" + my.getPartyId() + "|" + " get rank:" + rank);

                    rank++;
                }

                // 胜利军团直接发buff
                if (my.getPartyId() == globalDataManager.gameGlobal.getFortressPartyId()) {
                    // 发送buff
                    allProductBuff(my.getPartyId());
                    partyDataManager.addPartyTrend(my.getPartyId(), 17, "");

                    // 发送邮件
                    playerDataManager.sendMailToParty(my.getPartyId(), MailType.MOLD_FORTRESS_KING_REWARD);
                }

            }
        }
    }

    // 发帮贡
    private void sendFortressDonate() {
        Iterator<MyFortressFightData> its = warDataManager.getMyFortressFightData().values().iterator();
        int now = TimeHelper.getCurrentSecond();

        while (its.hasNext()) {
            MyFortressFightData my = its.next();
            Member member = partyDataManager.getMemberById(my.getLordId());

            if (member != null && my.getJifen() > 0) {

                int donate = my.getJifen() * 10;
                member.setDonate(member.getDonate() + donate);

                // 军团贡献增加记录日志
                {
                    Player player = playerDataManager.getPlayer(my.getLordId());
                    LogLordHelper.contribution(AwardFrom.SEND_FORTRESS_DONATE, player.account, player.lord, member.getDonate(),
                            member.getWeekAllDonate(), donate);
                }

                String mailContent = "";

                Iterator<SufferTank> iterator = my.getSufferTankMap().values().iterator();
                while (iterator.hasNext()) {
                    SufferTank st = iterator.next();
                    if (st.getTankId() != 0) {
                        int count = (st.getSufferCount() / 1000) + (((st.getSufferCount() % 1000) >= 100) ? 1 : 0);
                        if (count > 0) {
                            mailContent += (st.getTankId() + "|" + count + "&");
                        }
                    }
                }

                // 发邮件
                Player player = playerDataManager.getPlayer(my.getLordId());
                if (staticFunctionPlanDataMgr.isMilitaryRankOpen()) {
                    LogUtil.war(
                            String.format("nick :%s, mplt :%s, myData.hashcode :%d", player.lord.getNick(), my.getMplt(), my.hashCode()));
                    playerDataManager.sendNormalMail(player, MailType.MOLD_FORTRESS_RWARD_MILITARY_RANK, now, my.getJifen() + "",
                            donate + "", String.valueOf(my.getMplt()), mailContent);
                } else {
                    playerDataManager.sendNormalMail(player, MailType.MOLD_FORTRESS_RAWRD, now, my.getJifen() + "", donate + "",
                            mailContent);
                }
            }
        }
    }

    /**
     * 要塞战职务数据清理 void
     */
    private void clearFortressJob() {
        // 查看清理时间,若清理过不清理
        if (TimeHelper.getCurrentDay() != globalDataManager.gameGlobal.getClearJobTime()) {
            warDataManager.getFortressJobAppointList().clear();
            warDataManager.getFortressJobAppointMap().clear();
            warDataManager.getFortressJobAppointMapByLordId().clear();

            globalDataManager.gameGlobal.setClearJobTime(TimeHelper.getCurrentDay());
        }
    }

    /**
     * 军团全员5中资源基础产量+50%
     *
     * @param partyId
     */
    private void allProductBuff(int partyId) {
        Iterator<Member> it = partyDataManager.getMemberList(partyId).iterator();
        while (it.hasNext()) {
            Member member = (Member) it.next();
            Player player = playerDataManager.getPlayer(member.getLordId());
            if (player != null) {
                // playerDataManager.addEffect(player, EffectType.ALL_PRODUCT,
                // 12 * 3600);
                playerDataManager.addEffect(player, EffectType.WAR_CHAMPION, 12 * 3600);
            }
        }
    }

    /**
     * 获取我的要塞战信息 Method: getMyFortressFightData
     *
     * @param lordId
     * @return @return MyFortressFightData @throws
     */
    private MyFortressFightData getMyFortressFightData(long lordId) {
        Map<Long, MyFortressFightData> myFortressFightDatas = warDataManager.getMyFortressFightData();
        MyFortressFightData my = myFortressFightDatas.get(lordId);
        if (my == null) {
            my = new MyFortressFightData();
            my.setLordId(lordId);
            myFortressFightDatas.put(lordId, my);
        }
        return my;
    }

    /**
     * 推送要塞自身耐久度信息到所有参赛的军团
     */
    private void synFortressSelfToAllFortressParty() {
        FortressFight fFight = warDataManager.getFortressFight();

        int nowNpcNum = FortressFightConst.npcMaxNum - fFight.getOutNpcNum();

        GamePb4.SynFortressSelfRq.Builder builder = GamePb4.SynFortressSelfRq.newBuilder();
        builder.setFortressSelf(PbHelper.createFortressSelfPb(nowNpcNum, FortressFightConst.npcMaxNum));
        GamePb4.SynFortressSelfRq req = builder.build();

        // 获取所有参战的军团
        Iterator<Integer> its = warDataManager.getCanFightFortressPartyMap().keySet().iterator();
        while (its.hasNext()) {
            List<Member> list = partyDataManager.getMemberList(its.next());
            for (Member m : list) {
                playerDataManager.synFortressSelfToPlayer(playerDataManager.getPlayer(m.getLordId()), req);
            }
        }
    }

    public Map<Integer, MyFortressAttr> getMyFortressAttrMap(long lordId) {
        Map<Integer, MyFortressAttr> my = getMyFortressFightData(lordId).getMyFortressAttrs();

        int partyId = partyDataManager.getPartyId(lordId);

        if (my.size() == 0) {
            // 初始化
            for (Integer id : staticFortressDataMgr.getAttrIdList()) {
                if (id != FortressFightConst.Attr_Angle) {
                    MyFortressAttr ma = new MyFortressAttr(id, 0);
                    my.put(id, ma);
                } else {
                    // 判断id为狂怒并且不是防守军团则设置等级为1
                    if (isAttackFortress(partyId)) {
                        MyFortressAttr ma = new MyFortressAttr(id, 1);
                        my.put(id, ma);
                    }
                }
            }
        }
        return my;
    }

    /**
     * 判断是否是攻击者 Method: isAttackFortress
     *
     * @Description: @param player @return @return boolean @throws
     */
    private boolean isAttackFortress(int partyId) {
        FortressBattleParty party = warDataManager.getCanFightFortressPartyMap().get(partyId);
        return party.getRank() != 1;
    }

    /**
     * Fighter的force拿给form
     *
     * @param fighter
     * @param form    void
     */
    private void subForceToForm(Fighter fighter, Form form) {
        int[] c = form.c;
        for (int i = 0; i < c.length; i++) {
            Force force = fighter.forces[i];
            if (force != null) {
                form.c[i] = force.count;
            }
        }
    }

    /**
     * 获取myCD Method: getMyCD
     *
     * @param lordId
     * @return @return MyCD @throws
     */
    private MyCD getMyCD(long lordId) {
        MyCD myCD = getMyFortressFightData(lordId).getMyCD();
        if (myCD.getBeginTime() == 0) {
            int nowTime = TimeHelper.getCurrentSecond();
            myCD.setBeginTime(nowTime);
            myCD.setEndTime(nowTime);
        }

        return myCD;
    }

    ////////////////////////////// 处理要塞战信息Handler///////////////////////////////////////

    /**
     * 获取我的要塞职位信息
     *
     * @param handler
     */
    public void getMyFortressJob(ClientHandler handler) {
        GamePb4.GetMyFortressJobRs.Builder builder = GamePb4.GetMyFortressJobRs.newBuilder();
        FortressJobAppoint f = warDataManager.getFortressJobAppointMapByLordId().get(handler.getRoleId());
        if (f != null) {
            builder.setFortressJob(PbHelper.creatFortressJobPb(f));
        }

        handler.sendMsgToPlayer(GamePb4.GetMyFortressJobRs.ext, builder.build());
    }

    /**
     * 获取要塞战胜利军团
     *
     * @param getFortressWinPartyHandler
     */
    public void getFortressWinParty(ClientHandler handler) {
        GamePb4.GetFortressWinPartyRs.Builder builder = GamePb4.GetFortressWinPartyRs.newBuilder();
        int partyId = globalDataManager.gameGlobal.getFortressPartyId();
        if (partyId == 0) {
            // 还没有胜利军团
            builder.setPartyId(0);
            builder.setPartyName("");
            handler.sendMsgToPlayer(GamePb4.GetFortressWinPartyRs.ext, builder.build());
            return;
        }
        String partyName = partyDataManager.getParty(partyId).getPartyName();

        builder.setPartyId(partyId);
        builder.setPartyName(partyName);
        handler.sendMsgToPlayer(GamePb4.GetFortressWinPartyRs.ext, builder.build());
    }

    /**
     * 获取参加要塞战的军团 Method: getFortressBattleParty
     *
     * @return void @throws
     */
    public void getFortressBattleParty(ClientHandler handler) {
        GamePb4.GetFortressBattlePartyRs.Builder builder = GamePb4.GetFortressBattlePartyRs.newBuilder();
        for (FortressBattleParty fortressBattleParty : warDataManager.getCanFightFortressPartyMap().values()) {
            builder.addFortressBattleParty(PbHelper.createFortressBattlePartyPb(fortressBattleParty));
        }
        handler.sendMsgToPlayer(GamePb4.GetFortressBattlePartyRs.ext, builder.build());
    }

    /**
     * 获取要塞战任命职务
     *
     * @param handler
     */
    public void getFortressJob(ClientHandler handler) {
        GamePb4.GetFortressJobRs.Builder builder = GamePb4.GetFortressJobRs.newBuilder();

        Iterator<List<FortressJobAppoint>> its = warDataManager.getFortressJobAppointMap().values().iterator();
        while (its.hasNext()) {
            List<FortressJobAppoint> list = its.next();
            for (FortressJobAppoint f : list) {
                builder.addFortressJob(PbHelper.creatFortressJobPb(f));
            }
        }

        handler.sendMsgToPlayer(GamePb4.GetFortressJobRs.ext, builder.build());
    }

    /**
     * 获取要塞进修数据
     *
     * @param getFortressAttrHandler
     */
    public void getFortressAttr(ClientHandler handler) {
        GamePb4.GetFortressAttrRs.Builder builder = GamePb4.GetFortressAttrRs.newBuilder();

        int partyId = partyDataManager.getPartyId(handler.getRoleId());

        if (warDataManager.getCanFightFortressPartyMap().containsKey(partyId)) {
            Map<Integer, MyFortressAttr> my = getMyFortressAttrMap(handler.getRoleId());

            Iterator<MyFortressAttr> its = my.values().iterator();
            while (its.hasNext()) {
                builder.addMyFortressAttr(PbHelper.createMyFortressAttrPb(its.next()));
            }
        }

        handler.sendMsgToPlayer(GamePb4.GetFortressAttrRs.ext, builder.build());
    }

    /**
     * 进修
     *
     * @param extension
     * @param upFortressAttrHandler
     */
    public void upFortressAttr(GamePb4.UpFortressAttrRq req, ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        int id = req.getId();

        // 获取我的进修数据
        Map<Integer, MyFortressAttr> map = getMyFortressAttrMap(handler.getRoleId());
        MyFortressAttr my = map.get(id);
        // 判断等级
        if (my.getLevel() == 10 || id == FortressFightConst.Attr_Angle) {
            // 等级上限,不能在进修了
            handler.sendErrorMsgToPlayer(GameError.Fortress_Attr_Level_Limit);
            return;
        }

        int partyId = partyDataManager.getPartyId(handler.getRoleId());
        if (id == FortressFightConst.Attr_UpperHand && (!isAttackFortress(partyId))) {
            // 防守方不能购买先手值
            handler.sendErrorMsgToPlayer(GameError.Fortress_Ack_Can_Up_Hand);
            return;
        }

        // 获取进修需要的金币
        StaticFortressAttr s = staticFortressDataMgr.getStaticFortressAttr(id, my.getLevel() + 1);
        if (player.lord.getGold() < s.getPrice()) {
            handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
            return;
        }

        playerDataManager.subGold(player, s.getPrice(), AwardFrom.UP_FORTRESS_ATTR);

        my.setLevel(my.getLevel() + 1);

        GamePb4.UpFortressAttrRs.Builder builder = GamePb4.UpFortressAttrRs.newBuilder();
        builder.setId(my.getId());
        builder.setLevel(my.getLevel());
        builder.setGold(player.lord.getGold());

        handler.sendMsgToPlayer(GamePb4.UpFortressAttrRs.ext, builder.build());
    }

    /**
     * Method: setFortressBattleForm 设置要塞战阵型
     *
     * @param handler
     * @return void @throws
     */
    public void setFortressBattleForm(GamePb4.SetFortressBattleFormRq req, ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());

        // 判断军团是否能参加要塞战
        Member member = partyDataManager.getMemberById(handler.getRoleId());
        if (member == null || member.getPartyId() == 0) {
            handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
            return;
        }

        int partyId = member.getPartyId();
        FortressBattleParty party = warDataManager.getCanFightFortressPartyMap().get(partyId);
        if (party == null || party.getRank() != 1) {
            // 没有资格参加要塞战
            handler.sendErrorMsgToPlayer(GameError.Fortress_No_Qualification_Join);
            return;
        }

        // 判断状态
        FortressFight fFight = warDataManager.getFortressFight();
        if (!((fFight.getState() == FortressFightConst.Fight_prepare || fFight.getState() == FortressFightConst.Fight_Begin))) {
            // 要塞战状态不对
            handler.sendErrorMsgToPlayer(GameError.Fortress_State_Is_Not_Right);
            return;
        }

        // 如果设置过防守，不能再设置
        if (!fFight.isCanSettingDefence(player.account.getLordId())) {
            handler.sendErrorMsgToPlayer(GameError.Fortress_Already_Setting_Denfence);
            return;
        }

        int time = TimeHelper.getCurrentSecond();

        // 判断CD有没有到
        if (getMyCD(player.account.getLordId()).getEndTime() > time) {
            handler.sendErrorMsgToPlayer(GameError.Fortress_Attack_CD);
            return;
        }

        // 如果设置过防守，不能再设置
        for (Army army : player.armys) {
            if (army.getState() == ArmyState.FortessBattle) {
                // 已经设置过防守
                handler.sendErrorMsgToPlayer(GameError.Fortress_Already_Setting_Denfence);
                return;
            }
        }

        if (req.getForm().getType() != FormType.FORTRESS) {
            // 阵型类型不对
            handler.sendErrorMsgToPlayer(GameError.Fortress_No_Form);
            return;
        }

        Form form = PbHelper.createForm(req.getForm());

        StaticHero staticHero = null;
        int heroId = 0;
        AwakenHero awakenHero = null;
        Hero hero = null;
        if (form.getAwakenHero() != null) {// 使用觉醒将领

            if(form.getAwakenHero() == null ){
                handler.sendErrorMsgToPlayer(GameError.NO_HERO);
                return;
            }

            awakenHero = player.awakenHeros.get(form.getAwakenHero().getKeyId());
            if (awakenHero == null || awakenHero.isUsed()) {
                handler.sendErrorMsgToPlayer(GameError.NO_HERO);
                return;
            }
            form.setAwakenHero(awakenHero.clone());
            heroId = awakenHero.getHeroId();
        } else if (form.getCommander() > 0) {
            hero = player.heros.get(form.getCommander());
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
        if (!form.getTactics().isEmpty()) {
            boolean checkUseTactics = tacticsService.checkUseTactics(player, form);
            if (!checkUseTactics) {
                handler.sendErrorMsgToPlayer(GameError.USE_TACTICS_ERROR);
                return;
            }
        }

        int maxTankCount = playerDataManager.formTankCount(player, staticHero, awakenHero);
        if (!playerDataManager.checkAndSubTank(player, form, maxTankCount, AwardFrom.FORTRESS_FORM)) {
            handler.sendErrorMsgToPlayer(GameError.TANK_COUNT);
            return;
        }

        if (hero != null) {
            // hero.setCount(hero.getCount() - 1);
            playerDataManager.addHero(player, hero.getHeroId(), -1, AwardFrom.FORTRESS_FORM);
        }

        if (awakenHero != null) {
            awakenHero.setUsed(true);
            LogLordHelper.awakenHero(AwardFrom.FORTRESS_FORM, player.account, player.lord, awakenHero, 0);
        }

        //使用战术
        if (!form.getTactics().isEmpty()) {
            tacticsService.useTactics(player, form.getTactics());
        }

        // int fight = fightService.calcFormFight(player, form);

        int marchTime = 60 * 60;
        int now = TimeHelper.getCurrentSecond();
        Army army = new Army(player.maxKey(), 0, ArmyState.FortessBattle, form, marchTime, now + marchTime,
                playerDataManager.isRuins(player));
        player.armys.add(army);

        player.forms.put(form.getType(), form);

        fFight.joinDefencePlayer(player, form, req.getFight());

        GamePb4.SetFortressBattleFormRs.Builder builder = GamePb4.SetFortressBattleFormRs.newBuilder();
        builder.setFight(req.getFight());
        builder.setArmy(PbHelper.createArmyPb(army));
        builder.setForm(req.getForm());
        handler.sendMsgToPlayer(GamePb4.SetFortressBattleFormRs.ext, builder.build());

    }

    /**
     * Method: getFortressBattleDefend
     *
     * @Description: 获取防守方信息 @param getFortressBattleDefendHandler @return void @throws
     */
    public void getFortressBattleDefend(ClientHandler handler) {
        GamePb4.GetFortressBattleDefendRs.Builder builder = GamePb4.GetFortressBattleDefendRs.newBuilder();

        // 判断状态
        FortressFight fFight = warDataManager.getFortressFight();
        if (!((fFight != null
                && (fFight.getState() == FortressFightConst.Fight_prepare || fFight.getState() == FortressFightConst.Fight_Begin)))) {
            // 要塞战状态不对
            // handler.sendErrorMsgToPlayer(GameError.Fortress_State_Is_Not_Right);

            int nowNpcNum = 0;
            builder.setFortressSelf(PbHelper.createFortressSelfPb(nowNpcNum, FortressFightConst.npcMaxNum));
            handler.sendMsgToPlayer(GamePb4.GetFortressBattleDefendRs.ext, builder.build());
            return;
        }

        int nowNpcNum = FortressFightConst.npcMaxNum - fFight.getOutNpcNum();

        builder.setFortressSelf(PbHelper.createFortressSelfPb(nowNpcNum, FortressFightConst.npcMaxNum));

        Iterator<DefencePlayer> its = fFight.defencePlayerMap.values().iterator();
        while (its.hasNext()) {
            builder.addFortressDefend(PbHelper.createFortressDefendPb(its.next()));
        }

        int d = TimeHelper.getCurrentSecond() - getMyCD(handler.getRoleId()).getEndTime();

        builder.setCdTime(d >= 0 ? 0 : -d);

        handler.sendMsgToPlayer(GamePb4.GetFortressBattleDefendRs.ext, builder.build());
    }

    /**
     * Method: attackFortress
     *
     * @Description: 攻击要塞 @param extension @param attackFortressHandler @return void @throws
     */
    public void attackFortress(GamePb4.AttackFortressRq req, ClientHandler handler) {
        // 攻击
        FortressFight fFight = warDataManager.getFortressFight();
        if (!((fFight.getState() == FortressFightConst.Fight_prepare || fFight.getState() == FortressFightConst.Fight_Begin))) {
            // 要塞战状态不对
            handler.sendErrorMsgToPlayer(GameError.Fortress_State_Is_Not_Right);
            return;
        }

        // 判断有没有攻击资格(2,10名可以攻击)
        Player player = playerDataManager.getPlayer(handler.getRoleId());

        // 判断军团是否能参加要塞战
        Member member = partyDataManager.getMemberById(handler.getRoleId());
        if (member == null || member.getPartyId() == 0) {
            handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
            return;
        }

        int partyId = member.getPartyId();

        if (!(warDataManager.getCanFightFortressPartyMap().containsKey(partyId) && fFight.getDeFencePartyId() != partyId)) {
            // 没有资格参加要塞战
            handler.sendErrorMsgToPlayer(GameError.Fortress_No_Qualification_Join);
            return;
        }

        GamePb4.AttackFortressRs.Builder atkFortress = GamePb4.AttackFortressRs.newBuilder();

        if (fFight.attack(player, req.getLordId(), req.getForm(), atkFortress, handler)) {
            handler.sendMsgToPlayer(GamePb4.AttackFortressRs.ext, atkFortress.build());
        }
    }

    /**
     * Method: buyFortressCD
     *
     * @Description: 购买要塞CD @param buyFortressCDHandler @return void @throws
     */
    public void buyFortressCD(ClientHandler handler) {
        // 判断状态对不对
        FortressFight fFight = warDataManager.getFortressFight();
        if (fFight.getState() != FortressFightConst.Fight_Begin) {
            // 要塞战状态不对
            handler.sendErrorMsgToPlayer(GameError.Fortress_State_Is_Not_Right);
            return;
        }

        // 判断有没有资格
        Player player = playerDataManager.getPlayer(handler.getRoleId());

        // 判断军团是否能参加要塞战
        Member member = partyDataManager.getMemberById(handler.getRoleId());
        if (member == null || member.getPartyId() == 0) {
            handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
            return;
        }

        int partyId = member.getPartyId();
        FortressBattleParty party = warDataManager.getCanFightFortressPartyMap().get(partyId);
        if (party == null) {
            // 没有资格参加要塞战
            handler.sendErrorMsgToPlayer(GameError.Fortress_No_Qualification_Join);
            return;
        }

        // // 判断是攻击者还是防御者
        // boolean isAttack = isAttackFortress(partyId);

        // 计算CD
        MyCD myCD = getMyCD(player.account.getLordId());

        int nowTime = TimeHelper.getCurrentSecond();
        int d = myCD.getEndTime() - nowTime;
        if (d <= 0) {
            // CD已到，不需要买
            handler.sendErrorMsgToPlayer(GameError.Fortress_CD_TIME_BEGIN_NO_NEED_BUY);
            return;
        }

        int needGold = (d + 9) / 10 * 5;

        if (player.lord.getGold() < needGold) {
            handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
            return;
        }
        playerDataManager.subGold(player, needGold, AwardFrom.BUY_FORTRESS_CD);

        myCD.setEndTime(nowTime);

        GamePb4.BuyFortressBattleCdRs.Builder builder = GamePb4.BuyFortressBattleCdRs.newBuilder();
        builder.setGold(player.lord.getGold());
        handler.sendMsgToPlayer(GamePb4.BuyFortressBattleCdRs.ext, builder.build());
    }

    /**
     * 获取战报信息
     *
     * @param req
     * @param handler
     */
    public void fortressBattleRecord(GamePb4.FortressBattleRecordRq req, ClientHandler handler) {
        int type = req.getType();
        int page = req.getPage() - 1;

        int begin = page * 20;
        int end = begin + 20;

//        LogUtil.error("fortressBattleRecord begin="+begin+"  end="+end);

        GamePb4.FortressBattleRecordRs.Builder builder = GamePb4.FortressBattleRecordRs.newBuilder();

        LinkedHashMap<Integer, CommonPb.FortressRecord> map = null;

        if (type == FortressFightConst.Record_All) {
            // 全服战报
            map = warDataManager.getFortressRecords();

//            LogUtil.error("fortressBattleRecord type=1  size="+map.size());


            int index = 0;
            if (map != null) {
                for (Map.Entry<Integer, CommonPb.FortressRecord> entry : map.entrySet()) {
                    if (index >= end) {
                        break;
                    }
                    if (index >= begin) {
                        builder.addRecord(entry.getValue());
                    }
                    index++;
                }
            }
            // builder.addAllRecord(warDataManager.getFortressRecords().values());
        } else if (type == FortressFightConst.Record_Personal) {
            // 个人战报
            Player player = playerDataManager.getPlayer(handler.getRoleId());
            MyFortressFightData my = getMyFortressFightData(player.account.getLordId());
//            LogUtil.error("fortressBattleRecord type=2  size="+my.getMyReportKeys().size());

            int index = 0;
            if (my != null) {
                for (Integer key : my.getMyReportKeys()) {
                    if (index >= end) {
                        break;
                    }
                    if (index >= begin) {
                        CommonPb.FortressRecord f = warDataManager.getFortressRecords().get(key);
                        if (f != null) {
                            builder.addRecord(f);
                        }
                    }
                    index++;
                }
            }

            // for (Integer key : my.getMyReportKeys()) {
            // FortressRecord f = warDataManager.getFortressRecords().get(key);
            // if (f != null) {
            // builder.addRecord(f);}
            // }
        }


//        LogUtil.error("fortressBattleRecord end===========");


        handler.sendMsgToPlayer(GamePb4.FortressBattleRecordRs.ext, builder.build());
    }

    /**
     * 获取要塞战军团排名
     *
     * @param getFortressPartyRankHandler
     */
    public void getFortressPartyRank(ClientHandler handler) {
        // 获取本军团partyId
        int myPartyId = 0;
        Member member = partyDataManager.getMemberById(handler.getRoleId());
        if (member == null || member.getPartyId() == 0) {
            myPartyId = 0;
        } else {
            myPartyId = member.getPartyId();
        }

        GamePb4.GetFortressPartyRankRs.Builder builder = GamePb4.GetFortressPartyRankRs.newBuilder();
        Iterator<MyPartyStatistics> its = warDataManager.getPartyStatisticsMap().values().iterator();
        int rank = 0;
        while (its.hasNext()) {
            MyPartyStatistics ms = its.next();
            rank++;
            String partyName = partyDataManager.getParty(ms.getPartyId()).getPartyName();
            if (ms.getJifen() >= 50) {
                CommonPb.FortressPartyRank f = PbHelper.createFortressPartyRankPb(rank, partyName, ms);
                builder.addFortressPartyRank(f);
                if (myPartyId == ms.getPartyId()) {
                    builder.setMyFortressPartyRank(f);
                }
            }
        }

        handler.sendMsgToPlayer(GamePb4.GetFortressPartyRankRs.ext, builder.build());
    }

    /**
     * 获取要塞积分排名
     *
     * @param extension
     * @param getFortressJiFenRankHandler
     */
    public void getFortressJiFenRank(GamePb4.GetFortressJiFenRankRq req, ClientHandler handler) {
        GamePb4.GetFortressJiFenRankRs.Builder builder = GamePb4.GetFortressJiFenRankRs.newBuilder();
        // 获取本军团partyId
        int myPartyId = 0;
        Member member = partyDataManager.getMemberById(handler.getRoleId());
        if (member == null || member.getPartyId() == 0) {
            myPartyId = 0;
        } else {
            myPartyId = member.getPartyId();
        }

        int page = req.getPage();
        int begin = page * 20;
        int end = begin + 20;

        LinkedHashMap<Long, MyFortressFightData> rankMap = null;
        if (req.getType() == FortressFightConst.JiFen_Rank_Party_Type) {// 军团排名
            rankMap = warDataManager.getFortressPartyInnerJiFenRankMap().get(myPartyId);
        } else if (req.getType() == FortressFightConst.JiFen_Rank_All_Type) {// 全服排名
            rankMap = warDataManager.getAllServerFortressFightDataRankLordMap();
        }

        int index = 0;
        if (rankMap != null) {
            for (Map.Entry<Long, MyFortressFightData> entry : rankMap.entrySet()) {
                if (entry.getKey().longValue() == handler.getRoleId().longValue()) {
                    builder.setMyFortressJiFenRank(PbHelper.createFortressJiFenRankPb(index + 1,
                            playerDataManager.getPlayer(entry.getValue().getLordId()).lord.getNick(), entry.getValue().getFightNum(),
                            entry.getValue().getJifen()));
                }
                if (index >= end) {
                    break;
                }
                if (index >= begin) {
                    MyFortressFightData my = entry.getValue();
                    CommonPb.FortressJiFenRank fr = PbHelper.createFortressJiFenRankPb(index + 1,
                            playerDataManager.getPlayer(my.getLordId()).lord.getNick(), my.getFightNum(), my.getJifen());
                    builder.addFortressJiFenRank(fr);

                }
                index++;
            }
        }

        handler.sendMsgToPlayer(GamePb4.GetFortressJiFenRankRs.ext, builder.build());
    }

    /**
     * 战绩统计
     *
     * @param req
     * @param handler
     */
    public void getFortressCombatStatics(GamePb4.GetFortressCombatStaticsRq req, ClientHandler handler) {
        GamePb4.GetFortressCombatStaticsRs.Builder builder = GamePb4.GetFortressCombatStaticsRs.newBuilder();

        if (req.getType() == FortressFightConst.ComBatStatics_Personal) {
            MyFortressFightData my = warDataManager.getMyFortressFightData().get(handler.getRoleId());
            if (my != null) {
                Iterator<SufferTank> its = my.getDestoryTankMap().values().iterator();
                while (its.hasNext()) {
                    SufferTank st = its.next();
                    builder.addTwoInt(PbHelper.createTwoIntPb(st.getTankId(), st.getSufferCount()));
                }
                builder.setFightNum(my.getFightNum());
                builder.setWinNum(my.getWinNum());
            }

        } else if (req.getType() == FortressFightConst.ComBatStatics_Party) {
            // 获取partyId
            int myPartyId = 0;
            Member member = partyDataManager.getMemberById(handler.getRoleId());
            if (member == null || member.getPartyId() == 0) {
                myPartyId = 0;
            } else {
                myPartyId = member.getPartyId();
            }
            MyPartyStatistics my = warDataManager.getPartyStatisticsMap().get(myPartyId);
            if (my != null) {
                Iterator<SufferTank> its = my.getDestoryTankMap().values().iterator();
                while (its.hasNext()) {
                    SufferTank st = its.next();
                    builder.addTwoInt(PbHelper.createTwoIntPb(st.getTankId(), st.getSufferCount()));
                }
                builder.setFightNum(my.getFightNum());
                builder.setWinNum(my.getWinNum());
            }
        }

        handler.sendMsgToPlayer(GamePb4.GetFortressCombatStaticsRs.ext, builder.build());
    }

    /**
     * 获取要塞战战报
     *
     * @param extension
     * @param getFortressFightReportHandler
     */
    public void getFortressFightReport(GamePb4.GetFortressFightReportRq req, ClientHandler handler) {
        int reportKey = req.getReportKey();
        CommonPb.RptAtkFortress rf = warDataManager.getRptRtkFortresss().get(reportKey);
        if (rf == null) {
            // 没有该战报
            handler.sendErrorMsgToPlayer(GameError.Fortress_Error_ReportKey);
            return;
        }
        GamePb4.GetFortressFightReportRs.Builder builder = GamePb4.GetFortressFightReportRs.newBuilder();
        builder.setRptAtkFortress(rf);

        handler.sendMsgToPlayer(GamePb4.GetFortressFightReportRs.ext, builder.build());
    }

    /**
     * 要塞职位任命
     *
     * @param extension
     * @param fortressAppointHander
     */
    public void fortressAppoint(GamePb4.FortressAppointRq req, ClientHandler handler) {
        // 要塞战结束才可以任命
        // 今天必须要大于等于要塞战的日期，并且要塞战的状态为结束，并且任命截止时间为周六的19.30分
        FortressFight fFight = warDataManager.getFortressFight();
        if (fFight != null && fFight.getState() != FortressFightConst.Fortress_End) {
            // LogHelper.WAR_LOGGER.trace("Fortress is not end can not appoint
            // job");
            LogUtil.war("Fortress is not end can not appoint job");
            handler.sendErrorMsgToPlayer(GameError.Fortress_No_End_Can_Not_Appoint_Job);
            return;
        }

        // 若是周日，当前时间要大于要塞战开始准备时间才行
        if (TimeHelper.isSunDay()) {
            if (!TimeHelper.isMoreThan1930()) {
                // LogHelper.WAR_LOGGER.trace("Now time is:" + new Date() + "
                // ,can not appoint Fortress_Job");
                LogUtil.war("Now time is:" + new Date() + " ,can not appoint Fortress_Job");
                handler.sendErrorMsgToPlayer(GameError.Fortress_Error_Apponint_Time);
                return;
            }
        } else {
            // 若不是周日,则要小于周六的19:30才能任命
            if (!TimeHelper.isLessThanThisWeekSaturday1930()) {
                // 当前时间不能任命
                // LogHelper.WAR_LOGGER.trace("Now time is:" + new Date() + "
                // ,can not appoint Fortress_Job");
                LogUtil.war("Now time is:" + new Date() + " ,can not appoint Fortress_Job");
                handler.sendErrorMsgToPlayer(GameError.Fortress_Error_Apponint_Time);
                return;
            }
        }

        // 只有要塞主才能任命
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        String name = player.lord.getNick();

        // 获取军团
        Member member = partyDataManager.getMemberById(handler.getRoleId());
        if (member == null || member.getPartyId() == 0) {
            // 军团不存在
            handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
            return;
        }

        // 要塞主军团id
        int fortressPartyId = globalDataManager.gameGlobal.getFortressPartyId();
        if (member.getPartyId() != fortressPartyId) {
            // 军团不一样
            handler.sendErrorMsgToPlayer(GameError.Fortress_Not_Win_Party);
            return;
        }

        if (!((member.getJob() == PartyType.LEGATUS) || (member.getJob() == PartyType.LEGATUS_CP))) {
            // 不是军团长或者副军团长
            handler.sendErrorMsgToPlayer(GameError.Fortress_Not_Win_Party);
            return;
        }

        int jobId = req.getJobId();
        String nick = req.getNick();

        Player p = playerDataManager.getPlayer(nick);
        if (p == null) {
            // 没有该名字的玩家
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }

        int now = TimeHelper.getCurrentSecond();

        FortressJobAppoint f = warDataManager.getFortressJobAppointMapByLordId().get(p.lord.getLordId());
        if (f != null && f.getEndTime() > now) {
            // 已经任命过职务
            handler.sendErrorMsgToPlayer(GameError.Fortress_Have_Appoint_Job);
            return;
        }

        StaticFortressJob s = staticFortressDataMgr.getFortressJob(jobId);
        if (s == null) {
            // jobId未配置或不存在
            handler.sendErrorMsgToPlayer(GameError.Fortress_Job_No_Exist_Or_Config);
            return;
        }
        // 判断职务还够不够
        List<FortressJobAppoint> list = warDataManager.getFortressJobAppointMap().get(jobId);
        int haveAppointNum = 0;
        if (list == null) {
            haveAppointNum = 0;
        } else {
            haveAppointNum = list.size();
        }

        if (haveAppointNum >= s.getAppointNum()) {
            // 职位数已经分配满
            handler.sendErrorMsgToPlayer(GameError.Fortress_Job_Is_Full);
            return;
        }

        // 增益类只能发本军团的
        Member member2 = partyDataManager.getMemberById(p.lord.getLordId());
        if (s.getBuffType() == FortressFightConst.Buff && (member2 == null || member2.getPartyId() != fortressPartyId)) {
            handler.sendErrorMsgToPlayer(GameError.Fortress_Add_Buff_Job_Just_App_Our_Party);
            return;
        } else {
            if (s.getBuffType() == FortressFightConst.DeBuff && (member2 != null && member2.getPartyId() == fortressPartyId)) {
                handler.sendErrorMsgToPlayer(GameError.Fortress_Add_DeBuff_Job_Cant_APP_Our_Party);
                return;
            }
        }

        // 开始分配职务
        warDataManager.appointFortressJob(haveAppointNum + 1, jobId, p.lord.getLordId(), nick, s.getDurationTime());

        // 若存在军团,则需要发军团民情
        if (member2 != null && member2.getPartyId() != 0) {
            // 发军团民情
            partyDataManager.addPartyTrend(member2.getPartyId(), 18, String.valueOf(p.lord.getLordId()),
                    String.valueOf(handler.getRoleId()), String.valueOf(s.getName()));
        }

        // 发邮件给当事人
        playerDataManager.sendNormalMail(p, MailType.MOLD_FORTRESS_JOB_APPOINT, TimeHelper.getCurrentSecond(), name, s.getName(),
                s.getDurationTime() / 3600 + "", s.get_desc());

        // 发系统公告
        chatService.sendWorldChat(chatService.createSysChat(SysChatId.Fortress_Job_Appoint, name, p.lord.getNick(), s.getName()));

        // 给职位增加buff
        int durationTime = s.getDurationTime();
        playerDataManager.addEffect(p, s.getEffectId(), durationTime > 0 ? durationTime : -1);

        GamePb4.FortressAppointRs.Builder builder = GamePb4.FortressAppointRs.newBuilder();

        handler.sendMsgToPlayer(GamePb4.FortressAppointRs.ext, builder.build());
    }

    /***********************************************
     * 要塞战
     *
     * @author WanYi
     * @ClassName: FortressFight
     * @date 2016年6月4日 下午2:53:59 *********************************************
     */
    public class FortressFight {
        private int fightDay;// 发生日期
        private int state = FortressFightConst.Fight_UnBegin; // 要塞战状态
        private List<DefenceNPC> defenceNpcList = new ArrayList<DefenceNPC>();// 防守方npc
        private List<DefenceNPC> outNpcList = new ArrayList<DefenceNPC>(); // 出局的npcList
        private LinkedHashMap<Long, DefencePlayer> defencePlayerMap = new LinkedHashMap<Long, DefencePlayer>();// 防守方玩家
        private int deFencePartyId;// 防守方军团

        private int whoWin = FortressFightConst.Win_Default; // 谁赢了

        private int reportKey = 100001; // 战报key

        public int getWhoWin() {
            return whoWin;
        }

        public void resetReportKey() {
            reportKey = 100001;
        }

        /**
         * @param fightDay
         */
        public FortressFight(int fightDay) {
            super();
            this.fightDay = fightDay;
        }

        public void init() {
            initNpc();
            initDefaultPartyId();
        }

        private void initDefaultPartyId() {
            Iterator<FortressBattleParty> its = warDataManager.getCanFightFortressPartyMap().values().iterator();
            while (its.hasNext()) {
                FortressBattleParty p = its.next();
                if (p.getRank() == 1) {
                    deFencePartyId = p.getPartyId();
                    break;
                }
            }
        }

        /**
         * 获取出局的npc个数 Method: getOutNpcNum
         *
         * @return @return int @throws
         */
        public int getOutNpcNum() {
            return outNpcList.size();
        }

        // 初始化防守方npc
        public void initNpc() {
            for (int i = 1; i <= FortressFightConst.npcMaxNum; i++) {
                DefenceNPC npc = new DefenceNPC();
                npc.setIndex(i);
                npc.setState(FortressFightConst.Fighter_No_Out);
                npc.setForm(createDefenceNpcForm(npc.getExploreId()));
                npc.setInstForm(new Form(npc.getForm()));
                defenceNpcList.add(npc);
            }
        }

        /**
         * Method: createDefenceNpcForm
         *
         * @Description: 根据exploreId 创建form @param exploreId @return @return Form @throws
         */
        private Form createDefenceNpcForm(int exploreId) {
            StaticExplore staticExplore = staticCombatDataMgr.getStaticExplore(exploreId);
            return PbHelper.createForm(staticExplore.getForm());
        }

        /**
         * 设置并加入防守方玩家 Method: joinDefencePlayer
         *
         * @param player
         * @return void @throws
         */
        public void joinDefencePlayer(Player player, Form form, long fight) {
            DefencePlayer defencePlayer = new DefencePlayer();
            defencePlayer.setPlayer(player);
            defencePlayer.setForm(form);
            defencePlayer.setInstForm(new Form(form));
            defencePlayer.setFight(fight);
            defencePlayer.setState(FortressFightConst.Fighter_No_Out);
            defencePlayerMap.put(player.account.getLordId(), defencePlayer);
        }

        public void refulsh() {
            state = FortressFightConst.Fight_UnBegin;
            defenceNpcList.clear();
            defencePlayerMap.clear();
            outNpcList.clear();
            deFencePartyId = 0;
            resetReportKey();
            whoWin = FortressFightConst.Win_Default;

            globalDataManager.gameGlobal.setFortressTime(TimeHelper.getCurrentDay());
        }

        public int getFightDay() {
            return fightDay;
        }

        public int getDeFencePartyId() {
            return deFencePartyId;
        }

        public void setDeFencePartyId(int deFencePartyId) {
            this.deFencePartyId = deFencePartyId;
        }

        public void setFightDay(int fightDay) {
            this.fightDay = fightDay;
        }

        public int getState() {
            return state;
        }

        public void setState(int state) {
            this.state = state;
            globalDataManager.gameGlobal.setFortressState(state);

            // LogHelper.WAR_LOGGER.trace("fortress state:" + state);
            LogUtil.war("fortress state:" + state);
        }

        public List<DefenceNPC> getDefenceNpcList() {
            return defenceNpcList;
        }

        public void setDefenceNpcList(List<DefenceNPC> defenceNpcList) {
            this.defenceNpcList = defenceNpcList;
        }

        public List<DefenceNPC> getOutNpcList() {
            return outNpcList;
        }

        public void setOutNpcList(List<DefenceNPC> outNpcList) {
            this.outNpcList = outNpcList;
        }

        public LinkedHashMap<Long, DefencePlayer> getDefencePlayerMap() {
            return defencePlayerMap;
        }

        public void setDefencePlayerMap(LinkedHashMap<Long, DefencePlayer> defencePlayerMap) {
            this.defencePlayerMap = defencePlayerMap;
        }

        /**
         * 是否可以设置防守 Method: isCanSettingDefence
         *
         * @param lordIs
         * @return @return boolean @throws
         */
        public boolean isCanSettingDefence(long lordId) {
            // 若设置过防守并且没有出局,则不能设置
            DefencePlayer defence = defencePlayerMap.get(lordId);
            return !(defence != null && defence.getState() == FortressFightConst.Fighter_No_Out);
        }

        /**
         * Method: attack
         *
         * @Description: 攻击要塞 @param player @param lordId @param form @param atkFortress @return void @throws
         */
        public boolean attack(Player attackPlayer, long lordId, com.game.pb.CommonPb.Form form,
                              GamePb4.AttackFortressRs.Builder atkFortress, ClientHandler handler) {
            boolean ret = false;
            int time = TimeHelper.getCurrentSecond();

            // 判断cd是否到了
            if (getMyCD(attackPlayer.account.getLordId()).getEndTime() > time) {
                handler.sendErrorMsgToPlayer(GameError.Fortress_Attack_CD);
                return false;
            }

            // 若为0则表示攻击npc，需要判断防守玩家是否存在
            Form attackForm = PbHelper.createForm(form);
            //战术验证
            if (!attackForm.getTactics().isEmpty()) {
                if (!tacticsService.checkUseTactics(attackPlayer, attackForm)) {
                    handler.sendErrorMsgToPlayer(GameError.USE_TACTICS_ERROR);
                    return false;
                }
            }

            StaticHero staticHero = null;
            int heroId = 0;
            AwakenHero awakenHero = null;
            Hero hero = null;
            if (attackForm.getAwakenHero() != null) {// 使用觉醒将领
                awakenHero = attackPlayer.awakenHeros.get(attackForm.getAwakenHero().getKeyId());
                if (awakenHero == null || awakenHero.isUsed()) {
                    handler.sendErrorMsgToPlayer(GameError.NO_HERO);
                    return false;
                }
                attackForm.setAwakenHero(awakenHero.clone());
                heroId = awakenHero.getHeroId();
            } else if (attackForm.getCommander() > 0) {
                hero = attackPlayer.heros.get(attackForm.getCommander());
                if (hero == null || hero.getCount() <= 0) {
                    handler.sendErrorMsgToPlayer(GameError.NO_HERO);
                    return false;
                }
                heroId = hero.getHeroId();
            }

            if (heroId != 0) {
                staticHero = staticHeroDataMgr.getStaticHero(heroId);
                if (staticHero == null) {
                    handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
                    return false;
                }

                if (staticHero.getType() != 2) {
                    handler.sendErrorMsgToPlayer(GameError.NOT_HERO);
                    return false;
                }
            }
            Fighter attacker = null;
            Fighter defencer = null;
            int result = 0;
            if (lordId == 0) {
                if (defencePlayerMap.size() == 0) {
                    // 攻击npc
                    // 获取可攻击的npc
                    if (defenceNpcList.size() > 0) {
                        DefenceNPC defenceNpc = defenceNpcList.get(0);

                        attacker = fightService.createFortressFighter(attackPlayer, attackForm, AttackType.ACK_OTHER);
                        defencer = fightService.createFighter(defenceNpc, AttackType.ACK_OTHER);

                        result = atkNPC(attackPlayer, atkFortress, time, attackForm, attacker, defencer, defenceNpc);

                        ret = true;
                    } else {
                        // 要塞战打完
                        // 释放所有的防守方
                        endFortress(false);

                        handler.sendErrorMsgToPlayer(GameError.Fortress_State_Is_Not_Right);
                        return false;
                    }
                } else {
                    // 攻击玩家
                    DefencePlayer defence = getFristDencePlayer();
                    if (defence == null || defence.getState() == FortressFightConst.Fighter_Out) {
                        handler.sendErrorMsgToPlayer(GameError.Fortress_DefencePalyer_IS_NOT_EXIST_OR_BE_OUT);
                        return false;
                    }

                    attacker = fightService.createFortressFighter(attackPlayer, attackForm, 3);
                    defencer = fightService.createFortressFighter(defence.getPlayer(), defence.getInstForm(), 3);

                    result = atkPlayer(attackPlayer, atkFortress, time, attackForm, attacker, defencer, defence);

                    if (result == 1) {
                        // 发系统公告
                        chatService.sendWorldChat(chatService.createSysChat(SysChatId.Fortress_Defence_Fail, attackPlayer.lord.getNick(),
                                defence.getPlayer().lord.getNick()));
                    }

                    ret = true;

                }
            } else {
                // 攻击玩家
                DefencePlayer defence = defencePlayerMap.get(lordId);
                if (defence == null || defence.getState() == FortressFightConst.Fighter_Out) {
                    handler.sendErrorMsgToPlayer(GameError.Fortress_DefencePalyer_IS_NOT_EXIST_OR_BE_OUT);
                    return false;
                }

                attacker = fightService.createFortressFighter(attackPlayer, attackForm, 3);
                defencer = fightService.createFortressFighter(defence.getPlayer(), defence.getInstForm(), 3);

                result = atkPlayer(attackPlayer, atkFortress, time, attackForm, attacker, defencer, defence);

                if (result == 1) {
                    // 发系统公告
                    chatService.sendWorldChat(chatService.createSysChat(SysChatId.Fortress_Defence_Fail, attackPlayer.lord.getNick(),
                            defence.getPlayer().lord.getNick()));
                }

                ret = true;
            }

            // 设置攻击方cd
            MyCD attackMyCD = getMyCD(attackPlayer.account.getLordId());
            // 若攻击方赢了，cd时间为30s
            attackMyCD.setBeginTime(TimeHelper.getCurrentSecond());
            int coldTime = 0;
            if (result == 1) {
                coldTime = FortressFightConst.Attack_Vector_CD;
            } else {
                coldTime = FortressFightConst.Fail_CD;
            }
            attackMyCD.setEndTime(attackMyCD.getBeginTime() + coldTime);

            atkFortress.setColdTime(coldTime);

            // 判断要塞战是否结束
            if (defenceNpcList.size() == 0) {
                endFortress(false);
            }

            return ret;
        }

        /**
         * Method: atkPlayer 要塞战斗逻辑 玩家防守
         *
         * @param attackPlayer
         * @param atkFortress
         * @param time
         * @param attackForm
         * @param attacker
         * @param defencer
         * @param defence
         * @return @return int @throws
         */
        private int atkPlayer(Player attackPlayer, GamePb4.AttackFortressRs.Builder atkFortress, int time, Form attackForm,
                              Fighter attacker, Fighter defencer, DefencePlayer defence) {
            int result;
            FightLogic fightLogic = new FightLogic(attacker, defencer, FirstActType.FISRT_VALUE_2, true);
            fightLogic.packForm(attackForm, defence.getInstForm());
            fightLogic.fight();

            CommonPb.Record record = fightLogic.generateRecord();
            subForceToForm(defencer, defence.getInstForm());

            result = fightLogic.getWinState();

            // 计算守方损失并扣除坦克
            Map<Integer, Integer> defenceSufferTank = calDefenceSuffer(defence.getForm(), defencer, defence.getPlayer());
            // 计算攻方损失并扣除坦克
            Map<Integer, Integer> attackSufferTank = calAttackSuffer(attackForm, attacker, attackPlayer);

            // 攻击方tank数量
            Set<Integer> tankIdSet = attackSufferTank.keySet();
            for (Integer tankId : tankIdSet) {
                atkFortress.addTank(PbHelper.createTankPb(attackPlayer.tanks.get(tankId)));
            }

            boolean isVectory = false;
            if (result == 1) {// 攻方胜利
                isVectory = true;

                // 设置防守方状态为出局，并移除
                fightOut(defence);
                defencePlayerMap.remove(defence.getPlayer().account.getLordId());
                // 设置防守方cd
                MyCD defenceMyCD = getMyCD(defence.getPlayer().account.getLordId());
                defenceMyCD.setBeginTime(time);
                defenceMyCD.setEndTime(time + FortressFightConst.Fail_CD);
            } else {
                isVectory = false;
            }

            // 战功计算 0-攻方战功,1-防守方战功
            long[] mplts = calcMilitaryExploit(attackSufferTank, defenceSufferTank);
            playerDataManager.addAward(attackPlayer, AwardType.MILITARY_EXPLOIT, 1, mplts[0], AwardFrom.FIGHT_TANK_DISAPPER_AND_DESTROY);
            playerDataManager.addAward(defence.getPlayer(), AwardType.MILITARY_EXPLOIT, 1, mplts[1],
                    AwardFrom.FIGHT_TANK_DISAPPER_AND_DESTROY);
            MyFortressFightData myAtk = getMyFortressFightData(attackPlayer.lord.getLordId());
            MyFortressFightData myDef = getMyFortressFightData(defence.getPlayer().lord.getLordId());
            myAtk.addMplt(mplts[0]);
            myDef.addMplt(mplts[1]);
            LogUtil.war(String.format("atk nick :%s, myAtk got mplt :%d, total :%d, hashcode :%d", attackPlayer.lord.getNick(), mplts[0],
                    myAtk.getMplt(), myAtk.hashCode()));
            LogUtil.war(String.format("def nick :%s, myDef got mplt :%d, total :%d, hashcode :%d", defence.getPlayer().lord.getNick(),
                    mplts[1], myDef.getMplt(), myDef.hashCode()));

            CommonPb.RptAtkFortress rptAtk = PbHelper.createRptAtkFortressPb(reportKey++, isVectory, fightLogic.attackerIsFirst(),
                    PbHelper.createRptMan(attackPlayer, attackForm.getCommander(), mplts[0], attacker.firstValue),
                    PbHelper.createRptMan(defence.getPlayer(), defence.getInstForm().getCommander(), mplts[1], defencer.firstValue),
                    record);

            atkFortress.setRptAtkFortress(rptAtk);

            statistics(true, attackPlayer, result, attackSufferTank, defenceSufferTank, false);
            statistics(false, defence.getPlayer(), result, attackSufferTank, defenceSufferTank, false);

            int hp2 = defence.calcHp();

            String partyName1 = partyDataManager.getPartyNameByLordId(attackPlayer.account.getLordId());
            String partyName2 = partyDataManager.getPartyNameByLordId(defence.getPlayer().account.getLordId());

            CommonPb.FortressRecord fRecord = PbHelper.createFortressRecordPb(rptAtk.getReportKey(), attackPlayer, partyName1, defence,
                    partyName2, 100, hp2, time, result);
            atkFortress.setRecord(fRecord);

            // 存战斗记录和战报信息
            saveRecordAndReport(attackPlayer, defence, rptAtk, fRecord);

            // 给要塞军团统计排序
            warDataManager.sortPartyStatisticsMap();

            return result;
        }

        /**
         * Method: atkNPC 要塞战斗逻辑 NPC防守
         *
         * @param attackPlayer
         * @param atkFortress
         * @param time
         * @param attackForm
         * @param attacker
         * @param defencer
         * @param defenceNpc
         * @return @return int @throws
         */
        private int atkNPC(Player attackPlayer, GamePb4.AttackFortressRs.Builder atkFortress, int time, Form attackForm, Fighter attacker,
                           Fighter defencer, DefenceNPC defenceNpc) {
            int result;
            FightLogic fightLogic = new FightLogic(attacker, defencer, FirstActType.FISRT_VALUE_2, true);
            fightLogic.packForm(attackForm, defenceNpc.getInstForm());
            fightLogic.fight();

            CommonPb.Record record = fightLogic.generateRecord();
            subForceToForm(defencer, defenceNpc.getInstForm());

            result = fightLogic.getWinState();

            // 计算npc损失的坦克
            Map<Integer, Integer> npcSufferTank = calNpcSuffer(defencer);

            // 计算攻方损失并扣除坦克
            Map<Integer, Integer> attackSufferTank = calAttackSuffer(attackForm, attacker, attackPlayer);

            // 攻击方tank数量
            Set<Integer> tankIdSet = attackSufferTank.keySet();
            for (Integer tankId : tankIdSet) {
                atkFortress.addTank(PbHelper.createTankPb(attackPlayer.tanks.get(tankId)));
            }

            boolean isVectory = false;
            if (result == 1) {
                // 攻方胜利
                isVectory = true;

                // 设置防守方状态为出局，并移除
                fightOut(defenceNpc);
            } else {
                isVectory = false;
            }

            // 战功计算 0-攻方战功,1-防守方战功
            long[] mplts = null;
            if (staticFunctionPlanDataMgr.isMilitaryRankOpen()) {
                mplts = calcMilitaryExploit(attackSufferTank, null);
                playerDataManager.addAward(attackPlayer, AwardType.MILITARY_EXPLOIT, 1, mplts[0],
                        AwardFrom.FIGHT_TANK_DISAPPER_AND_DESTROY);
                MyFortressFightData myAtk = getMyFortressFightData(attackPlayer.lord.getLordId());
                myAtk.addMplt(mplts[0]);
                LogUtil.war(String.format("atk nick :%s, myAtk got mplt :%d, total :%d, hascode :%d", attackPlayer.lord.getNick(), mplts[0],
                        myAtk.getMplt(), myAtk.hashCode()));
            }

            CommonPb.RptAtkFortress rptAtk = PbHelper.createRptAtkFortressPb(reportKey++, isVectory, fightLogic.attackerIsFirst(),
                    PbHelper.createRptMan(attackPlayer, attackForm.getCommander(), mplts != null ? mplts[0] : null, attacker.firstValue),
                    PbHelper.createRptMan(defenceNpc, defenceNpc.getInstForm().getCommander(), mplts != null ? mplts[1] : null), record);

            atkFortress.setRptAtkFortress(rptAtk);

            // 计算积分
            statistics(true, attackPlayer, result, attackSufferTank, npcSufferTank, true);

            int hp2 = defenceNpc.calcHp();

            String partyName1 = partyDataManager.getPartyNameByLordId(attackPlayer.account.getLordId());
            String partyName2 = FortressFightConst.NPC_PartyName;
            String name2 = FortressFightConst.NPC_NAME;

            CommonPb.FortressRecord fRecord = PbHelper.createFortressRecordPb(rptAtk.getReportKey(), attackPlayer, partyName1, defenceNpc,
                    partyName2, name2, 100, hp2, time, result);
            atkFortress.setRecord(fRecord);

            // 存战斗记录和战报信息
            saveRecordAndReport(attackPlayer, defenceNpc, rptAtk, fRecord);

            // 给要塞军团统计排序
            warDataManager.sortPartyStatisticsMap();

            return result;
        }

        /**
         * 记录和战报
         *
         * @param attackPlayer
         * @param defenceNpc
         * @param rptAtk
         * @param fRecord
         */
        private void saveRecordAndReport(Player attackPlayer, Defence defence, CommonPb.RptAtkFortress rptAtk,
                                         CommonPb.FortressRecord fRecord) {
            // 存储记录和战报
            warDataManager.addFortressRecord(fRecord);
            warDataManager.addRptRtkFortress(rptAtk);

            if (defence instanceof DefencePlayer) {
                DefencePlayer dp = (DefencePlayer) defence;
                MyFortressFightData my = getMyFortressFightData(dp.getPlayer().account.getLordId());
                my.addReportKey(fRecord.getReportKey());
            }

            MyFortressFightData my = getMyFortressFightData(attackPlayer.account.getLordId());
            my.addReportKey(fRecord.getReportKey());
        }

        /**
         * Method: calJiFen
         *
         * @param attackPlayer
         * @param result
         * @param totalSufferTank
         * @return void @throws
         * @Description: 计算积分 获得积分=坦克编号*积分*失败/胜利系数*进攻/防守系数+NPC积分 失败系数=0.5 胜利系数=1 <br>
         * 进攻系数=1 防守系数=0.5 <br>
         * NPC积分=20 分 <br>
         */
        private void statistics(boolean isAttack, Player player, int result, Map<Integer, Integer> attackSufferTank,
                                Map<Integer, Integer> defenceSufferTank, boolean isAttackNPC) {
            float shengLiXiShu = 1f;
            float jiGongXiShu = 1f;
            int jifen = 0;

            Map<Integer, Integer> totalSufferTank = getTotalSufferTank(attackSufferTank, defenceSufferTank);

            // 进攻方
            if (isAttack) {
                jiGongXiShu = 1f;
                if (result == 1) {
                    shengLiXiShu = 1f;
                } else {
                    shengLiXiShu = 0.5f;
                }
            } else {
                jiGongXiShu = 0.5f;
                if (result == 1) {
                    shengLiXiShu = 0.5f;
                } else {
                    shengLiXiShu = 1f;
                }
            }
            Set<Integer> ketSet = totalSufferTank.keySet();
            for (Integer key : ketSet) {
                int count = totalSufferTank.get(key);

                int num = (count / 1000) + (((count % 1000) >= 100) ? 1 : 0);

                jifen += (int) (staticFortressDataMgr.getFortressSufferJifen(key) * num * shengLiXiShu * jiGongXiShu);
            }

            if (isAttackNPC) {
                jifen += 20;
            }

            // 进修积分加成
            jifen = attrAddJiFen(player.account.getLordId(), jifen);

            MyFortressFightData data = getMyFortressFightData(player.account.getLordId());
            // 加积分
            data.setJifen(data.getJifen() + jifen);
            // 加战斗次数
            data.setFightNum(data.getFightNum() + 1);
            // 加胜利次数
            if ((isAttack && result == 1) || (!isAttack && result == 2)) {
                data.setWinNum(data.getWinNum() + 1);
            }
            // 加击败坦克
            if (isAttack) {
                addDestroyTank(data.getDestoryTankMap(), defenceSufferTank);
            } else {
                addDestroyTank(data.getDestoryTankMap(), attackSufferTank);
            }

            // 获取军团id
            int partyId = partyDataManager.getMemberById(player.account.getLordId()).getPartyId();

            MyPartyStatistics ms = warDataManager.getMyPartyStatistics(partyId);
            // 加积分
            ms.setJifen(ms.getJifen() + jifen);
            // 加战斗次数
            ms.setFightNum(ms.getFightNum() + 1);
            // 加胜利次数
            if ((isAttack && result == 1) || (!isAttack && result == 2)) {
                ms.setWinNum(ms.getWinNum() + 1);
            }

            // 加击败坦克
            if (isAttack) {
                addDestroyTank(ms.getDestoryTankMap(), defenceSufferTank);
            } else {
                addDestroyTank(ms.getDestoryTankMap(), attackSufferTank);
            }

            // 个人积分排名
            warDataManager.joinMyFortressDataRankMap(data);
            warDataManager.joinFortressPartyInnerRankMap(data, true);
        }

        /**
         * 进修积分加成
         *
         * @param jifen
         * @return
         */
        private int attrAddJiFen(long lordId, int jifen) {
            MyFortressAttr my = getMyFortressAttrMap(lordId).get(FortressFightConst.Attr_Fen);
            if (my.getLevel() > 0) {
                List<List<Integer>> list = staticFortressDataMgr.getStaticFortressAttr(my.getId(), my.getLevel()).getEffect();
                int probability = list.get(0).get(1);

                jifen += (jifen * probability / 10000);
            }
            return jifen;
        }

        private void addDestroyTank(Map<Integer, SufferTank> baseMap, Map<Integer, Integer> addMap) {
            Set<Integer> keySet = addMap.keySet();
            for (Integer key : keySet) {
                int num = addMap.get(key);

                SufferTank st = baseMap.get(key);
                if (st == null) {
                    st = new SufferTank(key, num);
                    baseMap.put(key, st);
                } else {
                    st.setSufferCount(st.getSufferCount() + num);
                }
            }
        }

        /**
         * 损失的坦克总数
         *
         * @param attackSufferTank
         * @param defenceSufferTank
         * @return Map<Integer   ,   Integer>
         */
        private Map<Integer, Integer> getTotalSufferTank(Map<Integer, Integer> attackSufferTank, Map<Integer, Integer> defenceSufferTank) {
            Map<Integer, Integer> total = new HashMap<Integer, Integer>();

            Set<Integer> atkKeySet = attackSufferTank.keySet();
            for (Integer key : atkKeySet) {
                int num = attackSufferTank.get(key);

                Integer count = total.get(key);
                if (count == null) {
                    total.put(key, num);
                } else {
                    total.put(key, count + num);
                }
            }

            Set<Integer> defenceKeySet = defenceSufferTank.keySet();
            for (Integer key : defenceKeySet) {
                int num = defenceSufferTank.get(key);

                Integer count = total.get(key);
                if (count == null) {
                    total.put(key, num);
                } else {
                    total.put(key, count + num);
                }
            }

            return total;
        }

        /**
         * Method: calNpcSuffer NPC损失坦克总数
         *
         * @param totalSufferTank
         * @param defencer
         * @return void @throws
         */
        private Map<Integer, Integer> calNpcSuffer(Fighter defencer) {
            Map<Integer, Integer> sufferTank = new HashMap<Integer, Integer>();
            int length = defencer.forces.length;

            for (int i = 0; i < length; i++) {
                int tankId = defencer.forces[i].staticTank.getTankId();
                if (tankId == 0) {
                    continue;
                }
                int killCount = defencer.forces[i] == null ? 0 : defencer.forces[i].killed;

                Integer count = sufferTank.get(tankId);
                if (count == null) {
                    sufferTank.put(tankId, killCount);
                } else {
                    sufferTank.put(tankId, count + killCount);
                }
            }
            return sufferTank;
        }

        /**
         * Method: getFristDencePlayer
         *
         * @Description: 从有序的列表中获取第一个玩家 @return @return DefencePlayer @throws
         */
        private DefencePlayer getFristDencePlayer() {
            Iterator<DefencePlayer> its = defencePlayerMap.values().iterator();
            if (its.hasNext()) {
                return its.next();
            }
            return null;
        }

        /**
         * Method: endFortress
         *
         * @Description: 结束要塞战 时间到了结束还是击败 true 时间到了 false 击败
         */
        public void endFortress(boolean timeOverOrBeatOver) {
            // 设置要塞战为结束状态
            if (this.state != FortressFightConst.Fight_End && this.state < FortressFightConst.Fortress_End) {

                setState(FortressFightConst.Fight_End);

                if (timeOverOrBeatOver) {
                    whoWin = FortressFightConst.Win_Defence;

                    // 设置要塞主军团
                    setFortressKingPart(deFencePartyId);
                } else {
                    whoWin = FortressFightConst.Win_Attack;

                    // 获取积分最高的且不是防守军团的军团
                    int partyId = getTotalJiFenRankEptDefencePartyId();
                    setFortressKingPart(partyId);
                }

                // 释放所有防守方
                Iterator<DefencePlayer> its = defencePlayerMap.values().iterator();
                while (its.hasNext()) {
                    fightOut(its.next());
                    its.remove();
                }

                // 同步要塞战结束
                synFortressState(FortressFightConst.Fight_End);
            }
        }

        /**
         * 积分最高的非防守军团编号
         *
         * @return int
         */
        private int getTotalJiFenRankEptDefencePartyId() {
            Iterator<MyPartyStatistics> its = warDataManager.getPartyStatisticsMap().values().iterator();
            // int rank = 0;
            while (its.hasNext()) {
                MyPartyStatistics ms = its.next();
                // rank++;
                if (ms.getPartyId() == deFencePartyId) {
                    continue;
                }
                return ms.getPartyId();
            }

            return 0;
        }

        /**
         * 记录本次要塞战第一的军团
         *
         * @param partyId void
         */
        private void setFortressKingPart(int partyId) {
            globalDataManager.gameGlobal.setFortressPartyId(partyId);
        }

        /**
         * Method: calDefenceSuffer
         *
         * @Description: 计算防守方损失并扣除坦克 @param form @param defencer @param player @return void @throws
         */
        private Map<Integer, Integer> calDefenceSuffer(Form form, Fighter defencer, Player player) {
            Map<Integer, Integer> sufferTank = new HashMap<Integer, Integer>();

            MyFortressFightData my = getMyFortressFightData(player.account.getLordId());
            List<Army> armys = player.armys;
            Army army = null;
            for (Army i : armys) {
                if (i.getState() == ArmyState.FortessBattle) {
                    army = i;
                    break;
                }
            }

            int length = form.p.length;
            for (int i = 0; i < length; i++) {
                int tankId = form.p[i];
                if (tankId == 0) {
                    continue;
                }
                int killCount = defencer.forces[i] == null ? 0 : defencer.forces[i].killed;

                Integer count = sufferTank.get(tankId);
                if (count == null) {
                    sufferTank.put(tankId, killCount);
                } else {
                    sufferTank.put(tankId, count + killCount);
                }
            }

            Set<Integer> keySet = sufferTank.keySet();
            for (Integer tankId : keySet) {
                int count = sufferTank.get(tankId);

                int lastNum = 0;

                SufferTank st = my.getSufferTankMap().get(tankId);
                if (st == null) {
                    st = new SufferTank(tankId, count);
                    my.getSufferTankMap().put(tankId, st);
                } else {
                    lastNum = st.getSufferCount();
                    st.setSufferCount(st.getSufferCount() + count);
                }

                // 计算出原来需要消耗多少坦克
                int t1 = (lastNum / 1000) + (((lastNum % 1000) >= 100) ? 1 : 0);

                // 计算出最后需要消耗多少坦克
                int t2 = (st.getSufferCount() / 1000) + (((st.getSufferCount() % 1000) >= 100) ? 1 : 0);

                // LogHelper.WAR_LOGGER.trace("防守方---"+player.lord.getNick()+ "
                // tankId: "+tankId+",上次总记录损失坦克："+lastNum +" ,这次总记录损失坦克个数: "+
                // st.getSufferCount());

                // 差值就是要扣的坦克
                if (t2 - t1 > 0) {
                    Form armyForm = army.getForm();
                    int temp = (t2 - t1);
                    for (int i = 0; i < length; i++) {
                        if (tankId == form.p[i]) {
                            if (armyForm.c[i] >= temp) {
                                armyForm.c[i] = armyForm.c[i] - temp;
                                temp = 0;
                            } else {
                                temp = temp - armyForm.c[i];
                                armyForm.c[i] = 0;
                            }

                            if (temp == 0) {
                                break;
                            }
                        }
                    }

                    my.setSufferTankCountForevel(my.getSufferTankCountForevel() + (t2 - t1));
                }
            }
            playerDataManager.updTask(player, TaskType.COND_FORTRESS_BATTLE, 1);// 刷新要塞战任务进度
            playerEventService.calcStrongestFormAndFight(player);
            army = null;
            return sufferTank;
        }

        /**
         * Method: calAttackSuffer
         *
         * @Description: 计算损失并扣除坦克 @param attacker @return void @throws
         */
        private Map<Integer, Integer> calAttackSuffer(Form attackForm, Fighter attacker, Player player) {
            // 临时记录损失的坦克
            Map<Integer, Integer> sufferTank = new HashMap<Integer, Integer>();

            MyFortressFightData my = getMyFortressFightData(player.account.getLordId());

            Map<Integer, Tank> tanks = player.tanks;

            int length = attackForm.p.length;
            for (int i = 0; i < length; i++) {
                int tankId = attackForm.p[i];
                if (tankId == 0) {
                    continue;
                }
                int killCount = attacker.forces[i] == null ? 0 : attacker.forces[i].killed;

                Integer count = sufferTank.get(tankId);
                if (count == null) {
                    sufferTank.put(tankId, killCount);
                } else {
                    sufferTank.put(tankId, count + killCount);
                }
            }

            Set<Integer> keySet = sufferTank.keySet();
            for (Integer tankId : keySet) {
                int count = sufferTank.get(tankId);

                int lastNum = 0;

                SufferTank st = my.getSufferTankMap().get(tankId);
                if (st == null) {
                    st = new SufferTank(tankId, count);
                    my.getSufferTankMap().put(tankId, st);
                } else {
                    lastNum = st.getSufferCount();
                    st.setSufferCount(st.getSufferCount() + count);
                }

                // 计算出原来需要消耗多少坦克
                int t1 = (lastNum / 1000) + (((lastNum % 1000) >= 100) ? 1 : 0);

                // 计算出最后需要消耗多少坦克
                int t2 = (st.getSufferCount() / 1000) + (((st.getSufferCount() % 1000) >= 100) ? 1 : 0);

                // LogHelper.WAR_LOGGER.trace("进攻方---"+player.lord.getNick()+ "
                // tankId: "+tankId+",上次总记录损失坦克："+lastNum +" ,这次总记录损失坦克个数: "+
                // st.getSufferCount());

                // 差值就是要扣的坦克
                if (t2 - t1 > 0) {
                    Tank tank = tanks.get(tankId);
                    int kill = t2 - t1;
                    tank.setCount(tank.getCount() - kill);
                    LogLordHelper.tank(AwardFrom.FORTRESS_ATTACK, player.account, player.lord, tank.getTankId(), tank.getCount(), -kill,
                            -kill, 0);
                    my.setSufferTankCountForevel(my.getSufferTankCountForevel() + kill);

                    // LogHelper.WAR_LOGGER.trace(player.lord.getNick() + "
                    // tankId: " + tankId + "实际减坦克" + (t2 - t1)
                    // + "剩余tank" + tank.getCount());
                }
            }

            playerDataManager.updTask(player, TaskType.COND_FORTRESS_BATTLE, 1);// 刷新军事演习任务进度
            playerEventService.calcStrongestFormAndFight(player);
            return sufferTank;
        }

        /**
         * 出局 Method: fightOut
         *
         * @param defence
         * @return void @throws
         */
        private void fightOut(Defence defence) {
            defence.setState(FortressFightConst.Fighter_Out);
            if (defence instanceof DefenceNPC) {
                DefenceNPC d = (DefenceNPC) defence;
                defenceNpcList.remove(d);
                outNpcList.add(d);

                // 同步要塞耐久度到所有参赛军团
                synFortressSelfToAllFortressParty();
            } else if (defence instanceof DefencePlayer) {
                DefencePlayer d = (DefencePlayer) defence;
                // 释放防守阵容
                // 从出征的队伍中释放
                List<Army> armys = d.getPlayer().armys;
                Army army = null;
                for (Army i : armys) {
                    if (i.getState() == ArmyState.FortessBattle) {
                        army = i;
                        break;
                    }
                }

                Form form = army.getForm();
                for (int i = 0; i < form.p.length; i++) {
                    playerDataManager.addTank(d.getPlayer(), form.p[i], form.c[i], AwardFrom.FORTRESS_FIGHT_OUT);
                }
                if (form.getAwakenHero() != null) {
                    AwakenHero awakenHero = d.getPlayer().awakenHeros.get(form.getAwakenHero().getKeyId());
                    awakenHero.setUsed(false);
                    LogLordHelper.awakenHero(AwardFrom.FORTRESS_FIGHT_OUT, d.getPlayer().account, d.getPlayer().lord, awakenHero, 0);
                } else if (form.getCommander() > 0) {
                    playerDataManager.addHero(d.getPlayer(), form.getCommander(), 1, AwardFrom.FORTRESS_FIGHT_OUT);
                }

                //取消战术
                if (!form.getTactics().isEmpty()) {
                    tacticsService.cancelUseTactics(d.getPlayer(), form.getTactics());
                }

                armys.remove(army);

                playerDataManager.synArmyToPlayer(d.getPlayer(), new ArmyStatu(d.getPlayer().roleId, army.getKeyId(), 3));
            }
        }
    }

    /**
     * 计算军功
     *
     * @param attackSufferTank
     * @param defenceSufferTank
     * @return
     */
    private long[] calcMilitaryExploit(Map<Integer, Integer> attackSufferTank, Map<Integer, Integer> defenceSufferTank) {
        Map<Integer, RptTank> attackRptMap = null;
        Map<Integer, RptTank> defenceRptMap = null;
        if (attackSufferTank != null && !attackSufferTank.isEmpty()) {
            attackRptMap = new HashMap<>();
            for (Map.Entry<Integer, Integer> entry : attackSufferTank.entrySet()) {
                int tankId = entry.getKey();
                RptTank rptTank = attackRptMap.get(tankId);
                if (rptTank == null)
                    attackRptMap.put(tankId, rptTank = new RptTank(tankId, 0));
                rptTank.setCount(rptTank.getCount() + entry.getValue());
            }
        }
        if (defenceSufferTank != null && !defenceSufferTank.isEmpty()) {
            defenceRptMap = new HashMap<>();
            for (Map.Entry<Integer, Integer> entry : defenceSufferTank.entrySet()) {
                int tankId = entry.getKey();
                RptTank rptTank = defenceRptMap.get(tankId);
                if (rptTank == null)
                    defenceRptMap.put(tankId, rptTank = new RptTank(tankId, 0));
                rptTank.setCount(rptTank.getCount() + entry.getValue());
            }
        }
        return playerDataManager.calcMilitaryExploit(attackRptMap, defenceRptMap);
    }
}
