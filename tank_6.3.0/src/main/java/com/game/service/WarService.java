/**
 * @Title: WarService.java
 * @Package com.game.service
 * @Description:
 * @author ZhangJun
 * @date 2015年12月14日 下午5:05:40
 * @version V1.0
 */
package com.game.service;

import com.game.actor.role.PlayerEventService;
import com.game.constant.*;
import com.game.dataMgr.StaticFunctionPlanDataMgr;
import com.game.dataMgr.StaticHeroDataMgr;
import com.game.dataMgr.StaticTankDataMgr;
import com.game.dataMgr.StaticWarAwardDataMgr;
import com.game.domain.Member;
import com.game.domain.PartyData;
import com.game.domain.Player;
import com.game.domain.p.*;
import com.game.domain.s.StaticHero;
import com.game.fight.FightLogic;
import com.game.fight.domain.Fighter;
import com.game.fight.domain.Force;
import com.game.manager.GlobalDataManager;
import com.game.manager.PartyDataManager;
import com.game.manager.PlayerDataManager;
import com.game.manager.WarDataManager;
import com.game.message.handler.ClientHandler;
import com.game.pb.CommonPb;
import com.game.pb.CommonPb.RptAtkWar;
import com.game.pb.CommonPb.WarRecord;
import com.game.pb.CommonPb.WarRecordPerson;
import com.game.pb.GamePb3.*;
import com.game.pb.GamePb4.GetThisWeekMyWarJiFenRankRs;
import com.game.util.LogLordHelper;
import com.game.util.LogUtil;
import com.game.util.PbHelper;
import com.game.util.TimeHelper;
import com.game.warFight.domain.FightPair;
import com.game.warFight.domain.WarMember;
import com.game.warFight.domain.WarParty;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.*;

/**
 * @ClassName: WarService
 * @Description: 百团混战相关
 * @author ZhangJun
 * @date 2015年12月14日 下午5:05:40
 *
 */
@Service
public class WarService {
    @Autowired
    private PlayerDataManager playerDataManager;

    @Autowired
    private StaticHeroDataMgr staticHeroDataMgr;

    @Autowired
    private StaticTankDataMgr staticTankDataMgr;

    @Autowired
    private PartyDataManager partyDataManager;

    @Autowired
    private WarDataManager warDataManager;

    @Autowired
    private GlobalDataManager globalDataManager;

    @Autowired
    private StaticWarAwardDataMgr staticWarAwardDataMgr;

    @Autowired
    private FightService fightService;

    @Autowired
    private FortressWarService fortressWarService;

    @Autowired
    private ChatService chatService;

    @Autowired
    private PlayerEventService playerEventService;
    @Autowired
    private StaticFunctionPlanDataMgr staticFunctionPlanDataMgr;
    @Autowired
    private ActivityNewService activityNewService;
    @Autowired
    private TacticsService tacticsService;
    /**
     *
     * Method: warReg
     *
     * @Description: 百团混战报名 @param handler @return void @throws
     */
    public void warReg(WarRegRq req, ClientHandler handler) {
        // if (!inRegTime()) {
        // handler.sendErrorMsgToPlayer(GameError.OUT_REG_TIME);
        // return;
        // }

        // if (!TimeHelper.inWarRegTime()) {
        // handler.sendErrorMsgToPlayer(GameError.OUT_REG_TIME);
        // return;
        // }

        if (!warDataManager.inRegTime()) {
            handler.sendErrorMsgToPlayer(GameError.OUT_REG_TIME);
            return;
        }

        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null) {
            // LogHelper.ERROR_LOGGER.error("attack
            // nul!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! " + handler.getRoleId());
            LogUtil.error("attack null!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! " + handler.getRoleId());
            handler.sendErrorMsgToPlayer(GameError.SERVER_EXCEPTION);
            return;
        }

        Member member = partyDataManager.getMemberById(player.roleId);
        // int partyId = partyDataManager.getPartyId(player.roleId);
        if (member == null || member.getPartyId() == 0) {
            handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
            return;
        }

        int enterTime = member.getEnterTime();
        if (enterTime == TimeHelper.getCurrentDay()) {
            handler.sendErrorMsgToPlayer(GameError.IN_PARTY_TIME);
            return;
        }

