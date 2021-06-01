package com.test.simula;

import com.game.pb.BasePb;
import com.game.pb.*;
import com.game.pb.GamePb6.*;
import com.game.pb.GamePb5.*;
import com.google.protobuf.GeneratedMessage;

/**
 * @author zhangdh
 * @ClassName: SimulaRequestFactory
 * @Description: 创建Request
 * @date 2017/5/12 18:51
 */
public class SimulaRequestFactory {


    public static void ResetMilitaryScienceRq(String readLine) {
        ResetMilitaryScienceRq.Builder builder = ResetMilitaryScienceRq.newBuilder();
        builder.setType(1);
        BasePb.Base base = adaptBase(ResetMilitaryScienceRq.EXT_FIELD_NUMBER, ResetMilitaryScienceRq.ext, builder.build());
        SimulaAccout.ctx.writeAndFlush(base);
    }
    public static void ResetFightLabGraduateUpRq(String readLine) {
        ResetFightLabGraduateUpRq.Builder builder = ResetFightLabGraduateUpRq.newBuilder();
        builder.setType(1);
        BasePb.Base base = adaptBase(ResetFightLabGraduateUpRq.EXT_FIELD_NUMBER, ResetFightLabGraduateUpRq.ext, builder.build());
        SimulaAccout.ctx.writeAndFlush(base);
    }

    public static void GetActLuckyRewardRq(String readLine) {
        GetActLuckyRewardRq.Builder builder = GetActLuckyRewardRq.newBuilder();
        builder.setCount(Integer.valueOf(readLine));
        BasePb.Base base = adaptBase(GetActLuckyRewardRq.EXT_FIELD_NUMBER, GetActLuckyRewardRq.ext, builder.build());
        SimulaAccout.ctx.writeAndFlush(base);
    }


    public static void GetActLuckyInfoRq(String readLine) {
        GetActLuckyInfoRq.Builder builder = GetActLuckyInfoRq.newBuilder();
        BasePb.Base base = adaptBase(GetActLuckyInfoRq.EXT_FIELD_NUMBER, GetActLuckyInfoRq.ext, builder.build());
        SimulaAccout.ctx.writeAndFlush(base);
    }

    public static void GetFestivalLoginRewardRq(String readLine) {
        GetFestivalLoginRewardRq.Builder builder = GetFestivalLoginRewardRq.newBuilder();
        BasePb.Base base = adaptBase(GetFestivalLoginRewardRq.EXT_FIELD_NUMBER, GetFestivalLoginRewardRq.ext, builder.build());
        SimulaAccout.ctx.writeAndFlush(base);
    }

    public static void GetFestivalRewardRq(String readLine) {
        GetFestivalRewardRq.Builder builder = GetFestivalRewardRq.newBuilder();
        builder.setId(Integer.valueOf(readLine));
        BasePb.Base base = adaptBase(GetFestivalRewardRq.EXT_FIELD_NUMBER, GetFestivalRewardRq.ext, builder.build());
        SimulaAccout.ctx.writeAndFlush(base);
    }

