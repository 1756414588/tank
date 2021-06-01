/**   
 * @Title: StaticStaffingDataMgr.java    
 * @Package com.game.dataMgr    
 * @Description:   
 * @author ZhangJun   
 * @date 2016年3月10日 下午5:16:02    
 * @version V1.0   
 */
package com.game.dataMgr;

import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.game.dao.impl.s.StaticDataDao;
import com.game.domain.p.Lord;
import com.game.domain.s.StaticStaffing;
import com.game.domain.s.StaticStaffingLv;
import com.game.domain.s.StaticStaffingWorld;

/**
 * @ClassName: StaticStaffingDataMgr
 * @Description: 编制玩法相关配置
 * @author ZhangJun
 * @date 2016年3月10日 下午5:16:02
 * 
 */
@Component
public class StaticStaffingDataMgr extends BaseDataMgr {
	@Autowired
	private StaticDataDao staticDataDao;

	private Map<Integer, StaticStaffingLv> lvMap;
	private Map<Integer, StaticStaffing> staffingMap;
	private Map<Integer, StaticStaffingWorld> worldMap;

	/**
	 * Overriding: init
	 * 
	 * @see com.game.dataMgr.BaseDataMgr#init()
	 */
	@Override
	public void init() {
		Map<Integer, StaticStaffingLv> lvMap = staticDataDao.selectStaffingLv();
		this.lvMap = lvMap;

		Map<Integer, StaticStaffing> staffingMap = staticDataDao.selectStaffing();
		this.staffingMap = staffingMap;

		Map<Integer, StaticStaffingWorld> worldMap = staticDataDao.selectStaffingWorld();
		this.worldMap = worldMap;
	}

	public boolean addStaffingExp(Lord lord, int add) {
		int lv = lord.getStaffingLv();

		boolean up = false;
		int exp = lord.getStaffingExp() + add;
		while (true) {
			if (lv >= 1000) {
				break;
			}

			StaticStaffingLv staticStaffingLv = lvMap.get(lv + 1);
			if (exp >= staticStaffingLv.getExp()) {
				up = true;
				exp -= staticStaffingLv.getExp();
				lv++;
				continue;
			} else {
				break;
			}
		}

		lord.setStaffingLv(lv);
		lord.setStaffingExp(exp);
		return up;
	}

	public int getTotalExp(Lord lord) {
		if (lord.getStaffingLv() == 0) {
			return lord.getStaffingExp();
		}
		return lvMap.get(lord.getStaffingLv()).getTotalExp() + lord.getStaffingExp();
	}

	public boolean subStaffingExp(Lord lord, int sub) {
		int lv = lord.getStaffingLv();
		boolean down = false;

		int exp = lord.getStaffingExp() - sub;
		while (true) {
			if (lv < 1) {
				break;
			}

			if (exp < 0) {
				StaticStaffingLv staticStaffingLv = lvMap.get(lv);
				exp += staticStaffingLv.getExp();
				lv--;
				down = true;

				if (exp < 0) {
					continue;
				} else {
					break;
				}
			} else {
				break;
			}
		}

		if (exp < 0) {
			exp = 0;
		}

		lord.setStaffingLv(lv);
		lord.setStaffingExp(exp);
		return down;
	}

	public StaticStaffing getStaffing(int staffingId) {
		return staffingMap.get(staffingId);
	}

	public StaticStaffingWorld calcWolrdLv(int totalLv) {
		StaticStaffingWorld staticStaffingWorld = null;
		int worldLv = 0;
		while (true) {
			if (worldLv >= 10) {
				break;
			}

			StaticStaffingWorld world = worldMap.get(worldLv);
			if (totalLv >= world.getSumStaffing()) {
				worldLv++;
				staticStaffingWorld = world;
				continue;
			} else {
				break;
			}
		}

		return staticStaffingWorld;
	}

	public StaticStaffingWorld getStaffingWorld(int lv) {
		return worldMap.get(lv);
	}

	// public StaticStaffing calcStaffing(int lv, int ranks, int rank) {
	// StaticStaffing staticStaffing = null;
	// int id = 1;
	// while (id <= 11) {
	// StaticStaffing staffing = staffingMap.get(id);
	// if (lv >= staffing.getStaffingLv() && ranks >= staffing.getRank()) {
	// if (staffing.getCountLimit() != 0 && (rank == 0 || rank >
	// staffing.getCountLimit())) {
	// break;
	// }
	//
	// staticStaffing = staffing;
	// id++;
	// continue;
	// } else {
	// break;
	// }
	// }
	//
	// if (staticStaffing != null) {
	//
	// LogUtil.info("calcStaffing1:" + staticStaffing.getStaffingId() +
	// " ranks:" + ranks + " lv:" + lv + " rank:" + rank);
	// LogUtil.info("calcStaffing2:" + staticStaffing.getStaffingId() +
	// " ranks:" + staticStaffing.getRank() + " lv:"
	// + staticStaffing.getStaffingLv() + " rank:" +
	// staticStaffing.getCountLimit());
	// }
	//
	// return staticStaffing;
	// }

	/**
	 * 
	 * Method: calcStaffing
	 * 
	 * @Description: 不考虑人数限制时，应该可以得到的称号 @param lv @param ranks @return @return StaticStaffing @throws
	 */
	public StaticStaffing calcStaffing(int lv, int ranks) {
		StaticStaffing staticStaffing = null;
		int id = 1;
		while (id <= 11) {
			StaticStaffing staffing = staffingMap.get(id);
			if (lv >= staffing.getStaffingLv() && ranks >= staffing.getRank()) {
				staticStaffing = staffing;
				id++;
			} else {
				break;
			}
		}
		return staticStaffing;
	}

	public Map<Integer, StaticStaffing> getStaffingMap() {
		return staffingMap;
	}

	public void setStaffingMap(Map<Integer, StaticStaffing> staffingMap) {
		this.staffingMap = staffingMap;
	}
}
