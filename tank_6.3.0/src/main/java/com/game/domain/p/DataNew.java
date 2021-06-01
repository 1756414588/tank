/**   
 * @Title: DataNew.java    
 * @Package com.game.domain.p    
 * @Description:   
 * @author ZhangJun   
 * @date 2016年1月8日 下午6:20:11    
 * @version V1.0   
 */
package com.game.domain.p;

/**
 * @ClassName: DataNew
 * @Description: 用来保存到数据库的玩家数据对象
 * @author ZhangJun
 * @date 2016年1月8日 下午6:20:11
 * 
 */
public class DataNew {
	private long lordId;
	private byte[] roleData;
	private byte[] mail;
	private int combatId;
	private int equipEplrId;
	private int partEplrId;
	private int extrEplrId;
	private int militaryEplrId;
	private int extrMark;
	private int wipeTime;
	private int timePrlrId;
	private int energyStoneEplrId;// 能晶副本进度
	private int signLogin;
	private int maxKey;
	private int seniorWeek;
	private int seniorDay;
	private int seniorCount;
	private int seniorScore;
	private int seniorAward;
	private int seniorBuy;
//	private int smeltDay;//配件淬炼日期
//	private int smeltTimes;//配件淬炼次数
	private int medalEplrId;

	private int crossMineScore;	//跨服军矿积分
	private int crossMineAward;  //1.未领取 2.已领取


	public long getLordId() {
		return lordId;
	}

	public void setLordId(long lordId) {
		this.lordId = lordId;
	}

	public byte[] getRoleData() {
		return roleData;
	}

	public void setRoleData(byte[] roleData) {
		this.roleData = roleData;
	}

	public byte[] getMail() {
		return mail;
	}

	public void setMail(byte[] mail) {
		this.mail = mail;
	}

	public int getCombatId() {
		return combatId;
	}

	public void setCombatId(int combatId) {
		this.combatId = combatId;
	}

	public int getEquipEplrId() {
		return equipEplrId;
	}

	public void setEquipEplrId(int equipEplrId) {
		this.equipEplrId = equipEplrId;
	}

	public int getPartEplrId() {
		return partEplrId;
	}

	public void setPartEplrId(int partEplrId) {
		this.partEplrId = partEplrId;
	}

	public int getExtrEplrId() {
		return extrEplrId;
	}

	public void setExtrEplrId(int extrEplrId) {
		this.extrEplrId = extrEplrId;
	}

	public int getExtrMark() {
		return extrMark;
	}

	public void setExtrMark(int extrMark) {
		this.extrMark = extrMark;
	}

	public int getWipeTime() {
		return wipeTime;
	}

	public void setWipeTime(int wipeTime) {
		this.wipeTime = wipeTime;
	}

	public int getTimePrlrId() {
		return timePrlrId;
	}

	public void setTimePrlrId(int timePrlrId) {
		this.timePrlrId = timePrlrId;
	}

	public int getSignLogin() {
		return signLogin;
	}

	public void setSignLogin(int signLogin) {
		this.signLogin = signLogin;
	}

	public int getMaxKey() {
		return maxKey;
	}

	public void setMaxKey(int maxKey) {
		this.maxKey = maxKey;
	}

	public int getSeniorDay() {
		return seniorDay;
	}

	public void setSeniorDay(int seniorDay) {
		this.seniorDay = seniorDay;
	}

	public int getSeniorCount() {
		return seniorCount;
	}

	public void setSeniorCount(int seniorCount) {
		this.seniorCount = seniorCount;
	}

	public int getSeniorScore() {
		return seniorScore;
	}

	public void setSeniorScore(int seniorScore) {
		this.seniorScore = seniorScore;
	}

	public int getSeniorAward() {
		return seniorAward;
	}

	public void setSeniorAward(int seniorAward) {
		this.seniorAward = seniorAward;
	}

	public int getSeniorBuy() {
		return seniorBuy;
	}

	public void setSeniorBuy(int seniorBuy) {
		this.seniorBuy = seniorBuy;
	}

	public int getSeniorWeek() {
		return seniorWeek;
	}

	public void setSeniorWeek(int seniorWeek) {
		this.seniorWeek = seniorWeek;
	}

	public int getMilitaryEplrId() {
		return militaryEplrId;
	}

	public void setMilitaryEplrId(int militaryEplrId) {
		this.militaryEplrId = militaryEplrId;
	}

	public int getEnergyStoneEplrId() {
		return energyStoneEplrId;
	}

	public void setEnergyStoneEplrId(int energyStoneEplrId) {
		this.energyStoneEplrId = energyStoneEplrId;
	}

	public int getMedalEplrId() {
		return medalEplrId;
	}

	public void setMedalEplrId(int medalEplrId) {
		this.medalEplrId = medalEplrId;
	}

	public int getCrossMineScore() {
		return crossMineScore;
	}

	public void setCrossMineScore(int crossMineScore) {
		this.crossMineScore = crossMineScore;
	}

	public int getCrossMineAward() {
		return crossMineAward;
	}

	public void setCrossMineAward(int crossMineAward) {
		this.crossMineAward = crossMineAward;
	}

	//	public int getSmeltDay() {
//		return smeltDay;
//	}
//
//	public void setSmeltDay(int smeltDay) {
//		this.smeltDay = smeltDay;
//	}
//
//	public int getSmeltTimes() {
//		return smeltTimes;
//	}
//
//	public void setSmeltTimes(int smeltTimes) {
//		this.smeltTimes = smeltTimes;
//	}
}
