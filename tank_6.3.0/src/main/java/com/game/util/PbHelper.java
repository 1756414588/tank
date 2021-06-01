/**
 * @Title: PbHelper.java
 * @Package com.game.util
 * @Description:
 * @author ZhangJun
 * @date 2015年8月26日 下午3:47:08
 * @version V1.0
 */
package com.game.util;

import com.game.common.ServerSetting;
import com.game.constant.*;
import com.game.domain.MedalBouns;
import com.game.domain.*;
import com.game.domain.p.ActLuckyPoolLog;
import com.game.domain.p.ActPartyRank;
import com.game.domain.p.ActPlayerRank;
import com.game.domain.p.Activity;
import com.game.domain.p.Army;
import com.game.domain.p.ArmyStatu;
import com.game.domain.p.AwakenHero;
import com.game.domain.p.Award;
import com.game.domain.p.Bless;
import com.game.domain.p.BuildQue;
import com.game.domain.p.Cash;
import com.game.domain.p.Chip;
import com.game.domain.p.Collect;
import com.game.domain.p.Combat;
import com.game.domain.p.Day7Act;
import com.game.domain.p.Effect;
import com.game.domain.p.EnergyStoneInlay;
import com.game.domain.p.Equip;
import com.game.domain.p.FailNum;
import com.game.domain.p.Form;
import com.game.domain.p.FortressBattleParty;
import com.game.domain.p.Friend;
import com.game.domain.p.Grab;
import com.game.domain.p.Hero;
import com.game.domain.p.LiveTask;
import com.game.domain.p.LotteryEquip;
import com.game.domain.p.Mail;
import com.game.domain.p.Man;
import com.game.domain.p.Medal;
import com.game.domain.p.MedalChip;
import com.game.domain.p.MilitaryMaterial;
import com.game.domain.p.MilitaryScience;
import com.game.domain.p.MilitaryScienceGrid;
import com.game.domain.p.Mill;
import com.game.domain.p.Mine;
import com.game.domain.p.Part;
import com.game.domain.p.PartyApply;
import com.game.domain.p.PartyCombat;
import com.game.domain.p.PartyDonate;
import com.game.domain.p.PartyLvRank;
import com.game.domain.p.PartyProp;
import com.game.domain.p.PartyRank;
import com.game.domain.p.PartySection;
import com.game.domain.p.Pendant;
import com.game.domain.p.Portrait;
import com.game.domain.p.Prop;
import com.game.domain.p.PropQue;
import com.game.domain.p.PushComment;
import com.game.domain.p.QuinnPanel;
import com.game.domain.p.RefitQue;
import com.game.domain.p.RptTank;
import com.game.domain.p.Ruins;
import com.game.domain.p.Science;
import com.game.domain.p.ScienceQue;
import com.game.domain.p.SecretWeapon;
import com.game.domain.p.SecretWeaponBar;
import com.game.domain.p.Shop;
import com.game.domain.p.ShopBuy;
import com.game.domain.p.Store;
import com.game.domain.p.Tactics;
import com.game.domain.p.Tank;
import com.game.domain.p.TankQue;
import com.game.domain.p.Task;
import com.game.domain.p.Trend;
import com.game.domain.p.TrendParam;
import com.game.domain.p.WarRankInfo;
import com.game.domain.p.Weal;
import com.game.domain.p.WipeInfo;
import com.game.domain.p.*;
import com.game.domain.p.airship.Airship;
import com.game.domain.p.airship.AirshipTeam;
import com.game.domain.p.corss.ComptePojo;
import com.game.domain.p.corss.CompteRound;
import com.game.domain.p.corss.CrossFame;
import com.game.domain.p.corss.CrossFameInfo;
import com.game.domain.p.corss.FameBattleReview;
import com.game.domain.p.corss.FamePojo;
import com.game.domain.p.corssParty.CPFame;
import com.game.domain.p.corssParty.CPFameInfo;
import com.game.domain.p.friend.FriendGive;
import com.game.domain.p.friend.Friendliness;
import com.game.domain.p.friend.GetGiveProp;
import com.game.domain.p.lordequip.LordEquip;
import com.game.domain.p.lordequip.LordEquipBuilding;
import com.game.domain.p.lordequip.LordEquipMatBuilding;
import com.game.domain.s.*;
import com.game.domain.sort.ActRedBag;
import com.game.domain.sort.GrabRedBag;
import com.game.drill.domain.DrillFightData;
import com.game.drill.domain.DrillRank;
import com.game.drill.domain.DrillRecord;
import com.game.drill.domain.DrillResult;
import com.game.drill.domain.DrillShopBuy;
import com.game.fight.domain.Fighter;
import com.game.fortressFight.domain.FortressJobAppoint;
import com.game.fortressFight.domain.MyFortressAttr;
import com.game.fortressFight.domain.MyFortressFightData;
import com.game.fortressFight.domain.MyPartyStatistics;
import com.game.fortressFight.domain.*;
import com.game.grpc.proto.team.CrossTeamProto;
import com.game.honour.domain.HonourPartyScore;
import com.game.pb.BasePb.Base;
import com.game.pb.CommonPb;
import com.game.pb.CommonPb.Extreme;
import com.game.pb.CommonPb.MyCD;
import com.game.pb.CommonPb.SufferTank;
import com.game.pb.CommonPb.TreasureShopBuy;
import com.game.pb.CommonPb.*;
import com.game.pb.InnerPb;
import com.game.rebel.domain.PartyRebelData;
import com.game.rebel.domain.Rebel;
import com.game.rebel.domain.RoleRebelData;
import com.game.server.GameServer;
import com.game.service.FightService;
import com.game.warFight.domain.WarMember;
import com.game.warFight.domain.WarParty;
import com.google.protobuf.GeneratedMessage.GeneratedExtension;
import com.google.protobuf.InvalidProtocolBufferException;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;

/**
 * @author ZhangJun
 * @ClassName: PbHelper
 * @Description: 公用算法
 * @date 2015年8月26日 下午3:47:08
 */
public class PbHelper {
    /**
     * 数字s 右移8位
     *
     * @param s
     * @return byte[]
     */
    public static byte[] putShort(short s) {
        byte[] b = new byte[2];
        b[0] = (byte) (s >> 8);
        b[1] = (byte) (s >> 0);
        return b;
    }

    /**
     * 用来取数据正文的算法
     *
     * @param b
     * @param index
     * @return short
     */
    static public short getShort(byte[] b, int index) {
        return (short) (((b[index + 1] & 0xff) | b[index + 0] << 8));
    }

    /**
     * 从byte中取得协议对象
     *
     * @param result
     * @return
     * @throws InvalidProtocolBufferException Base
     */
    static public Base parseFromByte(byte[] result) throws InvalidProtocolBufferException {
        short len = PbHelper.getShort(result, 0);
        byte[] data = new byte[len];
        System.arraycopy(result, 2, data, 0, len);
        Base rs = Base.parseFrom(data, GameServer.registry);
        return rs;
    }

    /**
     * 创建回执客户端的协议对象
     *
     * @param cmd
     * @param ext
     * @param msg
     * @return Base.Builder
     */
    static public <T> Base.Builder createRsBase(int cmd, GeneratedExtension<Base, T> ext, T msg) {
        Base.Builder baseBuilder = Base.newBuilder();
        baseBuilder.setCmd(cmd);
        baseBuilder.setExtension(ext, msg);
        return baseBuilder;
    }

    /**
     * 创建回执错误信息到客户端的协议对象
     *
     * @param gameError
     * @param cmd
     * @param ext
     * @param msg
     * @return Base.Builder
     */
    static public <T> Base.Builder createRsBase(GameError gameError, int cmd, GeneratedExtension<Base, T> ext, T msg) {
        Base.Builder baseBuilder = Base.newBuilder();
        baseBuilder.setCmd(cmd);
        baseBuilder.setCode(gameError.getCode());
        if (msg != null) {
            baseBuilder.setExtension(ext, msg);
        }

        return baseBuilder;
    }

    /**
     * 创建http请求回执的协议对象
     *
     * @param cmd
     * @param code
     * @return Base
     */
    static public Base createRsBase(int cmd, int code) {
        Base.Builder baseBuilder = Base.newBuilder();
        baseBuilder.setCmd(cmd);
        baseBuilder.setCode(code);
        return baseBuilder.build();
    }

    /**
     * 创建消息协议对象 用来发送到跨服服
     *
     * @param cmd
     * @param param
     * @param ext
     * @param msg
     * @return Base.Builder
     */
    static public <T> Base.Builder createRqBase(int cmd, Long param, GeneratedExtension<Base, T> ext, T msg) {
        Base.Builder baseBuilder = Base.newBuilder();
        baseBuilder.setCmd(cmd);
        if (param != null) {
            baseBuilder.setParam(param);
        }
        baseBuilder.setExtension(ext, msg);
        return baseBuilder;
    }

    /**
     * 创建Broadcast协议对象
     *
     * @param msg
     * @return CommonPb.Broadcast
     */
    static public CommonPb.Broadcast createBroadcast(String[] msg) {
        CommonPb.Broadcast.Builder builder = CommonPb.Broadcast.newBuilder();
        builder.setNick(msg[0]);
        builder.setType(msg[1]);
        builder.setId(msg[2]);
        builder.setCount(msg[3]);
        return builder.build();
    }

    /**
     * 创建TwoInt协议对象
     *
     * @param p
     * @param c
     * @return CommonPb.TwoInt
     */
    static public CommonPb.TwoInt createTwoIntPb(int p, int c) {
        TwoInt.Builder builder = TwoInt.newBuilder();
        builder.setV1(p);
        builder.setV2(c);
        return builder.build();
    }

    /**
     * 创建ThreeInt协议对象
     *
     * @param p
     * @param c
     * @return CommonPb.TwoInt
     */
    static public CommonPb.ThreeInt createThreeIntPb(int p, int c,int s) {
        ThreeInt.Builder builder = ThreeInt.newBuilder();
        builder.setV1(p);
        builder.setV2(c);
        builder.setV3(s);
        return builder.build();
    }

    /**
     * 这个以下一大皮条都是protobuf协议对象和domain对象互转
     *
     * @param prop
     * @return CommonPb.Prop
     */
    static public CommonPb.Prop createPropPb(Prop prop) {
        CommonPb.Prop.Builder builder = CommonPb.Prop.newBuilder();
        builder.setPropId(prop.getPropId());
        builder.setCount(prop.getCount());
        return builder.build();
    }

    static public CommonPb.PropQue createPropQuePb(PropQue e) {
        CommonPb.PropQue.Builder builder = CommonPb.PropQue.newBuilder();
        builder.setKeyId(e.getKeyId());
        builder.setPropId(e.getPropId());
        builder.setCount(e.getCount());
        builder.setState(e.getState());
        builder.setPeriod(e.getPeriod());
        builder.setEndTime(e.getEndTime());
        return builder.build();
    }

    static public CommonPb.Tank createTankPb(Tank tank) {
        CommonPb.Tank.Builder builder = CommonPb.Tank.newBuilder();
        builder.setTankId(tank.getTankId());
        builder.setCount(tank.getCount());
        builder.setRest(tank.getRest());
        return builder.build();
    }

    static public CommonPb.RptTank createRtpTankPb(RptTank rptTank) {
        CommonPb.RptTank.Builder builder = CommonPb.RptTank.newBuilder();
        builder.setTankId(rptTank.getTankId());
        builder.setCount(rptTank.getCount());
        return builder.build();
    }

    static public CommonPb.TankQue createTankQuePb(TankQue e) {
        CommonPb.TankQue.Builder builder = CommonPb.TankQue.newBuilder();
        builder.setKeyId(e.getKeyId());
        builder.setTankId(e.getTankId());
        builder.setCount(e.getCount());
        builder.setState(e.getState());
        builder.setPeriod(e.getPeriod());
        builder.setEndTime(e.getEndTime());
        return builder.build();
    }

    static public CommonPb.RefitQue createRefitQuePb(RefitQue e) {
        CommonPb.RefitQue.Builder builder = CommonPb.RefitQue.newBuilder();
        builder.setKeyId(e.getKeyId());
        builder.setTankId(e.getTankId());
        builder.setRefitId(e.getRefitId());
        builder.setCount(e.getCount());
        builder.setState(e.getState());
        builder.setPeriod(e.getPeriod());
        builder.setEndTime(e.getEndTime());
        return builder.build();
    }

    static public CommonPb.BuildQue createBuildQuePb(BuildQue e) {
        CommonPb.BuildQue.Builder builder = CommonPb.BuildQue.newBuilder();
        builder.setKeyId(e.getKeyId());
        builder.setBuildingId(e.getBuildingId());
        builder.setPos(e.getPos());
        builder.setPeriod(e.getPeriod());
        builder.setEndTime(e.getEndTime());
        builder.setIronCost(e.getIronCost());
        builder.setGoldCost(e.getGoldCost());
        builder.setCopperCost(e.getCopperCost());
        builder.setOilCost(e.getOilCost());
        builder.setSiliconCost(e.getSiliconCost());
        return builder.build();
    }

    // static public CommonPb.Form createFormPb(Army army) {
    // CommonPb.Form.Builder builder = CommonPb.Form.newBuilder();
    // int v = army.getCommander();
    // if (v != 0) {
    // builder.setCommander(v);
    // }
    //
    // v = army.getP1();
    // if (v != 0) {
    // builder.setP1(PbHelper.createTwoIntPb(army.getP1(), army.getC1()));
    // }
    //
    // v = army.getP2();
    // if (v != 0) {
    // builder.setP2(PbHelper.createTwoIntPb(army.getP2(), army.getC2()));
    // }
    //
    // v = army.getP3();
    // if (v != 0) {
    // builder.setP3(PbHelper.createTwoIntPb(army.getP3(), army.getC3()));
    // }
    //
    // v = army.getP4();
    // if (v != 0) {
    // builder.setP4(PbHelper.createTwoIntPb(army.getP4(), army.getC4()));
    // }
    //
    // v = army.getP5();
    // if (v != 0) {
    // builder.setP5(PbHelper.createTwoIntPb(army.getP5(), army.getC5()));
    // }
    //
    // v = army.getP6();
    // if (v != 0) {
    // builder.setP6(PbHelper.createTwoIntPb(army.getP6(), army.getC6()));
    // }
    // return builder.build();
    // }

    static public Grab createGrab(CommonPb.Grab grab) {
        Grab e = new Grab();

        if (grab.hasIron()) {
            e.rs[0] = grab.getIron();
        }

        if (grab.hasOil()) {
            e.rs[1] = grab.getOil();
        }

        if (grab.hasCopper()) {
            e.rs[2] = grab.getCopper();
        }

        if (grab.hasSilicon()) {
            e.rs[3] = grab.getSilicon();
        }

        if (grab.hasStone()) {
            e.rs[4] = grab.getStone();
        }

        return e;
    }

    static public CommonPb.Grab createGrabPb(Grab grab) {
        CommonPb.Grab.Builder builder = CommonPb.Grab.newBuilder();

        if (grab.rs[0] != 0) {
            builder.setIron(grab.rs[0]);
        }

        if (grab.rs[1] != 0) {
            builder.setOil(grab.rs[1]);
        }

        if (grab.rs[2] != 0) {
            builder.setCopper(grab.rs[2]);
        }

        if (grab.rs[3] != 0) {
            builder.setSilicon(grab.rs[3]);
        }

        if (grab.rs[4] != 0) {
            builder.setStone(grab.rs[4]);
        }

        return builder.build();
    }

    static public Collect createCollect(CommonPb.Collect collect) {
        Collect e = new Collect();
        e.load = collect.getLoad();
        e.speed = collect.getSpeed();
        return e;
    }

    static public CommonPb.Collect createCollectPb(Collect collect) {
        CommonPb.Collect.Builder builder = CommonPb.Collect.newBuilder();
        builder.setLoad(collect.load);
        builder.setSpeed(collect.speed);
        return builder.build();
    }

    static public CommonPb.FailNum createFailNumPb(FailNum failNum) {
        CommonPb.FailNum.Builder builder = CommonPb.FailNum.newBuilder();
        builder.setOperType(failNum.getOperType());
        builder.setNum(failNum.getNum());
        return builder.build();
    }

