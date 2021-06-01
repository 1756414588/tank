package com.game.domain.p;

import com.hundredcent.game.aop.annotation.SaveLevel;
import com.hundredcent.game.aop.annotation.SaveOptimize;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@SaveOptimize(level = SaveLevel.IDLE)
public class Lord implements Cloneable {
    /**
     * roleId 唯一
     */
    private long lordId;
    /**
     * 昵称
     */
    private String nick;
    /**
     * 指挥官头像
     */
    private int portrait;
    /**
     * 性别
     */
    private int sex;
    /**
     * 普通等级
     */
    private int level;
    /**
     * 普通经验
     */
    private long exp;
    /**
     * vip
     */
    private int vip;
    /**
     * 累计充值金额
     */
    private int topup;
    /**
     * 首充金额(新加属性--->用来重置玩家首充信息)
     */
    private int topup1st;
    /**
     * 坐标
     */
    private int pos;
    /**
     * 金币
     */
    private int gold;
    private int goldCost;
    private int goldGive;
    private int goldTime;
    private int huangbao;
    private int ranks;
    private int command;
    private int fame;
    private int fameLv;
    private int fameTime1;
    private int fameTime2;
    private int honour;
    /**
     * 繁荣度
     */
    private int pros;
    private int prosMax;
    private int prosTime;
    private int power;
    private int powerTime;
    private long newState;
    private long fight;
    private int equip;
    private int fitting;
    private int metal;
    private int plan;
    private int mineral;
    private int tool;
    private int draw;
    private int tankDrive;
    private int chariotDrive;
    private int artilleryDrive;
    private int rocketDrive;
    private int eplrTime;
    private int equipEplr;
    private int partEplr;
    private int militaryEplr;
    private int extrEplr;
    private int timeEplr;
    private int equipBuy;
    private int partBuy;
    private int militaryBuy;
    private int extrReset;
    /**
     * 限时副本购买次数
     */
    private int timeBuy;
    private int goldHeroCount;
    private int goldHeroTime;
    private int stoneHeroCount;
    private int stoneHeroTime;
    private int blessCount;
    private int blessTime;
    private int taskDayiy;
    private int dayiyCount;
    private int taskLive;
    private int taskLiveAd;
    private int taskTime;
    /**
     * 活跃度任务刷新时间
     */
    private int taskLiveTime;
    private int buyPower;
    private int buyPowerTime;
    private int stars;
    /**
     * 玩家最近一次上关卡总星榜的时间
     */
    private int starRankTime;
    private int lotterExplore;
    private int buildCount;
    private int newerGift;
    private int freeMecha;
    private int onTime;
    private int olTime;
    private int offTime;
    private int ctTime;
    private int olAward;
    private int silence;
    private int pawn;
    private int partDial;
    private int consumeDial;
    private int energyStoneDial;
    private int partyLvAward;
    private int partyFightAward;
    private int olMonth;
    private int tankRaffle;
    private int partyTipAward;
    private int partExchangeAward;
    /**
     * 剩余自动升级时间
     */
    private int upBuildTime;
    /**
     * 开启自动升级
     */
    private int onBuild;
    private int staffing;
    private int staffingLv;
    private int staffingExp;
    private int staffingSaveExp;
    private int lockTankId;
    private int lockTime;
    private int scountDate;
    private int scount;
    /**
     * 能晶副本挑战次数
     */
    private int energyStoneEplr;
    /**
     * 能晶副本购买次数
     */
    private int energyStoneBuy;
    /**
     * 玩家的功勋值
     */
    private int exploit;
    /**
     * 玩家上次重置军演商店购买信息的时间
     */
    private int resetDrillShopTime;
    /**
     * 洗涤剂
     */
    private int detergent;
    /**
     * 研磨石
     */
    private int grindstone;
    /**
     * 抛光材料
     */
    private int polishingMtr;
    /**
     * 保养油
     */
    private int maintainOil;
    /**
     * 打磨工具
     */
    private int grindTool;
    /**
     * 精密仪器
     */
    private int precisionInstrument;
    /**
     * 神秘石
     */
    private int mysteryStone;
    /**
     * 惰性气体
     */
    private int inertGas;
    /**
     * 刚玉磨料
     */
    private int corundumMatrial;
    /**
     * 装备装盘免费次数使用时间
     */
    private int freeEquipDial;
    /**
     * 勋章强化冷却结束时间
     */
    private int medalUpCdTime;
    /**
     * 勋章关卡次数
     */
    private int medalEplr;
    /**
     * 勋章关卡购买次数
     */
    private int medalBuy;
    /**
     * 勋章 震慑总和
     */
    private int frighten;
    /**
     * 勋章 刚毅总和
     */
    private int fortitude;
    /**
     * 勋章价值总和
     */
    private int medalPrice;
    /**
     * 军衔
     */
    private int militaryRank;
    /**
     * 军衔升级时间
     */
    private long militaryRankUpTime;
    /**
     * 军功(战斗中击杀坦克与损失坦克会增加战功)
     */
    private long militaryExploit;
    /**
     * 今天获得的军功
     */
    private int mpltGetToday;
    /**
     * 最后获得军功时间(yyyymmdd)
     */
    private int lastMpltDay;
    /**
     * 回归玩家领取奖励状态
     */
    private int playerBack;
    /**
     * 总战斗力
     */
    private long maxFight;
    /**
     * 军团充值活动结算记录最后所在军团ID
     */
    private int oldPartyId;
    /**
     * 战术副本已购买次数
     */
    private int tacticsBuy;
    /**
     * 战术副本已经挑战次数
     */
    private int tacticsReset;
    /**
     * 战术转盘
     */
    private int ticDial;
    /**
     * 文官进驻列表 partyId 为键
     */
    private Map<Integer, List<Integer>> heroPut;

