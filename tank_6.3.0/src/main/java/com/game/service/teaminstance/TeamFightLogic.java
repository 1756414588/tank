package com.game.service.teaminstance;

import com.alibaba.fastjson.JSON;
import com.game.common.ServerSetting;
import com.game.constant.AttackType;
import com.game.constant.FirstActType;
import com.game.constant.FormType;
import com.game.dataMgr.StaticBountyDataMgr;
import com.game.domain.Player;
import com.game.domain.p.Form;
import com.game.domain.s.StaticBountyEnemy;
import com.game.domain.s.StaticBountySkill;
import com.game.fight.FightLogic;
import com.game.fight.domain.Fighter;
import com.game.fight.domain.Force;
import com.game.manager.PlayerDataManager;
import com.game.pb.BasePb;
import com.game.pb.CommonPb;
import com.game.pb.GamePb6;
import com.game.server.GameServer;
import com.game.service.FightService;
import com.game.util.DateHelper;
import com.game.util.LogUtil;
import com.game.util.PbHelper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.*;

/**
 * @author GuiJie
 * @description 描述
 * @created 2018/04/19 11:19
 */
@Component
public class TeamFightLogic {
    @Autowired
    private PlayerDataManager playerDataManager;
    @Autowired
    private FightService fightService;
    @Autowired
    private StaticBountyDataMgr staticBountyDataMgr;
    @Autowired
    private TeamInstanceService teamInstanceService;


    /**
     * 战斗
     *
     * @param team
     * @param stageId
     */
    public void fight(Team team, int stageId) {
        List<StaticBountyEnemy> bountyEnemyConfig = new ArrayList<>();
        List<StaticBountyEnemy> configList = staticBountyDataMgr.getBountyEnemyConfig(stageId);
        String openTime = GameServer.ac.getBean(ServerSetting.class).getOpenTime();
        Date openDate = DateHelper.parseDate(openTime);
        int dayiy = DateHelper.dayiy(openDate, new Date());
        for (StaticBountyEnemy cc : configList) {
            if (dayiy >= cc.getServerBegin() && dayiy <= cc.getServerEnd()) {
                bountyEnemyConfig.add(cc);
            }
        }
        Collections.sort(bountyEnemyConfig, new Comparator<StaticBountyEnemy>() {
            @Override
            public int compare(StaticBountyEnemy o1, StaticBountyEnemy o2) {
                return o1.getWave() - o2.getWave();
            }
        });
        List<TeamMonster> monsters = new ArrayList<>();
        for (StaticBountyEnemy c : bountyEnemyConfig) {
            StaticBountySkill config = null;
            List<Integer> skillId = c.getSkillId();
            if (skillId != null && !skillId.isEmpty()) {
                config = staticBountyDataMgr.getBountySkillConfig(skillId.get(0));
            }
            monsters.add(new TeamMonster(c, config, createForm(c.getEnemy())));
        }

        List<TeamPlayer> teamPlayers = new ArrayList<>();


        int tankCount = 0;

        List<Long> order = team.getOrder();
        for (long roleId : order) {
            Player p = playerDataManager.getPlayer(roleId);
            Form form = new Form(p.forms.get(FormType.TEAM));
            teamPlayers.add(new TeamPlayer(p, form));

            tankCount += form.getTankCount();
        }


        _fight(stageId, team, teamPlayers, monsters, tankCount);

    }