    static public CommonPb.Army createArmyPb(Army army) {
        CommonPb.Army.Builder builder = CommonPb.Army.newBuilder();
        builder.setKeyId(army.getKeyId());
        builder.setTarget(army.getTarget());
        builder.setState(army.getState());
        builder.setPeriod(army.getPeriod());
        builder.setEndTime(army.getEndTime());
        builder.setForm(createFormPb(army.getForm()));
        builder.setIsRuins(army.isRuins());
        builder.setTarQua(army.getTarQua());
        builder.setType(army.getType());
        builder.setCollectBeginTime(army.getCollectBeginTime());
        builder.setHonourGold(army.getHonourGold());
        builder.setHonourScore(army.getHonourScore());

        builder.setNewHeroAddGold(army.getNewHeroAddGold());
        builder.setCaiJiStartTime(army.getCaiJiStartTime());
        builder.setCaiJiEndTime(army.getCaiJiEndTime());
        builder.setNewHeroSubGold(army.getNewHeroSubGold());
        builder.setStaffingExp(army.getStaffingExp());
        builder.setIsZhuJun(army.getIsZhuJun());
        if (army.getGrab() != null) {
            builder.setGrab(createGrabPb(army.getGrab()));
        }

        if (army.getCollect() != null) {
            builder.setCollect(createCollectPb(army.getCollect()));
        }

        if (army.getStaffingTime() != 0) {
            builder.setStaffingTime(army.getStaffingTime());
        }

        if (army.getSenior()) {
            builder.setSenior(true);
        }

        if (army.getOccupy()) {
            builder.setOccupy(true);
        }

        builder.setFight(army.getFight());

        builder.setFreeWarTime(army.getFreeWarTime());
        builder.setStartFreeWarTime(army.getStartFreeWarTime());

        builder.setLoad(army.getLoad());
        builder.setCrossMine(army.isCrossMine());

        return builder.build();
    }

    static public CommonPb.Form createFormPb(Form form) {
        CommonPb.Form.Builder builder = CommonPb.Form.newBuilder();
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

        if (form.getFormName() != null) {
            builder.setFormName(form.getFormName());
        }

        if (form.getTactics() != null && !form.getTactics().isEmpty()) {
            builder.addAllTacticsKeyId(form.getTactics());
        }
        if (form.getTacticsList() != null && !form.getTacticsList().isEmpty()) {
            for (TowInt e : form.getTacticsList()) {
                builder.addTactics(createTwoIntPb(e.getKey(), e.getValue()));
            }
        }

        return builder.build();
    }

    static public CommonPb.Form createFormPb(List<List<Integer>> tanks) {
        CommonPb.Form.Builder builder = CommonPb.Form.newBuilder();
        List<Integer> one;
        one = tanks.get(0);
        if (!one.isEmpty()) {
            builder.setP1(createTwoIntPb(one.get(0), one.get(1)));
        }

        one = tanks.get(1);
        if (!one.isEmpty()) {
            builder.setP2(createTwoIntPb(one.get(0), one.get(1)));
        }

        one = tanks.get(2);
        if (!one.isEmpty()) {
            builder.setP3(createTwoIntPb(one.get(0), one.get(1)));
        }

        one = tanks.get(3);
        if (!one.isEmpty()) {
            builder.setP4(createTwoIntPb(one.get(0), one.get(1)));
        }

        one = tanks.get(4);
        if (!one.isEmpty()) {
            builder.setP5(createTwoIntPb(one.get(0), one.get(1)));
        }

        one = tanks.get(5);
        if (!one.isEmpty()) {
            builder.setP6(createTwoIntPb(one.get(0), one.get(1)));
        }

        return builder.build();
    }

    static public Form createForm(List<List<Integer>> tanks) {
        Form form = new Form();
        List<Integer> one;
        for (int i = 0; i < tanks.size() && i < 6; i++) {
            one = tanks.get(i);
            if (one.isEmpty())
                continue;
            form.p[i] = one.get(0);
            form.c[i] = one.get(1);
        }

        return form;
    }

    static public Form createForm(CommonPb.Form form) {
        Form e = new Form();
        e.setType(form.getType());
        if (form.hasAwakenHero()) {
            e.setAwakenHero(new AwakenHero(form.getAwakenHero()));
        }

        if (form.hasCommander()) {
            e.setCommander(form.getCommander());
        }

        if (form.hasP1()) {
            CommonPb.TwoInt p = form.getP1();
            e.p[0] = p.getV1();
            e.c[0] = p.getV2();
        }

        if (form.hasP2()) {
            CommonPb.TwoInt p = form.getP2();
            e.p[1] = p.getV1();
            e.c[1] = p.getV2();
        }

        if (form.hasP3()) {
            CommonPb.TwoInt p = form.getP3();
            e.p[2] = p.getV1();
            e.c[2] = p.getV2();
        }

        if (form.hasP4()) {
            CommonPb.TwoInt p = form.getP4();
            e.p[3] = p.getV1();
            e.c[3] = p.getV2();
        }

        if (form.hasP5()) {
            CommonPb.TwoInt p = form.getP5();
            e.p[4] = p.getV1();
            e.c[4] = p.getV2();
        }

        if (form.hasP6()) {
            CommonPb.TwoInt p = form.getP6();
            e.p[5] = p.getV1();
            e.c[5] = p.getV2();
        }

        if (form.hasFormName()) {
            e.setFormName(form.getFormName());
        }

        e.setTactics(new ArrayList<Integer>(form.getTacticsKeyIdList()));

        List<TwoInt> tacticsList = form.getTacticsList();
        if(!tacticsList.isEmpty()){
            for (TwoInt t : tacticsList){
                e.getTacticsList().add(new TowInt(t.getV1(),t.getV2()));
            }
        }
        return e;
    }

    static public CommonPb.Chip createChipPb(Chip chip) {
        CommonPb.Chip.Builder builder = CommonPb.Chip.newBuilder();
        builder.setChipId(chip.getChipId());
        builder.setCount(chip.getCount());
        return builder.build();
    }

    static public CommonPb.Hero createHeroPb(Hero hero) {
        CommonPb.Hero.Builder builder = CommonPb.Hero.newBuilder();
        builder.setKeyId(hero.getHeroId());
        builder.setHeroId(hero.getHeroId());
        builder.setCount(hero.getCount());
        builder.setEndTime(hero.getEndTime());
        builder.setCd(hero.getCd());
//		if(hero.getCd() >0 ){
//			LogUtil.info("AAAAAAAAA "+hero.getHeroId()+" "+hero.getCd());
//		}

        return builder.build();
    }

    static public CommonPb.Combat createCombatPb(Combat combat) {
        CommonPb.Combat.Builder builder = CommonPb.Combat.newBuilder();
        builder.setCombatId(combat.getCombatId());
        builder.setStar(combat.getStar());
        return builder.build();
    }

    static public CommonPb.Equip createEquipPb(Equip equip) {
        CommonPb.Equip.Builder builder = CommonPb.Equip.newBuilder();
        builder.setKeyId(equip.getKeyId());
        builder.setEquipId(equip.getEquipId());
        builder.setLv(equip.getLv());
        builder.setExp(equip.getExp());
        builder.setPos(equip.getPos());
        builder.setStarLv(equip.getStarlv());
        return builder.build();
    }

    static public CommonPb.Part createPartPb(Part part) {
        CommonPb.Part.Builder builder = CommonPb.Part.newBuilder();
        builder.setKeyId(part.getKeyId());
        builder.setPartId(part.getPartId());
        builder.setUpLv(part.getUpLv());
        builder.setRefitLv(part.getRefitLv());
        builder.setPos(part.getPos());
        builder.setLocked(part.isLocked());
        builder.setSmeltLv(part.getSmeltLv());
        builder.setSmeltExp(part.getSmeltExp());
        for (Entry<Integer, Integer[]> entry : part.getSmeltAttr().entrySet()) {
            PartSmeltAttr.Builder attr = PartSmeltAttr.newBuilder();
            attr.setId(entry.getKey());
            attr.setVal(entry.getValue()[0]);
            attr.setNewVal(entry.getValue()[1]);
            builder.addAttr(attr);
        }
        builder.setSaved(part.isSaved());
        return builder.build();
    }

    static public CommonPb.Science createSciencePb(Science science) {
        CommonPb.Science.Builder builder = CommonPb.Science.newBuilder();
        builder.setScienceId(science.getScienceId());
        builder.setScienceLv(science.getScienceLv());
        return builder.build();
    }

    static public CommonPb.Science createPartySciencePb(PartyScience science) {
        CommonPb.Science.Builder builder = CommonPb.Science.newBuilder();
        builder.setScienceId(science.getScienceId());
        builder.setScienceLv(science.getScienceLv());
        builder.setSchedule(science.getSchedule());
        return builder.build();
    }

    static public CommonPb.ScienceQue createScienceQuePb(ScienceQue e) {
        CommonPb.ScienceQue.Builder builder = CommonPb.ScienceQue.newBuilder();
        builder.setKeyId(e.getKeyId());
        builder.setScienceId(e.getScienceId());
        builder.setPeriod(e.getPeriod());
        builder.setState(e.getState());
        builder.setEndTime(e.getEndTime());
        builder.setStoneCost(e.getStoneCost());
        builder.setIronCost(e.getIronCost());
        builder.setCopperCost(e.getCopperCost());
        builder.setOilCost(e.getOilCost());
        builder.setSilionCost(e.getSilionCost());
        return builder.build();
    }

    /**
     * Method: createAwardPb
     *
     * @Description: 无keyId的奖励 @param type @param id @param count @return @return CommonPb.Award @throws
     */
    static public CommonPb.Award createAwardPb(int type, int id, long count) {
        CommonPb.Award.Builder builder = CommonPb.Award.newBuilder();
        builder.setType(type);
        builder.setId(id);
        builder.setCount(count);
        return builder.build();
    }

    static public List<CommonPb.Award> createAwardListPb(List<Award> award) {
        List<CommonPb.Award> rs = new ArrayList<CommonPb.Award>();
        for (Award e : award) {
            rs.add(createAwardPb(e.getType(), e.getId(), e.getCount(), e.getKeyId()));
        }
        return rs;
    }

    /**
     * Method: createAwardPb
     *
     * @Description: 有keyId的奖励 @param type @param id @param count @param keyId @return @return CommonPb.Award @throws
     */
    static public CommonPb.Award createAwardPb(int type, int id, long count, int keyId) {
        CommonPb.Award.Builder builder = CommonPb.Award.newBuilder();
        builder.setType(type);
        builder.setId(id);
        builder.setCount(count);
        if (keyId != 0) {
            builder.setKeyId(keyId);
        }

        return builder.build();
    }

    static public CommonPb.Award createAwardPbWithParam(int type, int id, long count, int keyId, int... param) {
        CommonPb.Award.Builder builder = CommonPb.Award.newBuilder();
        builder.setType(type);
        builder.setId(id);
        builder.setCount(count);
        if (keyId != 0) {
            builder.setKeyId(keyId);
        }
        for (int i = 0; i < param.length; i++) {
            builder.addParam(param[i]);
        }

        return builder.build();
    }

    /**
     * 创建奖励pb
     *
     * @param awardList
     * @return
     */
    public static List<CommonPb.Award> createAwardsPb(List<List<Integer>> awardList) {
        List<CommonPb.Award> awards = new ArrayList<>();
        if (!CheckNull.isEmpty(awardList)) {
            int type = 0;
            int id = 0;
            int count = 0;
            for (List<Integer> award : awardList) {
                if (award.size() != 3) {
                    continue;
                }

                type = award.get(0);
                id = award.get(1);
                count = award.get(2);
                awards.add(createAwardPb(type, id, count));
            }
        }
        return awards;
    }

    static public CommonPb.Section createSectionPb(int sectionId, int box) {
        CommonPb.Section.Builder builder = CommonPb.Section.newBuilder();
        builder.setSectionId(sectionId);
        builder.setBox(box);
        return builder.build();
    }

    static public CommonPb.Skill createSkillPb(int skillId, int lv) {
        CommonPb.Skill.Builder builder = CommonPb.Skill.newBuilder();
        builder.setId(skillId);
        builder.setLv(lv);
        return builder.build();
    }

    static public CommonPb.Mill createMillPb(Mill mill) {
        CommonPb.Mill.Builder builder = CommonPb.Mill.newBuilder();
        builder.setPos(mill.getPos());
        builder.setId(mill.getId());
        builder.setLv(mill.getLv());
        return builder.build();
    }

    static public CommonPb.Effect createEffectPb(Effect effect) {
        CommonPb.Effect.Builder builder = CommonPb.Effect.newBuilder();
        builder.setId(effect.getEffectId());
        builder.setEndTime(effect.getEndTime());
        return builder.build();
    }

    static public CommonPb.Man createManPb(Man man) {
        CommonPb.Man.Builder builder = CommonPb.Man.newBuilder();
        builder.setLordId(man.getLordId());
        int icon = man.getIcon();
        int sex = man.getSex();
        String nick = man.getNick();
        int level = man.getLevel();
        long fight = man.getFight();
        int ranks = man.getRanks();
        int exp = man.getExp();
        int pos = man.getPos();
        int vip = man.getVip();
        int honour = man.getHonour();
        int pros = man.getPros();
        int prosMax = man.getProsMax();
        String partyName = man.getPartyName();
        int jobId = man.getJobId();
        if (icon != 0) {
            builder.setIcon(icon);
        }
        if (sex != 0) {
            builder.setSex(sex);
        }
        if (nick != null) {
            builder.setNick(nick);
        }
        if (level != 0) {
            builder.setLevel(level);
        }
        if (fight != 0) {
            builder.setFight(fight);
        }
        if (ranks != 0) {
            builder.setRanks(ranks);
        }
        if (exp != 0) {
            builder.setExp(exp);
        }
        if (pos != 0) {
            builder.setPos(pos);
        }
        if (vip != -1) {
            builder.setVip(vip);
        }
        if (honour != -1) {
            builder.setHonour(honour);
        }
        if (pros != -1) {
            builder.setPros(pros);
        }
        if (prosMax != 0) {
            builder.setProsMax(prosMax);
        }
        if (partyName != null) {
            builder.setPartyName(partyName);
        }
        if (jobId != 0) {
            builder.setJobId(jobId);
        }
        return builder.build();
    }

    static public CommonPb.Friend createFriendPb(Man man, Friend friend, boolean mutualFriend, int giveCount) {
        CommonPb.Friend.Builder builder = CommonPb.Friend.newBuilder();
        builder.setMan(createManPb(man));
        builder.setBless(friend.getBless());
        builder.setBlessTime(friend.getBlessTime());
        builder.setState(mutualFriend ? 1 : 0);
        builder.setFriendliness(friend.getFriendliness());
        builder.setGiveCount(giveCount);
        return builder.build();
    }

    static public CommonPb.DbFriend createDbFriendPb(Friend friend) {
        CommonPb.DbFriend.Builder builder = CommonPb.DbFriend.newBuilder();
        builder.setLordId(friend.getLordId());
        builder.setBless(friend.getBless());
        builder.setBlessTime(friend.getBlessTime());
        builder.setFriendliness(friend.getFriendliness());
        return builder.build();
    }

    static public CommonPb.Bless createBlessPb(Man man, Bless bless) {
        CommonPb.Bless.Builder builder = CommonPb.Bless.newBuilder();
        builder.setMan(createManPb(man));
        builder.setBlessTime(bless.getBlessTime());
        builder.setState(bless.getState());
        return builder.build();
    }

    static public CommonPb.DbBless createDbBlessPb(Bless bless) {
        CommonPb.DbBless.Builder builder = CommonPb.DbBless.newBuilder();
        builder.setLordId(bless.getLordId());
        builder.setState(bless.getState());
        builder.setBlessTime(bless.getBlessTime());
        return builder.build();
    }

    static public CommonPb.Mine createMinePb(Mine mine) {
        CommonPb.Mine.Builder builder = CommonPb.Mine.newBuilder();
        builder.setMineId(mine.getMineId());
        builder.setMineLv(mine.getMineLv());
        return builder.build();
    }

    static public CommonPb.Mine createMinePb2(Mine mine, int scoutTime, Guard guard) {
        CommonPb.Mine.Builder builder = CommonPb.Mine.newBuilder();
        builder.setMineId(mine.getMineId());
        builder.setMineLv(mine.getMineLv());
        builder.setPos(mine.getPos());
        builder.setQua(mine.getQua());
        builder.setQuaExp(mine.getQuaExp());
        if (scoutTime > 0) {
            builder.setScoutTime(scoutTime);
        }

        return builder.build();
    }

