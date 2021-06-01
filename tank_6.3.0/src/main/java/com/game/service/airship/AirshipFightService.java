package com.game.service.airship;

import com.game.constant.*;
import com.game.dataMgr.StaticActivityDataMgr;
import com.game.domain.Member;
import com.game.domain.PartyData;
import com.game.domain.Player;
import com.game.domain.p.Activity;
import com.game.domain.p.Army;
import com.game.domain.p.Mail;
import com.game.domain.p.RptTank;
import com.game.domain.p.airship.Airship;
import com.game.domain.p.airship.AirshipTeam;
import com.game.domain.s.StaticActBrotherBuff;
import com.game.domain.s.StaticAirship;
import com.game.fight.FightLogic;
import com.game.fight.domain.Fighter;
import com.game.fight.domain.Force;
import com.game.manager.AirshipDataManager;
import com.game.manager.PartyDataManager;
import com.game.manager.PlayerDataManager;
import com.game.pb.CommonPb;
import com.game.service.ActionCenterService;
import com.game.service.FightService;
import com.game.service.WorldService;
import com.game.util.LogUtil;
import com.game.util.NumberHelper;
import com.game.util.PbHelper;
import com.game.util.StcHelper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.Map.Entry;

/**
 * @author zhangdh
 * @ClassName: AirshipFightSrv
 * @Description: 飞艇战斗服务
 * @date 2017-06-28 13:52
 */
@Service
public class AirshipFightService {

    @Autowired
    private PlayerDataManager playerDataManager;

    @Autowired
    private PartyDataManager partyDataManager;

    @Autowired
    private AirshipDataManager airshipDataManager;

    @Autowired
    private FightService fightService;

    @Autowired
    private WorldService worldService;
    
    @Autowired
    private ActionCenterService actionCenterService;

    @Autowired
    private StaticActivityDataMgr staticActivityDataMgr;
    
