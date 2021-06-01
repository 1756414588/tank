package com.game.util;

import com.game.domain.CrossPlayer;
import com.game.domain.SeniorScoreRank;
import com.game.domain.p.*;
import com.game.grpc.proto.mine.CrossSeniorMineProto;
import com.game.grpc.proto.team.CrossTeamProto;
import com.game.pb.CommonPb;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * @author yeding
 * @create 2019/4/24 18:24
 * @decs
 */
public class CrossPbHelper {

    public static CrossTeamProto.Form createFormPb(Form form) {
        CrossTeamProto.Form.Builder builder = CrossTeamProto.Form.newBuilder();
        int v = form.getCommander();
        if (v != 0) {
            builder.setCommander(v);
        }
        if (form.getAwakenHero() != null) {
            builder.setAwakenHero(createAwakenHeroPb(form.getAwakenHero()));
        }
        v = form.getType();
        if (v != 0) {
            builder.setType(v);
        }
        v = form.p[0];
        if (v != 0) {
            builder.setP1(createTwoIntPb(v, form.c[0]));
        }
        v = form.p[1];
        if (v != 0) {
            builder.setP2(createTwoIntPb(v, form.c[1]));
        }
        v = form.p[2];
        if (v != 0) {
            builder.setP3(createTwoIntPb(v, form.c[2]));
        }
        v = form.p[3];
        if (v != 0) {
            builder.setP4(createTwoIntPb(v, form.c[3]));
        }
        v = form.p[4];
        if (v != 0) {
            builder.setP5(createTwoIntPb(v, form.c[4]));
        }

        v = form.p[5];
        if (v != 0) {
            builder.setP6(createTwoIntPb(v, form.c[5]));
        }

        if (form.getTacticsKeyId() != null && !form.getTacticsKeyId().isEmpty()) {
            builder.addAllTacticsKeyId(form.getTacticsKeyId());
        }
        if (form.getTacticsList() != null && !form.getTacticsList().isEmpty()) {
            for (TowInt e : form.getTacticsList()) {
                builder.addTactics(createTwoIntPb(e.getKey(), e.getValue()));
            }
        }

        return builder.build();
    }

    /**
     * 跨服组队 form 反序列化
     *
     * @param form
     * @return
     */
    public static Form createForm(CrossTeamProto.Form form) {
        Form e = new Form();
        e.setType(form.getType());
        if (form.hasAwakenHero()) {
            e.setAwakenHero(new AwakenHero(form.getAwakenHero()));
        }
        if (form.hasCommander()) {
            e.setCommander(form.getCommander());
        }
        if (form.hasP1()) {
            CrossTeamProto.TwoInt p = form.getP1();
            e.p[0] = p.getV1();
            e.c[0] = p.getV2();
        }
        if (form.hasP2()) {
            CrossTeamProto.TwoInt p = form.getP2();
            e.p[1] = p.getV1();
            e.c[1] = p.getV2();
        }
        if (form.hasP3()) {
            CrossTeamProto.TwoInt p = form.getP3();
            e.p[2] = p.getV1();
            e.c[2] = p.getV2();
        }
        if (form.hasP4()) {
            CrossTeamProto.TwoInt p = form.getP4();
            e.p[3] = p.getV1();
            e.c[3] = p.getV2();
        }
        if (form.hasP5()) {
            CrossTeamProto.TwoInt p = form.getP5();
            e.p[4] = p.getV1();
            e.c[4] = p.getV2();
        }
        if (form.hasP6()) {
            CrossTeamProto.TwoInt p = form.getP6();
            e.p[5] = p.getV1();
            e.c[5] = p.getV2();
        }
        e.setTacticsKeyId(new ArrayList<Integer>(form.getTacticsKeyIdList()));
        List<CrossTeamProto.TwoInt> tacticsList = form.getTacticsList();
        for (CrossTeamProto.TwoInt t : tacticsList) {
            e.getTacticsList().add(new TowInt(t.getV1(), t.getV2()));
        }
        return e;
    }

    public static CrossTeamProto.AwakenHero createAwakenHeroPb(AwakenHero awakenHero) {
        CrossTeamProto.AwakenHero.Builder builder = CrossTeamProto.AwakenHero.newBuilder();
        builder.setKeyId(awakenHero.getKeyId());
        builder.setHeroId(awakenHero.getHeroId());
        builder.setState(awakenHero.getState());
        for (Map.Entry<Integer, Integer> entry : awakenHero.getSkillLv().entrySet()) {
            builder.addSkillLv(createTwoIntPb(entry.getKey(), entry.getValue()));
        }
        builder.setFailTimes(awakenHero.getFailTimes());
        return builder.build();
    }