    static public CommonPb.Store createStorePb(Store store) {
        CommonPb.Store.Builder builder = CommonPb.Store.newBuilder();
        builder.setPos(store.getPos());
        builder.setFriend(store.getFriend());
        builder.setEnemy(store.getEnemy());
        builder.setIsMine(store.getIsMine());
        if (store.getMan() != null) {
            builder.setMan(createManPb(store.getMan()));
        }
        if (store.getMine() != null) {
            builder.setMine(createMinePb(store.getMine()));
        }
        if (store.getMark() != null) {
            builder.setMark(store.getMark());
        } else {
            builder.setMark("");
        }
        builder.setType(store.getType());
        return builder.build();
    }

    static public CommonPb.Weal createWealPb(Weal weal) {
        CommonPb.Weal.Builder builder = CommonPb.Weal.newBuilder();
        builder.setStone(weal.getStone());
        builder.setIron(weal.getIron());
        builder.setSilicon(weal.getSilicon());
        builder.setCopper(weal.getCopper());
        builder.setOil(weal.getOil());
        builder.setGold(weal.getGold());
        return builder.build();
    }

    // static public List<CommonPb.Award> createAwardPb(List<Award> award) {
    // List<CommonPb.Award> rs = new ArrayList<CommonPb.Award>();
    // for (Award e : award) {
    // rs.add(createAwardPb(e.getType(), e.getId(), e.getCount(),
    // e.getKeyId()));
    // }
    // return rs;
    // }

    static public CommonPb.Mail createMailPb(Mail mail) {
        CommonPb.Mail.Builder builder = CommonPb.Mail.newBuilder();
        builder.setKeyId(mail.getKeyId());
        builder.setType(mail.getType());
        builder.setState(mail.getState());
        builder.setTime(mail.getTime());
        builder.setMoldId(mail.getMoldId());
        builder.setLv(mail.getLv());
        builder.setVipLv(mail.getVipLv());
        builder.setIsCollections(mail.getCollections());
        if (mail.getTitle() != null)
            builder.setTitle(mail.getTitle());

        if (mail.getSendName() != null)
            builder.setSendName(mail.getSendName());

        if (mail.getContont() != null)
            builder.setContont(mail.getContont());

        if (mail.getToName() != null)
            builder.addAllToName(mail.getToName());

        if (mail.getAward() != null)
            builder.addAllAward(mail.getAward());

        if (mail.getReport() != null)
            builder.setReport(mail.getReport());

        if (mail.getParam() != null) {
            for (String e : mail.getParam())
                if (e != null) {
                    builder.addParam(e);
                }
        }

        return builder.build();
    }

    static public CommonPb.MailShow createMailShowPb(Mail mail) {
        CommonPb.MailShow.Builder builder = CommonPb.MailShow.newBuilder();
        builder.setKeyId(mail.getKeyId());
        builder.setType(mail.getType());
        builder.setState(mail.getState());
        builder.setTime(mail.getTime());
        builder.setMoldId(mail.getMoldId());
        builder.setIsCollections(mail.getCollections());
        if (mail.getTitle() != null)
            builder.setTitle(mail.getTitle());

        if (mail.getSendName() != null)
            builder.setSendName(mail.getSendName());

        if (mail.getParam() != null) {
            for (String e : mail.getParam()) {
                if (e != null) {
                    builder.addParam(e);
                }
            }
        }
        return builder.build();
    }

    static public CommonPb.RankPlayer createRankPlayer(Arena arena, Player player) {
        CommonPb.RankPlayer.Builder builder = CommonPb.RankPlayer.newBuilder();
        builder.setRank(arena.getRank());
        builder.setName(player.lord.getNick());
        builder.setLv(player.lord.getLevel());
        builder.setFight(arena.getFight());
        return builder.build();
    }

    static public CommonPb.LotteryEquip createLotteryEquipPb(LotteryEquip lotteryEquip) {
        CommonPb.LotteryEquip.Builder builder = CommonPb.LotteryEquip.newBuilder();
        builder.setLotteryId(lotteryEquip.getLotteryId());
        builder.setFreetimes(lotteryEquip.getFreetimes());
        builder.setCd(lotteryEquip.getCd());
        if (lotteryEquip.getLotteryId() == 3) {
            if (lotteryEquip.getPurple() == 0) {
                builder.setPurple(1);
                builder.setIsFirst(0);
            } else {
                builder.setPurple(10 - lotteryEquip.getPurple() % 10);
                builder.setIsFirst(1);
            }
        }
        builder.setTime(lotteryEquip.getTime());
        // builder.setLotteryTime(lotterEquip.getLotteryTime());
        return builder.build();
    }

    static public CommonPb.LotteryEquip createDbLotteryEquipPb(LotteryEquip lotteryEquip) {
        CommonPb.LotteryEquip.Builder builder = CommonPb.LotteryEquip.newBuilder();
        builder.setLotteryId(lotteryEquip.getLotteryId());
        builder.setFreetimes(lotteryEquip.getFreetimes());
        builder.setCd(lotteryEquip.getCd());
        builder.setPurple(lotteryEquip.getPurple());
        builder.setTime(lotteryEquip.getTime());
        return builder.build();
    }

    static public CommonPb.PartyRank createPartyRankPb(PartyRank partyRank, PartyData partyData, int number) {
        CommonPb.PartyRank.Builder builder = CommonPb.PartyRank.newBuilder();
        builder.setRank(partyRank.getRank());
        builder.setPartyId(partyRank.getPartyId());
        builder.setPartyName(partyData.getPartyName());
        builder.setPartyLv(partyData.getPartyLv());
        builder.setMember(number);
        builder.setFight(partyRank.getFight());
        builder.setApplyLv(partyData.getPartyLv());
        builder.setApplyFight(partyData.getApplyFight());
        return builder.build();
    }

    static public CommonPb.PartyLvRank createPartyLvRankPb(PartyLvRank partyLvRank) {
        CommonPb.PartyLvRank.Builder builder = CommonPb.PartyLvRank.newBuilder();
        builder.setRank(partyLvRank.getRank());
        builder.setPartyId(partyLvRank.getPartyId());
        builder.setPartyName(partyLvRank.getPartyName());
        builder.setPartyLv(partyLvRank.getPartyLv());
        builder.setScienceLv(partyLvRank.getScienceLv());
        builder.setWealLv(partyLvRank.getWealLv());
        builder.setBuild(partyLvRank.getBuild());
        return builder.build();
    }

    static public CommonPb.Party createPartyPb(PartyData partyData, int member, int rank, int today) {
        CommonPb.Party.Builder builder = CommonPb.Party.newBuilder();
        builder.setPartyId(partyData.getPartyId());
        if (partyData.getPartyName() == null) {
            builder.setPartyName("");
        } else {
            builder.setPartyName(partyData.getPartyName());
        }
        if (partyData.getLegatusName() == null) {
            builder.setLegatusName("");
        } else {
            builder.setLegatusName(partyData.getLegatusName());
        }
        builder.setPartyLv(partyData.getPartyLv());
        builder.setMember(member);
        builder.setFight(partyData.getFight());
        if (partyData.getSlogan() == null) {
            builder.setSlogan("");
        } else {
            builder.setSlogan(partyData.getSlogan());
        }
        if (partyData.getInnerSlogan() == null) {
            builder.setInnerSlogan("");
        } else {
            builder.setInnerSlogan(partyData.getInnerSlogan());
        }
        builder.setApplyType(partyData.getApply());
        builder.setApplyLv(partyData.getApplyLv());
        builder.setApplyFight(partyData.getApplyFight());
        if (partyData.getJobName1() == null) {
            builder.setJobName1("");
        } else {
            builder.setJobName1(partyData.getJobName1());
        }
        if (partyData.getJobName1() == null) {
            builder.setJobName1("");
        } else {
            builder.setJobName1(partyData.getJobName1());
        }
        if (partyData.getJobName2() == null) {
            builder.setJobName2("");
        } else {
            builder.setJobName2(partyData.getJobName2());
        }
        if (partyData.getJobName3() == null) {
            builder.setJobName3("");
        } else {
            builder.setJobName3(partyData.getJobName3());
        }
        if (partyData.getJobName4() == null) {
            builder.setJobName4("");
        } else {
            builder.setJobName4(partyData.getJobName4());
        }

        // 设置今日免费攻打飞艇次数
        // if (!partyData.getFreeCrtMap().isEmpty()) {
        // for (Entry<Integer, Integer> entry : partyData.getFreeCrtMap().entrySet()) {
        // Integer crtDay = partyData.getFreeCrtDay().get(entry.getKey());
        // CommonPb.Kv.Builder kvb = CommonPb.Kv.newBuilder();
        // kvb.setKey(entry.getKey());
        // kvb.setValue(crtDay != null && crtDay == today ? entry.getValue() : 0);
        // builder.addFreeCnt(kvb);
        // }
        // }

        builder.setBuild(partyData.getBuild());
        builder.setRank(rank);
        builder.setScienceLv(partyData.getScienceLv());
        builder.setWealLv(partyData.getWealLv());
        builder.setAltarLv(partyData.getAltarLv());
        builder.setAltarexp(partyData.getAltarBossExp());
//		builder.setossLv(partyData.getgetb);
        builder.setAltarBossLv(partyData.getBossLv());

        return builder.build();
    }

    // static public CommonPb.PartyBuilding createPartyBuildingPb(int
    // buildingId, int buildingLv) {
    // CommonPb.PartyBuilding.Builder builder =
    // CommonPb.PartyBuilding.newBuilder();
    // builder.setBuildId(buildingId);
    // builder.setBuildLv(buildingLv);
    // return builder.build();
    // }

    static public CommonPb.PartyMember createPartyMemberPb(Member member, Lord lord, int online) {
        CommonPb.PartyMember.Builder builder = CommonPb.PartyMember.newBuilder();
        builder.setLordId(member.getLordId());
        builder.setNick(lord.getNick());
        builder.setJob(member.getJob());
        builder.setSex(lord.getSex());
        builder.setIcon(lord.getPortrait());
        builder.setLevel(lord.getLevel());
        builder.setFight(lord.getFight());
        builder.setDonate(member.getDonate());
        builder.setWeekDonate(member.getWeekDonate());
        builder.setWeekAllDonate(member.getWeekAllDonate());
        builder.setIsOnline(online);
        builder.setMilitaryRank(lord.getMilitaryRank());
        return builder.build();
    }

    static public CommonPb.LiveTask createLiveTaskPb(LiveTask liveTask) {
        CommonPb.LiveTask.Builder builder = CommonPb.LiveTask.newBuilder();
        builder.setTaskId(liveTask.getTaskId());
        builder.setCount(liveTask.getCount());
        return builder.build();
    }

    static public CommonPb.PartyDonate createPartyDonatePb(PartyDonate partyDonate) {
        CommonPb.PartyDonate.Builder builder = CommonPb.PartyDonate.newBuilder();
        builder.setStone(partyDonate.getStone());
        builder.setIron(partyDonate.getIron());
        builder.setSilicon(partyDonate.getSilicon());
        builder.setCopper(partyDonate.getCopper());
        builder.setOil(partyDonate.getOil());
        builder.setGold(partyDonate.getGold());
        return builder.build();
    }

    static public CommonPb.PartyProp createPartyPropPb(PartyProp partyProp) {
        CommonPb.PartyProp.Builder builder = CommonPb.PartyProp.newBuilder();
        builder.setKeyId(partyProp.getKeyId());
        builder.setCount(partyProp.getCount());
        return builder.build();
    }

    static public CommonPb.PartyProp createPartyPropPb(int keyId, int count) {
        CommonPb.PartyProp.Builder builder = CommonPb.PartyProp.newBuilder();
        builder.setKeyId(keyId);
        builder.setCount(count);
        return builder.build();
    }

    static public CommonPb.PartyApply createPartyApplyPb(Lord lord, PartyApply partyApply) {
        CommonPb.PartyApply.Builder builder = CommonPb.PartyApply.newBuilder();
        builder.setLordId(partyApply.getLordId());
        builder.setNick(lord.getNick());
        builder.setLevel(lord.getLevel());
        builder.setFight(lord.getFight());
        builder.setIcon(lord.getPortrait());
        builder.setApplyDate(partyApply.getApplyDate());
        return builder.build();
    }

    static public CommonPb.DbPartyApply createDbPartyApplyPb(PartyApply partyApply) {
        CommonPb.DbPartyApply.Builder builder = CommonPb.DbPartyApply.newBuilder();
        builder.setLordId(partyApply.getLordId());
        builder.setApplyDate(partyApply.getApplyDate());
        return builder.build();
    }

    static public CommonPb.MapData createMapDataPb(Player player, String party) {
        CommonPb.MapData.Builder builder = CommonPb.MapData.newBuilder();
        Lord lord = player.lord;
        builder.setPos(lord.getPos());
        builder.setName(lord.getNick());
        builder.setPros(lord.getPros());
        builder.setProsMax(lord.getProsMax());
        // builder.setRanks(lord.getRanks());
        // builder.setFight(lord.getFight());
        // builder.setPortrait(lord.getPortrait());
        // builder.setSex(lord.getSex());
        builder.setLv(lord.getLevel());
        if (party != null) {
            builder.setParty(party);
        }

        if (player.effects.containsKey(EffectType.ATTACK_FREE)) {
            builder.setFree(true);
        }

        if (player.surface != 0) {
            builder.setSurface(player.surface);
        }
        builder.setRuins(PbHelper.createRuinsPb(player.ruins));

        builder.setNameplate(player.getCurrentSkin(SkinType.NAMEPLATE));

        return builder.build();
    }

    static public CommonPb.MapData createMapDataPb(int pos, int count) {
        CommonPb.MapData.Builder builder = CommonPb.MapData.newBuilder();
        builder.setPos(pos);
        builder.setRebelGift(count);
        return builder.build();
    }

    static public CommonPb.MapData createMapDataPb(Rebel rebel) {
        CommonPb.MapData.Builder builder = CommonPb.MapData.newBuilder();
        builder.setPos(rebel.getPos());
        builder.setLv(rebel.getRebelLv());
        builder.setHeroPick(rebel.getHeroPick());
        builder.setSurface(rebel.getRebelId());// 该字段返回rebelId
        return builder.build();
    }

    static public CommonPb.PartyMine createPartyMinePb(String name, int pos) {
        CommonPb.PartyMine.Builder builder = CommonPb.PartyMine.newBuilder();
        builder.setPos(pos);
        builder.setName(name);
        return builder.build();
    }

    static public CommonPb.WorldFreeTimeInfo createWorldFreeTimeInfoPb(int time, int pos, boolean isMy) {
        CommonPb.WorldFreeTimeInfo.Builder builder = CommonPb.WorldFreeTimeInfo.newBuilder();
        builder.setPos(pos);
        builder.setTime(time);
        builder.setMy(isMy);

        // LogUtil.info("====22===="+pos+"========="+DateHelper.formatDateTime(new Date(time*1000l),"yyyy-MM-dd
        // HH:mm:ss"));

        return builder.build();
    }

    static public CommonPb.PartyLive createPartyLivePb(Lord lord, int job, int live) {
        CommonPb.PartyLive.Builder builder = CommonPb.PartyLive.newBuilder();
        builder.setLordId(lord.getLordId());
        builder.setIcon(lord.getPortrait());
        builder.setSex(lord.getSex());
        builder.setNick(lord.getNick());
        builder.setJob(job);
        builder.setLevel(lord.getLevel());
        builder.setLive(live);
        return builder.build();
    }

    // static public CommonPb.ScoutData createScoutDataPb(ReportScout report) {
    //
    // CommonPb.ScoutData.Builder builder = CommonPb.ScoutData.newBuilder();
    // builder.setKeyId(report.getKeyId());
    // builder.setTime(report.getTime());
    // builder.setPos(report.getPos());
    // builder.setLv(report.getLv());
    // if (report.getForm() != null) {
    // builder.setForm(createFormPb(report.getForm()));
    // }
    // builder.setPortrait(report.getPortrait());
    // builder.setSex(report.getSex());
    // builder.setName(report.getName());
    //
    // if (report.getParty() != null) {
    // builder.setParty(report.getParty());
    // }
    //
    // if (report.getFriend() != null) {
    // builder.setFriend(report.getFriend());
    // }
    //
    // builder.setPros(report.getPros());
    // builder.setProsMax(report.getProsMax());
    // builder.setStone(report.getStone());
    // builder.setIron(report.getIron());
    // builder.setSilicon(report.getSilicon());
    // builder.setCopper(report.getCopper());
    // builder.setOil(report.getOil());
    // builder.setHarvest(report.getHarvest());
    // return builder.build();
    // }