    /**
     * 巅峰等级
     */
    private int peakLv;
    /**
     * 巅峰经验
     */
    private long peakExp;
    /**
     * 技能点
     */
    private int peaks;

    public long getMaxFight() {
        return maxFight;
    }

    public void setMaxFight(long maxFight) {
        this.maxFight = maxFight;
    }

    public int getPlayerBack() {
        return playerBack;
    }

    public void setPlayerBack(int playerBack) {
        this.playerBack = playerBack;
    }

    public int getBuyPower() {
        return buyPower;
    }

    public void setBuyPower(int buyPower) {
        this.buyPower = buyPower;
    }

    public int getBuyPowerTime() {
        return buyPowerTime;
    }

    public void setBuyPowerTime(int buyPowerTime) {
        this.buyPowerTime = buyPowerTime;
    }

    public int getMilitaryBuy() {
        return militaryBuy;
    }

    public void setMilitaryBuy(int militaryBuy) {
        this.militaryBuy = militaryBuy;
    }

    public int getEquipBuy() {
        return equipBuy;
    }

    public void setEquipBuy(int equipBuy) {
        this.equipBuy = equipBuy;
    }

    public int getPartBuy() {
        return partBuy;
    }

    public void setPartBuy(int partBuy) {
        this.partBuy = partBuy;
    }

    public long getLordId() {
        return lordId;
    }

    public void setLordId(long lordId) {
        this.lordId = lordId;
    }

    public String getNick() {
        return nick;
    }

    public void setNick(String nick) {
        this.nick = nick;
    }

    public int getPortrait() {
        return portrait;
    }

    public void setPortrait(int portrait) {
        this.portrait = portrait;
    }

    public int getLevel() {
        return level;
    }

    public void setLevel(int level) {
        this.level = level;
    }

    public long getExp() {
        return exp;
    }

    public void setExp(long exp) {
        this.exp = exp;
    }

    public int getVip() {
        return vip;
    }

    public void setVip(int vip) {
        this.vip = vip;
    }

    public int getTopup() {
        return topup;
    }

    public void setTopup(int topup) {
        this.topup = topup;
    }

    public int getPos() {
        return pos;
    }

    public void setPos(int pos) {
        this.pos = pos;
    }

    public int getGold() {
        return gold;
    }

    public void setGold(int gold) {
        this.gold = gold;
    }

    public int getGoldCost() {
        return goldCost;
    }

    public void setGoldCost(int goldCost) {
        this.goldCost = goldCost;
    }

    public int getGoldGive() {
        return goldGive;
    }

    public void setGoldGive(int goldGive) {
        this.goldGive = goldGive;
    }

    public int getRanks() {
        return ranks;
    }

    public void setRanks(int ranks) {
        this.ranks = ranks;
    }

    public int getCommand() {
        return command;
    }

    public void setCommand(int command) {
        this.command = command;
    }

    public int getFame() {
        return fame;
    }

    public void setFame(int fame) {
        this.fame = fame;
    }

    public int getFameLv() {
        return fameLv;
    }

    public void setFameLv(int fameLv) {
        this.fameLv = fameLv;
    }