    /**
     * 攻打飞艇逻辑
     *
     * @param attackPartyData 进攻者工会
     * @param team            进攻队伍
     * @param airship         飞艇
     * @param sap             飞艇基础数据
     * @param now             当前时间
     * @param teamPlayer      队长
     * @return
     */
    public boolean fightAirship(PartyData attackPartyData, AirshipTeam team, Airship airship, StaticAirship sap, int now, Player teamPlayer) {
        List<Army> attackArmys = team.getArmys();
        List<Army> guardArmys = airship.getGuardArmy();
        List<Army> attackDieArmys = new ArrayList<>();

        CommonPb.RptAtkAirship.Builder rptAtkAirship = CommonPb.RptAtkAirship.newBuilder();

        String defencePartyName = "";
        if (airship.getPartyData() != null) {
            defencePartyName = airship.getPartyData().getPartyName();
        }


        rptAtkAirship.setAttackerName(attackPartyData.getPartyName());
        rptAtkAirship.setDefencerName(defencePartyName);
        rptAtkAirship.setAirshipId(sap.getId());

        //获取兄弟同心活动军团的buff
        Activity attackActivity = actionCenterService.getPartyActivity(attackPartyData.getPartyId(), ActivityConst.ACT_BROTHER);
        Activity guardActivity = actionCenterService.getPartyActivity(airship.getPartyId(), ActivityConst.ACT_BROTHER);
        Map<Integer, Integer> attackBuffMap = attackActivity == null ? null : attackActivity.getSaveMap();
        Map<Integer, Integer> guardBuffMap = guardActivity == null ? null : guardActivity.getSaveMap();
        
        //包含队伍集结者的进攻者列表
        Set<Player> attackMailPlayerSet = new HashSet<>();
        attackMailPlayerSet.add(teamPlayer);
        Map<Long, CommonPb.RptAtkMan.Builder> atkRptMan = new HashMap<>();
        Map<Long, Map<Integer, RptTank>> atkHutTotal = new HashMap<>();
        for (Army army : attackArmys) {
            CommonPb.RptAtkMan.Builder atkMan = PbHelper.createRptAtkMan(fightService, army.player, army);
            atkRptMan.put(army.player.roleId, atkMan);
            attackMailPlayerSet.add(army.player);
        }

        Map<Long, CommonPb.RptAtkMan.Builder> defRptMan = new HashMap<>();
        Map<Long, Map<Integer, RptTank>> defHutTotal = new HashMap<>();
        for (Army guardArmy : guardArmys) {
            CommonPb.RptAtkMan.Builder rptMan = PbHelper.createRptAtkMan(fightService, guardArmy.player, guardArmy);
            defRptMan.put(guardArmy.player.roleId, rptMan);
        }


        boolean isWin = true;

        //double ratio = 1 - AirshipConst.AIRSHIP_HAUST_TANK_RATIO / NumberHelper.TEN_THOUSAND_DOUBLE;
        Fighter defer = null;

        for (Army atkAm : attackArmys) {
            Player atkp = atkAm.player;
            Fighter atker = fightService.createFighter(atkp, atkAm.getForm(), AttackType.ACK_DEFAULT_PLAYER);
            
            //兄弟同心活动增加攻方buff
            addBuff(atker, attackBuffMap);
            
            boolean isNewAtker = true;//是否第一次与防守方战斗
            Iterator<Army> it = guardArmys.iterator();
            while (it.hasNext()) {
                Army defAm = it.next();
                Player defp = defAm.player;
                //A1与D1之间的战斗采用先手值判断,后面的战斗根据上一次战斗的情况取反
                int firstStrategy = FirstActType.FISRT_VALUE_2;//默认先手策略
                if (defer == null) {//为了保存血量
                    defer = fightService.createAirshipFighter(defp, defAm.getForm(), AttackType.ACK_DEFAULT_PLAYER);
                    if (!isNewAtker) firstStrategy = FirstActType.DEFENCER;
                } else {
                    firstStrategy = FirstActType.ATTACKER;
                }

                //兄弟同心活动增加守方buff
                addBuff(defer, guardBuffMap);
                
                //战斗坦克数量检测
                check(airship, atkp, atker);
                check(airship, defp, defer);

                FightLogic fightLogic = new FightLogic(atker, defer, firstStrategy, true);
                fightLogic.packForm(atkAm.getForm(), defAm.getForm());
                fightLogic.fight();
                //记录战报
                rptAtkAirship.addFirst(fightLogic.attackerIsFirst());
                rptAtkAirship.addRecord(fightLogic.generateRecord());
                rptAtkAirship.addRecordLord(PbHelper.createTwoLongPb(atkp.roleId, defp.roleId));

                //统计玩家军功与战损
                Map<Integer, RptTank> atkht = atkHutTotal.get(atkp.roleId);//进攻方总损耗
                if (atkht == null) atkHutTotal.put(atkp.roleId, atkht = new HashMap<Integer, RptTank>());
                CommonPb.RptAtkMan.Builder atkMan = atkRptMan.get(atkp.roleId);//进攻方pb
                Map<Integer, RptTank> defht = defHutTotal.get(defp.roleId);//防守方总损耗
                if (defht == null) defHutTotal.put(defp.roleId, defht = new HashMap<Integer, RptTank>());
                CommonPb.RptAtkMan.Builder defMan = defRptMan.get(defp.roleId);//防守方pb

                //损耗统计
                calcHaustWithGuard(atkp, atker, atkAm, atkht, atkMan, defp, defer, defAm, defht, defMan);

                isWin = fightLogic.getWinState() == 1;


                clearKilled(atker);
                clearKilled(defer);

                //防守方如果死亡则清除此玩家防守战斗对象
                if (!armyIsAlive(defAm)) {
                    it.remove();//驻军返回
                    airshipDataManager.retreatGuardArmy(defAm, now, airship);
                    defer = null;
                }else{
                    StcHelper.syncAirshipTeamArmy2Player(defp, AirshipConst.TEAM_STATE_ARMY_CHANGE);
                }

                //如果战斗攻打了100回合并且双方都没有死亡,则强制算进攻方(不是先手方)输,
                //但不杀死进攻方未死亡部队,防守方继续进入下一场战斗
                //进攻方死亡或者战斗回合达到上限
                if (!armyIsAlive(atkAm) || fightLogic.getWinState() == 0) {
                    attackDieArmys.add(atkAm);
                    break;
                }


                isNewAtker = false;
            }
        }

        isWin &= guardArmys.size() == 0;
        int lostDurability = 0;
        if (isWin) {
            //攻打飞艇
            List<Army> attackAliveArmys = new ArrayList<>(attackArmys);
            attackAliveArmys.removeAll(attackDieArmys);
            //飞艇战斗对象
            if (airship.getPartyData()==null && airship.getDurability()!=AirshipConst.AIRSHIP_REBUILD_DURABILITY_MAX){
                LogUtil.error(String.format("airship :%d, is npc, but durability :%d", airship.getId(), airship.getDurability()));
                airship.setDurability(AirshipConst.AIRSHIP_REBUILD_DURABILITY_MAX);
            }
            defer = fightService.createAirshipFighter(sap, airship);
            //如果对面有驻防部队表明进攻方已经战斗过则飞艇先手,后面的部队与飞艇战斗全部都是玩家先手
            //如果对面没有驻防部队直接与飞艇进行战斗,则进攻方先手,后面的部队与飞艇战斗全部都是玩家先手
            int firstStrategy = defRptMan.isEmpty() ? FirstActType.ATTACKER : FirstActType.DEFENCER;
            for (Army atkAm : attackAliveArmys) {
                Player atkp = atkAm.player;

                Fighter atker = fightService.createFighter(atkp, atkAm.getForm(), AttackType.ACK_DEFAULT_PLAYER);

                FightLogic fightLogic = new FightLogic(atker, defer, firstStrategy, true);
                fightLogic.packForm(atkAm.getForm(), null);
                fightLogic.fight();
                rptAtkAirship.addFirst(fightLogic.attackerIsFirst());
                rptAtkAirship.addRecord(fightLogic.generateRecord());
                rptAtkAirship.addRecordLord(PbHelper.createTwoLongPb(atkp.roleId, 0));

                if (fightLogic.getWinState() != 1 && fightLogic.getWinState() != 2) {
                    LogUtil.error(String.format("fight win state :%d, atker force :%s, atkAm form :%s", fightLogic.getWinState(), Arrays.toString(atker.forces), atkAm.getForm()));
                }

                //统计进攻方玩家战损
                Map<Integer, RptTank> atkht = atkHutTotal.get(atkp.roleId);//进攻方总损耗
                if (atkht == null) atkHutTotal.put(atkp.roleId, atkht = new HashMap<Integer, RptTank>());
                CommonPb.RptAtkMan.Builder atkMan = atkRptMan.get(atkp.roleId);//进攻方pb
                calcAtkHaustWithAirship(atkp, atker, atkAm, atkht, atkMan, airship);
                //打印超过回合上限的战斗,战功获得情况
                if (fightLogic.getWinState() != 1 && fightLogic.getWinState() != 2) {
                    LogUtil.error(String.format("nick :%s, get mplt :%d, atkht :%s", atkp.lord.getNick(), atkMan.getMplt(), atkht.toString()));
                }

                isWin = fightLogic.getWinState() == 1;

                //根据血量万分比设置飞艇剩余耐久度
                int beforeDurability = airship.getDurability();
                Force force = defer.forces[FightConst.AISHIP_FORCE_POS - 1];
                int remainPercent = (int) (force.hp * NumberHelper.TEN_THOUSAND / (force.maxHp * force.initCount));
                lostDurability += airship.getDurability() - remainPercent;//损失的耐久度
                airship.setDurability(remainPercent);
                LogUtil.common(String.format("atker :%s, airship id :%d, hp :%d, max hp :%d, beforeDurability :%d, durability :%d, lostDurability :%d", atkp.lord.getNick(), airship.getId(), force.hp, force.maxHp * force.count, beforeDurability, airship.getDurability(), lostDurability));

                clearKilled(atker);
                clearKilled(defer);

                if (!defer.alive()) {
                    break;
                }

                //fightLogic.getWinState()==0表示战斗打了100回合
                //如果战斗攻打了100回合并且双方都没有死亡,则强制算进攻方(不是先手方)输,
                //但不杀死进攻方未死亡部队,防守方继续进入下一场战斗
//                if (fightLogic.getWinState() == 0){
//                    continue;
//                }
                firstStrategy = FirstActType.ATTACKER;
            }
        }

        //在战报中设置进攻玩家战损
        for (Map.Entry<Long, CommonPb.RptAtkMan.Builder> entry : atkRptMan.entrySet()) {
            Map<Integer, RptTank> atkht = atkHutTotal.get(entry.getKey());
            CommonPb.RptAtkMan.Builder rptMan = entry.getValue();
            if (atkht != null && !atkht.isEmpty()) {
                for (Map.Entry<Integer, RptTank> tankEntry : atkht.entrySet()) {
                    rptMan.addTank(PbHelper.createRtpTankPb(tankEntry.getValue()));
                }
            }
            rptAtkAirship.addAttackers(rptMan);
        }

        //在战报中设置防守玩家战损
        for (Map.Entry<Long, CommonPb.RptAtkMan.Builder> entry : defRptMan.entrySet()) {
            Map<Integer, RptTank> defht = defHutTotal.get(entry.getKey());
            CommonPb.RptAtkMan.Builder rptMan = entry.getValue();
            if (defht != null && !defht.isEmpty()) {
                for (Map.Entry<Integer, RptTank> tankEntry : defht.entrySet()) {
                    rptMan.addTank(PbHelper.createRtpTankPb(tankEntry.getValue()));
                }
            }
            rptAtkAirship.addDefencers(rptMan);
        }

        rptAtkAirship.setResult(isWin);
        //战报记录飞艇耐久信息
        rptAtkAirship.setLostDurb(lostDurability);//本次战斗总共损失的耐久度
        rptAtkAirship.setRemainDurb(airship.getDurability());//飞艇剩余耐久度
        CommonPb.RptAtkAirship airshipRpt = rptAtkAirship.build();//飞艇战斗战报
        CommonPb.Report atkRpt = PbHelper.createAtkAirshipReport(airshipRpt, now); //防守方最终战报
        CommonPb.Report defRpt = PbHelper.createDefAirshipReport(airshipRpt, now); //防守方最终战报

        //如果进攻队伍打的是NPC飞艇,并且战斗失败,飞艇耐久度恢复为最大值
        if (airship.getPartyData() == null && !isWin) {
            airship.setDurability(AirshipConst.AIRSHIP_REBUILD_DURABILITY_MAX);
        }


        for (Player player : attackMailPlayerSet) {
            int modelId = isWin ? MailType.MOLD_ATTACK_AIRSHIP_WIN : MailType.MOLD_ATTACK_AIRSHIP_LOSE;
            Mail mail = playerDataManager.sendReportMail(player, atkRpt, modelId, now, defencePartyName, String.valueOf(sap.getId()));
        }

        if (isWin) {
            partyDataManager.addPartyTrend(attackPartyData.getPartyId(), PartyTrendConst.ATTACK_AIRSHIP_WIN, teamPlayer.lord.getNick(), String.valueOf(team.getId()));
            if (airship.getPartyData() != null) {//驻军
                //防守胜利军团增加军情
                partyDataManager.addPartyTrend(airship.getPartyData().getPartyId(), PartyTrendConst.DEFENCE_AIRSHIP_LOSE, attackPartyData.getPartyName(), teamPlayer.lord.getNick(), String.valueOf(team.getId()));
                //向防守失败方发送邮件
                sendReportMail2Party(airship.getPartyId(), MailType.MOLD_DEFENCE_AIRSHIP_LOSE, defRpt, now, String.valueOf(sap.getId()), attackPartyData.getPartyName());
            }

        } else {
            partyDataManager.addPartyTrend(attackPartyData.getPartyId(), PartyTrendConst.ATTACK_AIRSHIP_LOSE, teamPlayer.lord.getNick(), String.valueOf(team.getId()));
            if (airship.getPartyData() != null) {//驻军
                //防守胜利军团增加军情
                partyDataManager.addPartyTrend(airship.getPartyData().getPartyId(), PartyTrendConst.DEFENCE_AIRSHIP_WIN, attackPartyData.getPartyName(), teamPlayer.lord.getNick(), String.valueOf(team.getId()));
                //向防守胜利方发送邮件
                sendReportMail2Party(airship.getPartyId(), MailType.MOLD_DEFENCE_AIRSHIP_WIN, defRpt, now, attackPartyData.getPartyName());
            }

        }
        return isWin;
    }


//    private boolean fight2AirshipNpc(List<Army> attackAliveArmys, StaticAirship sap, Airship airship, double ratio, CommonPb.RptAtkAirship.Builder rptAtkAirship){
//    }