    public static void GetFestivalInfoRq(String readLine) {
        GetFestivalInfoRq.Builder builder = GetFestivalInfoRq.newBuilder();
        BasePb.Base base = adaptBase(GetFestivalInfoRq.EXT_FIELD_NUMBER, GetFestivalInfoRq.ext, builder.build());
        SimulaAccout.ctx.writeAndFlush(base);
    }



//    public static void GetGuideRewardRq(String readLine) {
//        GetGuideRewardRq.Builder builder = GetGuideRewardRq.newBuilder();
//        builder.setIndex(Integer.valueOf(readLine));
//        BasePb.Base base = adaptBase(GetGuideRewardRq.EXT_FIELD_NUMBER, GetGuideRewardRq.ext, builder.build());
//        SimulaAccout.ctx.writeAndFlush(base);
//    }
//
//    public static void GetRedPlanAreaInfoRq(String readLine) {
//        GetRedPlanAreaInfoRq.Builder builder = GetRedPlanAreaInfoRq.newBuilder();
//        builder.setAreaId(2);
//        BasePb.Base base = adaptBase(GetRedPlanAreaInfoRq.EXT_FIELD_NUMBER, GetRedPlanAreaInfoRq.ext, builder.build());
//        SimulaAccout.ctx.writeAndFlush(base);
//    }
//    public static void GetRedPlanBoxRq(String readLine) {
//        GetRedPlanBoxRq.Builder builder = GetRedPlanBoxRq.newBuilder();
//        builder.setAreaId(1);
//        BasePb.Base base = adaptBase(GetRedPlanBoxRq.EXT_FIELD_NUMBER, GetRedPlanBoxRq.ext, builder.build());
//        SimulaAccout.ctx.writeAndFlush(base);
//    }
//
//
//    public static void RedPlanBuyFuelRq(String readLine) {
//        RedPlanBuyFuelRq.Builder builder = RedPlanBuyFuelRq.newBuilder();
//        BasePb.Base base = adaptBase(RedPlanBuyFuelRq.EXT_FIELD_NUMBER, RedPlanBuyFuelRq.ext, builder.build());
//        SimulaAccout.ctx.writeAndFlush(base);
//    }
//
//    public static void RedPlanRewardRq(String readLine) {
//        RedPlanRewardRq.Builder builder = RedPlanRewardRq.newBuilder();
//        builder.setGoodsid(101);
//        BasePb.Base base = adaptBase(RedPlanRewardRq.EXT_FIELD_NUMBER, RedPlanRewardRq.ext, builder.build());
//        SimulaAccout.ctx.writeAndFlush(base);
//    }
//
//    public static void MoveRedPlanRq(String readLine) {
//        MoveRedPlanRq.Builder builder = MoveRedPlanRq.newBuilder();
//        builder.setAreaId(2);
//        BasePb.Base base = adaptBase(MoveRedPlanRq.EXT_FIELD_NUMBER, MoveRedPlanRq.ext, builder.build());
//        SimulaAccout.ctx.writeAndFlush(base);
//    }
//
//    public static void GetRedPlanInfoRq(String readLine) {
//        GetRedPlanInfoRq.Builder builder = GetRedPlanInfoRq.newBuilder();
//        BasePb.Base base = adaptBase(GetRedPlanInfoRq.EXT_FIELD_NUMBER, GetRedPlanInfoRq.ext, builder.build());
//        SimulaAccout.ctx.writeAndFlush(base);
//    }
//
//
//
//
//
//
//    /**
//     * 作战实验室 间谍任务领取奖励
//     */
//    public static void GctFightLabSpyTaskRewardRq(){
//        GctFightLabSpyTaskRewardRq.Builder builder = GctFightLabSpyTaskRewardRq.newBuilder();
//        builder.setAreaId(300);
//        BasePb.Base base = adaptBase(GctFightLabSpyTaskRewardRq.EXT_FIELD_NUMBER, GctFightLabSpyTaskRewardRq.ext, builder.build());
//        SimulaAccout.ctx.writeAndFlush(base);
//    }
//
//
//
//    /**
//     * 作战实验室 间谍任务派遣
//     */
//    public static void ActFightLabSpyTaskRq(){
//        ActFightLabSpyTaskRq.Builder builder = ActFightLabSpyTaskRq.newBuilder();
//        builder.setAreaId(300);
//        builder.setSpyId(101);
//        BasePb.Base base = adaptBase(ActFightLabSpyTaskRq.EXT_FIELD_NUMBER, ActFightLabSpyTaskRq.ext, builder.build());
//        SimulaAccout.ctx.writeAndFlush(base);
//    }
//
//
//    /**
//     * 作战实验室 间谍任务刷新
//     */
//    public static void RefFightLabSpyTaskRq(){
//        RefFightLabSpyTaskRq.Builder builder = RefFightLabSpyTaskRq.newBuilder();
//        builder.setAreaId(300);
//        BasePb.Base base = adaptBase(RefFightLabSpyTaskRq.EXT_FIELD_NUMBER, RefFightLabSpyTaskRq.ext, builder.build());
//        SimulaAccout.ctx.writeAndFlush(base);
//    }
//
//
//    /**
//     * 作战实验室 间谍地图激活
//     */
//    public static void ActFightLabSpyAreaRq(){
//        ActFightLabSpyAreaRq.Builder builder = ActFightLabSpyAreaRq.newBuilder();
//        builder.setAreaId(300);
//        BasePb.Base base = adaptBase(ActFightLabSpyAreaRq.EXT_FIELD_NUMBER, ActFightLabSpyAreaRq.ext, builder.build());
//        SimulaAccout.ctx.writeAndFlush(base);
//    }
//
//
//
//    /**
//     * 作战实验室 获取间谍信息
//     */
//    public static void GetFightLabSpyInfoRq(){
//        GetFightLabSpyInfoRq.Builder builder = GetFightLabSpyInfoRq.newBuilder();
//        BasePb.Base base = adaptBase(GetFightLabSpyInfoRq.EXT_FIELD_NUMBER, GetFightLabSpyInfoRq.ext, builder.build());
//        SimulaAccout.ctx.writeAndFlush(base);
//    }
//
//
//
//
//    /**
//     * 发送获取红包活动信息
//     */
//    public static void sendGetActRedBagInfoRq(){
//        GetActRedBagInfoRq.Builder builder = GetActRedBagInfoRq.newBuilder();
//        BasePb.Base base = adaptBase(GetActRedBagInfoRq.EXT_FIELD_NUMBER, GetActRedBagInfoRq.ext, builder.build());
//        SimulaAccout.ctx.writeAndFlush(base);
//    }
//
//    /**
//     * 领取阶段奖励
//     */
//    public static void sendDrawActRedBagStageAwardRq(String command){
//        DrawActRedBagStageAwardRq.Builder builder = DrawActRedBagStageAwardRq.newBuilder();
//        builder.setStage(Integer.parseInt(command.split(",")[1]));
//        BasePb.Base base = adaptBase(DrawActRedBagStageAwardRq.EXT_FIELD_NUMBER, DrawActRedBagStageAwardRq.ext, builder.build());
//        SimulaAccout.ctx.writeAndFlush(base);
//    }
//
//    /**
//     * 获取红包列表
//     */
//    public static void sendGetActRedBagListRq(){
//        GetActRedBagListRq.Builder builder = GetActRedBagListRq.newBuilder();
//        BasePb.Base base = adaptBase(GetActRedBagListRq.EXT_FIELD_NUMBER, GetActRedBagListRq.ext, builder.build());
//        SimulaAccout.ctx.writeAndFlush(base);
//    }
//
//    /**
//     * 抢红包
//     * @param command
//     */
//    public static void sendGrabRedBagRq(String command){
//        GrabRedBagRq.Builder builder = GrabRedBagRq.newBuilder();
//        builder.setUid(Integer.parseInt(command.split(",")[1]));
//        BasePb.Base base = adaptBase(GrabRedBagRq.EXT_FIELD_NUMBER, GrabRedBagRq.ext, builder.build());
//        SimulaAccout.ctx.writeAndFlush(base);
//    }
//
//    /**
//     * 发放红包,格式: 4621,19,10,0
//     * @param command
//     */
//    public static void sendActRedBag(String command) {
//        SendActRedBagRq.Builder builder = SendActRedBagRq.newBuilder();
//        String[] strArr = command.split(",");
//        builder.setPropId(Integer.parseInt(strArr[1]));
//        int grabCnt = strArr.length >= 2 ? 10 : Integer.parseInt(strArr[2]);
//        builder.setGrabCnt(grabCnt);
//        if (strArr.length == 4) {
//            builder.setIsPartyRedBag("1".equals(strArr[3]));
//        }
//        BasePb.Base base = adaptBase(SendActRedBagRq.EXT_FIELD_NUMBER, SendActRedBagRq.ext, builder.build());
//        SimulaAccout.ctx.writeAndFlush(base);
//    }
//
//    /**
//     * 探宝活动配置信息
//     */
//    public static void sendActLotteryExplore() {
//        GetActLotteryExploreRq.Builder builder = GetActLotteryExploreRq.newBuilder();
//        BasePb.Base base = adaptBase(GetActLotteryExploreRq.EXT_FIELD_NUMBER, GetActLotteryExploreRq.ext, builder.build());
//        SimulaAccout.ctx.writeAndFlush(base);
//    }
//
//    public static void sendAttackPosRq(String command) {
//        GamePb2.AttackPosRq.Builder builder = GamePb2.AttackPosRq.newBuilder();
//        String[] arr = command.split(",");
//        Form form = new Form();
//        for (int i = 0; i < 6; i++) {
//            form.p[i] = 25;
//            form.c[i] = 200;
//        }
//        CommonPb.Form pbForm = PbHelper.createFormPb(form);
//        builder.setForm(pbForm);
//        builder.setPos(Integer.parseInt(arr[1]));
//        BasePb.Base base = adaptBase(GamePb2.AttackPosRq.EXT_FIELD_NUMBER, GamePb2.AttackPosRq.ext, builder.build());
//        SimulaAccout.ctx.writeAndFlush(base);
//    }
//
//    public static void getFightLabGraduateRewardRq(String command) {
//        GetFightLabGraduateRewardRq.Builder builder = GetFightLabGraduateRewardRq.newBuilder();
//        BasePb.Base base = adaptBase(GetFightLabGraduateRewardRq.EXT_FIELD_NUMBER, GetFightLabGraduateRewardRq.ext, builder.build());
//        SimulaAccout.ctx.writeAndFlush(base);
//    }
//
//    public static void upFightLabGraduateUpRq(String command) {
//
//        String[] s = command.split(",");
//        UpFightLabGraduateUpRq.Builder builder = UpFightLabGraduateUpRq.newBuilder();
//        builder.setType(Integer.valueOf(s[1]));
//        builder.setSkillId(Integer.valueOf(s[2]));
//        BasePb.Base base = adaptBase(UpFightLabGraduateUpRq.EXT_FIELD_NUMBER, UpFightLabGraduateUpRq.ext, builder.build());
//        SimulaAccout.ctx.writeAndFlush(base);
//    }
//
//    public static void getFightLabGraduateInfoRq(String command) {
//        GetFightLabGraduateInfoRq.Builder builder = GetFightLabGraduateInfoRq.newBuilder();
//        BasePb.Base base = adaptBase(GetFightLabGraduateInfoRq.EXT_FIELD_NUMBER, GetFightLabGraduateInfoRq.ext, builder.build());
//        SimulaAccout.ctx.writeAndFlush(base);
//    }
//
//    public static void getFightLabResourceRq(String command) {
//        GetFightLabResourceRq.Builder builder = GetFightLabResourceRq.newBuilder();
//        String[] s = command.split(",");
//        builder.setResourceId(Integer.valueOf(s[1]));
//        BasePb.Base base = adaptBase(GetFightLabResourceRq.EXT_FIELD_NUMBER, GetFightLabResourceRq.ext, builder.build());
//        SimulaAccout.ctx.writeAndFlush(base);
//    }
//
//    public static void actFightLabArchActRq(String command) {
//        ActFightLabArchActRq.Builder builder = ActFightLabArchActRq.newBuilder();
//        String[] s = command.split(",");
//        builder.setActId(Integer.valueOf(s[1]));
//        BasePb.Base base = adaptBase(ActFightLabArchActRq.EXT_FIELD_NUMBER, ActFightLabArchActRq.ext, builder.build());
//        SimulaAccout.ctx.writeAndFlush(base);
//    }
//
//    public static void upFightLabTechUpLevelRq(String command) {
//        UpFightLabTechUpLevelRq.Builder builder = UpFightLabTechUpLevelRq.newBuilder();
//        String[] s = command.split(",");
//        builder.setTechId(Integer.valueOf(s[1]));
//        BasePb.Base base = adaptBase(UpFightLabTechUpLevelRq.EXT_FIELD_NUMBER, UpFightLabTechUpLevelRq.ext, builder.build());
//        SimulaAccout.ctx.writeAndFlush(base);
//    }
//
//    public static void setFightLabPersonCountRq(String command) {
//        SetFightLabPersonCountRq.Builder builder = SetFightLabPersonCountRq.newBuilder();
//
//        String[] s = command.split(",");
//        CommonPb.TwoInt.Builder twoInt = CommonPb.TwoInt.newBuilder();
//        twoInt.setV1(101);
//        twoInt.setV2(Integer.valueOf(s[1]));
//        builder.addPresonCount(twoInt);
//
//
//        CommonPb.TwoInt.Builder twoInt2 = CommonPb.TwoInt.newBuilder();
//        twoInt2.setV1(102);
//        twoInt2.setV2(Integer.valueOf(s[2]));
//        builder.addPresonCount(twoInt2);
//
//
//        CommonPb.TwoInt.Builder twoInt3 = CommonPb.TwoInt.newBuilder();
//        twoInt3.setV1(103);
//        twoInt3.setV2(Integer.valueOf(s[3]));
//        builder.addPresonCount(twoInt3);
//
//        CommonPb.TwoInt.Builder twoInt4 = CommonPb.TwoInt.newBuilder();
//        twoInt4.setV1(104);
//        twoInt4.setV2(Integer.valueOf(s[4]));
//        builder.addPresonCount(twoInt4);
//
//        BasePb.Base base = adaptBase(SetFightLabPersonCountRq.EXT_FIELD_NUMBER, SetFightLabPersonCountRq.ext, builder.build());
//        SimulaAccout.ctx.writeAndFlush(base);
//    }
//
//    public static void getFightLabInfoRq(String command) {
//        GetFightLabInfoRq.Builder builder = GetFightLabInfoRq.newBuilder();
//        BasePb.Base base = adaptBase(GetFightLabInfoRq.EXT_FIELD_NUMBER, GetFightLabInfoRq.ext, builder.build());
//        SimulaAccout.ctx.writeAndFlush(base);
//    }
//
//    public static void getFightLabItemInfoRq(String command) {
//        GetFightLabItemInfoRq.Builder builder = GetFightLabItemInfoRq.newBuilder();
//        BasePb.Base base = adaptBase(GetFightLabItemInfoRq.EXT_FIELD_NUMBER, GetFightLabItemInfoRq.ext, builder.build());
//        SimulaAccout.ctx.writeAndFlush(base);
//    }
//
//    public static void sendThrowDiceRq(String command) {
//        ThrowDiceRq.Builder builder = ThrowDiceRq.newBuilder();
//        builder.setPoint(Integer.parseInt(command.split(",")[1]));
//        BasePb.Base base = adaptBase(ThrowDiceRq.EXT_FIELD_NUMBER, ThrowDiceRq.ext, builder.build());
//        SimulaAccout.ctx.writeAndFlush(base);
//    }
//
//    public static void sendBuyEnergyRq() {
//        BuyOrUseEnergyRq.Builder builder = BuyOrUseEnergyRq.newBuilder();
//        BasePb.Base base = adaptBase(BuyOrUseEnergyRq.EXT_FIELD_NUMBER, BuyOrUseEnergyRq.ext, builder.build());
//        SimulaAccout.ctx.writeAndFlush(base);
//    }
//
//    public static void sendGetMonopolyRq() {
//        GetMonopolyInfoRq.Builder builder = GetMonopolyInfoRq.newBuilder();
//        BasePb.Base base = adaptBase(GetMonopolyInfoRq.EXT_FIELD_NUMBER, GetMonopolyInfoRq.ext, builder.build());
//        SimulaAccout.ctx.writeAndFlush(base);
//    }
//
//    /**
//     * 获取攻击特效列表
//     */
//    public static void sendGetAttackEffectRq() {
//        GetAttackEffectRq.Builder builder = GetAttackEffectRq.newBuilder();
//        BasePb.Base base = adaptBase(GetAttackEffectRq.EXT_FIELD_NUMBER, GetAttackEffectRq.ext, builder.build());
//        SimulaAccout.ctx.writeAndFlush(base);
//    }
//
//    /**
//     * 发送秘密武器洗练
//     *
//     * @param command
//     */
//    public static void sendStudyWeaponSkillRq(String command) {
//        StudyWeaponSkillRq.Builder builder = StudyWeaponSkillRq.newBuilder();
//        builder.setWeaponId(Integer.parseInt(command.split(",")[1]));
//        BasePb.Base base = adaptBase(StudyWeaponSkillRq.EXT_FIELD_NUMBER, StudyWeaponSkillRq.ext, builder.build());
//        SimulaAccout.ctx.writeAndFlush(base);
//    }
//
//    /**
//     * 锁定洗练栏
//     *
//     * @param command
//     */
//    public static void sendLockedWeaponBarRq(String command) {
//        LockedWeaponBarRq.Builder builder = LockedWeaponBarRq.newBuilder();
//        String[] params = command.split(",");
//        int weaponId = Integer.parseInt(params[1]);
//        int barIdx = Integer.parseInt(params[2]);
//        boolean lock = false;
//        if (params.length == 4) {
//            lock = "1".equals(params[3]);
//        }
//        builder.setWeaponId(weaponId);
//        builder.setBarIdx(barIdx);
//        builder.setLock(lock);
//        BasePb.Base base = adaptBase(LockedWeaponBarRq.EXT_FIELD_NUMBER, LockedWeaponBarRq.ext, builder.build());
//        SimulaAccout.ctx.writeAndFlush(base);
//    }

//    /**
//     * 解锁技能栏
//     *
//     * @param command
//     */
//    public static void sendunlockweaponbarrq(string command) {
//        unlockweaponbarrq.builder builder = unlockweaponbarrq.newbuilder();
//        string[] params = command.split(",");
//        builder.setweaponid(integer.parseint(params[1]));
//        basepb.base base = adaptbase(unlockweaponbarrq.ext_field_number, unlockweaponbarrq.ext, builder.build());
//        simulaaccout.ctx.writeandflush(base);
//    }
//
//    public static void sendgetsecretweaponinfors() {
//        getsecretweaponinforq.builder builder = getsecretweaponinforq.newbuilder();
//        basepb.base base = adaptbase(getsecretweaponinforq.ext_field_number, getsecretweaponinforq.ext, builder.build());
//        simulaaccout.ctx.writeandflush(base);
//    }