        for (Army army : player.armys) {
            if (army.getState() == ArmyState.WAR) {
                handler.sendErrorMsgToPlayer(GameError.ALREADY_REG);
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
        if (!playerDataManager.checkAndSubTank(player, attackForm, maxTankCount, AwardFrom.WAR_REG)) {
            handler.sendErrorMsgToPlayer(GameError.TANK_COUNT);
            return;
        }

        if (hero != null) {
            playerDataManager.addHero(player, hero.getHeroId(), -1, AwardFrom.WAR_REG);
        }

        if (awakenHero != null) {
            awakenHero.setUsed(true);
            LogLordHelper.awakenHero(AwardFrom.WAR_REG, player.account, player.lord, awakenHero, 0);
        }


        //战术
        if( !attackForm.getTactics().isEmpty()){
            tacticsService.useTactics(player,attackForm.getTactics());
        }


        long fight = fightService.calcFormFight(player, attackForm);

        int marchTime = 60 * 60;
        int now = TimeHelper.getCurrentSecond();
        Army army = new Army(player.maxKey(), 0, ArmyState.WAR, attackForm, marchTime, now + marchTime, playerDataManager.isRuins(player));
        player.armys.add(army);

        WarMember warMember = warDataManager.createWarMember(player, member, attackForm, fight);
        playerDataManager.updTask(player, TaskType.COND_WAR_PARTY, 1);// 百团大战报名任务进度刷新
        warDataManager.warReg(warMember);

        activityNewService.refreshState(warMember.getPlayer(),3,1);
        WarRegRs.Builder builder = WarRegRs.newBuilder();
        builder.setFight(fight);
        builder.setArmy(PbHelper.createArmyPb(army));
        handler.sendMsgToPlayer(WarRegRs.ext, builder.build());
    }

    /**
     * 
    * 召回部队
    * @param player
    * @param army  
    * void
     */
    private void retreatEnd(Player player, Army army) {
        // 部队返回
        int[] p = army.getForm().p;
        int[] c = army.getForm().c;
        for (int i = 0; i < p.length; i++) {
            if (p[i] > 0 && c[i] > 0) {
                playerDataManager.addTank(player, p[i], c[i], AwardFrom.RETREAT_END);
            }
        }
        // 将领返回
        if (army.getForm().getAwakenHero() != null) {
            AwakenHero awakenHero = player.awakenHeros.get(army.getForm().getAwakenHero().getKeyId());
            awakenHero.setUsed(false);
            LogLordHelper.awakenHero(AwardFrom.RETREAT_END, player.account, player.lord, awakenHero, 0);
        } else {
            int heroId = army.getForm().getCommander();
            if (heroId > 0) {
                playerDataManager.addHero(player, heroId, 1, AwardFrom.RETREAT_END);
            }
        }

        //取消战术
        if( !army.getForm().getTactics().isEmpty()){
            tacticsService.cancelUseTactics(player,army.getForm().getTactics());
        }

    }

    /**
     *
     * Method: warCancel
     *
     * @Description: 百团混战取消报名 @param handler @return void @throws
     */
    public void warCancel(ClientHandler handler) {
        // if (!TimeHelper.inWarRegTime()) {
        // handler.sendErrorMsgToPlayer(GameError.OUT_REG_TIME);
        // return;
        // }

        if (!warDataManager.inRegTime()) {
            handler.sendErrorMsgToPlayer(GameError.OUT_REG_TIME);
            return;
        }

        long roleId = handler.getRoleId();
        int partyId = partyDataManager.getPartyId(roleId);
        if (partyId == 0) {
            handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
            return;
        }

        Player player = playerDataManager.getPlayer(handler.getRoleId());
        Iterator<Army> it = player.armys.iterator();
        while (it.hasNext()) {
            Army army = (Army) it.next();
            if (army.getState() == ArmyState.WAR) {
                retreatEnd(player, army);
                warDataManager.warUnReg(partyId, roleId);
                it.remove();
                WarCancelRs.Builder builder = WarCancelRs.newBuilder();
                handler.sendMsgToPlayer(WarCancelRs.ext, builder.build());

                return;
            }
        }

        handler.sendErrorMsgToPlayer(GameError.NO_ARMY);
    }

    /**
     *
     * Method: warMembers
     *
     * @Description: 获取军团成员报名列表 @param handler @return void @throws
     */
    public void warMembers(ClientHandler handler) {
        long roleId = handler.getRoleId();
        int partyId = partyDataManager.getPartyId(roleId);
        if (partyId == 0) {
            handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
            return;
        }

        WarMembersRs.Builder builder = WarMembersRs.newBuilder();
        WarParty warParty = warDataManager.getWarParty(partyId);
        if (warParty != null) {
            Iterator<WarMember> it = warParty.getMembers().values().iterator();
            while (it.hasNext()) {
                WarMember warMember = (WarMember) it.next();
                builder.addMemberReg(PbHelper.createWarRegPb(warMember));
            }
        }

        handler.sendMsgToPlayer(WarMembersRs.ext, builder.build());
    }

    /**
     *
     * Method: warParties
     *
     * @Description: 获取参战军团列表 @param handler @return void @throws
     */
    public void warParties(WarPartiesRq req, ClientHandler handler) {
        long roleId = handler.getRoleId();
        int partyId = partyDataManager.getPartyId(roleId);
        if (partyId == 0) {
            handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
            return;
        }

        int page = req.getPage();
        int begin = page * 20;
        int end = begin + 20;

        WarPartiesRs.Builder builder = WarPartiesRs.newBuilder();
        Map<Integer, Long> parties = warDataManager.getPartyFightMap();
        int index = 0;
        for (Map.Entry<Integer, Long> entry : parties.entrySet()) {
            if (index >= end) {
                break;
            }

            if (index >= begin) {
                // PartyData partyData =
                // partyDataManager.getParty(entry.getKey());
                WarParty warParty = warDataManager.getWarParty(entry.getKey());
                if (warParty != null) {
                    PartyData partyData = warParty.getPartyData();
                    if (partyData == null) {
                        handler.sendErrorMsgToPlayer(GameError.SERVER_EXCEPTION);
                        return;
                    }

                    // LogHelper.ERROR_LOGGER.error("partyName:" +
                    // partyData.getPartyName());
                    // LogHelper.ERROR_LOGGER.error("regLv:" +
                    // partyData.getRegLv());
                    // LogHelper.ERROR_LOGGER.error("count:" +
                    // warParty.getMembers().size());
                    // LogHelper.ERROR_LOGGER.error("fight:" +
                    // entry.getValue());

                    builder.addPartyReg(PbHelper.createPartyRegPb(partyData.getPartyName(), partyData.getRegLv(),
                            warParty.getMembers().size(), entry.getValue()));
                }
            }
            index++;
        }

        builder.setTotal(parties.size());
        handler.sendMsgToPlayer(WarPartiesRs.ext, builder.build());
    }

    /**
     *
     * Method: winAward
     *
     * @Description: 百团混战领取个人连胜排行奖励 @param handler @return void @throws
     */
    public void winAward(ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());

        int partyId = partyDataManager.getPartyId(player.roleId);
        if (partyId == 0) {
            handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
            return;
        }

        if (globalDataManager.gameGlobal.getWarState() != WarState.WAR_END) {
            handler.sendErrorMsgToPlayer(GameError.WAR_PROCESS);
            return;
        }

        if (warDataManager.hadGetWinRankAward(player.roleId)) {
            handler.sendErrorMsgToPlayer(GameError.ALREADY_GET_BOX);
            return;
        }

        int rank = warDataManager.getWinRank(player.roleId);
        if (rank < 1 || rank > 10) {
            handler.sendErrorMsgToPlayer(GameError.NOT_ON_RANK);
            return;
        }

        warDataManager.setWinRankAward(player.roleId);

        WarWinAwardRs.Builder builder = WarWinAwardRs.newBuilder();

        List<List<Integer>> awards = staticWarAwardDataMgr.getWinAward(rank);
        builder.addAllAward(playerDataManager.addAwardsBackPb(player, awards, AwardFrom.WAR_WIN));
        handler.sendMsgToPlayer(WarWinAwardRs.ext, builder.build());
    }