    /**
     * 统计玩家与玩家战斗的战损与军功信息
     *
     * @param atkp   进攻玩家
     * @param atker  进攻战斗对象
     * @param atkAm  进攻部队
     * @param atkht  进攻玩家总战损
     * @param atkMan 进攻玩家pb对象
     * @param defp   防守玩家
     * @param defer  防守对象
     * @param defAm  防守阵形
     * @param defht  防守方总战损
     * @param defMan 防守方pb对象
     */
    private void calcHaustWithGuard(Player atkp, Fighter atker, Army atkAm, Map<Integer, RptTank> atkht, CommonPb.RptAtkMan.Builder atkMan,
                                    Player defp, Fighter defer, Army defAm, Map<Integer, RptTank> defht, CommonPb.RptAtkMan.Builder defMan) {
    	//兄弟同心活动减少战损
    	double reduceloss = (100 - actionCenterService.getActBrotherReduceloss()) / 100.0d;
    	
        double ratio = 1 - (AirshipConst.AIRSHIP_HAUST_TANK_RATIO / NumberHelper.TEN_THOUSAND_DOUBLE) * reduceloss;
        Map<Integer, RptTank> atkh = worldService.haustArmyTank(atkp, atker, atkAm.getForm(), ratio, defp.roleId, AwardFrom.ATTACK_AIRSHIP);
        Map<Integer, RptTank> defh = worldService.haustArmyTank(defp, defer, defAm.getForm(), ratio, atkp.roleId, AwardFrom.ATTACK_AIRSHIP);
        //军功统计
        long[] mplts = playerDataManager.calcMilitaryExploit(atkh, defh);
        atkMan.setMplt((int) (atkMan.getMplt() + mplts[0]));
        defMan.setMplt((int) (defMan.getMplt() + mplts[1]));
        playerDataManager.addAward(atkp, AwardType.MILITARY_EXPLOIT, 1, mplts[0], AwardFrom.ATTACK_AIRSHIP);
        playerDataManager.addAward(defp, AwardType.MILITARY_EXPLOIT, 1, mplts[1], AwardFrom.AIRSHIP_DEFENCE_FIGHT);
        //进攻方战损统计累计
        calcHaust(atkht, atkh);
        calcHaust(defht, defh);
    }

