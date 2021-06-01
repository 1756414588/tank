package com.game.service.teaminstance;

import com.game.constant.AttackType;
import com.game.constant.FirstActType;
import com.game.constant.FormType;
import com.game.datamgr.StaticBountyDataMgr;
import com.game.domain.CrossPlayer;
import com.game.domain.p.Form;
import com.game.domain.s.StaticBountyEnemy;
import com.game.domain.s.StaticBountySkill;
import com.game.fight.FightLogic;
import com.game.fight.domain.Fighter;
import com.game.fight.domain.Force;
import com.game.pb.CommonPb;
import com.game.pb.GamePb6;
import com.game.service.FightService;
import com.game.util.PbHelper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

/**
 * @author GuiJie
 * @description 描述
 * @created 2018/04/19 11:19
 */
@Component
public class TeamFightLogic {
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
     */
    public void fight(Team team) {
        List<StaticBountyEnemy> bountyEnemyConfig = new ArrayList<>();
        List<StaticBountyEnemy> configList = staticBountyDataMgr.getBountyEnemyConfig(team.getTeamType());
        int dayiy = 1;
        List<Integer> opList = new ArrayList<>();
        for (Long roleId : team.getMembersInfo().keySet()) {
            CrossPlayer player = CrossPlayerCacheLoader.get(roleId);
            if (player != null) {
                opList.add(player.getOpenTime());
            }
        }
        dayiy = Collections.min(opList);
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
            CrossPlayer crossPlayer = CrossPlayerCacheLoader.get(roleId);
            Form form = new Form(crossPlayer.getForms().get(FormType.TEAM));
            teamPlayers.add(new TeamPlayer(crossPlayer, form));
            tankCount += form.getTankCount();
        }
        _fight(team.getTeamType(), team, teamPlayers, monsters, tankCount);

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
            Fighter atker = fightService.createFighter(player.getCrossPlayer(), player.getForm(), AttackType.ACK_DEFAULT_PLAYER);
            atker.setTeamFrom(player.getForm());
            while (!isPlayerEnd) {
                FightLogic fightLogic = new FightLogic(atker, defer, FirstActType.ATTACKER, true);
                fightLogic.packForm(atker.getTeamFrom(), defer.getTeamFrom());
                fightLogic.fightTeam();
                recordList.add(fightLogic.generateRecord());
                recordLordList.add(atker.crossPlayer.getRoleId());
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
                        //TODO: 任务更新
                        isSucc = true;
                        if (stageId == 102 && countPlayer == 1) {
                            for (TeamPlayer p : teamPlayers) {
                                teamInstanceService.changeTask(p.getCrossPlayer(), 7, 1);
                            }
                        }
                        if (stageId == 103 && countPlayer == 3) {
                            for (TeamPlayer p : teamPlayers) {
                                teamInstanceService.changeTask(p.getCrossPlayer(), 8, 1);
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

                        }
                    }

                }

            }

        }
//        printRecordList(recordList);
        for (TeamPlayer player : teamPlayers) {
            teamInstanceService.succFight(recordList, tankCount, recordLordList, player, stageId, isSucc);
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
            if (f == null) {
                continue;
            }

            if (f.staticTank.getType() == 5 && !f.alive()) {
                for (TeamPlayer player : teamPlayers) {
                    teamInstanceService.changeTask(player.getCrossPlayer(), 9, 1);
                }
            }

            if (f.staticTank.getType() == 5) {
                //teamInstanceService.changeTask(null, );

                teamInstanceService.changeServerTask(5, f.lcbHurt, teamPlayers);
            }


            if (f.staticTank.getType() == 5 && !f.alive() && f.force == 0) {
                for (TeamPlayer player : teamPlayers) {
                    teamInstanceService.changeTask(player.getCrossPlayer(), 1, 1);
                }
            }
            if (f.staticTank.getType() == 6 && !f.alive() && f.zbCount == 6) {
                for (TeamPlayer player : teamPlayers) {
                    teamInstanceService.changeTask(player.getCrossPlayer(), 3, 1);
                }
            }
            if (f.staticTank.getType() == 7 && !f.alive()) {
                for (TeamPlayer player : teamPlayers) {
                    teamInstanceService.changeTask(player.getCrossPlayer(), 4, 1);
                }
            }
            if (f.staticTank.getType() == 8 && !f.alive()) {
                //teamInstanceService.changeTask(null, 2, 1);
                teamInstanceService.changeServerTask(2, 1, teamPlayers);
            }
            if (f.staticTank.getType() == 6 && !f.alive() && f.zbCount > 0) {
                //teamInstanceService.changeTask(null, 6, f.zbCount);
                teamInstanceService.changeServerTask(6, f.zbCount, teamPlayers);
            }
        }
    }


}

class TeamPlayer {
    private CrossPlayer crossPlayer;
    private Form form;
    private GamePb6.SyncTeamFightBossRq.Builder builder = GamePb6.SyncTeamFightBossRq.newBuilder();

    public TeamPlayer(CrossPlayer crossPlayer, Form form) {
        this.crossPlayer = crossPlayer;
        this.form = form;
    }

    public CrossPlayer getCrossPlayer() {
        return crossPlayer;
    }

    public void setCrossPlayer(CrossPlayer player) {
        this.crossPlayer = player;
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