    /**
     *
     * Method: warReport
     *
     * @Description: 获取百团混战战况 @param req @param handler @return void @throws
     */
    public void warReport(WarReportRq req, ClientHandler handler) {
        long roleId = handler.getRoleId();
        Member member = partyDataManager.getMemberById(roleId);
        if (member == null || member.getPartyId() == 0) {
            handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
            return;
        }

        int type = req.getType();
        WarReportRs.Builder builder = WarReportRs.newBuilder();

        if (type == 1) {// 全服战况
            LinkedList<WarRecord> list = globalDataManager.getWarRecord();
            if (list != null) {
                builder.addAllRecord(list);
            }
        } else if (type == 2) {// 军团战况
            LinkedList<WarRecord> list = warDataManager.getPartyWarRecord(member.getPartyId());
            if (list != null) {
                builder.addAllRecord(list);
            }
        } else if (type == 3) {// 个人战况
            // Player player = playerDataManager.getPlayer(roleId);
            LinkedList<WarRecordPerson> list = member.getWarRecords();

            if (list != null) {
                for (WarRecordPerson warRecordPerson : list) {
                    builder.addRecord(warRecordPerson.getRecord());
                }
            }
        }

        handler.sendMsgToPlayer(WarReportRs.ext, builder.build());
    }

    /**
     *
     * Method: warRank
     *
     * @Description: 获取军团排名列表 @param req @param handler @return void @throws
     */
    public void warRank(WarRankRq req, ClientHandler handler) {
        long roleId = handler.getRoleId();
        int partyId = partyDataManager.getPartyId(roleId);
        if (partyId == 0) {
            handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
            return;
        }

        int page = req.getPage();
        int begin = page * 20;
        int end = begin + 20;

        Map<Integer, WarParty> rankMap = warDataManager.getRankMap();
        WarRankRs.Builder builder = WarRankRs.newBuilder();
        int index = 0;

        for (Map.Entry<Integer, WarParty> entry : rankMap.entrySet()) {
            if (index >= end) {
                break;
            }

            if (index >= begin) {
                builder.addWarRank(PbHelper.createWarRankPb(entry.getValue()));
            }
            index++;
        }

        WarParty selfParty = warDataManager.getWarParty(partyId);
        if (selfParty != null) {
            builder.setSelfParty(PbHelper.createWarRankPb(selfParty));
        }

        handler.sendMsgToPlayer(WarRankRs.ext, builder.build());
    }

    /**
     *
     * Method: getWarFight
     *
     * @Description: 获取战报 @param req @param handler @return void @throws
     */
    public void getWarFight(GetWarFightRq req, ClientHandler handler) {
        long roleId = handler.getRoleId();
        Member member = partyDataManager.getMemberById(roleId);
        if (member == null || member.getPartyId() == 0) {
            handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
            return;
        }

        int index = req.getIndex();
        GetWarFightRs.Builder builder = GetWarFightRs.newBuilder();

        int loop = 0;
        for (WarRecordPerson record : member.getWarRecords()) {
            if (loop == index) {
                builder.setRpt(record.getRpt());
                break;
            }

            loop++;
        }

        handler.sendMsgToPlayer(GetWarFightRs.ext, builder.build());
    }

    /**
     *
     * Method: warWinRank
     *
     * @Description: 百团混战连胜排名列表 @param handler @return void @throws
     */
    public void warWinRank(ClientHandler handler) {
        long roleId = handler.getRoleId();
        int partyId = partyDataManager.getPartyId(roleId);

        LinkedList<WarMember> list = warDataManager.getWinRankList();
        WarWinRankRs.Builder builder = WarWinRankRs.newBuilder();
        int rank = 0;
        for (WarMember warMember : list) {
            rank++;
            builder.addWinRank(PbHelper.createWarWinRankPb(warMember, rank));
        }

        int winCount = 0;
        long fight = 0;
        WarParty selfParty = warDataManager.getWarParty(partyId);
        if (selfParty != null) {
            WarMember warMember = selfParty.getMember(roleId);
            if (warMember != null) {
                Member member = warMember.getMember();
                winCount = member.getWinCount();
                fight = member.getRegFight();
            }
        }

        builder.setWinCount(winCount);
        builder.setFight(fight);
        boolean canGet = false;
        if (globalDataManager.gameGlobal.getWarState() == WarState.WAR_END) {
            int myRank = warDataManager.getWinRank(roleId);
            if (myRank > 0 && myRank < 11) {
                if (!warDataManager.hadGetWinRankAward(roleId)) {
                    canGet = true;
                }
            }
        }

        builder.setCanGet(canGet);
        handler.sendMsgToPlayer(WarWinRankRs.ext, builder.build());
    }

