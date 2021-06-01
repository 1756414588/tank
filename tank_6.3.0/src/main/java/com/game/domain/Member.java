package com.game.domain;

import com.game.domain.p.PartyDonate;
import com.game.domain.p.PartyMember;
import com.game.domain.p.PartyProp;
import com.game.domain.p.Weal;
import com.game.pb.CommonPb;
import com.game.pb.CommonPb.WarRecordPerson;
import com.game.pb.SerializePb.*;
import com.game.util.PbHelper;
import com.game.util.TimeHelper;
import com.google.protobuf.InvalidProtocolBufferException;
import com.hundredcent.game.aop.annotation.SaveLevel;
import com.hundredcent.game.aop.annotation.SaveOptimize;

import java.util.*;

/**
 * @author ChenKui
 * @version 创建时间：2015-9-9 下午5:53:44
 * @declare 工会会员
 */
@SaveOptimize(level = SaveLevel.IDLE)
public class Member {

	private long lordId;
	/*
	 * 军团ID
	 */
	private int partyId;
	/*
	 * 帮派职位
	 */
	private int job;
	/*
	 * 军团威望
	 */
	private long prestige;
	/*
	 * 总贡献
	 */
	private int donate;
	/*
	 * 周捐献贡献
	 */
	private int weekDonate;
	/*
	 * 周全部贡献
	 */
	private int weekAllDonate;
	/*
	 * 贡献时间
	 */
	private int donateTime;
	/*
	 * 日常福利
	 */
	private int dayWeal;
	/*
	 * 军团副本次数
	 */
	private int combatCount;
	/*
	 * 刷新时间(刷新有关的均采用这个时间做记录)
	 */
	private int refreshTime;
	/*
	 * 进军团时间
	 */
	private int enterTime;

	private int activity;

	/*
	 * 玩家申请军团列表
	 */
	private String applyList;
	/*
	 * 军团大厅捐献
	 */
	private PartyDonate hallMine = new PartyDonate();
	/*
	 * 军团科技捐献
	 */
	private PartyDonate scienceMine = new PartyDonate();
	/*
	 * 福利院资源
	 */
	private Weal wealMine = new Weal();

	/*
	 * 帮派道具
	 */
	private List<PartyProp> partyProps = new ArrayList<PartyProp>();
	/*
	 * 军团副本记录
	 */
	private Set<Integer> combatIds = new HashSet<Integer>();

	/**
	 * 报名时所在军团id
	 */
	private int regParty;
	
	/**
	 * 百团混战时间
	 */
	private int regTime;

	/*
	 * 报名等级
	 */
	private int regLv;

	/*
	 * 报名战力
	 */
	private long regFight;

	/**
	 * 连胜数
	 */
	private int winCount;

	/**
	 * 百团混战个人战报
	 */
	public LinkedList<WarRecordPerson> warRecords = new LinkedList<>();
	

	
	public LinkedList<WarRecordPerson> getWarRecords() {
		return warRecords;
	}

	public void setWarRecords(LinkedList<WarRecordPerson> warRecords) {
		this.warRecords = warRecords;
	}

	public int getWinCount() {
		return winCount;
	}

	public void setWinCount(int winCount) {
		this.winCount = winCount;
	}

	public long getLordId() {
		return lordId;
	}

	public void setLordId(long lordId) {
		this.lordId = lordId;
	}

	public PartyDonate getHallMine() {
		return hallMine;
	}

	public void setHallMine(PartyDonate hallMine) {
		this.hallMine = hallMine;
	}

	public PartyDonate getScienceMine() {
		return scienceMine;
	}

	public void setScienceMine(PartyDonate scienceMine) {
		this.scienceMine = scienceMine;
	}

	public Weal getWealMine() {
		return wealMine;
	}

	public void setWealMine(Weal wealMine) {
		this.wealMine = wealMine;
	}

	public int getWeekAllDonate() {
		return weekAllDonate;
	}

	public void setWeekAllDonate(int weekAllDonate) {
		this.weekAllDonate = weekAllDonate;
	}

	public List<PartyProp> getPartyProps() {
		return partyProps;
	}

	public void setPartyProps(List<PartyProp> partyProps) {
		this.partyProps = partyProps;
	}

	public Set<Integer> getCombatIds() {
		return combatIds;
	}

	public void setCombatIds(Set<Integer> combatIds) {
		this.combatIds = combatIds;
	}

	public void enterParty(int partyId) {
		this.setPartyId(partyId);
		this.setDonate(0);
		this.setWeekDonate(0);
		this.setWeekAllDonate(0);
		this.setJob(10);
		this.setApplyList("|");
		this.setEnterTime(TimeHelper.getCurrentDay());
//		this.setRegTime(0);
//		this.setRegLv(0);
//		this.setRegFight(0L);
//		this.setWinCount(0);
//		warRecords.clear();
	}