    /**
     * 搜索荣誉勋章
     *
     * @param command
     */
    public static void sendSearchMedalofhonor(String command) {
        SearchActMedalofhonorTargetsRq.Builder builder = SearchActMedalofhonorTargetsRq.newBuilder();
        String[] arr = command.split(",");
        if (arr.length == 2) {
            builder.setForceResult(Integer.parseInt(arr[1]));
            builder.setSearchType(Integer.parseInt(arr[2]));
        }
        BasePb.Base base = adaptBase(SearchActMedalofhonorTargetsRq.EXT_FIELD_NUMBER, SearchActMedalofhonorTargetsRq.ext, builder.build());
        SimulaAccout.ctx.writeAndFlush(base);
    }

    /**
     * 打开荣誉勋章宝箱
     *
     * @param command
     */
    public static void sendOpenMedalofhonorOpen(String command) {
        OpenActMedalofhonorRq.Builder builder = OpenActMedalofhonorRq.newBuilder();
        String[] arr = command.split(",");
        builder.setPos(Integer.parseInt(arr[1]));
        BasePb.Base base = adaptBase(OpenActMedalofhonorRq.EXT_FIELD_NUMBER, OpenActMedalofhonorRq.ext, builder.build());
        SimulaAccout.ctx.writeAndFlush(base);
    }