    static public CommonPb.TaskDayiy createTaskDayiyPb(Lord lord) {
        CommonPb.TaskDayiy.Builder builder = CommonPb.TaskDayiy.newBuilder();
        builder.setDayiy(lord.getTaskDayiy());
        builder.setDayiyCount(lord.getDayiyCount());
        return builder.build();
    }

    static public CommonPb.TaskLive createTaskLivePb(Lord lord) {
        CommonPb.TaskLive.Builder builder = CommonPb.TaskLive.newBuilder();
        builder.setLive(lord.getTaskLive());
        builder.setLiveAward(lord.getTaskLiveAd());
        return builder.build();
    }

    static public CommonPb.Task createTaskPb(Task task) {
        CommonPb.Task.Builder builder = CommonPb.Task.newBuilder();
        builder.setTaskId(task.getTaskId());
        builder.setSchedule(task.getSchedule());
        builder.setAccept(task.getAccept());
        builder.setStatus(task.getStatus());
        return builder.build();
    }

    static public CommonPb.Ruins createRuinsPb(Ruins r) {
        CommonPb.Ruins.Builder builder = CommonPb.Ruins.newBuilder();
        builder.setIsRuins(r.isRuins());
        builder.setLordId(r.getLordId());
        builder.setAttackerName(r.getAttackerName());
        return builder.build();
    }

    static public CommonPb.TrendParam createTrendParamPb(TrendParam trendParam) {
        CommonPb.TrendParam.Builder builder = CommonPb.TrendParam.newBuilder();
        if (trendParam.getContent() != null) {
            builder.setContent(trendParam.getContent());
        }

        if (trendParam.getMan() != null) {
            builder.setMan(PbHelper.createManPb(trendParam.getMan()));
        }
        return builder.build();
    }

    static public CommonPb.Trend createTrendPb(Trend trend, List<TrendParam> manList) {
        CommonPb.Trend.Builder builder = CommonPb.Trend.newBuilder();
        builder.setTrendId(trend.getTrendId());
        for (int i = 0; i < manList.size(); i++) {
            TrendParam trendParam = manList.get(i);
            builder.addTrendParam(createTrendParamPb(trendParam));
        }
        builder.setTrendTime(trend.getTrendTime());
        return builder.build();
    }

    static public CommonPb.DbTrend createDbTrendPb(Trend trend) {
        CommonPb.DbTrend.Builder builder = CommonPb.DbTrend.newBuilder();
        builder.setTrendId(trend.getTrendId());
        String[] param = trend.getParam();
        if (param != null) {
            for (String v : param) {
                builder.addParam(v);
            }
        }
        builder.setTrendTime(trend.getTrendTime());
        return builder.build();
    }

    static public CommonPb.PartyCombat createPartyCombatPb(PartyCombat partyCombat) {
        CommonPb.PartyCombat.Builder builder = CommonPb.PartyCombat.newBuilder();
        builder.setCombatId(partyCombat.getCombatId());
        builder.setSchedule(partyCombat.getSchedule());
        if (partyCombat.getForm() != null) {
            builder.setForm(createFormPb(partyCombat.getForm()));
        }
        return builder.build();
    }

    static public CommonPb.PartyCombat createPartyCombatInfoPb(PartyCombat partyCombat) {
        CommonPb.PartyCombat.Builder builder = CommonPb.PartyCombat.newBuilder();
        builder.setCombatId(partyCombat.getCombatId());
        builder.setSchedule(partyCombat.getSchedule());
        return builder.build();
    }

    static public CommonPb.PartySection createPartySectionPb(PartySection partySection) {
        CommonPb.PartySection.Builder builder = CommonPb.PartySection.newBuilder();
        builder.setSectionId(partySection.getSectionId());
        builder.setCombatLive(partySection.getCombatLive());
        builder.setStatus(partySection.getStatus());
        return builder.build();
    }

    static public CommonPb.Invasion createInvasionPb(March march) {
        CommonPb.Invasion.Builder builder = CommonPb.Invasion.newBuilder();
        Army army = march.getArmy();
        Lord lord = march.getPlayer().lord;
        builder.setLordId(lord.getLordId());
        builder.setKeyId(army.getKeyId());

        builder.setPortrait(lord.getPortrait());
        builder.setState(army.getState());
        builder.setName(lord.getNick());
        builder.setLv(lord.getLevel());
        builder.setEndTime(army.getEndTime());
        // builder.setTarget(army.getTarget());
        return builder.build();
    }

    static public CommonPb.Aid createAidPb(Guard guard, long fight, long load) {
        CommonPb.Aid.Builder builder = CommonPb.Aid.newBuilder();
        Army army = guard.getArmy();
        Lord lord = guard.getPlayer().lord;
        builder.setLordId(lord.getLordId());
        builder.setKeyId(army.getKeyId());
        builder.setPortrait(lord.getPortrait());
        builder.setName(lord.getNick());
        builder.setLv(lord.getLevel());
        builder.setState(army.getState());
        builder.setForm(createFormPb(army.getForm()));
        builder.setFight(fight);
        builder.setLoad(load);
        return builder.build();
    }

    static public CommonPb.ArmyStatu createArmyStatuPb(ArmyStatu armyStatu) {
        CommonPb.ArmyStatu.Builder builder = CommonPb.ArmyStatu.newBuilder();
        builder.setLordId(armyStatu.getLordId());
        builder.setKeyId(armyStatu.getKeyId());
        builder.setState(armyStatu.getState());
        return builder.build();
    }

    static public CommonPb.Extreme createExtreme(String name, int lv, int time) {
        CommonPb.Extreme.Builder builder = CommonPb.Extreme.newBuilder();
        builder.setName(name);
        builder.setLv(lv);
        builder.setTime(time);
        return builder.build();
    }

    static public CommonPb.AtkExtreme createAtkExtreme(Extreme extreme, Record record) {
        CommonPb.AtkExtreme.Builder builder = CommonPb.AtkExtreme.newBuilder();
        builder.setRecord(record);
        builder.setAttacker(extreme);
        return builder.build();
    }

    static public <T> Base.Builder createSynBase(int cmd, GeneratedExtension<Base, T> ext, T msg) {
        Base.Builder baseBuilder = Base.newBuilder();
        baseBuilder.setCmd(cmd);
        if (msg != null) {
            baseBuilder.setExtension(ext, msg);
        }

        return baseBuilder;
    }

    static public CommonPb.RankData createRankData(String name, int lv, long v, long v2) {
        CommonPb.RankData.Builder builder = CommonPb.RankData.newBuilder();
        builder.setName(name);
        builder.setLv(lv);
        builder.setValue(v);
        builder.setValue2(v2);
        return builder.build();
    }

    static public CommonPb.RankData createRankData(String name, int lv) {
        CommonPb.RankData.Builder builder = CommonPb.RankData.newBuilder();
        builder.setName(name);
        builder.setLv(lv);
        return builder.build();
    }

    static public CommonPb.Activity createActivityPb(ActivityBase activityBase, boolean open, int tips) {
        CommonPb.Activity.Builder builder = CommonPb.Activity.newBuilder();
        builder.setActivityId(activityBase.getActivityId());
        builder.setName(activityBase.getStaticActivity().getName());
        builder.setBeginTime((int) (activityBase.getBeginTime().getTime() / 1000));
        builder.setEndTime((int) (activityBase.getEndTime().getTime() / 1000));
        if (activityBase.getDisplayTime() != null) {
            builder.setDisplayTime((int) (activityBase.getDisplayTime().getTime() / 1000));
        }
        builder.setOpen(open);
        builder.setTips(tips);
        builder.setAwardId(activityBase.getKeyId());
        builder.setMinLv(activityBase.getStaticActivity().getMinLv());
        return builder.build();
    }

    static public CommonPb.ActivityCond createActivityCondPb(StaticActAward actAward, int status) {
        CommonPb.ActivityCond.Builder builder = CommonPb.ActivityCond.newBuilder();
        builder.setKeyId(actAward.getKeyId());
        builder.setCond(actAward.getCond());
        builder.setStatus(status);
        if (actAward.getParam() != null && !actAward.getParam().equals("")) {
            builder.setParam(actAward.getParam());
        }
        List<List<Integer>> awardList = actAward.getAwardList();
        for (List<Integer> e : awardList) {
            if (e.size() != 3) {
                continue;
            }
            int type = e.get(0);
            int id = e.get(1);
            int count = e.get(2);
            builder.addAward(PbHelper.createAwardPb(type, id, count));
        }
        return builder.build();
    }

    static public CommonPb.CondState createCondStatePb(int state, List<CommonPb.ActivityCond> listActAward) {
        CommonPb.CondState.Builder builder = CommonPb.CondState.newBuilder();
        builder.setState(state);
        builder.addAllActivityCond(listActAward);
        return builder.build();
    }

    static public CommonPb.CondState createCondStatePb(int state, StaticActAward actAward, int status) {
        CommonPb.CondState.Builder builder = CommonPb.CondState.newBuilder();
        builder.setState(state);
        builder.addActivityCond(PbHelper.createActivityCondPb(actAward, status));
        return builder.build();
    }

    static public CommonPb.DbActivity createDbActivityPb(Activity activity) {
        CommonPb.DbActivity.Builder builder = CommonPb.DbActivity.newBuilder();
        builder.setActivityId(activity.getActivityId());
        builder.setBeginTime(activity.getBeginTime());
        builder.setEndTime(activity.getEndTime());
        builder.setOpen(activity.getOpen());
        if (activity.getStatusList() != null) {
            for (Long e : activity.getStatusList())
                builder.addStatus(e);
        }
        if (null != activity.getStatusMap()) {
            Iterator<Entry<Integer, Integer>> it = activity.getStatusMap().entrySet().iterator();
            while (it.hasNext()) {
                Entry<Integer, Integer> next = it.next();
                int keyId = next.getKey();
                int value = next.getValue();
                builder.addTowInt(createTwoIntPb(keyId, value));
            }
        }
        if (null != activity.getPropMap()) {
            Iterator<Entry<Integer, Integer>> it = activity.getPropMap().entrySet().iterator();
            while (it.hasNext()) {
                Entry<Integer, Integer> next = it.next();
                int keyId = next.getKey();
                int value = next.getValue();
                builder.addProp(createTwoIntPb(keyId, value));
            }
        }
        if (null != activity.getSaveMap()) {
            Iterator<Entry<Integer, Integer>> it = activity.getSaveMap().entrySet().iterator();
            while (it.hasNext()) {
                Entry<Integer, Integer> next = it.next();
                int keyId = next.getKey();
                int value = next.getValue();
                builder.addSave(createTwoIntPb(keyId, value));
            }
        }
        return builder.build();
    }

    static public CommonPb.Mecha createMechaPb(StaticActMecha actMecha, int free, int crit, int part) {
        CommonPb.Mecha.Builder builder = CommonPb.Mecha.newBuilder();
        builder.setMechaId(actMecha.getMechaId());
        builder.setTankId(actMecha.getTank());
        builder.setCost(actMecha.getCost());
        builder.setCount(actMecha.getCount());
        builder.setCrit(crit);
        builder.setPart(part);
        builder.setFree(free);
        return builder.build();
    }

    static public CommonPb.Quota createQuotaPb(StaticActQuota quota, int buy) {
        CommonPb.Quota.Builder builder = CommonPb.Quota.newBuilder();
        builder.setQuotaId(quota.getQuotaId());
        builder.setDisplay(quota.getDisplay());
        builder.setPrice(quota.getPrice());
        builder.setCount(quota.getCount());
        builder.setBuy(buy);
        List<List<Integer>> awardList = quota.getAwardList();
        for (List<Integer> e : awardList) {
            if (e.size() != 3) {
                continue;
            }
            int type = e.get(0);
            int id = e.get(1);
            int count = e.get(2);
            builder.addAward(PbHelper.createAwardPb(type, id, count));
        }
        return builder.build();
    }

    static public CommonPb.AmyRebate createAmyRebatePb(int rebateId, int count) {
        CommonPb.AmyRebate.Builder builder = CommonPb.AmyRebate.newBuilder();
        builder.setRebateId(rebateId);
        builder.setStatus(count);
        return builder.build();
    }

    static public CommonPb.ActPlayerRank createActPlayerRank(ActPlayerRank actPlayerRank, String nick) {
        CommonPb.ActPlayerRank.Builder builder = CommonPb.ActPlayerRank.newBuilder();
        builder.setLordId(actPlayerRank.getLordId());
        builder.setRankType(actPlayerRank.getRankType());
        builder.setRankValue(actPlayerRank.getRankValue());
        builder.setNick(nick);
        if (actPlayerRank.getParam() != null) {
            builder.setParam(actPlayerRank.getParam());
        }
        builder.setRankTime(actPlayerRank.getRankTime());
        return builder.build();
    }

    static public CommonPb.ActPlayerRank createActPlayerRank(ActPlayerRank actPlayerRank) {
        CommonPb.ActPlayerRank.Builder builder = CommonPb.ActPlayerRank.newBuilder();
        builder.setLordId(actPlayerRank.getLordId());
        builder.setRankType(actPlayerRank.getRankType());
        builder.setRankValue(actPlayerRank.getRankValue());
        if (actPlayerRank.getParam() != null) {
            builder.setParam(actPlayerRank.getParam());
        }
        builder.setRankTime(actPlayerRank.getRankTime());
        return builder.build();
    }

    static public CommonPb.ActPartyRank createActPartyRank(ActPartyRank actPartyRank) {
        CommonPb.ActPartyRank.Builder builder = CommonPb.ActPartyRank.newBuilder();
        builder.setPartyId(actPartyRank.getPartyId());
        builder.setRankType(actPartyRank.getRankType());
        builder.setRankValue(actPartyRank.getRankValue());
        if (actPartyRank.getParam() != null) {
            builder.setParam(actPartyRank.getParam());
        }
        List<Long> lordIds = actPartyRank.getLordIds();
        if (lordIds != null) {
            for (Long lordId : lordIds) {
                builder.addLordId(lordId);
            }
        }
        builder.setRankTime(actPartyRank.getRankTime());
        return builder.build();
    }

    static public CommonPb.ActPartyRank createPartyRankPb(ActPartyRank actPartyRank, int rank, String partyName, long fight) {
        CommonPb.ActPartyRank.Builder builder = CommonPb.ActPartyRank.newBuilder();
        builder.setPartyId(actPartyRank.getPartyId());
        builder.setPartyName(partyName);
        builder.setFight(fight);
        builder.setRankType(0);
        builder.setRankValue(actPartyRank.getRankValue());
        if (actPartyRank.getParam() != null) {
            builder.setParam(actPartyRank.getParam());
        }
        List<Long> lordIds = actPartyRank.getLordIds();
        if (lordIds != null) {
            for (Long lordId : lordIds) {
                builder.addLordId(lordId);
            }
        }
        builder.setRankTime(actPartyRank.getRankTime());
        return builder.build();
    }

    static public CommonPb.Fortune createFortunePb(StaticActFortune fortune) {
        CommonPb.Fortune.Builder builder = CommonPb.Fortune.newBuilder();
        builder.setFortuneId(fortune.getFortuneId());
        builder.setCost(fortune.getPrice());
        builder.setCount(fortune.getCount());
        builder.setScore(fortune.getPoint());
        return builder.build();
    }

    static public CommonPb.RankAward createRankAwardPb(StaticActRank rank) {
        CommonPb.RankAward.Builder builder = CommonPb.RankAward.newBuilder();
        builder.setRank(rank.getRankBegin());
        builder.setRankEd(rank.getRankEnd());
        builder.setRankType(rank.getSortId());
        List<List<Integer>> awardList = rank.getAwardList();
        for (List<Integer> e : awardList) {
            if (e.size() != 3) {
                continue;
            }
            int type = e.get(0);
            int id = e.get(1);
            int count = e.get(2);
            builder.addAward(PbHelper.createAwardPb(type, id, count));
        }
        return builder.build();
    }

    static public CommonPb.BeeRank createBeeRankPb(int resourceId, long state, int status, List<CommonPb.ActPlayerRank> playerRanks) {
        CommonPb.BeeRank.Builder builder = CommonPb.BeeRank.newBuilder();
        builder.setResourceId(resourceId);
        builder.setState(state);// 我的资源采集量
        if (playerRanks != null) {
            for (CommonPb.ActPlayerRank e : playerRanks) {
                builder.addActPlayerRank(e);
            }
        }
        builder.setStatus(status);
        return builder.build();
    }