	public void quitParty() {
		this.setPartyId(0);
		this.setDonate(0);
		this.setWeekDonate(0);
		this.setWeekAllDonate(0);
		this.setJob(10);
		this.setApplyList("|");
		this.setEnterTime(TimeHelper.getCurrentDay());
//		this.setRegTime(0);
//		this.setRegLv(0);
//		this.setRegFight(0L);
//		this.setWinCount(0);
		warRecords.clear();
	}

	public byte[] serWeal(Weal weal) {
		SerWeal.Builder ser = SerWeal.newBuilder();
		ser.setWeal(PbHelper.createWealPb(weal));
		return ser.build().toByteArray();
	}

	public byte[] serPartyDonate(PartyDonate partyDonate) {
		SerPartyDonate.Builder ser = SerPartyDonate.newBuilder();
		ser.setPartyDonate(PbHelper.createPartyDonatePb(partyDonate));
		return ser.build().toByteArray();
	}

	public Weal dserWeal(byte[] data) throws InvalidProtocolBufferException {
		Weal reportMine = new Weal();
		if (data == null) {
			return reportMine;
		}
		SerWeal ser = SerWeal.parseFrom(data);
		CommonPb.Weal e = ser.getWeal();
		reportMine.setStone(e.getStone());
		reportMine.setIron(e.getIron());
		reportMine.setCopper(e.getCopper());
		reportMine.setSilicon(e.getSilicon());
		reportMine.setOil(e.getOil());
		reportMine.setGold(e.getGold());
		return reportMine;
	}

	public PartyDonate dserPartyDonate(byte[] data) throws InvalidProtocolBufferException {
		PartyDonate reportMine = new PartyDonate();
		if (data == null) {
			return reportMine;
		}
		SerPartyDonate ser = SerPartyDonate.parseFrom(data);
		CommonPb.PartyDonate e = ser.getPartyDonate();
		reportMine.setStone(e.getStone());
		reportMine.setIron(e.getIron());
		reportMine.setCopper(e.getCopper());
		reportMine.setSilicon(e.getSilicon());
		reportMine.setOil(e.getOil());
		reportMine.setGold(e.getGold());
		return reportMine;
	}

	public byte[] serCombatId() {
		SerOneInt.Builder ser = SerOneInt.newBuilder();
		Iterator<Integer> it = this.combatIds.iterator();
		while (it.hasNext()) {
			ser.addV(it.next());
		}
		return ser.build().toByteArray();
	}

	public byte[] serWarRecord() {
		SerPersonWarRecord.Builder ser = SerPersonWarRecord.newBuilder();
		ser.addAllWarRecord(warRecords);
		return ser.build().toByteArray();
	}

	public void dserCombatId(byte[] data) throws InvalidProtocolBufferException {
		if (data == null) {
			return;
		}
		SerOneInt ser = SerOneInt.parseFrom(data);
		List<Integer> list = ser.getVList();
		for (Integer e : list) {
			combatIds.add(e);
		}
	}

	public void dserWarRecord(byte[] data) throws InvalidProtocolBufferException {
		if (data == null) {
			return;
		}

		SerPersonWarRecord ser = SerPersonWarRecord.parseFrom(data);
		warRecords.addAll(ser.getWarRecordList());
	}

	public byte[] serPartyProp() {
		SerPartyProp.Builder ser = SerPartyProp.newBuilder();
		Iterator<PartyProp> it = this.partyProps.iterator();
		while (it.hasNext()) {
			ser.addPartyProp(PbHelper.createPartyPropPb(it.next()));
		}
		return ser.build().toByteArray();
	}

	public void dserPartyProp(byte[] data) throws InvalidProtocolBufferException {
		if (data == null) {
			return;
		}
		SerPartyProp ser = SerPartyProp.parseFrom(data);
		List<CommonPb.PartyProp> list = ser.getPartyPropList();
		for (CommonPb.PartyProp e : list) {
			PartyProp prop = new PartyProp();
			prop.setKeyId(e.getKeyId());
			prop.setCount(e.getCount());
			partyProps.add(prop);
		}
	}

	public int getPartyId() {
		return partyId;
	}

	public void setPartyId(int partyId) {
		this.partyId = partyId;
	}

	public int getJob() {
		return job;
	}

	public void setJob(int job) {
		this.job = job;
	}

	public long getPrestige() {
		return prestige;
	}

	public void setPrestige(long prestige) {
		this.prestige = prestige;
	}