    /**
     * 获取荣誉勋章活动信息
     *
     * @return
     */
    public static void sendGetActMedalofhonorInfoRq() {
        GetActMedalofhonorInfoRq.Builder builder = GetActMedalofhonorInfoRq.newBuilder();
        BasePb.Base base = adaptBase(GetActMedalofhonorInfoRq.EXT_FIELD_NUMBER, GetActMedalofhonorInfoRq.ext, builder.build());
        SimulaAccout.ctx.writeAndFlush(base);
    }

    /**
     * 发送GM指令
     *
     * @param command
     */
    public static void sendGm(String command) {
        GamePb1.DoSomeRq.Builder builder = GamePb1.DoSomeRq.newBuilder();
        builder.setStr(command.substring(4));
        BasePb.Base base = adaptBase(GamePb1.DoSomeRq.EXT_FIELD_NUMBER, GamePb1.DoSomeRq.ext, builder.build());
        SimulaAccout.ctx.writeAndFlush(base);
    }

    public static BasePb.Base createGetLordRq() {
        GamePb1.GetLordRq.Builder req = GamePb1.GetLordRq.newBuilder();
        return adaptBase(GamePb1.GetLordRq.EXT_FIELD_NUMBER, GamePb1.GetLordRq.ext, req.build());
    }