    static public CommonPb.MemberReg createWarRegPb(WarMember warMember) {
        CommonPb.MemberReg.Builder builder = CommonPb.MemberReg.newBuilder();
        builder.setName(warMember.getPlayer().lord.getNick());
        builder.setTime(warMember.getMember().getRegTime());
        builder.setLv(warMember.getMember().getRegLv());
        builder.setFight(warMember.getMember().getRegFight());

        return builder.build();
    }

    static public CommonPb.PartyReg createPartyRegPb(String name, int lv, int count, long fight) {
        CommonPb.PartyReg.Builder builder = CommonPb.PartyReg.newBuilder();
        builder.setLv(lv);
        builder.setName(name);
        builder.setCount(count);
        builder.setFight(fight);

        return builder.build();
    }

    static public CommonPb.WarRecord createWarRecordPb(WarMember attacker, WarMember defencer, int hp1, int hp2, int result, int time) {
        CommonPb.WarRecord.Builder builder = CommonPb.WarRecord.newBuilder();
        builder.setPartyName1(attacker.getWarParty().getPartyData().getPartyName());
        builder.setName1(attacker.getPlayer().lord.getNick());
        builder.setHp1(hp1);
        builder.setPartyName2(defencer.getWarParty().getPartyData().getPartyName());
        builder.setName2(defencer.getPlayer().lord.getNick());
        builder.setHp2(hp2);
        builder.setTime(time);
        builder.setResult(result);

        return builder.build();
    }

    static public CommonPb.WarRecordPerson createPersonWarRecordPb(WarRecord record, RptAtkWar rpt) {
        CommonPb.WarRecordPerson.Builder builder = CommonPb.WarRecordPerson.newBuilder();
        builder.setRecord(record);
        builder.setRpt(rpt);
        return builder.build();
    }

    static public CommonPb.WarRecord createWarResultPb(String partyName, WarMember warMember, int rank, int time) {
        CommonPb.WarRecord.Builder builder = CommonPb.WarRecord.newBuilder();
        builder.setPartyName1(partyName);
        builder.setName1(warMember.getPlayer().lord.getNick());
        builder.setTime(time);
        builder.setRank(rank);

        return builder.build();
    }

    static public CommonPb.WarRecord createWarWinPb(String partyName, int rank, int time) {
        CommonPb.WarRecord.Builder builder = CommonPb.WarRecord.newBuilder();
        builder.setPartyName1(partyName);
        builder.setTime(time);
        builder.setRank(rank);

        return builder.build();
    }

    static public CommonPb.Profoto createProfotoPb(int propId, int count) {
        CommonPb.Profoto.Builder builder = CommonPb.Profoto.newBuilder();
        builder.setPropId(propId);
        builder.setCount(count);
        return builder.build();
    }

    static public CommonPb.WarRank createWarRankPb(WarParty warParty) {
        CommonPb.WarRank.Builder builder = CommonPb.WarRank.newBuilder();
        builder.setPartyName(warParty.getPartyData().getPartyName());
        builder.setRank(warParty.getPartyData().getWarRank());
        builder.setCount(warParty.getMembers().size());
        builder.setFight(warParty.getPartyData().getRegFight());
        return builder.build();
    }

    static public CommonPb.HurtRank createHurtRankPb(BossFight bossFight, String nick, int rank) {
        CommonPb.HurtRank.Builder builder = CommonPb.HurtRank.newBuilder();
        builder.setName(nick);
        builder.setRank(rank);
        builder.setHurt(bossFight.getHurt());
        return builder.build();
    }

    static public CommonPb.WarWinRank createWarWinRankPb(WarMember warMember, int rank) {
        CommonPb.WarWinRank.Builder builder = CommonPb.WarWinRank.newBuilder();
        builder.setName(warMember.getPlayer().lord.getNick());
        builder.setRank(rank);
        builder.setWinCount(warMember.getMember().getWinCount());
        builder.setFight(warMember.getMember().getRegFight());
        return builder.build();
    }

    static public CommonPb.Tech createTechPb(StaticActTech staticActTech) {
        CommonPb.Tech.Builder builder = CommonPb.Tech.newBuilder();
        builder.setTechId(staticActTech.getTechId());
        builder.setType(staticActTech.getType());
        builder.setUsePropId(staticActTech.getPropId());
        builder.setUsePropcount(staticActTech.getCount());
        if (staticActTech.getType() == 1) {
            int propId = staticActTech.getAwardList().get(0).get(1);
            int propCount = staticActTech.getAwardList().get(0).get(2);
            builder.setPropId(propId);
            builder.setCount(propCount);
        } else {
            builder.setPropId(0);
            builder.setCount(1);
        }
        return builder.build();
    }

    static public CommonPb.General createGeneralPb(StaticActGeneral staticActGeneral) {
        CommonPb.General.Builder builder = CommonPb.General.newBuilder();
        builder.setGeneranlId(staticActGeneral.getGeneralId());
        builder.setHeroId(staticActGeneral.getHeroId());
        builder.setPrice(staticActGeneral.getPrice());
        builder.setCount(staticActGeneral.getCount());
        builder.setPoint(staticActGeneral.getPoint());
        return builder.build();
    }

    static public CommonPb.QuotaVip createQuotaVipPb(StaticActQuota staticActQuota, int buy) {
        CommonPb.QuotaVip.Builder builder = CommonPb.QuotaVip.newBuilder();
        builder.setVip(staticActQuota.getCond());
        builder.setQuota(PbHelper.createQuotaPb(staticActQuota, buy));
        return builder.build();
    }

    static public CommonPb.SeniorMapData createSeniorMapDataPb(Player my, Player player, Army army, boolean party, long freeWarTime,
                                                               long startFreeWarTime) {
        CommonPb.SeniorMapData.Builder builder = CommonPb.SeniorMapData.newBuilder();
        Lord lord = player.lord;
        builder.setPos(army.getTarget());
        builder.setName(lord.getNick());
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

        if (my.roleId.longValue() != player.roleId.longValue()) {
            builder.setMy(false);
        } else {
            builder.setMy(true);
        }

        return builder.build();
    }

    static public CommonPb.ScoreRank createScoreRankPb(String name, SeniorScoreRank scoreRank) {
        CommonPb.ScoreRank.Builder builder = CommonPb.ScoreRank.newBuilder();
        builder.setName(name);
        builder.setFight(scoreRank.getFight());
        builder.setScore(scoreRank.getScore());
        return builder.build();
    }

    static public CommonPb.ScoreRank createScoreRankPb(String name, SeniorPartyScoreRank scoreRank) {
        CommonPb.ScoreRank.Builder builder = CommonPb.ScoreRank.newBuilder();
        builder.setName(name);
        builder.setFight(scoreRank.getFight());
        builder.setScore(scoreRank.getScore());
        return builder.build();
    }

    static public CommonPb.Village createVillagePb(StaticActVacationland land) {
        CommonPb.Village.Builder builder = CommonPb.Village.newBuilder();
        builder.setVillageId(land.getVillageId());
        builder.setTopup(land.getTopup());
        builder.setPrice(land.getPrice());
        return builder.build();
    }

    static public CommonPb.VillageAward createVillageAwardPb(StaticActVacationland land, int buyId, int state, int status) {
        CommonPb.VillageAward.Builder builder = CommonPb.VillageAward.newBuilder();
        builder.setLandId(land.getLandId());
        builder.setVillageId(land.getVillageId());
        builder.setOnday(land.getOnday());
        if (land.getVillageId() != buyId) {
            builder.setState(0);
            builder.setStatus(0);
        } else {
            builder.setState(state);
            builder.setStatus(status);
        }
        List<List<Integer>> awardList = land.getAwardList();
        if (awardList != null) {
            for (List<Integer> e : awardList) {
                if (e.size() < 3) {
                    continue;
                }
                int type = e.get(0);
                int id = e.get(1);
                int count = e.get(2);
                builder.addAward(PbHelper.createAwardPb(type, id, count));
            }
        }
        return builder.build();
    }

    static public CommonPb.Atom createAtomPb(int grid, int type, int id, int count) {
        CommonPb.Atom.Builder builder = CommonPb.Atom.newBuilder();
        builder.setGrid(grid);
        builder.setType(type);
        builder.setId(id);
        builder.setCount(count);
        return builder.build();
    }

    static public CommonPb.Atom2 createAtom2Pb(int type, int id, long count) {
        CommonPb.Atom2.Builder builder = CommonPb.Atom2.newBuilder();
        builder.setKind(type);
        builder.setId(id);
        builder.setCount(count);
        return builder.build();
    }

    static public CommonPb.Cash createCashPb(Cash cash) {
        CommonPb.Cash.Builder builder = CommonPb.Cash.newBuilder();
        builder.setCashId(cash.getCashId());
        builder.setFormulaId(cash.getFormulaId());
        builder.setPrice(cash.getPrice());
        builder.setFree(cash.getFree());
        builder.setState(cash.getState());
        builder.setRefreshDate(cash.getRefreshDate());

        List<List<Integer>> list = cash.getList();
        for (int i = 0; i < list.size(); i++) {
            List<Integer> e = list.get(i);
            int type = e.get(0);
            int id = e.get(1);
            int count = e.get(2);
            builder.addAtom(PbHelper.createAtomPb(i + 1, type, id, count));
        }
        int type = cash.getAwardList().get(0);
        int id = cash.getAwardList().get(1);
        int count = cash.getAwardList().get(2);
        builder.setAward(PbHelper.createAwardPb(type, id, count));
        return builder.build();
    }

    static public CommonPb.MilitaryScience createMilitaryScienecePb(MilitaryScience militaryScienece) {
        CommonPb.MilitaryScience.Builder builder = CommonPb.MilitaryScience.newBuilder();
        builder.setMilitaryScienceId(militaryScienece.getMilitaryScienceId());
        builder.setLevel(militaryScienece.getLevel());
        builder.setFitTankId(militaryScienece.getFitTankId());
        builder.setFitPos(militaryScienece.getFitPos());
        return builder.build();
    }

    static public CommonPb.MilitaryScienceGrid createMilitaryScieneceGridPb(MilitaryScienceGrid militaryScieneceGrid) {
        CommonPb.MilitaryScienceGrid.Builder builder = CommonPb.MilitaryScienceGrid.newBuilder();
        builder.setTankId(militaryScieneceGrid.getTankId());
        builder.setPos(militaryScieneceGrid.getPos());
        builder.setStatus(militaryScieneceGrid.getStatus());
        builder.setMilitaryScienceId(militaryScieneceGrid.getMilitaryScienceId());
        return builder.build();
    }

    static public CommonPb.MilitaryMaterial createMilitaryMaterialPb(MilitaryMaterial militaryMaterial) {
        CommonPb.MilitaryMaterial.Builder builder = CommonPb.MilitaryMaterial.newBuilder();
        builder.setId(militaryMaterial.getId());
        builder.setCount(militaryMaterial.getCount());
        return builder.build();
    }

    static public CommonPb.PartResolve createPartResolvePb(StaticActPartResolve staticActPartResolve) {
        CommonPb.PartResolve.Builder builder = CommonPb.PartResolve.newBuilder();
        builder.setResolveId(staticActPartResolve.getResolveId());
        builder.setCount(staticActPartResolve.getSlug());
        List<List<Integer>> awardList = staticActPartResolve.getAwardList();
        for (List<Integer> e : awardList) {
            int type = e.get(0);
            int id = e.get(1);
            int count = e.get(2);
            builder.setAward(PbHelper.createAwardPb(type, id, count));
        }
        return builder.build();
    }

    static public CommonPb.TopupGamble createTopupGamblePb(StaticActGamble staticActGamble) {
        CommonPb.TopupGamble.Builder builder = CommonPb.TopupGamble.newBuilder();
        builder.setGambleId(staticActGamble.getGambleId());
        builder.setPrice(staticActGamble.getPrice());
        builder.setTopup(staticActGamble.getTopup());
        List<List<Integer>> awardList = staticActGamble.getAwardList();
        if (awardList != null) {
            for (List<Integer> e : awardList) {
                int type = e.get(0);
                int id = e.get(1);
                int count = e.get(2);
                builder.addAward(PbHelper.createAwardPb(type, id, count));
            }
        }
        return builder.build();
    }

    static public CommonPb.TwoValue createTwoValuePb(int key, long value) {
        CommonPb.TwoValue.Builder builder = CommonPb.TwoValue.newBuilder();
        builder.setV1(key);
        builder.setV2(value);
        return builder.build();
    }

    static public CommonPb.Pendant createPendantPb(StaticPendant staticPendant, Pendant pendant) {
        CommonPb.Pendant.Builder builder = CommonPb.Pendant.newBuilder();

        builder.setPendantId(pendant.getPendantId());
        builder.setEndTime(pendant.getEndTime());
        builder.setForeverHold(pendant.isForeverHold());
        return builder.build();
    }

    static public CommonPb.Portrait createPortraitPb(StaticPortrait staticPortrait, Portrait portrait) {
        CommonPb.Portrait.Builder builder = CommonPb.Portrait.newBuilder();
        builder.setId(portrait.getId());
        builder.setEndTime(portrait.getEndTime());
        builder.setForeverHold(portrait.isForeverHold());
        return builder.build();
    }

    public static CommonPb.EnergyStoneInlay createEnergyStoneInlayPb(EnergyStoneInlay inlay) {
        CommonPb.EnergyStoneInlay.Builder builder = CommonPb.EnergyStoneInlay.newBuilder();
        builder.setHole(inlay.getHole());
        builder.setStoneId(inlay.getStoneId());
        builder.setPos(inlay.getPos());
        return builder.build();
    }

    /**
     * Method: createWarRankInfoPb @Description: @param next @return @return com.game.pb.CommonPb.WarRankInfo @throws
     */
    public static com.game.pb.CommonPb.WarRankInfo createWarRankInfoPb(WarRankInfo info) {
        com.game.pb.CommonPb.WarRankInfo.Builder builder = com.game.pb.CommonPb.WarRankInfo.newBuilder();
        builder.setDateTime(info.getDateTime());
        builder.setRankId(info.getRank());
        builder.setPartyId(info.getPartyId());
        if (info.getPartyName() != null) {
            builder.setPartyName(info.getPartyName());
        }
        return builder.build();
    }

    /**
     * Method: createFortressBattlePartyPb @Description: @param fortressBattleParty @return @return
     * com.game.pb.CommonPb.FortressBattleParty @throws
     */
    public static com.game.pb.CommonPb.FortressBattleParty createFortressBattlePartyPb(FortressBattleParty fortressBattleParty) {
        com.game.pb.CommonPb.FortressBattleParty.Builder builder = com.game.pb.CommonPb.FortressBattleParty.newBuilder();
        builder.setPartyId(fortressBattleParty.getPartyId());
        builder.setPartyName(fortressBattleParty.getPartyName());
        builder.setRank(fortressBattleParty.getRank());
        return builder.build();
    }

    /**
     * Method: createFortressSelfPb @Description: @param nowNpcNum @param npcMaxNum @return @return FortressSelf @throws
     */
    public static FortressSelf createFortressSelfPb(int nowNpcNum, int npcMaxNum) {
        com.game.pb.CommonPb.FortressSelf.Builder builder = com.game.pb.CommonPb.FortressSelf.newBuilder();
        builder.setNowNum(nowNpcNum);
        builder.setTotalNum(npcMaxNum);
        return builder.build();
    }

    /**
     * Method: createFortressDefendPb @Description: @param next @return void @throws
     */
    public static FortressDefend createFortressDefendPb(DefencePlayer info) {
        com.game.pb.CommonPb.FortressDefend.Builder builder = com.game.pb.CommonPb.FortressDefend.newBuilder();
        builder.setLordId(info.getPlayer().account.getLordId());
        builder.setNick(info.getPlayer().lord.getNick());
        builder.setLevel(info.getPlayer().lord.getLevel());
        builder.setFight(info.getFight());
        return builder.build();
    }

    /**
     * Method: createFortressRecordPb @Description: @param attackPlayer @param defence @param hp1 @param hp2 @param
     * time @param result @return @return FortressRecord @throws
     */
    public static FortressRecord createFortressRecordPb(int reportKey, Player attackPlayer, String partyName1, DefencePlayer defence,
                                                        String partyName2, int hp1, int hp2, int time, int result) {
        if (result != 1) {
            result = 0;
        }
        FortressRecord.Builder builder = FortressRecord.newBuilder();
        builder.setReportKey(reportKey);
        builder.setPartyName1(partyName1);
        builder.setName1(attackPlayer.lord.getNick());
        builder.setHp1(hp1);
        builder.setPartyName2(partyName2);
        builder.setName2(defence.getPlayer().lord.getNick());
        builder.setHp2(hp2);
        builder.setResult(result);
        builder.setTime(time);
        builder.setIsNPC(false);
        return builder.build();
    }