    public int getHonour() {
        return honour;
    }

    public void setHonour(int honour) {
        this.honour = honour;
    }

    public int getPros() {
        return pros;
    }

    public void setPros(int pros) {
        this.pros = pros;
    }

    public int getProsMax() {
        return prosMax;
    }

    public void setProsMax(int prosMax) {
        this.prosMax = prosMax;
    }

    public int getPower() {
        return power;
    }

    public void setPower(int power) {
        this.power = power;
    }

    public int getProsTime() {
        return prosTime;
    }

    public void setProsTime(int prosTime) {
        this.prosTime = prosTime;
    }

    public int getPowerTime() {
        return powerTime;
    }

    public void setPowerTime(int powerTime) {
        this.powerTime = powerTime;
    }

    public long getNewState() {
        return newState;
    }

    public void setNewState(long newState) {
        this.newState = newState;
    }

    public long getFight() {
        return fight;
    }

    public void setFight(long fight) {
        this.fight = fight;
    }

    public int getEquip() {
        return equip;
    }

    public void setEquip(int equip) {
        this.equip = equip;
    }

    public int getFitting() {
        return fitting;
    }

    public void setFitting(int fitting) {
        this.fitting = fitting;
    }

    public int getMetal() {
        return metal;
    }

    public void setMetal(int metal) {
        this.metal = metal;
    }

    public int getPlan() {
        return plan;
    }

    public void setPlan(int plan) {
        this.plan = plan;
    }

    public int getMineral() {
        return mineral;
    }

    public void setMineral(int mineral) {
        this.mineral = mineral;
    }

    public int getTool() {
        return tool;
    }

    public void setTool(int tool) {
        this.tool = tool;
    }

    public int getDraw() {
        return draw;
    }

    public void setDraw(int draw) {
        this.draw = draw;
    }

    public int getTankDrive() {
        return tankDrive;
    }

    public void setTankDrive(int tankDrive) {
        this.tankDrive = tankDrive;
    }

    public int getChariotDrive() {
        return chariotDrive;
    }

    public void setChariotDrive(int chariotDrive) {
        this.chariotDrive = chariotDrive;
    }

    public int getArtilleryDrive() {
        return artilleryDrive;
    }

    public void setArtilleryDrive(int artilleryDrive) {
        this.artilleryDrive = artilleryDrive;
    }

    public int getRocketDrive() {
        return rocketDrive;
    }

    public void setRocketDrive(int rocketDrive) {
        this.rocketDrive = rocketDrive;
    }

    public int getEplrTime() {
        return eplrTime;
    }

    public void setEplrTime(int eplrTime) {
        this.eplrTime = eplrTime;
    }

    public int getEquipEplr() {
        return equipEplr;
    }

    public void setEquipEplr(int equipEplr) {
        this.equipEplr = equipEplr;
    }

    public int getPartEplr() {
        return partEplr;
    }

    public void setPartEplr(int partEplr) {
        this.partEplr = partEplr;
    }

    public int getExtrEplr() {
        return extrEplr;
    }

    public void setExtrEplr(int extrEplr) {
        this.extrEplr = extrEplr;
    }

    public int getGoldHeroCount() {
        return goldHeroCount;
    }

    public void setGoldHeroCount(int goldHeroCount) {
        this.goldHeroCount = goldHeroCount;
    }

    public int getGoldHeroTime() {
        return goldHeroTime;
    }

    public void setGoldHeroTime(int goldHeroTime) {
        this.goldHeroTime = goldHeroTime;
    }

    public int getStoneHeroCount() {
        return stoneHeroCount;
    }

    public void setStoneHeroCount(int stoneHeroCount) {
        this.stoneHeroCount = stoneHeroCount;
    }

    public int getStoneHeroTime() {
        return stoneHeroTime;
    }

    public void setStoneHeroTime(int stoneHeroTime) {
        this.stoneHeroTime = stoneHeroTime;
    }

    public int getExtrReset() {
        return extrReset;
    }

    public void setExtrReset(int extrReset) {
        this.extrReset = extrReset;
    }

    public int getTimeEplr() {
        return timeEplr;
    }

    public void setTimeEplr(int timeEplr) {
        this.timeEplr = timeEplr;
    }

    public int getHuangbao() {
        return huangbao;
    }

    public void setHuangbao(int huangbao) {
        this.huangbao = huangbao;
    }

    public int getBlessCount() {
        return blessCount;
    }

