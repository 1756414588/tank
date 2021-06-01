/**   
 * @Title: DbGlobal.java    
 * @Package com.game.domain.p    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年10月13日 下午3:18:31    
 * @version V1.0   
 */
package com.game.domain.p;

/**
 * @ClassName: DbGlobal
 * @Description: 用来保存到数据库中的全局变量pojo
 * @author ZhangJun
 * @date 2015年10月13日 下午3:18:31
 */
public class DbGlobal {
	private int globalId;
	private int maxKey;
	private byte[] mails;
	private int warTime;
	private byte[] warRecord;
	private int warState;
	private byte[] winRank;
	private byte[] getWinRank;
	private int bossTime;
	private int bossLv;
	private int bossWhich;
	private int bossHp;
	private int bossState;
	private byte[] hurtRank;
	private byte[] getHurtRank;
	private String bossKiller;
	private String shop;
	private int shopTime;
	private byte[] scoreRank;
	private byte[] scorePartyRank;
	private int seniorWeek;
	private int seniorState;
	private byte[] warRankRecords;
	private byte[] canFightFortressPartyMap;
	private int fortressTime;
	private int fortressState;
	private int fortressPartyId;
	private byte[] fortressRecords;
	private byte[] rptRtkFortresss;
	private byte[] myFortressFightDatas;
	private byte[] partyStatisticsMap;
	private byte[] fortressJobAppointList;
	private byte[] allServerFortressFightDataRankLordMap;
	private int drillStatus;// 红蓝大战活动的状态，0 未开启，1 报名，2 备战，3 预热，4 第一部队战斗，5 第二部队战斗，6 第三部队战斗
	private int lastOpenDrillDate;// 红蓝大战最近一次开启的日期，格式:20160809
	private byte[] drillRank;// 红蓝大战玩家排行榜
	private byte[] drillRecords;// 红蓝大战玩家战况记录
	private byte[] drillFightRpts;// 红蓝大战玩家的战报记录
	private byte[] drillResult;// 红蓝大战三路战斗结果
	private byte[] drillImprove;// 红蓝大战双方进修情况
	private byte[] drillShop;// 红蓝大战军演商店购买情况
	private int rebelStatus;// 叛军入侵活动状态
	private int rebelLastOpenTime;// 叛军入侵活动最近一次开启的时间
	private byte[] rebelTotalData;// 叛军入侵活动，所有公用数据
	private byte[] worldMineInfo;//世界地图矿点信息
    private int gameStopTime;
    private byte[] airship;//飞艇数据
    private byte[] notGetAward; // 未领取奖励

	private byte[] luckyInfo;//幸运奖池数据
	private byte[] teamTask;//组队副本任务
	
	private byte[] honourTotalData;//荣耀生存玩法公共数据

	private byte[] WorldStaffing;//世界矿点编制经验
	
	private byte[] actKingInfo;//最强王者活动

	

	public byte[] getCanFightFortressPartyMap() {
		return canFightFortressPartyMap;
	}

	public void setCanFightFortressPartyMap(byte[] canFightFortressPartyMap) {
		this.canFightFortressPartyMap = canFightFortressPartyMap;
	}

	public int getFortressTime() {
		return fortressTime;
	}

	public void setFortressTime(int fortressTime) {
		this.fortressTime = fortressTime;
	}

	public int getFortressState() {
		return fortressState;
	}

	public void setFortressState(int fortressState) {
		this.fortressState = fortressState;
	}

	public byte[] getFortressRecords() {
		return fortressRecords;
	}

	public void setFortressRecords(byte[] fortressRecords) {
		this.fortressRecords = fortressRecords;
	}

	public byte[] getRptRtkFortresss() {
		return rptRtkFortresss;
	}

	public void setRptRtkFortresss(byte[] rptRtkFortresss) {
		this.rptRtkFortresss = rptRtkFortresss;
	}

	public byte[] getMyFortressFightDatas() {
		return myFortressFightDatas;
	}

	public void setMyFortressFightDatas(byte[] myFortressFightDatas) {
		this.myFortressFightDatas = myFortressFightDatas;
	}