    public static FortressRecord createFortressRecordPb(int reportKey, Player attackPlayer, String partyName1, DefenceNPC defence,
                                                        String partyName2, String name2, int hp1, int hp2, int time, int result) {
        if (result != 1) {
            result = 0;
        }
        FortressRecord.Builder builder = FortressRecord.newBuilder();
        builder.setReportKey(reportKey);
        builder.setPartyName1(partyName1);
        builder.setName1(attackPlayer.lord.getNick());
        builder.setHp1(hp1);
        builder.setPartyName2(partyName2);
        builder.setName2(name2);
        builder.setHp2(hp2);
        builder.setResult(result);
        builder.setTime(time);
        builder.setIsNPC(true);

        return builder.build();
    }

    public static RptAtkFortress createRptAtkFortressPb(int reportKey, boolean result, boolean attackerIsFirst, RptMan attackRptMan,
                                                        RptMan defenceRptMan, Record record) {
        RptAtkFortress.Builder builder = RptAtkFortress.newBuilder();
        builder.setReportKey(reportKey);
        builder.setResult(result);
        builder.setFirst(attackerIsFirst);
        builder.setAttacker(attackRptMan);
        builder.setDefencer(defenceRptMan);
        builder.setRecord(record);
        return builder.build();
    }

    public static FortressPartyRank createFortressPartyRankPb(int rank, String partyName, MyPartyStatistics ms) {
        FortressPartyRank.Builder builder = FortressPartyRank.newBuilder();
        builder.setRank(rank);
        builder.setPartyName(partyName);
        builder.setFightNum(ms.getFightNum());
        builder.setJifen(ms.getJifen());
        builder.setIsAttack(ms.isAttack());
        return builder.build();
    }

    public static FortressJiFenRank createFortressJiFenRankPb(int rank, String nick, int fightNum, int jifen) {
        FortressJiFenRank.Builder builder = FortressJiFenRank.newBuilder();
        builder.setRank(rank);
        builder.setNick(nick);
        builder.setFightNum(fightNum);
        builder.setJifen(jifen);
        return builder.build();
    }

    public static com.game.pb.CommonPb.MyFortressAttr createMyFortressAttrPb(MyFortressAttr attr) {
        com.game.pb.CommonPb.MyFortressAttr.Builder builder = com.game.pb.CommonPb.MyFortressAttr.newBuilder();
        builder.setId(attr.getId());
        builder.setLevel(attr.getLevel());
        return builder.build();
    }

    public static FortressJob creatFortressJobPb(FortressJobAppoint f) {
        FortressJob.Builder builder = FortressJob.newBuilder();
        builder.setJobId(f.getJobId());
        builder.setLordId(f.getLordId());
        builder.setAppointTime(f.getAppointTime());
        builder.setEndTime(f.getEndTime());
        builder.setNick(f.getNick());
        builder.setIndex(f.getIndex());
        return builder.build();
    }

    public static FortressRecord createFortressRecord(FortressRecord r) {
        FortressRecord.Builder builder = FortressRecord.newBuilder();
        builder.setReportKey(r.getReportKey());
        builder.setPartyName1(r.getPartyName1());
        builder.setName1(r.getName1());
        builder.setHp1(r.getHp1());
        builder.setPartyName2(r.getPartyName2());
        builder.setName2(r.getName2());
        builder.setHp2(r.getHp2());
        builder.setResult(r.getResult());
        builder.setTime(r.getTime());
        builder.setIsNPC(r.getIsNPC());
        return builder.build();
    }

    public static RptAtkFortress createRptAtkFortressPb(RptAtkFortress r) {
        RptAtkFortress.Builder builder = RptAtkFortress.newBuilder();
        builder.setReportKey(r.getReportKey());
        builder.setResult(r.getResult());
        builder.setFirst(r.getFirst());
        builder.setAttacker(r.getAttacker());
        builder.setDefencer(r.getDefencer());
        builder.setRecord(r.getRecord());
        return builder.build();
    }

    public static com.game.pb.CommonPb.MyFortressFightData createMyFortressFightDataPb(MyFortressFightData m) {
        com.game.pb.CommonPb.MyFortressFightData.Builder builder = com.game.pb.CommonPb.MyFortressFightData.newBuilder();
        builder.setLordId(m.getLordId());

        Iterator<com.game.fortressFight.domain.SufferTank> its = m.getSufferTankMap().values().iterator();
        while (its.hasNext()) {
            builder.addSufferTankMap(createSufferTankPb(its.next()));
        }

        Iterator<com.game.fortressFight.domain.SufferTank> its2 = m.getDestoryTankMap().values().iterator();
        while (its2.hasNext()) {
            builder.addDestoryTankMap(createSufferTankPb(its2.next()));
        }

        builder.setMyCD(createMyCDPb(m.getMyCD()));
        builder.setJifen(m.getJifen());
        builder.setFightNum(m.getFightNum());
        builder.setWinNum(m.getWinNum());
        builder.addAllMyReportKeys(m.getMyReportKeys());

        Iterator<com.game.fortressFight.domain.MyFortressAttr> its3 = m.getMyFortressAttrs().values().iterator();
        while (its3.hasNext()) {
            builder.addMyFortressAttr(PbHelper.createMyFortressAttrPb(its3.next()));
        }

        builder.setSufferTankCountForevel(m.getSufferTankCountForevel());
        builder.setMplt((int) m.getMplt());

        return builder.build();
    }

    private static MyCD createMyCDPb(com.game.fortressFight.domain.MyCD myCD) {
        MyCD.Builder builder = MyCD.newBuilder();
        builder.setBeginTime(myCD.getBeginTime());
        builder.setEndTime(myCD.getEndTime());
        return builder.build();
    }

    private static SufferTank createSufferTankPb(com.game.fortressFight.domain.SufferTank s) {
        SufferTank.Builder builder = SufferTank.newBuilder();
        builder.setTankId(s.getTankId());
        builder.setSufferCount(s.getSufferCount());
        return builder.build();
    }

    public static com.game.pb.CommonPb.MyPartyStatistics createMyPartyStatistics(MyPartyStatistics m) {
        com.game.pb.CommonPb.MyPartyStatistics.Builder builder = com.game.pb.CommonPb.MyPartyStatistics.newBuilder();
        builder.setPartyId(m.getPartyId());
        builder.setFightNum(m.getFightNum());
        builder.setJifen(m.getJifen());
        builder.setWinNum(m.getWinNum());
        builder.setIsAttack(m.isAttack());
        Iterator<com.game.fortressFight.domain.SufferTank> its = m.getDestoryTankMap().values().iterator();
        while (its.hasNext()) {
            builder.addDestoryTankMap(createSufferTankPb(its.next()));
        }
        return builder.build();
    }

    public static com.game.pb.CommonPb.FortressJobAppoint createFortressJobAppointPb(FortressJobAppoint f) {
        com.game.pb.CommonPb.FortressJobAppoint.Builder builder = com.game.pb.CommonPb.FortressJobAppoint.newBuilder();
        builder.setAppointTime(f.getAppointTime());
        builder.setEndTime(f.getEndTime());
        builder.setJobId(f.getJobId());
        builder.setLordId(f.getLordId());
        builder.setNick(f.getNick());
        builder.setIndex(f.getIndex());

        return builder.build();
    }

    static public CommonPb.Pendant createPendantPb(Pendant pendant) {
        CommonPb.Pendant.Builder builder = CommonPb.Pendant.newBuilder();
        builder.setPendantId(pendant.getPendantId());
        builder.setEndTime(pendant.getEndTime());
        builder.setForeverHold(pendant.isForeverHold());
        return builder.build();
    }

    static public CommonPb.Portrait createPortraitPb(Portrait portrait) {
        CommonPb.Portrait.Builder builder = CommonPb.Portrait.newBuilder();
        builder.setId(portrait.getId());
        builder.setEndTime(portrait.getEndTime());
        builder.setForeverHold(portrait.isForeverHold());
        return builder.build();
    }

    public static TreasureShopBuy createTreasureShopBuyPb(com.game.domain.p.TreasureShopBuy buy) {
        TreasureShopBuy.Builder builder = TreasureShopBuy.newBuilder();
        builder.setTreasureId(buy.getTreasureId());
        builder.setBuyNum(buy.getBuyNum());
        builder.setBuyWeek(buy.getBuyWeek());
        return builder.build();
    }

    public static com.game.pb.CommonPb.DrillRecord createDrillRecordPb(DrillRecord record) {
        com.game.pb.CommonPb.DrillRecord.Builder builder = com.game.pb.CommonPb.DrillRecord.newBuilder();
        builder.setReportKey(record.getReportKey());
        builder.setAttacker(record.getAttacker());
        builder.setAttackNum(record.getAttackNum());
        builder.setAttackCamp(record.isAttackCamp());
        builder.setDefender(record.getDefender());
        builder.setDefendNum(record.getDefendNum());
        builder.setDefendCamp(record.isDefendCamp());
        builder.setResult(record.isResult());
        builder.setTime(record.getTime());
        return builder.build();
    }

    public static com.game.pb.CommonPb.DrillRank createDrillRankPb(DrillRank rank) {
        com.game.pb.CommonPb.DrillRank.Builder builder = com.game.pb.CommonPb.DrillRank.newBuilder();
        builder.setRank(rank.getRank());
        builder.setName(rank.getName());
        builder.setFightNum(rank.getFightNum());
        builder.setSuccessNum(rank.getSuccessNum());
        builder.setFailNum(rank.getFailNum());
        builder.setCamp(rank.isCamp());
        builder.setLordId(rank.getLordId());
        builder.setIsReward(rank.isReward());
        return builder.build();
    }

    public static com.game.pb.CommonPb.DrillResult createDrillResultPb(DrillResult result) {
        com.game.pb.CommonPb.DrillResult.Builder builder = com.game.pb.CommonPb.DrillResult.newBuilder();
        builder.setRedRest(result.getDrillRedRest());
        builder.setRedTotal(result.getDrillRedTotal());
        builder.setBlueRest(result.getDrillBlueRest());
        builder.setBlueTotal(result.getDrillBlueTotal());
        if (result.getStatus() > 0) {
            builder.setRedWin(result.getStatus() == 1);
        }
        return builder.build();
    }

    public static CommonPb.DrillImproveInfo createDrillImproveInfoPb(int buffId, int buffLv, int exper, int ratio) {
        com.game.pb.CommonPb.DrillImproveInfo.Builder builder = com.game.pb.CommonPb.DrillImproveInfo.newBuilder();
        builder.setBuffId(buffId);
        builder.setBuffLv(buffLv);
        builder.setExper(exper);
        builder.setRatio(ratio);
        return builder.build();
    }

    public static com.game.pb.CommonPb.DrillShopBuy createDrillShopBuyPb(DrillShopBuy buy, int restNum) {
        com.game.pb.CommonPb.DrillShopBuy.Builder builder = com.game.pb.CommonPb.DrillShopBuy.newBuilder();
        builder.setShopId(buy.getShopId());
        builder.setBuyNum(buy.getBuyNum());
        builder.setRestNum(restNum);
        return builder.build();
    }

    public static com.game.pb.CommonPb.DrillShopBuy createDrillShopBuyPb(int shopId, int buyNum, int restNum) {
        com.game.pb.CommonPb.DrillShopBuy.Builder builder = com.game.pb.CommonPb.DrillShopBuy.newBuilder();
        builder.setShopId(shopId);
        builder.setBuyNum(buyNum);
        builder.setRestNum(restNum);
        return builder.build();
    }

    public static CommonPb.DrillFightData createDrillFightDataPb(DrillFightData data) {
        CommonPb.DrillFightData.Builder builder = CommonPb.DrillFightData.newBuilder();
        builder.setLordId(data.getLordId());
        builder.setLastEnrollDate(data.getLastEnrollDate());
        builder.setSuccessNum(data.getSuccessNum());
        builder.setFailNum(data.getFailNum());
        builder.setExploit(data.getExploit());
        builder.setIsRed(data.isRed());
        builder.setCampRewad(data.isCampRewad());
        List<Integer> list = data.getRecordKeyMap().get(1);
        if (!CheckNull.isEmpty(list)) {
            for (Integer reportKey : list) {
                builder.addFirstRecordKey(reportKey);
            }
        }
        list = data.getRecordKeyMap().get(2);
        if (!CheckNull.isEmpty(list)) {
            for (Integer reportKey : list) {
                builder.addSecondRecordKey(reportKey);
            }
        }
        list = data.getRecordKeyMap().get(3);
        if (!CheckNull.isEmpty(list)) {
            for (Integer reportKey : list) {
                builder.addThirdRecordKey(reportKey);
            }
        }
        return builder.build();
    }

    public static com.game.pb.CommonPb.PushComment createPushComment(PushComment pushComment) {
        CommonPb.PushComment.Builder builder = CommonPb.PushComment.newBuilder();
        builder.setState(pushComment.getState());
        builder.setLastCommentTime(pushComment.getLastCommentTime());
        builder.setShouldPushTime(pushComment.getShouldPushTime());
        return builder.build();
    }

    public static CommonPb.TankCarnivalReward createTankCrnivalRewardPb(int line, List<CommonPb.Award> awardList) {
        CommonPb.TankCarnivalReward.Builder builder = CommonPb.TankCarnivalReward.newBuilder();
        builder.setLineNum(line);
        builder.addAllAwards(awardList);
        return builder.build();
    }

    public static com.game.pb.CommonPb.Rebel createRebelPb(Rebel rebel) {
        CommonPb.Rebel.Builder builder = CommonPb.Rebel.newBuilder();
        builder.setRebelId(rebel.getRebelId());
        builder.setRebelLv(rebel.getRebelLv());
        builder.setHeroPick(rebel.getHeroPick());
        builder.setState(rebel.getState());
        builder.setType(rebel.getType());
        builder.setPos(rebel.getPos());
        return builder.build();
    }

    public static CommonPb.RebelRank createRebelRankPb(int rank, long lordId, String nick, int killUnit, int killGuard, int killLeader,
                                                       int score) {
        CommonPb.RebelRank.Builder builder = CommonPb.RebelRank.newBuilder();
        builder.setRank(rank);
        builder.setLordId(lordId);
        builder.setName(nick);
        builder.setKillUnit(killUnit);
        builder.setKillGuard(killGuard);
        builder.setKillLeader(killLeader);
        builder.setScore(score);
        return builder.build();
    }

    public static CommonPb.RoleRebelData createRoleRebelDataPb(RoleRebelData data) {
        CommonPb.RoleRebelData.Builder builder = CommonPb.RoleRebelData.newBuilder();
        builder.setLordId(data.getLordId());
        builder.setName(data.getNick());
        builder.setLastUpdateWeek(data.getLastUpdateWeek());
        builder.setLastUpdateTime(data.getLastUpdateTime());
        builder.setKillNum(data.getKillNum());
        builder.setKillUnit(data.getKillUnit());
        builder.setKillGuard(data.getKillGuard());
        builder.setKillLeader(data.getKillLeader());
        builder.setScore(data.getScore());
        builder.setTotalUnit(data.getTotalUnit());
        builder.setTotalGuard(data.getTotalGuard());
        builder.setTotalLeader(data.getTotalLeader());
        builder.setTotalScore(data.getTotalScore());
        builder.setWeekRankTime(data.getWeekRankTime());
        builder.setTotalRankTime(data.getTotalRankTime());
        return builder.build();
    }

    static public com.game.pb.CommonPb.ComptePojo createComptePojoPb(ComptePojo cp) {
        com.game.pb.CommonPb.ComptePojo.Builder builder = com.game.pb.CommonPb.ComptePojo.newBuilder();
        builder.setPos(cp.getPos());
        builder.setServerId(cp.getServerId());
        builder.setRoleId(cp.getRoleId());
        builder.setNick(cp.getNick());
        builder.setBet(cp.getBet());
        builder.setMyBetNum(cp.getMyBetNum());
        builder.setServerName(cp.getServerName());
        builder.setFight(cp.getFight());
        builder.setPortrait(cp.getPortrait());
        if (cp.getPartyName() != null) {
            builder.setPartyName(cp.getPartyName());
        }

        return builder.build();
    }