    public void setBlessCount(int blessCount) {
        this.blessCount = blessCount;
    }

    public int getBlessTime() {
        return blessTime;
    }

    public void setBlessTime(int blessTime) {
        this.blessTime = blessTime;
    }

    @Override
    public Object clone() {
        try {
            return super.clone();
        } catch (CloneNotSupportedException e) {
            e.printStackTrace();
        }
        return null;
    }

    public int getFameTime1() {
        return fameTime1;
    }

    public void setFameTime1(int fameTime1) {
        this.fameTime1 = fameTime1;
    }

    public int getFameTime2() {
        return fameTime2;
    }

    public void setFameTime2(int fameTime2) {
        this.fameTime2 = fameTime2;
    }

    public int getGoldTime() {
        return goldTime;
    }

    public void setGoldTime(int goldTime) {
        this.goldTime = goldTime;
    }

    public int getSex() {
        return sex;
    }

    public void setSex(int sex) {
        this.sex = sex;
    }

    public int getTaskDayiy() {
        return taskDayiy;
    }

    public void setTaskDayiy(int taskDayiy) {
        this.taskDayiy = taskDayiy;
    }

    public int getDayiyCount() {
        return dayiyCount;
    }

    public void setDayiyCount(int dayiyCount) {
        this.dayiyCount = dayiyCount;
    }

    public int getTaskLive() {
        return taskLive;
    }

    public void setTaskLive(int taskLive) {
        this.taskLive = taskLive;
    }

    public int getTaskLiveAd() {
        return taskLiveAd;
    }

    public void setTaskLiveAd(int taskLiveAd) {
        this.taskLiveAd = taskLiveAd;
    }

    public int getTaskTime() {
        return taskTime;
    }

    public void setTaskTime(int taskTime) {
        this.taskTime = taskTime;
    }

    public int getTaskLiveTime() {
        return taskLiveTime;
    }

    public void setTaskLiveTime(int taskLiveTime) {
        this.taskLiveTime = taskLiveTime;
    }

    public int getStars() {
        return stars;
    }

    public void setStars(int stars) {
        this.stars = stars;
    }

    public int getStarRankTime() {
        return starRankTime;
    }

    public void setStarRankTime(int starRankTime) {
        this.starRankTime = starRankTime;
    }

    public int getLotterExplore() {
        return lotterExplore;
    }

    public void setLotterExplore(int lotterExplore) {
        this.lotterExplore = lotterExplore;
    }

    public int getNewerGift() {
        return newerGift;
    }

    public void setNewerGift(int newerGift) {
        this.newerGift = newerGift;
    }

    public int getBuildCount() {
        return buildCount;
    }

    public void setBuildCount(int buildCount) {
        this.buildCount = buildCount;
    }

    public int getFreeMecha() {
        return freeMecha;
    }

    public void setFreeMecha(int freeMecha) {
        this.freeMecha = freeMecha;
    }

    public int getOnTime() {
        return onTime;
    }

    public void setOnTime(int onTime) {
        this.onTime = onTime;
    }

    public int getOlTime() {
        return olTime;
    }

    public void setOlTime(int olTime) {
        this.olTime = olTime;
    }

    public int getOffTime() {
        return offTime;
    }

    public void setOffTime(int offTime) {
        this.offTime = offTime;
    }

    public int getCtTime() {
        return ctTime;
    }

    public void setCtTime(int ctTime) {
        this.ctTime = ctTime;
    }

    public int getOlAward() {
        return olAward;
    }

    public void setOlAward(int olAward) {
        this.olAward = olAward;
    }

    public int getSilence() {
        return silence;
    }

    public void setSilence(int silence) {
        this.silence = silence;
    }

    public int getPawn() {
        return pawn;
    }

    public void setPawn(int pawn) {
        this.pawn = pawn;
    }

    public int getPartDial() {
        return partDial;
    }

    public void setPartDial(int partDial) {
        this.partDial = partDial;
    }

    public int getConsumeDial() {
        return consumeDial;
    }

    public void setConsumeDial(int consumeDial) {
        this.consumeDial = consumeDial;
    }

    public int getEnergyStoneDial() {
        return energyStoneDial;
    }

    public void setEnergyStoneDial(int energyStoneDial) {
        this.energyStoneDial = energyStoneDial;
    }

    public int getPartyLvAward() {
        return partyLvAward;
    }

    public void setPartyLvAward(int partyLvAward) {
        this.partyLvAward = partyLvAward;
    }