	public int getDonate() {
		return donate;
	}

	public void setDonate(int donate) {
		this.donate = donate;
	}

	public int getWeekDonate() {
		return weekDonate;
	}

	public void setWeekDonate(int weekDonate) {
		this.weekDonate = weekDonate;
	}

	public int getDonateTime() {
		return donateTime;
	}

	public void setDonateTime(int donateTime) {
		this.donateTime = donateTime;
	}

	public int getDayWeal() {
		return dayWeal;
	}

	public void setDayWeal(int dayWeal) {
		this.dayWeal = dayWeal;
	}

	public int getCombatCount() {
		return combatCount;
	}

	public void setCombatCount(int combatCount) {
		this.combatCount = combatCount;
	}

	public int getRefreshTime() {
		return refreshTime;
	}

	public void setRefreshTime(int refreshTime) {
		this.refreshTime = refreshTime;
	}

	public String getApplyList() {
		return applyList;
	}

	public void setApplyList(String applyList) {
		this.applyList = applyList;
	}

	public void loadMember(PartyMember partyMember) throws InvalidProtocolBufferException {
		this.lordId = partyMember.getLordId();
		this.partyId = partyMember.getPartyId();
		this.job = partyMember.getJob();
		this.donate = partyMember.getDonate();
		this.weekAllDonate = partyMember.getWeekAllDonate();
		this.weekDonate = partyMember.getWeekDonate();
		this.donateTime = partyMember.getDonateTime();
		this.combatCount = partyMember.getCombatCount();
		this.dayWeal = partyMember.getDayWeal();
		this.refreshTime = partyMember.getRefreshTime();
		this.enterTime = partyMember.getEnterTime();
		this.applyList = partyMember.getApplyList();
		this.setHallMine(dserPartyDonate(partyMember.getHallMine()));
		this.setScienceMine(dserPartyDonate(partyMember.getScienceMine()));
		this.setWealMine(dserWeal(partyMember.getWealMine()));
		this.activity = partyMember.getActivity();
		this.dserPartyProp(partyMember.getPartyProp());
		this.dserCombatId(partyMember.getCombatId());

		regTime = partyMember.getRegTime();
		regLv = partyMember.getRegLv();
		regFight = partyMember.getRegFight();
		winCount = partyMember.getWinCount();
		regParty = partyMember.getRegParty();
		this.dserWarRecord(partyMember.getWarRecord());
	}

	/**
	 * 数据拷贝
	 * 
	 * @return
	 */
	public PartyMember copyData() {
		PartyMember partyMember = new PartyMember();
		partyMember.setLordId(this.lordId);
		partyMember.setPartyId(this.partyId);
		partyMember.setJob(this.job);
		partyMember.setPrestige(this.prestige);
		partyMember.setDonate(this.donate);
		partyMember.setWeekDonate(this.weekDonate);
		partyMember.setDonateTime(this.donateTime);
		partyMember.setDayWeal(this.dayWeal);
		partyMember.setCombatCount(this.combatCount);
		partyMember.setRefreshTime(this.refreshTime);
		partyMember.setEnterTime(this.enterTime);
		partyMember.setActivity(this.activity);
		partyMember.setApplyList((this.applyList != null) ? new String(this.applyList) : "|");
		partyMember.setHallMine(serPartyDonate(this.hallMine));
		partyMember.setScienceMine(serPartyDonate(this.scienceMine));
		partyMember.setWealMine(serWeal(this.wealMine));
		partyMember.setPartyProp(serPartyProp());
		partyMember.setCombatId(serCombatId());
		partyMember.setRegTime(regTime);
		partyMember.setRegLv(regLv);
		partyMember.setRegFight(regFight);
		partyMember.setWarRecord(serWarRecord());
		partyMember.setWinCount(winCount);
		partyMember.setRegParty(regParty);
		return partyMember;
	}

	public int getEnterTime() {
		return enterTime;
	}

	public void setEnterTime(int enterTime) {
		this.enterTime = enterTime;
	}

	public int getActivity() {
		return activity;
	}

	public void setActivity(int activity) {
		this.activity = activity;
	}

	public int getRegTime() {
		return regTime;
	}

	public void setRegTime(int regTime) {
		this.regTime = regTime;
	}

	public int getRegLv() {
		return regLv;
	}

	public void setRegLv(int regLv) {
		this.regLv = regLv;
	}

	public long getRegFight() {
		return regFight;
	}

	public void setRegFight(long regFight) {
		this.regFight = regFight;
	}

	public int getRegParty() {
		return regParty;
	}

	public void setRegParty(int regParty) {
		this.regParty = regParty;
	}
	


}