    static public com.game.pb.CommonPb.ComptePojo createComptePojoPb(int pos, int serverId, long roleId, String nick, int bet, int myBetNum,
                                                                     String serverName, long fight, int portrait, String partyName) {
        com.game.pb.CommonPb.ComptePojo.Builder builder = com.game.pb.CommonPb.ComptePojo.newBuilder();
        builder.setPos(pos);
        builder.setServerId(serverId);
        builder.setRoleId(roleId);
        builder.setNick(nick);
        builder.setBet(bet);
        builder.setMyBetNum(myBetNum);
        builder.setServerName(serverName);
        builder.setFight(fight);
        builder.setPortrait(portrait);
        if (partyName != null) {
            builder.setPartyName(partyName);
        }

        return builder.build();
    }

    static public com.game.pb.CommonPb.CompteRound createCompteRoundPb(CompteRound cr) {
        com.game.pb.CommonPb.CompteRound.Builder builder = com.game.pb.CommonPb.CompteRound.newBuilder();
        builder.setRoundNum(cr.getRoundNum());
        builder.setWin(cr.getWin());
        builder.setReportKey(cr.getReportKey());
        builder.setDetail(cr.getDetail());
        return builder.build();
    }

    static public com.game.pb.CommonPb.CompteRound createCompteRoundPb(int roundNum, int win, int reportKey) {
        com.game.pb.CommonPb.CompteRound.Builder builder = com.game.pb.CommonPb.CompteRound.newBuilder();
        builder.setRoundNum(roundNum);
        builder.setWin(win);
        builder.setReportKey(reportKey);

        return builder.build();
    }

    public static CrossFame createCrossFame(com.game.pb.CommonPb.CrossFame cf) {
        CrossFame crossFame = new CrossFame();
        crossFame.setGroupId(cf.getGroupId());

        for (com.game.pb.CommonPb.FamePojo fp : cf.getFamePojoList()) {
            crossFame.famePojos.add(createFamePojo(fp));
        }

        for (com.game.pb.CommonPb.FameBattleReview fr : cf.getFameBattleReviewList()) {
            crossFame.fameBattleReviews.add(createFameBattleReview(fr));
        }

        return crossFame;
    }

    private static FameBattleReview createFameBattleReview(com.game.pb.CommonPb.FameBattleReview fr) {
        FameBattleReview fameBattleR = new FameBattleReview();
        fameBattleR.setPos(fr.getPos());
        fameBattleR.setName(fr.getName());
        fameBattleR.setServerId(fr.getServerId());
        fameBattleR.setServerName(fr.getServerName());
        fameBattleR.setLevel(fr.getLevel());
        fameBattleR.setFight(fr.getFight());
        fameBattleR.setPortrait(fr.getPortrait());
        return fameBattleR;
    }

    private static FamePojo createFamePojo(com.game.pb.CommonPb.FamePojo fp) {
        FamePojo famePojo = new FamePojo();
        famePojo.setId(fp.getId());
        famePojo.setName(fp.getName());
        famePojo.setServerId(fp.getServerId());
        famePojo.setServerName(fp.getServerName());
        famePojo.setLevel(fp.getLevel());
        famePojo.setFight(fp.getFight());
        famePojo.setPortrait(fp.getPortrait());
        return famePojo;
    }

    public static com.game.pb.CommonPb.CrossFameInfo createCrossFameInfoPb(CrossFameInfo info, int rank) {
        com.game.pb.CommonPb.CrossFameInfo.Builder builder = com.game.pb.CommonPb.CrossFameInfo.newBuilder();
        builder.setKeyId(rank);
        builder.setBeginTime(info.getBeginTime());
        builder.setEndTime(info.getEndTime());
        for (com.game.domain.p.corss.CrossFame cf : info.getCrossFames()) {
            builder.addCrossFame(createCrossFamePb(cf));
        }

        return builder.build();
    }

    private static com.game.pb.CommonPb.CrossFame createCrossFamePb(CrossFame cf) {
        com.game.pb.CommonPb.CrossFame.Builder builder = com.game.pb.CommonPb.CrossFame.newBuilder();
        builder.setGroupId(cf.getGroupId());
        for (com.game.domain.p.corss.FamePojo fp : cf.getFamePojos()) {
            builder.addFamePojo(createFamePojoPb(fp));
        }

        for (com.game.domain.p.corss.FameBattleReview fr : cf.getFameBattleReviews()) {
            builder.addFameBattleReview(createFameBattleReviewPb(fr));
        }

        return builder.build();
    }

    public static com.game.pb.CommonPb.CPFameInfo createCPFameInfoPb(CPFameInfo info, int rank) {
        com.game.pb.CommonPb.CPFameInfo.Builder builder = com.game.pb.CommonPb.CPFameInfo.newBuilder();
        builder.setKeyId(rank);
        builder.setBeginTime(info.getBeginTime());
        builder.setEndTime(info.getEndTime());

        for (com.game.domain.p.corssParty.CPFame cp : info.getCrossFames()) {
            builder.addCpFame(createCPFamePb(cp));
        }

        return builder.build();
    }

    private static com.game.pb.CommonPb.CPFame createCPFamePb(CPFame cp) {
        com.game.pb.CommonPb.CPFame.Builder builder = com.game.pb.CommonPb.CPFame.newBuilder();
        builder.setType(cp.getType());
        builder.setName(cp.getName());
        builder.setServerName(cp.getServerName());
        builder.setPortrait(cp.getPortrait());
        return builder.build();
    }

    private static com.game.pb.CommonPb.FameBattleReview createFameBattleReviewPb(FameBattleReview fr) {
        com.game.pb.CommonPb.FameBattleReview.Builder builder = com.game.pb.CommonPb.FameBattleReview.newBuilder();
        builder.setPos(fr.getPos());
        builder.setName(fr.getName());
        builder.setServerId(fr.getServerId());
        builder.setServerName(fr.getServerName());
        builder.setLevel(fr.getLevel());
        builder.setFight(fr.getFight());
        builder.setPortrait(fr.getPortrait());

        return builder.build();
    }

    private static com.game.pb.CommonPb.FamePojo createFamePojoPb(FamePojo fp) {
        com.game.pb.CommonPb.FamePojo.Builder builder = com.game.pb.CommonPb.FamePojo.newBuilder();
        builder.setId(fp.getId());
        builder.setName(fp.getName());
        builder.setServerId(fp.getServerId());
        builder.setServerName(fp.getServerName());
        builder.setLevel(fp.getLevel());
        builder.setFight(fp.getFight());
        builder.setPortrait(fp.getPortrait());

        return builder.build();
    }

    static public CommonPb.Medal createMedalPb(Medal medal) {
        CommonPb.Medal.Builder builder = CommonPb.Medal.newBuilder();
        builder.setKeyId(medal.getKeyId());
        builder.setMedalId(medal.getMedalId());
        builder.setUpLv(medal.getUpLv());
        builder.setUpExp(medal.getUpExp());
        builder.setRefitLv(medal.getRefitLv());
        builder.setPos(medal.getPos());
        builder.setLocked(medal.isLocked());
        return builder.build();
    }

    static public CommonPb.MedalBouns createMedalBounsPb(MedalBouns medalBouns) {
        CommonPb.MedalBouns.Builder builder = CommonPb.MedalBouns.newBuilder();
        builder.setMedalId(medalBouns.getMedalId());
        builder.setState(medalBouns.getState());
        return builder.build();
    }

    static public CommonPb.MedalChip createMedalChipPb(MedalChip medalChip) {
        CommonPb.MedalChip.Builder builder = CommonPb.MedalChip.newBuilder();
        builder.setChipId(medalChip.getChipId());
        builder.setCount(medalChip.getCount());
        return builder.build();
    }

    public static com.game.pb.CommonPb.PayRebate createPayRebatePb(List<Long> list, int maxCount) {
        com.game.pb.CommonPb.PayRebate.Builder builder = com.game.pb.CommonPb.PayRebate.newBuilder();
        builder.setMoney(list.get(0).intValue());
        builder.setRate(list.get(1).intValue());
        builder.setRecharge(list.get(2).intValue());
        builder.setNum(maxCount - list.get(3).intValue());

        return builder.build();
    }

    public static com.game.pb.CommonPb.PirateGrid createPirateGridPb(int grid, boolean has, List<Integer> award) {
        com.game.pb.CommonPb.PirateGrid.Builder builder = com.game.pb.CommonPb.PirateGrid.newBuilder();
        builder.setHas(has);
        builder.setGridData(createAtomPb(grid, award.get(0), award.get(1), award.get(2)));

        return builder.build();
    }

    public static CPFame createCPFame(com.game.pb.CommonPb.CPFame cf) {
        CPFame cc = new CPFame();
        cc.setType(cf.getType());
        cc.setName(cf.getName());
        cc.setServerName(cf.getServerName());
        if (cf.hasPortrait()) {
            cc.setPortrait(cf.getPortrait());
        }
        return cc;
    }

    public static Base.Builder createGameSaveErrorLogBase(int dataType, int errorCount, String errorDesc) {
        InnerPb.ServerErrorLogRq.Builder builder = InnerPb.ServerErrorLogRq.newBuilder();
        builder.setServerId(GameServer.ac.getBean(ServerSetting.class).getServerID());
        builder.setDataType(dataType);
        builder.setErrorCount(errorCount);
        builder.setErrorDesc(errorDesc);
        builder.setErrorTime(System.currentTimeMillis());
        return createRqBase(InnerPb.ServerErrorLogRq.EXT_FIELD_NUMBER, null, InnerPb.ServerErrorLogRq.ext, builder.build());
    }

    static public CommonPb.MapData createMapDataPb(ActRebelData rebel) {
        CommonPb.MapData.Builder builder = CommonPb.MapData.newBuilder();
        builder.setPos(rebel.getPos());
        builder.setLv(rebel.getRebelLv());
        builder.setHeroPick(ActRebelConst.REBEL_TYPE_ACT);
        builder.setSurface(rebel.getRebelId());// 该字段返回rebelId
        return builder.build();
    }

    public static CommonPb.ActRebelRank createActRebelRankPb(int rank, long lordId, String nick, int killNum, int score) {
        CommonPb.ActRebelRank.Builder builder = CommonPb.ActRebelRank.newBuilder();
        builder.setRank(rank);
        builder.setLordId(lordId);
        builder.setName(nick);
        builder.setKillNum(killNum);
        builder.setScore(score);
        return builder.build();
    }

    public static CommonPb.Day7Act createDay7ActPb(int keyId, int status, int recved) {
        CommonPb.Day7Act.Builder builder = CommonPb.Day7Act.newBuilder();
        builder.setKeyId(keyId);
        builder.setStatus(status);
        builder.setRecved(recved);
        return builder.build();
    }

    public static CommonPb.DbDay7Act createDbDay7ActPb(Day7Act day7Act) {
        CommonPb.DbDay7Act.Builder builder = CommonPb.DbDay7Act.newBuilder();
        builder.addAllRecvAwardIds(day7Act.getRecvAwardIds());
        for (Entry<Integer, Integer> e : day7Act.getStatus().entrySet()) {
            builder.addStatus(createTwoIntPb(e.getKey(), e.getValue()));
        }
        for (Entry<Integer, Integer> e : day7Act.getTankTypes().entrySet()) {
            builder.addTankTypes(createTwoIntPb(e.getKey(), e.getValue()));
        }
        builder.setLvUpDay(day7Act.getLvUpDay());
        for (int[] e : day7Act.getEquips()) {
            builder.addEquips(createTwoIntPb(e[0], e[1]));
        }
        return builder.build();
    }

    public static CommonPb.AwakenHero createAwakenHeroPb(AwakenHero awakenHero) {
        CommonPb.AwakenHero.Builder builder = CommonPb.AwakenHero.newBuilder();
        builder.setKeyId(awakenHero.getKeyId());
        builder.setHeroId(awakenHero.getHeroId());
        builder.setState(awakenHero.getState());
        for (Entry<Integer, Integer> entry : awakenHero.getSkillLv().entrySet()) {
            builder.addSkillLv(PbHelper.createTwoIntPb(entry.getKey(), entry.getValue()));
        }
        builder.setFailTimes(awakenHero.getFailTimes());
        return builder.build();
    }

    public static CommonPb.Shop createShopPb(Shop shop) {
        CommonPb.Shop.Builder builder = CommonPb.Shop.newBuilder();
        builder.setSty(shop.getSty());
        builder.setRefreashTime(shop.getRefreashTime());
        if (!shop.getBuyMap().isEmpty()) {
            CommonPb.ShopBuy.Builder buyBuilder = CommonPb.ShopBuy.newBuilder();
            for (Entry<Integer, ShopBuy> entry : shop.getBuyMap().entrySet()) {
                buyBuilder.setGid(entry.getValue().getGid());
                buyBuilder.setBuyCount(entry.getValue().getBuyCount());
                builder.addBuy(buyBuilder.build());
                buyBuilder.clear();
            }
        }
        return builder.build();
    }

    public static CommonPb.RptMan createRptMan(Player player, int hero, Long mplt, int firstValue) {
        CommonPb.RptMan.Builder builder = CommonPb.RptMan.newBuilder();
        Lord lord = player.lord;
        builder.setName(lord.getNick());
        builder.setHero(hero);
        builder.setFirstValue(firstValue);
        if (mplt != null) {
            builder.setMplt(mplt.intValue());
        }
        return builder.build();
    }

    public static CommonPb.RptMan createRptMan(DefenceNPC npc, int hero, Long mplt) {
        CommonPb.RptMan.Builder builder = CommonPb.RptMan.newBuilder();
        builder.setName(FortressFightConst.NPC_NAME);
        builder.setHero(hero);
        if (mplt != null) {
            builder.setMplt(mplt.intValue());
        }
        return builder.build();
    }

    /**
     * 创建飞艇基础信息
     *
     * @param airship
     * @param teamLeader 0-本公会当前没有对该飞艇发起战斗队伍集结
     * @return
     */
    public static CommonPb.AirshipBase.Builder createAirshipBase(Airship airship, long teamLeader) {
        CommonPb.AirshipBase.Builder builder = CommonPb.AirshipBase.newBuilder();
        builder.setId(airship.getId());
        builder.setSafeEndTime(airship.getSafeEndTime());
        builder.setTeamLeader(teamLeader);
        builder.setRuins(airship.isRuins());
        int attackCount = 0;
        if (!airship.getTeamArmy().isEmpty()) {
            for (AirshipTeam airshipTeam : airship.getTeamArmy()) {
                if (airshipTeam.getState() == ArmyState.AIRSHIP_MARCH) {
                    attackCount++;
                }
            }
        }
        builder.setAttackCount(attackCount);
        return builder;
    }

    public static CommonPb.AirshipOccupy.Builder createAirshipOccupy(Airship airship, PartyData data, Lord commander) {
        CommonPb.AirshipOccupy.Builder builder = CommonPb.AirshipOccupy.newBuilder();
        builder.setPartyId(data.getPartyId());
        builder.setPartyName(data.getPartyName());
        builder.setLordId(commander.getLordId());
        builder.setLordName(commander.getNick());
        builder.setPortrait(commander.getPortrait());
        return builder;
    }

    /**
     * 创建飞艇详细信息
     *
     * @param airship
     * @param team_leader 飞艇
     * @return
     */
    public static CommonPb.AirshipDetail.Builder createAirshipDetail(Airship airship) {
        CommonPb.AirshipDetail.Builder builder = CommonPb.AirshipDetail.newBuilder();
        builder.setProduceNum(airship.getProduceNum());
        builder.setProduceTime(airship.getProduceTime());
        builder.setDurability(airship.getDurability());
        return builder;
    }

    static public CommonPb.TwoLong createTwoLongPb(long p, long c) {
        TwoLong.Builder builder = TwoLong.newBuilder();
        builder.setV1(p);
        builder.setV2(c);
        return builder.build();
    }

    public static CommonPb.AirshipTeam createAirshipTeam(AirshipTeam team, Player p) {
        CommonPb.AirshipTeam.Builder builder = CommonPb.AirshipTeam.newBuilder();
        builder.setLordId(team.getLordId());
        String lordName = p.lord.getNick();
        int portrait = p.lord.getPortrait();
        builder.setLordName(lordName);
        builder.setPortrait(portrait);
        builder.setAirshipId(team.getId());
        builder.setArmyNum(team.getArmys().size());
        long fight = 0;
        for (Army army : team.getArmys()) {
            fight += army.getFight();
        }
        builder.setFight(fight);
        builder.setEndTime(team.getEndTime());
        builder.setState(team.getState());
        return builder.build();
    }