    /**
     * 
    * fighter的forces给form
    * @param fighter
    * @param form  
    * void
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
     * 
    * 团战战斗逻辑
    * @param a
    * @param d
    * @param rptAtkWar
    * @return  
    * boolean
     */
    private boolean fightWarMember(WarMember a, WarMember d, RptAtkWar.Builder rptAtkWar) {

        Fighter attacker = fightService.createFighter(a.getPlayer(), a.getInstForm(), AttackType.ACK_PLAYER);
        Fighter defencer = fightService.createFighter(d.getPlayer(), d.getInstForm(), AttackType.ACK_PLAYER);

        FightLogic fightLogic = new FightLogic(attacker, defencer, FirstActType.FISRT_VALUE_2, true);
        fightLogic.packForm(a.getInstForm(), d.getInstForm());
        fightLogic.fight();

        //统计战功
        long[] mplts = null;
        if (staticFunctionPlanDataMgr.isMilitaryRankOpen()) {
            mplts = calcMilitaryExploit(attacker, a, defencer, d);
            a.addMplt(mplts[0]);
            d.addMplt(mplts[1]);
            playerDataManager.addAward(a.getPlayer(), AwardType.MILITARY_EXPLOIT, 1, mplts[0], AwardFrom.FIGHT_TANK_DISAPPER_AND_DESTROY);
            playerDataManager.addAward(d.getPlayer(), AwardType.MILITARY_EXPLOIT, 1, mplts[1], AwardFrom.FIGHT_TANK_DISAPPER_AND_DESTROY);
        }

        CommonPb.Record record = fightLogic.generateRecord();
        subForceToForm(attacker, a.getInstForm());
        subForceToForm(defencer, d.getInstForm());
        //因为有可能损失不可生产的坦克(金币坦克)导致最强战力变化
        playerEventService.calcStrongestFormAndFight(a.getPlayer());
        playerEventService.calcStrongestFormAndFight(d.getPlayer());

        int result = fightLogic.getWinState();

        // RptAtkWar.Builder rptAtkWar = RptAtkWar.newBuilder();
        rptAtkWar.setFirst(fightLogic.attackerIsFirst());
        rptAtkWar.setAttacker(PbHelper.createRptMan(a.getPlayer(), a.getInstForm().getHero(), mplts != null ? mplts[0] : null, attacker.firstValue));
        rptAtkWar.setDefencer(PbHelper.createRptMan(d.getPlayer(), d.getInstForm().getHero(), mplts != null ? mplts[1] : null, defencer.firstValue));
        rptAtkWar.setRecord(record);

        if (result == 1) {// 攻方胜利
            rptAtkWar.setResult(true);
            return true;
        } else {
            rptAtkWar.setResult(false);
            return false;
        }
    }

    /**
     * 
    *   发送战斗奖励
    * void
     */
    private void sendWarAward() {
        Map<Integer, WarParty> rankMap = warDataManager.getRankMap();
        int partyId;
        PartyData partyData;
        for (int i = 1; i < 11; i++) {
            WarParty warParty = rankMap.get(i);
            List<Prop> props = new ArrayList<>();
            List<List<Integer>> awards = staticWarAwardDataMgr.getRankAward(i);

            for (List<Integer> prop : awards) {
                props.add(new Prop(prop.get(1), prop.get(2)));
            }

            partyData = warParty.getPartyData();
            partyId = partyData.getPartyId();
            partyDataManager.addAmyProps(partyId, props);

            if (i == 1) {
                championBuff(warParty);
                partyDataManager.addPartyTrend(partyId, 15, "");
            }

            partyDataManager.addPartyTrend(partyId, 14, String.valueOf(i));
        }
    }

    /**
     * 
    *   战斗完毕  分配积分 召回部队
    * void
     */
    private void membersAward() {
        int now = TimeHelper.getCurrentSecond();
        Map<Integer, WarParty> parties = warDataManager.getParties();
        Iterator<WarParty> it = parties.values().iterator();
        while (it.hasNext()) {
            WarParty warParty = (WarParty) it.next();
            Iterator<WarMember> iterator = warParty.getMembers().values().iterator();
            while (iterator.hasNext()) {
                WarMember warMember = (WarMember) iterator.next();
                addScoreAndBackArmy(warMember, now);
            }
        }
    }

    /**
     * 
    * 取消军团战
    * @param isServerRest  
    * void
     */
    private void cancelWar(boolean isServerRest) {
        // int now = TimeHelper.getCurrentSecond();
        Map<Integer, WarParty> parties = warDataManager.getParties();
        Iterator<WarParty> it = parties.values().iterator();
        while (it.hasNext()) {
            WarParty warParty = (WarParty) it.next();
            Iterator<WarMember> iterator = warParty.getMembers().values().iterator();
            while (iterator.hasNext()) {
                WarMember warMember = (WarMember) iterator.next();

                try {
                    warDataManager.cancelArmy(warMember, isServerRest);
                } catch (Exception e) {
                    LogUtil.error("百团大战，返还玩家部队出错, warMember:" + warMember.toSimpleString(), e);
                }
            }
        }

        warDataManager.cancelWarFight();
    }

