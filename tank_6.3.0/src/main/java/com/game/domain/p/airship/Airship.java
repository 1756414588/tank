package com.game.domain.p.airship;

import com.game.domain.PartyData;
import com.game.domain.p.Army;
import com.game.pb.SerializePb;
import com.game.pb.SerializePb.SaveRecvRecord;

import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;

/**
 * 飞艇信息
 */
public class Airship {
    private int id;
    private int partyId;
    private int safeEndTime;
    private int fight;//飞艇战斗力
    private int produceTime;//开始生产时间
    private int produceNum;//已生产数量
    private int durability;//耐久度(首次耐久度满才可以开始生产资源,之后资源生产不受耐久度影响)
    private int occupyTime;//飞艇被占领时间
    private boolean ruins;//true-废墟状态

    public List<Airship> waitOpenAirship = null;
    private PartyData partyData;
    private List<AirshipTeam> teamArmy = new ArrayList<>();//进攻部队列表
    private List<Army> guardArmy = new ArrayList<>();//防守部队列表

    //团员收取记录，最多50条
    private List<RecvAirshipProduceAwardRecord> recvRecordList = new LinkedList<>();
    
	public Airship() {
    }

    public Airship(SerializePb.AirshipDb pbAirship) {
        id = pbAirship.getId();
        partyId = pbAirship.getPartyId();
        safeEndTime = pbAirship.getSafeEndTime();
        produceTime = pbAirship.getProduceTime();
        produceNum = pbAirship.getProduceNum();
        durability = pbAirship.getDurability();
        occupyTime = pbAirship.getOccupyTime();
        ruins = pbAirship.getRuins();
        
        for(SaveRecvRecord record : pbAirship.getRecvRecordsList()) {
        	RecvAirshipProduceAwardRecord r = new RecvAirshipProduceAwardRecord();
        	r.setLordId(record.getLordId());
        	r.setType(record.getType());
        	r.setAwardId(record.getAwardId());
        	r.setCount(record.getCount());
        	r.setTimeSec(record.getRecvTime());
        	r.setMplt(record.getMplt());
        	recvRecordList.add(r);
        }
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getPartyId() {
        return partyId;
    }

    public void setPartyId(int partyId) {
        this.partyId = partyId;
    }

    public int getSafeEndTime() {
        return safeEndTime;
    }

    public void setSafeEndTime(int safeEndTime) {
        this.safeEndTime = safeEndTime;
    }

    public int getProduceTime() {
        return produceTime;
    }

    public void setProduceTime(int produceTime) {
        this.produceTime = produceTime;
    }

    public int getProduceNum() {
        return produceNum;
    }

    public void setProduceNum(int produceNum) {
        this.produceNum = produceNum;
    }

    public List<AirshipTeam> getTeamArmy() {
        return teamArmy;
    }

    public void setTeamArmy(List<AirshipTeam> teamArmy) {
        this.teamArmy = teamArmy;
    }

    public List<Army> getGuardArmy() {
        return guardArmy;
    }

    public void setGuardArmy(List<Army> guardArmy) {
        this.guardArmy = guardArmy;
    }

    public PartyData getPartyData() {
        return partyData;
    }

    public int getFight() {
        return fight;
    }

    public void setFight(int fight) {
        this.fight = fight;
    }

    public int getDurability() {
        return durability;
    }

    public void setDurability(int durability) {
        this.durability = durability;
    }

    public int getOccupyTime() {
        return occupyTime;
    }

    public void setOccupyTime(int occupyTime) {
        this.occupyTime = occupyTime;
    }

    public boolean isRuins() {
        return ruins;
    }

    public void setRuins(boolean ruins) {
        this.ruins = ruins;
    }

    public List<RecvAirshipProduceAwardRecord> getRecvRecordList() {
		return recvRecordList;
	}

    
    public void setPartyData(PartyData partyData) {
        this.partyData = partyData;
        if (partyData != null) {
            this.partyId = partyData.getPartyId();
        } else {
            this.partyId = 0;
        }
    }
}