	public byte[] getPartyStatisticsMap() {
		return partyStatisticsMap;
	}

	public void setPartyStatisticsMap(byte[] partyStatisticsMap) {
		this.partyStatisticsMap = partyStatisticsMap;
	}

	public byte[] getFortressJobAppointList() {
		return fortressJobAppointList;
	}

	public void setFortressJobAppointList(byte[] fortressJobAppointList) {
		this.fortressJobAppointList = fortressJobAppointList;
	}

	public byte[] getAllServerFortressFightDataRankLordMap() {
		return allServerFortressFightDataRankLordMap;
	}

	public void setAllServerFortressFightDataRankLordMap(byte[] allServerFortressFightDataRankLordMap) {
		this.allServerFortressFightDataRankLordMap = allServerFortressFightDataRankLordMap;
	}

	public int getGlobalId() {
		return globalId;
	}

	public void setGlobalId(int globalId) {
		this.globalId = globalId;
	}

	public int getFortressPartyId() {
		return fortressPartyId;
	}

	public void setFortressPartyId(int fortressPartyId) {
		this.fortressPartyId = fortressPartyId;
	}

	public byte[] getMails() {
		return mails;
	}

	public void setMails(byte[] mails) {
		this.mails = mails;
	}

	public int getMaxKey() {
		return maxKey;
	}

	public void setMaxKey(int maxKey) {
		this.maxKey = maxKey;
	}

	public int getWarTime() {
		return warTime;
	}

	public void setWarTime(int warTime) {
		this.warTime = warTime;
	}

	public byte[] getWarRecord() {
		return warRecord;
	}

	public void setWarRecord(byte[] warRecord) {
		this.warRecord = warRecord;
	}

	public int getWarState() {
		return warState;
	}

	public void setWarState(int warState) {
		this.warState = warState;
	}

	public byte[] getGetWinRank() {
		return getWinRank;
	}

	public void setGetWinRank(byte[] getWinRank) {
		this.getWinRank = getWinRank;
	}

	public byte[] getWinRank() {
		return winRank;
	}

	public void setWinRank(byte[] winRank) {
		this.winRank = winRank;
	}

	public int getBossLv() {
		return bossLv;
	}

	public void setBossLv(int bossLv) {
		this.bossLv = bossLv;
	}

	public int getBossWhich() {
		return bossWhich;
	}

	public void setBossWhich(int bossWhich) {
		this.bossWhich = bossWhich;
	}

	public int getBossHp() {
		return bossHp;
	}

	public void setBossHp(int bossHp) {
		this.bossHp = bossHp;
	}

	public byte[] getHurtRank() {
		return hurtRank;
	}

	public void setHurtRank(byte[] hurtRank) {
		this.hurtRank = hurtRank;
	}

	public byte[] getGetHurtRank() {
		return getHurtRank;
	}

	public void setGetHurtRank(byte[] getHurtRank) {
		this.getHurtRank = getHurtRank;
	}

	public int getBossTime() {
		return bossTime;
	}

	public void setBossTime(int bossTime) {
		this.bossTime = bossTime;
	}

	public int getBossState() {
		return bossState;
	}

	public void setBossState(int bossState) {
		this.bossState = bossState;
	}

	public String getBossKiller() {
		return bossKiller;
	}

	public void setBossKiller(String bossKiller) {
		this.bossKiller = bossKiller;
	}

	public String getShop() {
		return shop;
	}

	public void setShop(String shop) {
		this.shop = shop;
	}

	public int getShopTime() {
		return shopTime;
	}

	public void setShopTime(int shopTime) {
		this.shopTime = shopTime;
	}

	public byte[] getScoreRank() {
		return scoreRank;
	}

	public void setScoreRank(byte[] scoreRank) {
		this.scoreRank = scoreRank;
	}

	public byte[] getScorePartyRank() {
		return scorePartyRank;
	}

	public void setScorePartyRank(byte[] scorePartyRank) {
		this.scorePartyRank = scorePartyRank;
	}

	public int getSeniorWeek() {
		return seniorWeek;
	}