    /**
     * 统计玩家与飞艇战斗的军功与战损信息
     *
     * @param atkp    进攻玩家
     * @param atker   进攻战斗对象
     * @param atkAm   进攻部队
     * @param atkht   进攻玩家总战损
     * @param atkMan  进攻玩家pb对象
     * @param airship 飞艇信息
     */
    private void calcAtkHaustWithAirship(Player atkp, Fighter atker, Army atkAm, Map<Integer, RptTank> atkht,
                                         CommonPb.RptAtkMan.Builder atkMan, Airship airship) {
    	//兄弟同心活动减少战损
    	double reduceloss = (100 - actionCenterService.getActBrotherReduceloss()) / 100.0d;
    	
        double ratio = 1 - (AirshipConst.AIRSHIP_HAUST_TANK_RATIO / NumberHelper.TEN_THOUSAND_DOUBLE) * reduceloss;
        Map<Integer, RptTank> atkh = worldService.haustArmyTank(atkp, atker, atkAm.getForm(), ratio, airship.getId(), AwardFrom.ATTACK_AIRSHIP);
        //军功统计
        long[] mplts = playerDataManager.calcMilitaryExploit(atkh, null);
        atkMan.setMplt((int) (atkMan.getMplt() + mplts[0]));
        playerDataManager.addAward(atkp, AwardType.MILITARY_EXPLOIT, 1, mplts[0], AwardFrom.ATTACK_AIRSHIP);
        calcHaust(atkht, atkh);
    }

