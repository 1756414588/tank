package com.game.domain.p;

import java.util.Arrays;

/**
 * @author ChenKui
 * @version 创建时间：2015-9-9 上午10:33:04
 * @Description: 军团
 */
public class Party {
	private int partyId;
	private String partyName;
	private String legatusName;
	private int partyLv;
	private int scienceLv;
	private int wealLv;
	private int lively;
	private int build;
	private long fight;
	private int apply;
	private int applyLv;
	private long applyFight;
	private String slogan;
	private String innerSlogan;
	private String jobName1;
	private String jobName2;
	private String jobName3;
	private String jobName4;
	private byte[] mine;
	private byte[] science;
	private byte[] applyList;
	private byte[] trend;
	private byte[] partyCombat;
	private byte[] liveTask;
	private byte[] activity;
	private byte[] amyProps;
	private byte[] warRecord;
	private byte[] donates;
	private int regLv;
	private int warRank;
	private long regFight;
	private String shopProps;
	private int score;
	private int refreshTime;
	private int altarLv;// 军团祭坛的等级
	private int nextCallBossSec;// 下一次可以召唤祭坛BOSS的时间（CD结束时间），毫秒数/1000
	private int bossLv;// 祭坛BOSS的等级
	private int bossState;// 祭坛BOSS的状态
	private int bossWhich;// 祭坛BOSS当前是第几管血
	private int bossHp;// 祭坛BOSS当前血量万分比
	private String bossHurtRank;// 祭坛BOSS伤害排行
	private String bossAward;// 祭坛BOSS排行奖励，已领取奖励的玩家记录
	private int shopTime;//军团商店 上次全局刷新时间
	private byte[] airshipData;//飞艇信息
	private long teamRecharge;//军团累计充值金币量
	private int altarBossExp; //祭坛Boss的经验
	public int getPartyId() {
		return partyId;
	}

	public void setPartyId(int partyId) {
		this.partyId = partyId;
	}

	public String getPartyName() {
		return partyName;
	}

	public void setPartyName(String partyName) {
		this.partyName = partyName;
	}

	public String getLegatusName() {
		return legatusName;
	}

	public void setLegatusName(String legatusName) {
		this.legatusName = legatusName;
	}

	public int getPartyLv() {
		return partyLv;
	}

	public void setPartyLv(int partyLv) {
		this.partyLv = partyLv;
	}

	public int getScienceLv() {
		return scienceLv;
	}

	public void setScienceLv(int scienceLv) {
		this.scienceLv = scienceLv;
	}

	public int getWealLv() {
		return wealLv;
	}

	public void setWealLv(int wealLv) {
		this.wealLv = wealLv;
	}

	public int getLively() {
		return lively;
	}

	public void setLively(int lively) {
		this.lively = lively;
	}

	public int getBuild() {
		return build;
	}

	public void setBuild(int build) {
		this.build = build;
	}

	public int getApply() {
		return apply;
	}

	public void setApply(int apply) {
		this.apply = apply;
	}

	public int getApplyLv() {
		return applyLv;
	}

	public void setApplyLv(int applyLv) {
		this.applyLv = applyLv;
	}

	public long getFight() {
		return fight;
	}

	public void setFight(long fight) {
		this.fight = fight;
	}

	public long getApplyFight() {
		return applyFight;
	}

	public void setApplyFight(long applyFight) {
		this.applyFight = applyFight;
	}

	public String getSlogan() {
		return slogan;
	}

	public void setSlogan(String slogan) {
		this.slogan = slogan;
	}

	public String getInnerSlogan() {
		return innerSlogan;
	}

	public void setInnerSlogan(String innerSlogan) {
		this.innerSlogan = innerSlogan;
	}

	public String getJobName1() {
		return jobName1;
	}

	public void setJobName1(String jobName1) {
		this.jobName1 = jobName1;
	}

	public String getJobName2() {
		return jobName2;
	}

	public void setJobName2(String jobName2) {
		this.jobName2 = jobName2;
	}

	public String getJobName3() {
		return jobName3;
	}

	public void setJobName3(String jobName3) {
		this.jobName3 = jobName3;
	}

	public String getJobName4() {
		return jobName4;
	}

	public void setJobName4(String jobName4) {
		this.jobName4 = jobName4;
	}

	public byte[] getMine() {
		return mine;
	}

	public void setMine(byte[] mine) {
		this.mine = mine;
	}

	public byte[] getScience() {
		return science;
	}

	public void setScience(byte[] science) {
		this.science = science;
	}

	public byte[] getApplyList() {
		return applyList;
	}

	public void setApplyList(byte[] applyList) {
		this.applyList = applyList;
	}

	public byte[] getTrend() {
		return trend;
	}

	public void setTrend(byte[] trend) {
		this.trend = trend;
	}

	public byte[] getPartyCombat() {
		return partyCombat;
	}

	public void setPartyCombat(byte[] partyCombat) {
		this.partyCombat = partyCombat;
	}

	public int getRefreshTime() {
		return refreshTime;
	}