    public static CrossSeniorMineProto.MineAwakenHero createMineAwakenHeroPb(AwakenHero awakenHero) {
        CrossSeniorMineProto.MineAwakenHero.Builder builder = CrossSeniorMineProto.MineAwakenHero.newBuilder();
        builder.setKeyId(awakenHero.getKeyId());
        builder.setHeroId(awakenHero.getHeroId());
        builder.setState(awakenHero.getState());
        for (Map.Entry<Integer, Integer> entry : awakenHero.getSkillLv().entrySet()) {
            builder.addSkillLv(createMineTwoIntPb(entry.getKey(), entry.getValue()));
        }
        builder.setFailTimes(awakenHero.getFailTimes());
        return builder.build();
    }

    public static CrossTeamProto.TwoInt createTwoIntPb(int p, int c) {
        CrossTeamProto.TwoInt.Builder builder = CrossTeamProto.TwoInt.newBuilder();
        builder.setV1(p);
        builder.setV2(c);
        return builder.build();
    }

    public static CrossSeniorMineProto.MineTwoInt createMineTwoIntPb(int p, int c) {
        CrossSeniorMineProto.MineTwoInt.Builder builder = CrossSeniorMineProto.MineTwoInt.newBuilder();
        builder.setV1(p);
        builder.setV2(c);
        return builder.build();
    }

    /**
     * 军矿信息
     *
     * @param my
     * @param player
     * @param army
     * @param party
     * @param freeWarTime
     * @param startFreeWarTime
     * @return
     */
    static public CrossSeniorMineProto.SeniorMapData createSeniorPb(CrossPlayer my, CrossPlayer player, Army army, boolean party, long freeWarTime, long startFreeWarTime) {
        CrossSeniorMineProto.SeniorMapData.Builder builder = CrossSeniorMineProto.SeniorMapData.newBuilder();
        builder.setPos(army.getTarget());
        builder.setName(player.getNick());
        builder.setParty(party);
        long now = System.currentTimeMillis();
        if (army.getOccupy()) {
            int t = (int) ((army.getCaiJiStartTime() / 1000) + 1800 + (int) ((freeWarTime - startFreeWarTime) / 1000));
            builder.setFreeTime(t);
        } else {
            if (freeWarTime > 0 && freeWarTime > now) {
                builder.setFreeTime((int) (freeWarTime / 1000));
            }
        }
        if (my.getRoleId() != player.getRoleId()) {
            builder.setMy(false);
        } else {
            builder.setMy(true);
        }
        return builder.build();
    }


    /**
     * 跨服军矿form
     *
     * @param form
     * @return
     */
    public static CrossSeniorMineProto.MineForm createMineFormPb(Form form) {
        CrossSeniorMineProto.MineForm.Builder builder = CrossSeniorMineProto.MineForm.newBuilder();
        int v = form.getCommander();
        if (v != 0) {
            builder.setCommander(v);
        }
        if (form.getAwakenHero() != null) {
            builder.setAwakenHero(createMineAwakenHeroPb(form.getAwakenHero()));
        }
        v = form.getType();
        if (v != 0) {
            builder.setType(v);
        }
        v = form.p[0];
        if (v != 0) {
            builder.setP1(createMineTwoIntPb(v, form.c[0]));
        }
        v = form.p[1];
        if (v != 0) {
            builder.setP2(createMineTwoIntPb(v, form.c[1]));
        }
        v = form.p[2];
        if (v != 0) {
            builder.setP3(createMineTwoIntPb(v, form.c[2]));
        }
        v = form.p[3];
        if (v != 0) {
            builder.setP4(createMineTwoIntPb(v, form.c[3]));
        }
        v = form.p[4];
        if (v != 0) {
            builder.setP5(createMineTwoIntPb(v, form.c[4]));
        }
        v = form.p[5];
        if (v != 0) {
            builder.setP6(createMineTwoIntPb(v, form.c[5]));
        }
        if (form.getTacticsKeyId() != null && !form.getTacticsKeyId().isEmpty()) {
            builder.addAllTacticsKeyId(form.getTacticsKeyId());
        }
        if (form.getTacticsList() != null && !form.getTacticsList().isEmpty()) {
            for (TowInt e : form.getTacticsList()) {
                builder.addTactics(createMineTwoIntPb(e.getKey(), e.getValue()));
            }
        }
        return builder.build();
    }