    /**
     * 累加玩家战损
     *
     * @param huastTotal 玩家总战损
     * @param huast      玩家本次战斗战损
     */
    private void calcHaust(Map<Integer, RptTank> huastTotal, Map<Integer, RptTank> huast) {
        for (Map.Entry<Integer, RptTank> entry : huast.entrySet()) {
            RptTank rptk = huastTotal.get(entry.getKey());
            if (rptk != null) {
                rptk.setCount(rptk.getCount() + entry.getValue().getCount());
            } else {
                huastTotal.put(entry.getKey(), entry.getValue());
            }
        }
    }

    /**
     * 向工会发送邮件
     *
     * @param partyId
     * @param mailId
     * @param rpt
     * @param nowSec
     * @param params
     */
    private void sendReportMail2Party(int partyId, int mailId, CommonPb.Report rpt, int nowSec, String... params) {
        List<Member> memberList = partyDataManager.getMemberList(partyId);
        for (Member member : memberList) {
            Player memberPlayer = playerDataManager.getPlayer(member.getLordId());
            playerDataManager.sendReportMail(memberPlayer, rpt, mailId, nowSec, params);
        }
    }

    /**
     * 
    * 部队中还有兵
    * @param army
    * @return  
    * boolean
     */
    private boolean armyIsAlive(Army army) {
        int count = 0;
        int[] p = army.getForm().p;
        int[] c = army.getForm().c;
        for (int i = 0; i < p.length; i++) {
            if (p[i] != 0) {
                count += c[i];
            }
        }
        return count > 0;
    }