	public void setRefreshTime(int refreshTime) {
		this.refreshTime = refreshTime;
	}

	public byte[] getLiveTask() {
		return liveTask;
	}

	public void setLiveTask(byte[] liveTask) {
		this.liveTask = liveTask;
	}

	public byte[] getActivity() {
		return activity;
	}

	public void setActivity(byte[] activity) {
		this.activity = activity;
	}

	public byte[] getAmyProps() {
		return amyProps;
	}

	public void setAmyProps(byte[] amyProps) {
		this.amyProps = amyProps;
	}

	public byte[] getWarRecord() {
		return warRecord;
	}

	public void setWarRecord(byte[] warRecord) {
		this.warRecord = warRecord;
	}

	public int getRegLv() {
		return regLv;
	}

	public void setRegLv(int regLv) {
		this.regLv = regLv;
	}

	public int getWarRank() {
		return warRank;
	}

	public void setWarRank(int warRank) {
		this.warRank = warRank;
	}

	public long getRegFight() {
		return regFight;
	}

	public void setRegFight(long regFight) {
		this.regFight = regFight;
	}

	public String getShopProps() {
		return shopProps;
	}

	public void setShopProps(String shopProps) {
		this.shopProps = shopProps;
	}

	public int getScore() {
		return score;
	}

	public void setScore(int score) {
		this.score = score;
	}

	public byte[] getDonates() {
		return donates;
	}

	public void setDonates(byte[] donates) {
		this.donates = donates;
	}

	public int getAltarLv() {
		return altarLv;
	}

	public void setAltarLv(int altarLv) {
		this.altarLv = altarLv;
	}

	public int getNextCallBossSec() {
		return nextCallBossSec;
	}

	public void setNextCallBossSec(int nextCallBossSec) {
		this.nextCallBossSec = nextCallBossSec;
	}

	public int getBossLv() {
		return bossLv;
	}

	public void setBossLv(int bossLv) {
		this.bossLv = bossLv;
	}

	public int getBossState() {
		return bossState;
	}

	public void setBossState(int bossState) {
		this.bossState = bossState;
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

	public String getBossHurtRank() {
		return bossHurtRank;
	}

	public void setBossHurtRank(String bossHurtRank) {
		this.bossHurtRank = bossHurtRank;
	}

	public String getBossAward() {
		return bossAward;
	}

	public void setBossAward(String bossAward) {
		this.bossAward = bossAward;
	}

	public int getShopTime() {
		return shopTime;
	}

	public void setShopTime(int shopTime) {
		this.shopTime = shopTime;
	}

	public byte[] getAirshipData() {
		return airshipData;
	}

	public void setAirshipData(byte[] airshipData) {
		this.airshipData = airshipData;
	}
	
	

	public int getAltarBossExp() {
		return altarBossExp;
	}

	public void setAltarBossExp(int altarBossExp) {
		this.altarBossExp = altarBossExp;
	}

	

	@Override
	public String toString() {
		return "Party [partyId=" + partyId + ", partyName=" + partyName + ", legatusName=" + legatusName + ", partyLv="
				+ partyLv + ", scienceLv=" + scienceLv + ", wealLv=" + wealLv + ", lively=" + lively + ", build="
				+ build + ", fight=" + fight + ", apply=" + apply + ", applyLv=" + applyLv + ", applyFight="
				+ applyFight + ", slogan=" + slogan + ", innerSlogan=" + innerSlogan + ", jobName1=" + jobName1
				+ ", jobName2=" + jobName2 + ", jobName3=" + jobName3 + ", jobName4=" + jobName4 + ", mine="
				+ Arrays.toString(mine) + ", science=" + Arrays.toString(science) + ", applyList="
				+ Arrays.toString(applyList) + ", trend=" + Arrays.toString(trend) + ", partyCombat="
				+ Arrays.toString(partyCombat) + ", liveTask=" + Arrays.toString(liveTask) + ", activity="
				+ Arrays.toString(activity) + ", amyProps=" + Arrays.toString(amyProps) + ", warRecord="
				+ Arrays.toString(warRecord) + ", donates=" + Arrays.toString(donates) + ", regLv=" + regLv
				+ ", warRank=" + warRank + ", regFight=" + regFight + ", shopProps=" + shopProps + ", score=" + score
				+ ", refreshTime=" + refreshTime + ", altarLv=" + altarLv + ", nextCallBossSec=" + nextCallBossSec
				+ ", bossLv=" + bossLv + ", bossState=" + bossState + ", bossWhich=" + bossWhich + ", bossHp=" + bossHp
				+ ", bossHurtRank=" + bossHurtRank + ", bossAward=" + bossAward + ", shopTime=" + shopTime
				+ ", airshipData=" + Arrays.toString(airshipData) + ", teamRecharge=" + teamRecharge + ", altarBossExp="
				+ altarBossExp + "]";
	}

	public long getTeamRecharge() {
		return teamRecharge;
	}

	public void setTeamRecharge(long teamRecharge) {
		this.teamRecharge = teamRecharge;
	}

}