    public static BasePb.Base createRoleLoginRq() {
        GamePb1.RoleLoginRq.Builder builder = GamePb1.RoleLoginRq.newBuilder();
        return adaptBase(GamePb1.RoleLoginRq.EXT_FIELD_NUMBER, GamePb1.RoleLoginRq.ext, builder.build());
    }

    public static BasePb.Base createBeginGameReqest() {
        GamePb1.BeginGameRq.Builder beginBuilder = GamePb1.BeginGameRq.newBuilder();
        beginBuilder.setKeyId(SimulaAccout.keyId);
        beginBuilder.setToken(SimulaAccout.token);
        beginBuilder.setServerId(SimulaClient.sid);
        beginBuilder.setDeviceNo(SimulaClient.deviceNo);
        beginBuilder.setCurVersion(SimulaClient.version);
        return adaptBase(GamePb1.BeginGameRq.EXT_FIELD_NUMBER, GamePb1.BeginGameRq.ext, beginBuilder.build());
    }

    public static BasePb.Base createGetNamesRq() {
        GamePb1.GetNamesRq.Builder builder = GamePb1.GetNamesRq.newBuilder();
        return adaptBase(GamePb1.GetNamesRq.EXT_FIELD_NUMBER, GamePb1.GetNamesRq.ext, builder.build());
    }

    private static <T> BasePb.Base adaptBase(int cmd, GeneratedMessage.GeneratedExtension<BasePb.Base, T> ext, T msg) {
        BasePb.Base.Builder builder = BasePb.Base.newBuilder();
        builder.setCmd(cmd);
        builder.setExtension(ext, msg);
        return builder.build();
    }


}