    public static CrossSeniorMineProto.MineForm createMineFormPb(CommonPb.Form form) {
        CrossSeniorMineProto.MineForm.Builder builder = CrossSeniorMineProto.MineForm.newBuilder();
        int v = form.getCommander();
        if (v != 0) {
            builder.setCommander(v);
        }
        if (form.getAwakenHero() != null) {
            CommonPb.AwakenHero awakenHero = form.getAwakenHero();
            builder.setAwakenHero(createMineAwakenHeroPb(awakenHero));
        }
        v = form.getType();
        if (v != 0) {
            builder.setType(v);
        }
        v = form.getP1().getV1();
        if (v != 0) {
            builder.setP1(createMineTwoIntPb(v, form.getP1().getV2()));
        }
        v = form.getP2().getV1();
        if (v != 0) {
            builder.setP2(createMineTwoIntPb(v, form.getP2().getV2()));
        }
        v = form.getP3().getV1();
        if (v != 0) {
            builder.setP3(createMineTwoIntPb(v, form.getP3().getV2()));
        }
        v = form.getP4().getV1();
        if (v != 0) {
            builder.setP4(createMineTwoIntPb(v, form.getP4().getV2()));
        }
        v = form.getP5().getV1();
        if (v != 0) {
            builder.setP5(createMineTwoIntPb(v, form.getP5().getV2()));
        }
        v = form.getP6().getV1();
        if (v != 0) {
            builder.setP6(createMineTwoIntPb(v, form.getP6().getV2()));
        }
        if (form.getTacticsKeyIdList() != null && !form.getTacticsKeyIdList().isEmpty()) {
            builder.addAllTacticsKeyId(form.getTacticsKeyIdList());
        }
        if (form.getTacticsList() != null && !form.getTacticsList().isEmpty()) {
            for (CommonPb.TwoInt e : form.getTacticsList()) {
                builder.addTactics(createMineTwoIntPb(e.getV1(), e.getV2()));
            }
        }
        return builder.build();
    }

    public static CrossSeniorMineProto.MineAwakenHero createMineAwakenHeroPb(CommonPb.AwakenHero awakenHero) {
        CrossSeniorMineProto.MineAwakenHero.Builder builder = CrossSeniorMineProto.MineAwakenHero.newBuilder();
        builder.setKeyId(awakenHero.getKeyId());
        builder.setHeroId(awakenHero.getHeroId());
        builder.setState(awakenHero.getState());
        for (CommonPb.TwoInt e : awakenHero.getSkillLvList()) {
            builder.addSkillLv(createMineTwoIntPb(e.getV1(), e.getV2()));
        }
        builder.setFailTimes(awakenHero.getFailTimes());
        return builder.build();
    }


    public static Form createForm(CrossSeniorMineProto.MineForm form) {
        Form e = new Form();
        e.setType(form.getType());
        if (form.hasAwakenHero()) {
            e.setAwakenHero(new AwakenHero(form.getAwakenHero()));
        }
        if (form.hasCommander()) {
            e.setCommander(form.getCommander());
        }
        if (form.hasP1()) {
            CrossSeniorMineProto.MineTwoInt p = form.getP1();
            e.p[0] = p.getV1();
            e.c[0] = p.getV2();
        }
        if (form.hasP2()) {
            CrossSeniorMineProto.MineTwoInt p = form.getP2();
            e.p[1] = p.getV1();
            e.c[1] = p.getV2();
        }
        if (form.hasP3()) {
            CrossSeniorMineProto.MineTwoInt p = form.getP3();
            e.p[2] = p.getV1();
            e.c[2] = p.getV2();
        }
        if (form.hasP4()) {
            CrossSeniorMineProto.MineTwoInt p = form.getP4();
            e.p[3] = p.getV1();
            e.c[3] = p.getV2();
        }
        if (form.hasP5()) {
            CrossSeniorMineProto.MineTwoInt p = form.getP5();
            e.p[4] = p.getV1();
            e.c[4] = p.getV2();
        }
        if (form.hasP6()) {
            CrossSeniorMineProto.MineTwoInt p = form.getP6();
            e.p[5] = p.getV1();
            e.c[5] = p.getV2();
        }
        e.setTacticsKeyId(new ArrayList<>(form.getTacticsKeyIdList()));
        List<CrossSeniorMineProto.MineTwoInt> tacticsList = form.getTacticsList();
        for (CrossSeniorMineProto.MineTwoInt t : tacticsList) {
            e.getTacticsList().add(new TowInt(t.getV1(), t.getV2()));
        }
        return e;
    }

    static public CommonPb.RptTank createRtpTankPb(RptTank rptTank) {
        CommonPb.RptTank.Builder builder = CommonPb.RptTank.newBuilder();
        builder.setTankId(rptTank.getTankId());
        builder.setCount(rptTank.getCount());
        return builder.build();
    }

    public static CommonPb.TwoInt createCrossMineTwoIntPb(int p, int c) {
        CommonPb.TwoInt.Builder builder = CommonPb.TwoInt.newBuilder();
        builder.setV1(p);
        builder.setV2(c);
        return builder.build();
    }

    static public CrossSeniorMineProto.ScoreRank createScoreRankPb(String name, SeniorScoreRank scoreRank) {
        CrossSeniorMineProto.ScoreRank.Builder builder = CrossSeniorMineProto.ScoreRank.newBuilder();
        builder.setName(name);
        builder.setFight(scoreRank.getFight());
        builder.setScore(scoreRank.getScore());
        return builder.build();
    }




}