    /**
     * 
    *   战斗结束
    * void
     */
    private void endWar() {
        WarParty warParty = warDataManager.getRankMap().get(1);
        WarRecord out = PbHelper.createWarWinPb(warParty.getPartyData().getPartyName(), 1,
                TimeHelper.getCurrentSecond());
        synWarRecord(out);
        warDataManager.addWorldAndPartyRecord(warParty, out);

        for (WarMember warMember : warDataManager.getWinRankList()) {
            globalDataManager.gameGlobal.getWinRank().add(warMember.getPlayer().roleId);
        }

        // 冠军决出后,将前10名存起来
        recordRankTop10();

        // 计算本周军团积分和排名
        warDataManager.calThisWeekWarPartyJiFenRank();


        try {
            LinkedList<WarMember> winRankList = warDataManager.getWinRankList();
            if(winRankList.size() !=0 ){
                WarMember warMember = winRankList.get(0);
                activityNewService.refreshState(warMember.getPlayer(),2,1);
            }
        } catch (Exception e) {
            LogUtil.error(e);
        }

        // 若是第三次军团大战，结束的时候计算参加要塞战的军团
        if (TimeHelper.isCalJoinFortressParty()) {
            fortressWarService.calCanFightFortressParty();
        }
    }

    /**
     * 记录前10名 Method: recordRankTop10
     *
     * @return void @throws
     */
    private void recordRankTop10() {
        warDataManager.recordRankTop10();
    }

    /**
     * 
    * 增加buff奖励
    * @param warParty  
    * void
     */
    private void championBuff(WarParty warParty) {
        Iterator<Member> it = partyDataManager.getMemberList(warParty.getPartyData().getPartyId()).iterator();
        while (it.hasNext()) {
            Member member = (Member) it.next();
            Player player = playerDataManager.getPlayer(member.getLordId());
            if (player != null) {
                playerDataManager.addEffect(player, EffectType.COLLECT_SPEED_SUPER, 18 * 3600);
                // playerDataManager.addEffect(player, EffectType.WAR_CHAMPION,
                // 18 * 3600);
            }
        }
    }

    final private static int[] WIN_COUNT_SCORE = {0, 3, 7, 10, 23, 40, 60, 84, 111, 146};

    /**
     * 
    * 根据排名计算得分
    * @param winCount
    * @return  
    * int
     */
    private int rankScore(int winCount) {
        int score = 0;
        if (winCount >= 10) {
            score = 180;
        } else {
            score = WIN_COUNT_SCORE[winCount];
        }

        return score;
    }

    /**
     * 计算百团大战战损
     * @param warMember
     * @param now
     */
    private void addScoreAndBackArmy(WarMember warMember, int now) {
        Player target = warMember.getPlayer();

        Form regForm = warMember.getForm();
        Form insForm = warMember.getInstForm();

        // 永久损失的坦克
        int[] c = new int[6];
        for (int i = 0; i < c.length; i++) {
            c[i] = (regForm.c[i] - insForm.c[i]) / 100;
        }

        int score = 90 + rankScore(warMember.getMember().getWinCount());
        String mailContent = "";
        for (int i = 0; i < c.length; i++) {
            if (c[i] > 0) {
                score += staticTankDataMgr.getStaticTank(regForm.p[i]).getWarScore() * c[i];
                mailContent += (regForm.p[i] + "|" + c[i] + "&");
            }

            if (regForm.p[i] > 0) {
                playerDataManager.addTank(target, regForm.p[i], regForm.c[i] - c[i], AwardFrom.WAR_PARTY);
            }
        }
        if (regForm.getAwakenHero() != null) {
            AwakenHero awakenHero = target.awakenHeros.get(regForm.getAwakenHero().getKeyId());
            awakenHero.setUsed(false);
            LogLordHelper.awakenHero(AwardFrom.WAR_PARTY, target.account, target.lord, awakenHero, 0);
        } else if (regForm.getCommander() > 0) {
            playerDataManager.addHero(target, regForm.getCommander(), 1, AwardFrom.WAR_PARTY);
        }

        //取消战术
        if( !regForm.getTactics().isEmpty()){
            tacticsService.cancelUseTactics(target,regForm.getTactics());
        }

        Iterator<Army> it = target.armys.iterator();
        while (it.hasNext()) {
            Army army = (Army) it.next();
            if (army.getState() == ArmyState.WAR) {
                it.remove();
                break;
            }
        }

        PartyDataManager.doPartyLivelyTask(warMember.getWarParty().getPartyData(), warMember.getMember(),
                PartyType.TASK_TEAM);

        activityNewService.refreshState(warMember.getPlayer(),4,score);

        playerDataManager.addAward(target, AwardType.CONTRIBUTION, 0, score, AwardFrom.WAR_PARTY);

        if (staticFunctionPlanDataMgr.isMilitaryRankOpen()){//军功功能开了则发送邮件的内容包含军功
            playerDataManager.sendNormalMail(target, MailType.MOLD_PARTY_WAR_MILITARY_RANK, now,
                    String.valueOf(warMember.getMember().getWinCount()), String.valueOf(score), String.valueOf(warMember.getMplt()), mailContent);
        }else{
            playerDataManager.sendNormalMail(target, MailType.MOLD_PARTY_WAR, now,
                    String.valueOf(warMember.getMember().getWinCount()), String.valueOf(score), mailContent);
        }
    }