    /**
     * 战斗
     *
     * @param stageId
     * @param team
     * @param teamPlayers
     * @param monsters
     */
    private void _fight(int stageId, Team team, List<TeamPlayer> teamPlayers, List<TeamMonster> monsters, int tankCount) {


        List<CommonPb.Record> recordList = new ArrayList<>();
        List<Long> recordLordList = new ArrayList<>();

        TeamMonster teamMonster = monsters.get(0);
        Form deferForm = new Form(teamMonster.getForm());
        Fighter defer = fightService.createTeamFighter(deferForm, teamMonster.getStaticBountyEnemy(), teamMonster.getStaticBountySkill());
        defer.setTeamFrom(deferForm);

        int wave = 1;

        //战斗是否成功
        boolean isSucc = false;

        int countPlayer = 0;

        for (TeamPlayer player : teamPlayers) {

            if (isSucc) {
                break;
            }

            countPlayer++;

            //单个玩家是否战斗结束
            boolean isPlayerEnd = false;
            Fighter atker = fightService.createFighter(player.getPlayer(), player.getForm(), AttackType.ACK_DEFAULT_PLAYER);
            atker.setTeamFrom(player.getForm());


            while (!isPlayerEnd) {

                FightLogic fightLogic = new FightLogic(atker, defer, FirstActType.ATTACKER, true);

                fightLogic.packForm(atker.getTeamFrom(), defer.getTeamFrom());
                fightLogic.fightTeam();

                recordList.add(fightLogic.generateRecord());
                recordLordList.add(atker.player.roleId);


                //如果双方都死了
                boolean isAllOver = true;

                Force[] atkerForces = atker.forces;
                for (Force f : atkerForces) {
                    if (f != null && f.alive()) {
                        isAllOver = false;
                    }
                }

                Force[] deferForces = defer.forces;
                for (Force f : deferForces) {
                    if (f != null && f.alive()) {
                        isAllOver = false;
                    }
                }

                refTask(deferForces, teamPlayers);


                if (isAllOver) {
                    isPlayerEnd = true;
                }

                clearKilled(atker);
                clearKilled(defer);


                //玩家赢了
                if (fightLogic.getWinState() == 1) {
                    //还有下一波怪
                    if (wave < monsters.size()) {
                        TeamMonster teamMonster1 = monsters.get(wave);
                        deferForm = new Form(teamMonster1.getForm());
                        defer = fightService.createTeamFighter(deferForm, teamMonster1.getStaticBountyEnemy(), teamMonster1.getStaticBountySkill());
                        defer.setTeamFrom(deferForm);

                        wave++;

                    } else {
                        //玩家赢了
                        isSucc = true;

                        if (stageId == 102 && countPlayer == 1) {
                            for (TeamPlayer p : teamPlayers) {
                                teamInstanceService.changeTask(p.getPlayer(), 7, 1);
                            }
                        }

                        if (stageId == 103 && countPlayer == 3) {
                            for (TeamPlayer p : teamPlayers) {
                                teamInstanceService.changeTask(p.getPlayer(), 8, 1);
                            }
                        }

                        break;
                    }

                    //玩家输了换下一个玩家
                } else {
                    isPlayerEnd = true;

                    //清空防守方震慑眩晕
                    Force[] forces = defer.forces;
                    for (Force f : forces) {
                        if (f != null) {
                            if (f.dizzy) {
                                f.dizzy = false;
                            }

//                            if( f.frightenDizzy ){
//                                f.frightenDizzy = false;
//                                f.frightenNum =0;
//                            }

                        }
                    }

                }

            }

        }


//        printRecordList(recordList);


        for (TeamPlayer player : teamPlayers) {

            for (CommonPb.Record record : recordList) {
                player.getBuilder().addRecord(record);
            }

            player.getBuilder().setTankCount(tankCount);

            for (Long recordLord : recordLordList) {
                player.getBuilder().addRecordLord(PbHelper.createTwoLongPb(recordLord, -1));
            }

            teamInstanceService.succFight(player.getPlayer(), player.getBuilder(), stageId, isSucc);

            if (player.getPlayer().isActive() && player.getPlayer().isLogin && player.getPlayer().ctx != null) {
                BasePb.Base.Builder msg = PbHelper.createSynBase(GamePb6.SyncTeamFightBossRq.EXT_FIELD_NUMBER, GamePb6.SyncTeamFightBossRq.ext, player.getBuilder().build());
                GameServer.getInstance().synMsgToPlayer(player.getPlayer().ctx, msg);
            }
        }
        TeamManager.dismissTeam(team);

    }

    private void clearKilled(Fighter fighter) {
        for (int i = 0; i < fighter.forces.length; i++) {
            Force force = fighter.forces[i];
            if (force != null) {

                force.lcbHurt = 0;
                force.zbCount = 0;

                if (!force.alive()) {
                    fighter.getTeamFrom().p[force.pos - 1] = 0;
                    fighter.getTeamFrom().c[force.pos - 1] = 0;
                    fighter.forces[i] = null;
                } else {
                    //损兵
                    if (force.killed > 0) {
                        fighter.getTeamFrom().c[force.pos - 1] = fighter.getTeamFrom().c[force.pos - 1] - force.killed;
                    }
                }
            }
        }
    }