    /**
     * 
    * 清楚部队阵容中兵已经死光的格子
    * @param fighter  
    * void
     */
    private void clearKilled(Fighter fighter) {
        for (int i = 0; i < fighter.forces.length; i++) {
            Force force = fighter.forces[i];
            if (force != null) {
                if (!force.alive()) {
                    fighter.forces[i] = null;
                } else {
                    force.killed = 0;
                }
            }
        }
    }

    /**
     * 战斗单元要么为NULL要么count>0, 不应该出现不为NULL但是坦克数量为0的状况
     * @param airship
     * @param player
     * @param fighter
     * @return
     */
    private boolean check(Airship airship, Player player, Fighter fighter){
        for (Force force : fighter.forces) {
            if (force!=null && force.count<=0){
                LogUtil.error(String.format("airship id :%d, nick :%s, force not null but tank count == 0 , force info :%s",
                        airship.getId(), player.lord.getNick(), Arrays.toString(fighter.forces)));
                return false;
            }
        }
        return true;
    }
    
    /**
     * 兄弟同心活动加buff
     * @param fighter
     * @param map
     */
    private void addBuff(Fighter fighter, Map<Integer, Integer> map) {
		if (map == null || map.size() == 0) {
			return;
		}
		StaticActBrotherBuff buff;
		List<List<Integer>> effects;
		// 每个force都增加buff
		for (Force force : fighter.forces) {
			if (force != null) {
				for (Entry<Integer, Integer> entry : map.entrySet()) {
					buff = staticActivityDataMgr.getActBrotherBuff(entry.getKey(), entry.getValue());
					effects = buff.getEffcetVal();
					for (List<Integer> e : effects) {
						force.attrData.addValue(e.get(0), e.get(1));
					}
				}
			}
		}
    }

//    public void printAirshipRecord(CommonPb.Report report) {
//        CommonPb.RptAtkAirship atkAirship = report.getAtkAirship();
//        CommonPb.RptAtkAirship defAirship = report.getDefAirship();
//        if (atkAirship != null) {
//
//        }
//    }
//
//    private void print(CommonPb.RptAtkAirship report) {
//        String SP = "\n";
//        StringBuilder aspSb = new StringBuilder();
//        aspSb.append(String.format("进攻方 :%s, ----------> 防守方 :%s, 飞艇ID :%d, 战斗结果 :%b, ",
//                report.getAttackerName(), report.getDefencerName(), report.getAirshipId(), report.getResult())).append(SP);
//
//    }
//
//    private void print(int round, CommonPb.TwoLong tl, CommonPb.Record record, boolean bFirst) {
//        String SP = "\n";
//        StringBuilder recSb = new StringBuilder();
//        recSb.append(String.format("**********************当前回合 :%d ***************************", round)).append(SP);
//        recSb.append(String.format("进攻位置 :%d, 坦克名字 :%d, "));
//    }
//
//    private void print(CommonPb.Record rcd) {
//        String SP = "\n";
//        StringBuilder rcdSb = new StringBuilder();
//        rcdSb.append("key Id :%d" + rcd.getKeyId()).append(SP);
//        rcdSb.append(String.format("初始HP 列表 :%s", Arrays.toString(rcd.getHpList().toArray()))).append(SP);
////        rcdSb.append(String.format())
//    }
}