    /**
     * 
    *   团战定时器 （根据开启时间对百团战 ，要塞战进行逻辑处理）
    * void
     */
    public void warTimerLogic() {
        if (TimeHelper.isWarDay()) {
            warFightLogic();// 百团大战
        } else if (TimeHelper.isFortressBattleDay()) {
            fortressWarService.fortressBattleLogic();// 要塞战
        }
        if (TimeHelper.isCalCanJoinFortressTime()) {
            fortressWarService.calCanFightFortressParty();
        }
    }

   /**
   * @Title: warFightLogic 
   * @Description:   开启一个军团战
   * void   
   * @throws
    */
    private void warFightLogic() {
        int nowDay = TimeHelper.getCurrentDay();
        WarLog warLog = warDataManager.getWarLog();
        if (warLog == null || nowDay != warLog.getWarTime()) {
            warLog = new WarLog();
            warLog.setWarTime(nowDay);
            warDataManager.setWarLog(warLog);
            warDataManager.flushWarLog();
        }

        WarFight warFight = warDataManager.getWarFight();
        if (TimeHelper.isWarBeginReg()) {// 开始报名
            if (warFight == null || warFight.getFightDay() != nowDay) {
                warFight = new WarFight(nowDay);
                warDataManager.setWarFight(warFight);
                warFight.setState(WarState.REG_STATE);
            }
        } else if (TimeHelper.isWarBeginEnd()) {// 报名结束
            if (warFight != null && warFight.getState() == WarState.REG_STATE) {
                warFight.setState(WarState.PREPAIR_STATE);
                synWarState(WarState.PREPAIR_STATE);
            }
        } else if (TimeHelper.isWarBeginFight()) {// 开战时间
            if (warFight != null && warFight.getState() == WarState.PREPAIR_STATE) {
                if (warDataManager.getParties().size() < 10) {
                    warFight.setState(WarState.CANCEL_STATE);
                    synWarState(WarState.CANCEL_STATE);
                    cancelWar(false);
                    // LogHelper.WAR_LOGGER.error("reg member count not
                    // enough!");
                    LogUtil.war("reg member count not enough!");
                } else {
                    warFight.prepairForFight();
                    warFight.setState(WarState.FIGHT_STATE);
                    synWarState(WarState.FIGHT_STATE);
                }
            }
            if (warFight == null) {
                // 服务器重启后,20点取消战斗
                // LogHelper.WAR_LOGGER.error("cancel war case rest server");
                LogUtil.war("cancel war case rest server");
                cancelWar(true);
                warFight = new WarFight(nowDay);
                warDataManager.setWarFight(warFight);
                warFight.setState(WarState.CANCEL_STATE);
            }
        }

        if (warFight != null) {
            int state = warFight.getState();
            if (state == WarState.FIGHT_STATE) {
                if (warFight.round()) {
                    warFight.setState(WarState.FIGHT_END);
                }
            } else if (state == WarState.FIGHT_END) {
                warFight.setState(WarState.WAR_END);
                synWarState(WarState.WAR_END);
                sendWarAward();
                membersAward();
                endWar();
            }
        }
    }

    /**
     * 
    * 同步战斗记录到玩家
    * @param record  
    * void
     */
    private void synWarRecord(WarRecord record) {
        SynWarRecordRq.Builder builder = SynWarRecordRq.newBuilder();
        builder.setRecord(record);
        SynWarRecordRq req = builder.build();

        Map<Integer, WarParty> parties = warDataManager.getParties();
        Iterator<WarParty> it = parties.values().iterator();
        while (it.hasNext()) {
            WarParty warParty = (WarParty) it.next();
            Iterator<WarMember> iterator = warParty.getMembers().values().iterator();
            while (iterator.hasNext()) {
                WarMember warMember = (WarMember) iterator.next();
                playerDataManager.synWarRecordToPlayer(warMember.getPlayer(), req);
            }
        }
    }

    /**
     * 
    * 同步团战状态到玩家
    * @param state  
    * void
     */
    private void synWarState(int state) {
        SynWarStateRq.Builder builder = SynWarStateRq.newBuilder();
        builder.setState(state);
        SynWarStateRq req = builder.build();

        Map<Integer, WarParty> parties = warDataManager.getParties();
        Iterator<WarParty> it = parties.values().iterator();
        while (it.hasNext()) {
            WarParty warParty = (WarParty) it.next();
            Iterator<WarMember> iterator = warParty.getMembers().values().iterator();
            while (iterator.hasNext()) {
                WarMember warMember = (WarMember) iterator.next();
                playerDataManager.synWarStateToPlayer(warMember.getPlayer(), req);
            }
        }
    }

    /**
     * 团战战斗逻辑
    * @ClassName: WarFight 
    * @Description: TODO
    * @author
     */
    public class WarFight {
        private List<WarParty> fighters = new ArrayList<>();
        private int outCount = 0;
        private int tick = 0;
        private int fightDay = 0;
        private int state = 0;
        private List<FightPair> pairs;

        public WarFight(int fightDay) {
            this.setFightDay(fightDay);
        }