    public static CommonPb.AirshipArmy createAirshipTeamArmy(Army teamArmy, Player lordPlayer) {
        CommonPb.AirshipArmy.Builder builder = CommonPb.AirshipArmy.newBuilder();
        builder.setLordId(teamArmy.player.roleId);
        builder.setArmyKeyId(teamArmy.getKeyId());

        String lordName = "";
        int portrait = 0;
        int level = 0;
        if (lordPlayer != null) {
            lordName = lordPlayer.lord.getNick();
            portrait = lordPlayer.lord.getPortrait();
            level = lordPlayer.lord.getLevel();
        }
        builder.setLordName(lordName);
        builder.setPortrait(portrait);

        int tankCount = 0;
        int[] p = teamArmy.getForm().p;
        int[] c = teamArmy.getForm().c;
        for (int i = 0; i < p.length; i++) {
            if (p[i] > 0) {
                tankCount += c[i];
            }
        }

        builder.setTankCount(tankCount);
        builder.setFight(teamArmy.getFight());
        builder.setLevel(level);
        if (teamArmy.getForm().getAwakenHero() != null) {
            builder.setCommander(teamArmy.getForm().getAwakenHero().getHeroId());
        } else {
            builder.setCommander(teamArmy.getForm().getCommander());
        }
        return builder.build();
    }

    public static CommonPb.RptAtkMan.Builder createRptAtkMan(FightService fightService, Player player, Army army) {
        CommonPb.RptAtkMan.Builder builder = CommonPb.RptAtkMan.newBuilder();
        builder.setName(player.lord.getNick());
        builder.setLordId(player.roleId);

        if (army.getForm().getAwakenHero() != null) {
            builder.setCommander(army.getForm().getAwakenHero().getHeroId());
        } else {
            builder.setCommander(army.getForm().getCommander());
        }

        Fighter fight = fightService.createAirshipFighter(player, army.getForm(), AttackType.ACK_DEFAULT_PLAYER);
        builder.setFirstValue(fight.firstValue);

        return builder;
    }

    public static CommonPb.Report createAtkAirshipReport(RptAtkAirship rpt, int now) {
        Report.Builder report = Report.newBuilder();
        report.setAtkAirship(rpt);
        report.setTime(now);
        return report.build();
    }

    public static CommonPb.Report createDefAirshipReport(RptAtkAirship rpt, int now) {
        Report.Builder report = Report.newBuilder();
        report.setDefAirship(rpt);
        report.setTime(now);
        return report.build();
    }

    public static CommonPb.LordEquip createLordEquip(LordEquip eq) {
        CommonPb.LordEquip.Builder builder = CommonPb.LordEquip.newBuilder();
        builder.setKeyId(eq.getKeyId());
        builder.setEquipId(eq.getEquipId());
        builder.setPos(eq.getPos());
        builder.setIsLock(eq.isLock());
        for (List<Integer> skillId : eq.getLordEquipSkillList()) {
            // [军备技能id,等级]列表
            builder.addSkillLv(createTwoIntPb(skillId.get(0), skillId.get(1)));
        }

        for (List<Integer> skillId : eq.getLordEquipSkillSecondList()) {
            // [军备技能id,等级]列表
            builder.addSkillLvSecond(createTwoIntPb(skillId.get(0), skillId.get(1)));
        }

        builder.setLordEquipSaveType(eq.getLordEquipSaveType());

        return builder.build();
    }

    public static CommonPb.LordEquipBuilding createLordEquipBuilding(LordEquipBuilding building) {
        CommonPb.LordEquipBuilding.Builder builder = CommonPb.LordEquipBuilding.newBuilder();
        builder.setEquipId(building.getStaticId());
        builder.setEndTime((int) building.getEndTime());
        builder.setTechId(building.getTechId());
        builder.setPeriod((int) building.getPeriod());
        return builder.build();
    }

    public static CommonPb.LeqMatBuilding createLordEquipMatBuilding(LordEquipMatBuilding building) {
        CommonPb.LeqMatBuilding.Builder builder = CommonPb.LeqMatBuilding.newBuilder();
        builder.setPid(building.getStaticId());
        builder.setCount(building.getCount());
        builder.setPeriod(building.getPeriod());
        builder.setComplete(building.getComplete());
        builder.setEndTime(building.getEndTime());
        return builder.build();
    }

    /**
     * 文官进驻
     *
     * @param heroList
     * @return
     */
    public static HeroPut createHeroPut(List<Integer> heroList) {
        HeroPut.Builder builder = HeroPut.newBuilder();
        builder.setPartId(heroList.get(0));
        for (int i = 1; i < heroList.size(); i++) {
            builder.addHeroId(heroList.get(i));
        }
        return builder.build();
    }

    /**
     * @param type      类型
     * @param id        编号
     * @param count     数量
     * @param key       这个物品的唯一标识
     * @param skillList
     * @return
     */
    public static CommonPb.Award createAwardPbWithParamList(int type, int id, long count, int keyId, List<Integer> list) {
        CommonPb.Award.Builder builder = CommonPb.Award.newBuilder();
        builder.setType(type);
        builder.setId(id);
        builder.setCount(count);
        if (keyId != 0) {
            builder.setKeyId(keyId);
        }
        for (int param : list) {
            builder.addParam(param);
        }

        return builder.build();
    }

    /**
     * 超时空财团面板 转换 上午11:52:19
     */
    public static CommonPb.QuinnPanel createQuinnPanel(QuinnPanel next) {
        CommonPb.QuinnPanel.Builder builder = CommonPb.QuinnPanel.newBuilder();
        builder.setType(next.getType());
        builder.addAllQuinn(next.getQuinns());
        builder.setGetType(next.getGetType());
        builder.setGetNumber(next.getGetNumber());
        builder.setGetSum(next.getGetSum());
        builder.setRefreshTime(next.getFreshedDate());
        if (next.getAwards() != null) {
            builder.addAllAward(next.getAwards());
        }
        builder.setEggId(next.getEggId());
        return builder.build();
    }

    /**
     * @param type
     * @param skinId
     * @param count
     * @return
     */
    public static ThreeInt createThreePb(int v1, int v2, int v3) {
        ThreeInt.Builder builder = ThreeInt.newBuilder();
        builder.setV1(v1);
        builder.setV2(v2);
        builder.setV3(v3);
        return builder.build();
    }

    /**
     * 创建秘密武器信息
     *
     * @param weapon
     * @return
     */
    public static CommonPb.SecretWeapon createSecretWeapon(SecretWeapon weapon) {
        CommonPb.SecretWeapon.Builder builder = CommonPb.SecretWeapon.newBuilder();
        builder.setId(weapon.getId());
        for (SecretWeaponBar bar : weapon.getBars()) {
            CommonPb.SecretWeaponBar.Builder pbBar = CommonPb.SecretWeaponBar.newBuilder();
            pbBar.setSid(bar.getSid());
            pbBar.setLocked(bar.isLock());
            builder.addBar(pbBar);
        }
        return builder.build();
    }

    /**
     * @param effect
     * @return
     */
    public static AttackEffectPb createAttackEffectPb(AttackEffect effect) {
        AttackEffectPb.Builder builder = AttackEffectPb.newBuilder();
        builder.addAllUnlock(effect.getUnlock());
        builder.setType(effect.getType());
        builder.setUseId(effect.getUseId());
        return builder.build();
    }

    /**
     * 序列化作战实验室兵种调配
     *
     * @param labInfo
     * @return
     */
    public static List<CommonPb.GraduateInfoPb> createGraduateInfoPb(Map<Integer, Map<Integer, Integer>> graduateMap) {
        List<CommonPb.GraduateInfoPb> list = new ArrayList<>();
        for (Entry<Integer, Map<Integer, Integer>> typeEntry : graduateMap.entrySet()) {
            CommonPb.GraduateInfoPb.Builder builder = CommonPb.GraduateInfoPb.newBuilder();
            builder.setType(typeEntry.getKey());
            for (Entry<Integer, Integer> skillEntry : typeEntry.getValue().entrySet()) {
                Integer level = skillEntry.getValue();
                if (level != null && level > 0) {
                    builder.addGraduateInfo(PbHelper.createTwoIntPb(skillEntry.getKey(), skillEntry.getValue()));
                }
            }
            list.add(builder.build());
        }
        return list;
    }

    /**
     * 红包在聊天框里面显示的信息
     *
     * @param player
     * @param arb
     * @return
     */
    public static CommonPb.RedBagChat createRedBagChat(Player player, ActRedBag arb) {
        CommonPb.RedBagChat.Builder builder = CommonPb.RedBagChat.newBuilder();
        Lord lord = player.lord;
        builder.setTime((int) (arb.getSendTime() / 1000));
        builder.setUid(arb.getId());
        builder.setName(lord.getNick());
        builder.setPortrait(lord.getPortrait());
        builder.setStaffing(lord.getStaffing());
        builder.setVip(lord.getVip());
        builder.setMilitaryRank(lord.getMilitaryRank());
        builder.setBubble(player.getCurrentSkin(SkinType.BUBBLE));
        builder.setUid(arb.getId());
        builder.setRemainGrab(arb.getGrabCnt() - arb.getGrabs().size());
        builder.setType(arb.getPartyId() == 0 ? 1 : 2);// 1-世界红包,2-军团红包
        return builder.build();
    }

    /**
     * 组队副本队员信息
     *
     * @param player
     * @param status
     * @return
     */
    public static CommonPb.TeamRoleInfo createTeamRoleInfo(Player player, int status, long fight) {
        CommonPb.TeamRoleInfo.Builder builder = CommonPb.TeamRoleInfo.newBuilder();
        Lord lord = player.lord;
        builder.setRoleId(lord.getLordId());
        builder.setNick(lord.getNick());
        builder.setPortrait(lord.getPortrait());
        builder.setFight(fight);
        builder.setStatus(status);
        return builder.build();
    }

    /**
     * 组队副本队员信息
     *
     * @param player
     * @param status
     * @return
     */
    public static CommonPb.TeamRoleInfo createTeamRoleInfo(CrossTeamProto.RpcTeamRoleInfo response) {
        CommonPb.TeamRoleInfo.Builder builder = CommonPb.TeamRoleInfo.newBuilder();
        builder.setRoleId(response.getRoleId());
        builder.setNick(response.getNick());
        builder.setPortrait(response.getPortrait());
        builder.setFight(response.getFight());
        builder.setStatus(response.getStatus());
        builder.setServerName(response.getServerName());
        return builder.build();
    }


    /**
     * 商店一次兑换信息
     *
     * @param goodid
     * @param count
     * @return
     */
    public static CommonPb.ShopBuy createShopBuy(int goodId, int count) {
        CommonPb.ShopBuy.Builder builder = CommonPb.ShopBuy.newBuilder();
        builder.setGid(goodId);
        builder.setBuyCount(count);
        return builder.build();
    }

    /**
     * 红包信息
     *
     * @param goodid
     * @param count
     * @return
     */
    public static CommonPb.ActRedBag createActRedBag(Player player, List<Player> playerList, ActRedBag arb) {
        CommonPb.ActRedBag.Builder builder = CommonPb.ActRedBag.newBuilder();
        builder.setUid(arb.getId());
        builder.setTotalMoney(arb.getTotalMoney());
        builder.setRemainMoney(arb.getRemainMoney());
        builder.setGrabCnt(arb.getGrabCnt());
        builder.setSendTime(arb.getSendTime());
        builder.setLordName(player.lord.getNick());
        builder.setPortrait(player.lord.getPortrait());
        for (Player p : playerList) {
            for (Map.Entry<Long, GrabRedBag> entry : arb.getGrabs().entrySet()) {
                if (p.lord.getLordId() == entry.getKey()) {
                    builder.addGrab(createGrabRedBag(p, entry.getValue()));
                }
            }
        }

        return builder.build();
    }

    /**
     * 本次抢红包结果信息
     *
     * @param goodid
     * @param count
     * @return
     */
    public static CommonPb.GrabRedBag createGrabRedBag(Player player, GrabRedBag grb) {
        CommonPb.GrabRedBag.Builder builder = CommonPb.GrabRedBag.newBuilder();
        builder.setLordName(player.lord.getNick());
        builder.setPortrait(player.lord.getPortrait());
        builder.setGrabMoney(grb.getGrabMoney());
        builder.setGrabTime(grb.getGrabTime());
        return builder.build();
    }

    /**
     * 幸运奖池中大奖记录
     *
     * @param goodid
     * @return
     */
    public static CommonPb.ActLuckyPoolLog createActLuckyPoolLog(ActLuckyPoolLog log) {
        CommonPb.ActLuckyPoolLog.Builder builder = CommonPb.ActLuckyPoolLog.newBuilder();
        builder.setName(log.getName());
        builder.setGoodInfo(log.getGoodInfo());
        builder.setTime(log.getTime());
        return builder.build();
    }

    /**
     * 叛军活动军团周记录
     *
     * @param goodid
     */
    public static CommonPb.PartyRebelData createPartyRebelData(PartyRebelData data) {
        CommonPb.PartyRebelData.Builder builder = CommonPb.PartyRebelData.newBuilder();
        builder.setPartyId(data.getPartyId());
        builder.setPartyName(data.getPartyName());
        builder.setRank(data.getRank());
        builder.setLastRank(data.getLastRank());
        builder.setKillUnit(data.getKillUnit());
        builder.setKillGuard(data.getKillGuard());
        builder.setKillLeader(data.getKillLeader());
        builder.setScore(data.getScore());
        return builder.build();
    }

    public static CommonPb.HonourScore createHonourPartyScore(HonourPartyScore data) {
        CommonPb.HonourScore.Builder builder = CommonPb.HonourScore.newBuilder();
        builder.setPartyId(data.getPartyId());
        builder.setScore(data.getScore());
        builder.setRankTime(data.getRankTime());
        builder.setScore(data.getScore());
        builder.setOpenTime(data.getOpenTime());
        return builder.build();
    }

    public static CommonPb.HonourRank createHonourRank(int rank, int score, String nick) {
        CommonPb.HonourRank.Builder builder = CommonPb.HonourRank.newBuilder();
        builder.setNick(nick);
        builder.setRank(rank);
        builder.setScore(score);
        return builder.build();
    }

    public static CommonPb.LeqScheme createSimpleLeqScheme(int type, String name) {
        CommonPb.LeqScheme.Builder builder = CommonPb.LeqScheme.newBuilder();
        builder.setType(type);
        builder.setName(name == null ? "" : name);
        return builder.build();
    }

    public static CommonPb.Tactics createTactics(Tactics t) {
        CommonPb.Tactics.Builder builder1 = CommonPb.Tactics.newBuilder();
        builder1.setKeyId(t.getKeyId());
        builder1.setTacticsId(t.getTacticsId());
        builder1.setLv(t.getLv());
        builder1.setExp(t.getExp());
        builder1.setUse(t.getUse());
        builder1.setState(t.getState());
        builder1.setBind(t.getBind());
        return builder1.build();
    }

    public static CommonPb.WipeInfo createWipeInfo(WipeInfo info) {
        CommonPb.WipeInfo.Builder builder1 = CommonPb.WipeInfo.newBuilder();
        builder1.setExploreType(info.getExploreType());
        builder1.setCombatId(info.getCombatId());
        builder1.setBuyCount(info.getBuyCount());
        return builder1.build();
    }

    public static CommonPb.FriendGive createFriendGivePb(FriendGive next) {
        CommonPb.FriendGive.Builder builder = CommonPb.FriendGive.newBuilder();
        builder.setLordId(next.getLordId());
        builder.setCount(next.getCount());
        builder.setGiveTime(next.getGiveTime());
        return builder.build();
    }

    public static CommonPb.GetGiveProp createGetGivePropPb(GetGiveProp getGiveProp) {
        CommonPb.GetGiveProp.Builder builder = CommonPb.GetGiveProp.newBuilder();
        builder.setType(getGiveProp.getType());
        builder.setPropId(getGiveProp.getPropId());
        builder.setNum(getGiveProp.getNum());
        builder.setLastGiveTime(getGiveProp.getLastGiveTime());
        return builder.build();
    }

    public static CommonPb.DBFriendliness createDbFriendlinessPb(Friendliness next) {
        CommonPb.DBFriendliness.Builder builder = CommonPb.DBFriendliness.newBuilder();
        builder.setLordId(next.getLordId());
        builder.setState(next.getState());
        builder.setCreateTime(next.getCreateTime());
        return builder.build();
    }
}