    private void printRecordList(List<CommonPb.Record> recordList) {

        LogUtil.info("***************************************");


        for (CommonPb.Record record : recordList) {

            List<Long> hpList = record.getHpList();
            LogUtil.info("hp " + JSON.toJSONString(hpList));
            LogUtil.info("A  " + record.getFormA().toString());
            LogUtil.info("B  " + record.getFormB().toString());

            List<CommonPb.Round> roundList = record.getRoundList();


            for (CommonPb.Round round : roundList) {

                if (round.getKey() % 2 == 0) {
                    LogUtil.info("防御 " + (round.getKey() / 2));
                } else {
                    LogUtil.info("攻击 " + (round.getKey() + 1) / 2);
                }

                List<CommonPb.Action> actionList = round.getActionList();

                if (actionList.isEmpty()) {
                    LogUtil.info("取消眩晕效果 ");
                }


                for (CommonPb.Action action : actionList) {

                    if (round.getKey() % 2 == 0) {
                        LogUtil.info("======防action  " + (round.getKey() / 2) + (action.getFrighten() ? " 震慑 " : "") + (action.getImpale() ? " 穿刺 " : "") + "  " + action.toString());
                    } else {
                        LogUtil.info("======攻action  " + (round.getKey() + 1) / 2 + (action.getFrighten() ? " 震慑 " : "") + (action.getImpale() ? " 穿刺 " : "") + "  " + action.toString());
                    }

                }
                LogUtil.info("%%%%%%%%%%%%%%%%%%%%%%%%%%%%%");
            }
        }

    }


    /**
     * 创建form
     *
     * @param formInfo
     * @return
     */
    private Form createForm(List<List<Integer>> formInfo) {
        Form form = new Form();
        for (List<Integer> info : formInfo) {
            form.p[info.get(3) - 1] = info.get(1);//id
            form.c[info.get(3) - 1] = info.get(2);//数量
        }
        return form;
    }


    /**
     * 类型任务
     *
     * @param deferForces
     * @param teamPlayers
     */
    private void refTask(Force[] deferForces, List<TeamPlayer> teamPlayers) {
        for (Force f : deferForces) {
            if (f != null) {
                if (f.staticTank.getType() == 5 && !f.alive()) {
                    for (TeamPlayer player : teamPlayers) {
                        teamInstanceService.changeTask(player.getPlayer(), 9, 1);
                    }
                }

                if (f.staticTank.getType() == 5) {
                    teamInstanceService.changeTask(null, 5, f.lcbHurt);
                }


                if (f.staticTank.getType() == 5 && !f.alive() && f.force == 0) {
                    for (TeamPlayer player : teamPlayers) {
                        teamInstanceService.changeTask(player.getPlayer(), 1, 1);
                    }
                }

                if (f.staticTank.getType() == 6 && !f.alive() && f.zbCount == 6) {
                    for (TeamPlayer player : teamPlayers) {
                        teamInstanceService.changeTask(player.getPlayer(), 3, 1);
                    }
                }

                if (f.staticTank.getType() == 7 && !f.alive()) {
                    for (TeamPlayer player : teamPlayers) {
                        teamInstanceService.changeTask(player.getPlayer(), 4, 1);
                    }
                }


                if (f.staticTank.getType() == 8 && !f.alive()) {
                    teamInstanceService.changeTask(null, 2, 1);
                }


                if (f.staticTank.getType() == 6 && !f.alive() && f.zbCount > 0) {
                    teamInstanceService.changeTask(null, 6, f.zbCount);
                }

            }
        }

    }


}

class TeamPlayer {
    private Player player;
    private Form form;
    private GamePb6.SyncTeamFightBossRq.Builder builder = GamePb6.SyncTeamFightBossRq.newBuilder();

    public TeamPlayer(Player player, Form form) {
        this.player = player;
        this.form = form;
    }

    public Player getPlayer() {
        return player;
    }

    public void setPlayer(Player player) {
        this.player = player;
    }

    public Form getForm() {
        return form;
    }

    public void setForm(Form form) {
        this.form = form;
    }

    public GamePb6.SyncTeamFightBossRq.Builder getBuilder() {
        return builder;
    }

    public void setBuilder(GamePb6.SyncTeamFightBossRq.Builder builder) {
        this.builder = builder;
    }
}

class TeamMonster {

    private StaticBountyEnemy staticBountyEnemy;
    private StaticBountySkill staticBountySkill;
    private Form form;

    public TeamMonster(StaticBountyEnemy staticBountyEnemy, StaticBountySkill staticBountySkill, Form form) {
        this.staticBountyEnemy = staticBountyEnemy;
        this.staticBountySkill = staticBountySkill;
        this.form = form;
    }

    public StaticBountyEnemy getStaticBountyEnemy() {
        return staticBountyEnemy;
    }


    public StaticBountySkill getStaticBountySkill() {
        return staticBountySkill;
    }


    public Form getForm() {
        return form;
    }

    public void setForm(Form form) {
        this.form = form;
    }
}