    public int getPartyFightAward() {
        return partyFightAward;
    }

    public void setPartyFightAward(int partyFightAward) {
        this.partyFightAward = partyFightAward;
    }

    public int getOlMonth() {
        return olMonth;
    }

    public void setOlMonth(int olMonth) {
        this.olMonth = olMonth;
    }

    public int getTankRaffle() {
        return tankRaffle;
    }

    public void setTankRaffle(int tankRaffle) {
        this.tankRaffle = tankRaffle;
    }

    public int getPartyTipAward() {
        return partyTipAward;
    }

    public void setPartyTipAward(int partyTipAward) {
        this.partyTipAward = partyTipAward;
    }

    public int getPartExchangeAward() {
        return partExchangeAward;
    }

    public void setPartExchangeAward(int partExchangeAward) {
        this.partExchangeAward = partExchangeAward;
    }

    public int getUpBuildTime() {
        return upBuildTime;
    }

    public void setUpBuildTime(int upBuildTime) {
        this.upBuildTime = upBuildTime;
    }

    public int getOnBuild() {
        return onBuild;
    }

    public void setOnBuild(int onBuild) {
        this.onBuild = onBuild;
    }

    public int getStaffingLv() {
        return staffingLv;
    }

    public void setStaffingLv(int staffingLv) {
        this.staffingLv = staffingLv;
    }

    public int getStaffingExp() {
        return staffingExp;
    }

    public void setStaffingExp(int staffingExp) {
        this.staffingExp = staffingExp;
    }

    public int getStaffing() {
        return staffing;
    }

    public void setStaffing(int staffing) {
        this.staffing = staffing;
    }

    public int getStaffingSaveExp() {
        return staffingSaveExp;
    }

    public void setStaffingSaveExp(int staffingSaveExp) {
        this.staffingSaveExp = staffingSaveExp;
    }

    public int getMilitaryEplr() {
        return militaryEplr;
    }

    public void setMilitaryEplr(int militaryEplr) {
        this.militaryEplr = militaryEplr;
    }

    public int getLockTankId() {
        return lockTankId;
    }

    public void setLockTankId(int lockTankId) {
        this.lockTankId = lockTankId;
    }

    public int getLockTime() {
        return lockTime;
    }

    public void setLockTime(int lockTime) {
        this.lockTime = lockTime;
    }

    public int getScountDate() {
        return scountDate;
    }

    public void setScountDate(int scountDate) {
        this.scountDate = scountDate;
    }

    public int getScount() {
        return scount;
    }

    public void setScount(int scount) {
        this.scount = scount;
    }

    public int getEnergyStoneEplr() {
        return energyStoneEplr;
    }

    public void setEnergyStoneEplr(int energyStoneEplr) {
        this.energyStoneEplr = energyStoneEplr;
    }

    public int getEnergyStoneBuy() {
        return energyStoneBuy;
    }

    public void setEnergyStoneBuy(int energyStoneBuy) {
        this.energyStoneBuy = energyStoneBuy;
    }

    public int getTimeBuy() {
        return timeBuy;
    }

    public void setTimeBuy(int timeBuy) {
        this.timeBuy = timeBuy;
    }

    public int getExploit() {
        return exploit;
    }

    public void setExploit(int exploit) {
        this.exploit = exploit;
    }

    public int getResetDrillShopTime() {
        return resetDrillShopTime;
    }

    public void setResetDrillShopTime(int resetDrillShopTime) {
        this.resetDrillShopTime = resetDrillShopTime;
    }

    public int getDetergent() {
        return detergent;
    }

    public void setDetergent(int detergent) {
        this.detergent = detergent;
    }

    public int getGrindstone() {
        return grindstone;
    }

    public void setGrindstone(int grindstone) {
        this.grindstone = grindstone;
    }

    public int getPolishingMtr() {
        return polishingMtr;
    }

    public void setPolishingMtr(int polishingMtr) {
        this.polishingMtr = polishingMtr;
    }

    public int getMaintainOil() {
        return maintainOil;
    }

    public void setMaintainOil(int maintainOil) {
        this.maintainOil = maintainOil;
    }

    public int getGrindTool() {
        return grindTool;
    }

    public void setGrindTool(int grindTool) {
        this.grindTool = grindTool;
    }

    public int getMedalUpCdTime() {
        return medalUpCdTime;
    }

    public void setMedalUpCdTime(int medalUpCdTime) {
        this.medalUpCdTime = medalUpCdTime;
    }