        /**
         * 
        *   团战前的数据处理
        * void
         */
        public void prepairForFight() {
            Map<Integer, WarParty> parties = warDataManager.getParties();
            fighters.addAll(parties.values());
            PartyData partyData;
            for (WarParty warParty : fighters) {
                warParty.prepair();
                partyData = warParty.getPartyData();
                // LogHelper.WAR_LOGGER.trace(partyData.getPartyName() + " lv:"
                // + partyData.getRegLv() + " reg in war");
                LogUtil.war(partyData.getPartyName() + " lv:" + partyData.getRegLv() + " reg in war");
            }
        }

        /**
         * 
        * 分配谁与谁交战
        * @return  
        * List<FightPair>
         */
        public List<FightPair> arrangePair() {
            List<FightPair> pairs = new LinkedList<>();

            Collections.shuffle(fighters);
            int size = fighters.size();
            for (int i = 0; i < size / 2; i += 2) {
                FightPair fightPair = new FightPair();
                fightPair.attacker = fighters.get(i).aquireFighter();
                fightPair.defencer = fighters.get(i + 1).aquireFighter();
                pairs.add(fightPair);
            }

            return pairs;
        }

        /**
         * 
        * 进行一轮战斗
        * @return  
        * boolean
         */
        public boolean round() {
            tick++;
            if (tick % 3 != 0) {
                return false;
            }

            int time = TimeHelper.getCurrentSecond();
            // int fightCount = 0;
            // while (fightCount < 1) {
            if (pairs == null || pairs.isEmpty()) {
                pairs = arrangePair();
            }

            int result;
            int rank;
            int hp1;
            int hp2;
            Iterator<FightPair> it = pairs.iterator();
            while (it.hasNext()) {
                FightPair fightPair = (FightPair) it.next();
                hp1 = fightPair.attacker.calcHp();
                hp2 = fightPair.defencer.calcHp();
                RptAtkWar.Builder rptAtkWar = RptAtkWar.newBuilder();
                if (fightWarMember(fightPair.attacker, fightPair.defencer, rptAtkWar)) {
                    addWinCount(fightPair.attacker);
                    result = fightPair.attacker.getMember().getWinCount();
                    fightPair.defencer.getWarParty().fighterOut(fightPair.defencer);
                } else {
                    result = 0;
                    addWinCount(fightPair.defencer);
                    fightPair.attacker.getWarParty().fighterOut(fightPair.attacker);
                }

                // fightCount++;

                WarRecord record = PbHelper.createWarRecordPb(fightPair.attacker, fightPair.defencer, hp1, hp2, result, time);
                synWarRecord(record);
                warDataManager.addRecord(fightPair, record, rptAtkWar.build());

                WarParty warParty = null;
                if (result == 0) {
                    warParty = fightPair.attacker.getWarParty();
                    if (warParty.allOut()) {
                        rank = warDataManager.getParties().size() - outCount;
                        setWarRank(warParty, rank);

                        outCount++;
                        WarRecord out = PbHelper.createWarResultPb(warParty.getPartyData().getPartyName(),
                                fightPair.defencer, rank, time);
                        synWarRecord(out);
                        warDataManager.addWorldAndPartyRecord(warParty, out);

                        chatService.sendWorldChat(
                                chatService.createSysChat(SysChatId.PARTY_WAR, warParty.getPartyData().getPartyName(),
                                        fightPair.defencer.getPlayer().lord.getNick(), String.valueOf(rank)));
                    }
                } else {
                    warParty = fightPair.defencer.getWarParty();
                    if (warParty.allOut()) {
                        rank = warDataManager.getParties().size() - outCount;
                        setWarRank(warParty, rank);

                        outCount++;
                        WarRecord out = PbHelper.createWarResultPb(warParty.getPartyData().getPartyName(),
                                fightPair.attacker, rank, time);
                        synWarRecord(out);
                        warDataManager.addWorldAndPartyRecord(warParty, out);

                        chatService.sendWorldChat(
                                chatService.createSysChat(SysChatId.PARTY_WAR, warParty.getPartyData().getPartyName(),
                                        fightPair.attacker.getPlayer().lord.getNick(), String.valueOf(rank)));
                    }
                }

                it.remove();
                break;
            }

            partyOut();

            if (fighters.size() == 1) {// 剩下的是冠军，比赛结束
                WarParty warParty = fighters.get(0);
                setWarRank(warParty, 1);

                chatService.sendWorldChat(
                        chatService.createSysChat(SysChatId.PARTY_CHAMPION, warParty.getPartyData().getPartyName()));
                return true;
            }
            // }

            return false;
        }

        /**
         * 
        * 设置军团排名
        * @param warParty
        * @param rank  
        * void
         */
        private void setWarRank(WarParty warParty, int rank) {
            warParty.getPartyData().setWarRank(rank);
            warDataManager.setWarRank(warParty, rank);
        }

        /**
         * 
        * 增加连胜次数  发世界公告
        * @param warMember  
        * void
         */
        private void addWinCount(WarMember warMember) {
            Member member = warMember.getMember();
            member.setWinCount(member.getWinCount() + 1);
            warDataManager.setWinRank(warMember);
            if (member.getWinCount() == 5) {
                chatService.sendWorldChat(chatService.createSysChat(SysChatId.PARTY_WAR_WIN,
                        warMember.getWarParty().getPartyData().getPartyName(), warMember.getPlayer().lord.getNick()));
            }
        }

        /**
         * 
        *   军团里所有人都失败出局，则军团出局
        * void
         */
        public void partyOut() {
            Iterator<WarParty> it = fighters.iterator();
            while (it.hasNext()) {
                WarParty warParty = (WarParty) it.next();
                if (warParty.allOut()) {
                    it.remove();
                }
            }
        }