	public void setSeniorWeek(int seniorWeek) {
		this.seniorWeek = seniorWeek;
	}

	public int getSeniorState() {
		return seniorState;
	}

	public void setSeniorState(int seniorState) {
		this.seniorState = seniorState;
	}

	public byte[] getWarRankRecords() {
		return warRankRecords;
	}

	public void setWarRankRecords(byte[] warRankRecords) {
		this.warRankRecords = warRankRecords;
	}

	public int getDrillStatus() {
		return drillStatus;
	}

	public void setDrillStatus(int drillStatus) {
		this.drillStatus = drillStatus;
	}

	public int getLastOpenDrillDate() {
		return lastOpenDrillDate;
	}

	public void setLastOpenDrillDate(int lastOpenDrillDate) {
		this.lastOpenDrillDate = lastOpenDrillDate;
	}

	public byte[] getDrillRank() {
		return drillRank;
	}

	public void setDrillRank(byte[] drillRank) {
		this.drillRank = drillRank;
	}

	public byte[] getDrillRecords() {
		return drillRecords;
	}

	public void setDrillRecords(byte[] drillRecords) {
		this.drillRecords = drillRecords;
	}

	public byte[] getDrillFightRpts() {
		return drillFightRpts;
	}

	public void setDrillFightRpts(byte[] drillFightRpts) {
		this.drillFightRpts = drillFightRpts;
	}

	public byte[] getDrillResult() {
		return drillResult;
	}

	public void setDrillResult(byte[] drillResult) {
		this.drillResult = drillResult;
	}

	public byte[] getDrillImprove() {
		return drillImprove;
	}

	public void setDrillImprove(byte[] drillImprove) {
		this.drillImprove = drillImprove;
	}

	public byte[] getDrillShop() {
		return drillShop;
	}

	public void setDrillShop(byte[] drillShop) {
		this.drillShop = drillShop;
	}

	public int getRebelStatus() {
		return rebelStatus;
	}

	public void setRebelStatus(int rebelStatus) {
		this.rebelStatus = rebelStatus;
	}

	public int getRebelLastOpenTime() {
		return rebelLastOpenTime;
	}

	public void setRebelLastOpenTime(int rebelLastOpenTime) {
		this.rebelLastOpenTime = rebelLastOpenTime;
	}

	public byte[] getRebelTotalData() {
		return rebelTotalData;
	}

	public void setRebelTotalData(byte[] rebelTotalData) {
		this.rebelTotalData = rebelTotalData;
	}

	public byte[] getWorldMineInfo() {
		return worldMineInfo;
	}

	public void setWorldMineInfo(byte[] worldMineInfo) {
		this.worldMineInfo = worldMineInfo;
	}

    public int getGameStopTime() {
        return gameStopTime;
    }

    public void setGameStopTime(int gameStopTime) {
        this.gameStopTime = gameStopTime;
    }

	public byte[] getAirship() {
		return airship;
	}

	public void setAirship(byte[] airship) {
		this.airship = airship;
	}

	public byte[] getLuckyInfo() {
		return luckyInfo;
	}

	public void setLuckyInfo(byte[] luckyInfo) {
		this.luckyInfo = luckyInfo;
	}

	public byte[] getTeamTask() {
		return teamTask;
	}

	public void setTeamTask(byte[] teamTask) {
		this.teamTask = teamTask;
	}

	public byte[] getHonourTotalData() {
		return honourTotalData;
	}

	public void setHonourTotalData(byte[] honourTotalData) {
		this.honourTotalData = honourTotalData;
	}

	public byte[] getWorldStaffing() {
		return WorldStaffing;
	}

	public void setWorldStaffing(byte[] worldStaffing) {
		WorldStaffing = worldStaffing;
	}

	public byte[] getNotGetAward() {
		return notGetAward;
	}

	public void setNotGetAward(byte[] notGetAward) {
		this.notGetAward = notGetAward;
	}

	public byte[] getActKingInfo() {
		return actKingInfo;
	}

	public void setActKingInfo(byte[] actKingInfo) {
		this.actKingInfo = actKingInfo;
	}
}
