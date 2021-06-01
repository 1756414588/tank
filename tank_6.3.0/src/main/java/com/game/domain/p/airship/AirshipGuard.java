package com.game.domain.p.airship;

import java.util.ArrayList;
import java.util.List;

import com.game.domain.p.Army;
import com.game.pb.CommonPb;
import com.game.pb.SerializePb;
/**
* @ClassName: AirshipGuard 
* @Description: 飞艇防守部队
* @author
 */
public class AirshipGuard {
	private int id;
	//V1: lordId, V2:armyId
	private List<Long[]> armysDb = new ArrayList<>();
    private List<Army> armys = new ArrayList<>();// 按照顺序来
	
	public AirshipGuard(int airshipId){
		this.id = airshipId;
	}

	public AirshipGuard(SerializePb.AirshipGuard guard) {
		id = guard.getId();
		for (CommonPb.TwoLong army : guard.getArmysList()) {
			armysDb.add(new Long[]{army.getV1(),army.getV2()});
		}
	}

	public int getId() {
		return id;
	}

	public List<Long[]> getArmysDb() {
		return armysDb;
	}

	public List<Army> getArmys() {
		return armys;
	}
}