        public int getState() {
            return state;
        }

        public void setState(int state) {
            this.state = state;
            globalDataManager.gameGlobal.setWarState(state);
        }

        public int getFightDay() {
            return fightDay;
        }

        public void setFightDay(int fightDay) {
            this.fightDay = fightDay;
        }

        public int getTick() {
            return tick;
        }

        public void setTick(int tick) {
            this.tick = tick;
        }
    }

    /**
     * 获取本周军团混战的积分排行
     *
     * @param getThisWeekMyWarJiFenRankHandler
     */
    public void getThisWeekMyWarJiFenRank(ClientHandler handler) {
        long roleId = handler.getRoleId();
        int partyId = partyDataManager.getPartyId(roleId);
        if (partyId == 0) {
            handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
            return;
        }

        GetThisWeekMyWarJiFenRankRs.Builder builder = GetThisWeekMyWarJiFenRankRs.newBuilder();

        FortressBattleParty f = warDataManager.getThisWeekMyWarJiFenRank().get(partyId);
        if (f != null) {
            builder.setRank(f.getRank());
            builder.setJifen(f.getJifen());
        }

        handler.sendMsgToPlayer(GetThisWeekMyWarJiFenRankRs.ext, builder.build());
    }

    /**
     * 
    * 玩家报名
    * @param player  
    * void
     */
    private void playerReg(Player player) {
        if (!warDataManager.inRegTime()) {
            return;
        }

        Member member = partyDataManager.getMemberById(player.roleId);
        // int partyId = partyDataManager.getPartyId(player.roleId);
        if (member == null || member.getPartyId() == 0) {
            return;
        }

        int enterTime = member.getEnterTime();
        if (enterTime == TimeHelper.getCurrentDay()) {
            return;
        }

        for (Army army : player.armys) {
            if (army.getState() == ArmyState.WAR) {
                return;
            }
        }

        Tank tank = null;
        Iterator<Tank> its = player.tanks.values().iterator();
        while (its.hasNext()) {
            tank = its.next();
            if (tank.getCount() > 0) {
                break;
            }
        }
        Form attackForm = new Form();
        attackForm.p[0] = tank.getTankId();
        attackForm.c[0] = tank.getCount();

        int maxTankCount = playerDataManager.formTankCount(player, null, null);
        if (!playerDataManager.checkAndSubTank(player, attackForm, maxTankCount, AwardFrom.WAR_REG)) {
            return;
        }

        long fight = fightService.calcFormFight(player, attackForm);

        int marchTime = 60 * 60;
        int now = TimeHelper.getCurrentSecond();
        Army army = new Army(player.maxKey(), 0, ArmyState.WAR, attackForm, marchTime, now + marchTime, playerDataManager.isRuins(player));
        player.armys.add(army);

        WarMember warMember = warDataManager.createWarMember(player, member, attackForm, fight);
        warDataManager.warReg(warMember);



    }

    /**
     * 
    * 军团报名
    * @param player  
    * void
     */
    public void partyReg(Player player) {
        // 获取军团成员
        Member member = partyDataManager.getMemberById(player.roleId);
        // int partyId = partyDataManager.getPartyId(player.roleId);
        if (member == null || member.getPartyId() == 0) {
            return;
        }

        int partyId = member.getPartyId();

        // 获取军团成员
        List<Member> list = partyDataManager.getMemberList(partyId);
        for (Member m : list) {
            Player p = playerDataManager.getPlayer(m.getLordId());
            try {
                playerReg(p);
            } catch (Exception e) {
                LogUtil.error("gm报名处问题:" + p.lord.getNick());
            }
        }

    }

    /**
     * 计算战功
     * @param attacker
     * @param a 进攻方战斗前阵形
     * @param defencer
     * @param b 防守方战斗前阵形
     * @return
     */
    private long[] calcMilitaryExploit(Fighter attacker, WarMember a, Fighter defencer, WarMember d) {
        Map<Integer, RptTank> aMap = new HashMap<>();
        Map<Integer, RptTank> bMap = new HashMap<>();
        //进攻方战损
        for (int i = 0; i < attacker.forces.length; i++) {
            Force force = attacker.forces[i];
            if (force != null) {
                int tankId = force.staticTank.getTankId();
                RptTank rptTank = aMap.get(tankId);
                if (rptTank == null) aMap.put(tankId, rptTank = new RptTank(tankId, 0));
                rptTank.setCount(rptTank.getCount() + force.killed);
            }
        }

        //防守放战损
        for (int i = 0; i < defencer.forces.length; i++) {
            Force force = defencer.forces[i];
            if (force != null) {
                int tankId = force.staticTank.getTankId();
                RptTank rptTank = bMap.get(tankId);
                if (rptTank == null) bMap.put(tankId, rptTank = new RptTank(tankId, 0));
                rptTank.setCount(rptTank.getCount() + force.killed);
            }
        }
        long[] mplts = playerDataManager.calcMilitaryExploit(aMap, bMap);
        String str_aMap = Arrays.toString(aMap.values().toArray());
        String str_bMap = Arrays.toString(bMap.values().toArray());
        LogUtil.war(String.format("atk nick :%s, def id :%d, aMap :%s, bMap :%s, mplts[0] :%d, mplts[1] :%d, atk mplt :%d, def mplts :%d",
                attacker.player.lord.getNick(), defencer.player.lord.getLordId(), str_aMap, str_bMap, mplts[0], mplts[1], a.getMplt(), d.getMplt()));
        return mplts;
    }

}