    public int getMedalEplr() {
        return medalEplr;
    }

    public void setMedalEplr(int medalEplr) {
        this.medalEplr = medalEplr;
    }

    public int getMedalBuy() {
        return medalBuy;
    }

    public void setMedalBuy(int medalBuy) {
        this.medalBuy = medalBuy;
    }

    public int getFrighten() {
        return frighten;
    }

    public void setFrighten(int frighten) {
        this.frighten = frighten;
    }

    public int getFortitude() {
        return fortitude;
    }

    public void setFortitude(int fortitude) {
        this.fortitude = fortitude;
    }

    public int getMedalPrice() {
        return medalPrice;
    }

    public void setMedalPrice(int medalPrice) {
        this.medalPrice = medalPrice;
    }

    public int getMilitaryRank() {
        return militaryRank;
    }

    public void setMilitaryRank(int militaryRank) {
        this.militaryRank = militaryRank;
    }

    public long getMilitaryRankUpTime() {
        return militaryRankUpTime;
    }

    public void setMilitaryRankUpTime(long militaryRankUpTime) {
        this.militaryRankUpTime = militaryRankUpTime;
    }

    public long getMilitaryExploit() {
        return militaryExploit;
    }

    public void setMilitaryExploit(long militaryExploit) {
        this.militaryExploit = militaryExploit;
    }

    public void setMilitaryExploit(int militaryExploit) {
        this.militaryExploit = militaryExploit;
    }

    public int getMpltGetToday() {
        return mpltGetToday;
    }

    public void setMpltGetToday(int mpltGetToday) {
        this.mpltGetToday = mpltGetToday;
    }

    public int getLastMpltDay() {
        return lastMpltDay;
    }

    public void setLastMpltDay(int lastMpltDay) {
        this.lastMpltDay = lastMpltDay;
    }

    public int getTopup1st() {
        return topup1st;
    }

    public void setTopup1st(int topup1st) {
        this.topup1st = topup1st;
    }

    public Map<Integer, List<Integer>> getHeroPut() {
        if (heroPut == null) {
            heroPut = new HashMap<>();
        }
        return heroPut;
    }

    public void setHeroPut(Map<Integer, List<Integer>> heroPut) {
        this.heroPut = heroPut;
    }

    public int getPrecisionInstrument() {
        return precisionInstrument;
    }

    public void setPrecisionInstrument(int precisionInstrument) {
        this.precisionInstrument = precisionInstrument;
    }

    public int getMysteryStone() {
        return mysteryStone;
    }

    public void setMysteryStone(int mysteryStone) {
        this.mysteryStone = mysteryStone;
    }

    public int getInertGas() {
        return inertGas;
    }

    public void setInertGas(int inertGas) {
        this.inertGas = inertGas;
    }

    public int getCorundumMatrial() {
        return corundumMatrial;
    }

    public void setCorundumMatrial(int corundumMatrial) {
        this.corundumMatrial = corundumMatrial;
    }

    public int getFreeEquipDial() {
        return freeEquipDial;
    }

    public void setFreeEquipDial(int freeEquipDial) {
        this.freeEquipDial = freeEquipDial;
    }

    public int getOldPartyId() {
        return oldPartyId;
    }

    public void setOldPartyId(int oldPartyId) {
        this.oldPartyId = oldPartyId;
    }

    public int getTacticsBuy() {
        return tacticsBuy;
    }

    public void setTacticsBuy(int tacticsBuy) {
        this.tacticsBuy = tacticsBuy;
    }

    public int getTacticsReset() {
        return tacticsReset;
    }

    public void setTacticsReset(int tacticsReset) {
        this.tacticsReset = tacticsReset;
    }

    public int getTicDial() {
        return ticDial;
    }

    public void setTicDial(int ticDial) {
        this.ticDial = ticDial;
    }

    public int getPeakLv() {
        return peakLv;
    }

    public void setPeakLv(int peakLv) {
        this.peakLv = peakLv;
    }

    public long getPeakExp() {
        return peakExp;
    }

    public void setPeakExp(long peakExp) {
        this.peakExp = peakExp;
    }

    public int getPeaks() {
        return peaks;
    }

    public void setPeaks(int peaks) {
        this.peaks = peaks;
    }

    @Override
    public String toString() {
        return "Lord{" +
                "lordId=" + lordId +
                ", nick='" + nick + '\'' +
                '}';
    }
}
