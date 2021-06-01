package com.game.domain.p.airship;

import java.util.ArrayList;
import java.util.List;

import com.game.domain.p.Army;
import com.game.pb.CommonPb;
import com.game.pb.SerializePb;
/**
* @ClassName: AirshipTeam 
* @Description: 飞艇进攻部队
* @author
 */
public class AirshipTeam {
	private long lordId;// 发起人角色id
	private int id;// 飞艇id
	private List<Long[]> armysDb = new ArrayList<>();//主要保存顺序， lordId 列表
	private int endTime;//到达秒
	private int state;//
	private List<Army> armys = new ArrayList<>();// 按照顺序来

	public AirshipTeam() {
		
	}
	
	public AirshipTeam(SerializePb.AirshipTeamDb team) {
		lordId = team.getLordId();
		id = team.getId();
		endTime = team.getEndTime();
		state = team.getState();
		for (CommonPb.TwoLong army : team.getArmysList()) {
			armysDb.add(new Long[]{army.getV1(),army.getV2()});
		}
	}

	public long getLordId() {
		return lordId;
	}

	public void setLordId(long lordId) {
		this.lordId = lordId;
	}

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public List<Long[]> getArmysDb() {
		return armysDb;
	}

	public int getEndTime() {
		return endTime;
	}

	public void setEndTime(int endTime) {
		this.endTime = endTime;
	}

	public int getState() {
		return state;
	}

	public void setState(int state) {
		this.state = state;
	}
	
	public List<Army> getArmys() {
		return armys;
	}

	public void setArmys(List<Army> armys) {
		this.armys = armys;
	}
}
