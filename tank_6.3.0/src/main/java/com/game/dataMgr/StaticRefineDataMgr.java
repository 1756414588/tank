/**   
 * @Title: StaticRefineDataMgr.java    
 * @Package com.game.dataMgr    
 * @Description:   
 * @author ChenKui   
 * @date 2015-8-27    
 * @version V1.0   
 */
package com.game.dataMgr;

import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.game.dao.impl.s.StaticDataDao;
import com.game.domain.s.StaticRefine;
import com.game.domain.s.StaticRefineLv;

/**
* @ClassName: StaticRefineDataMgr 
* @Description: 科技馆 配置
* @author
 */
@Component
public class StaticRefineDataMgr extends BaseDataMgr {
	@Autowired
	private StaticDataDao staticDataDao;

	private Map<Integer, StaticRefine> refineMap;

	private Map<Integer, Map<Integer, StaticRefineLv>> refineLvMap = new HashMap<Integer, Map<Integer, StaticRefineLv>>();

	/**
	 * Overriding: init
	 * 
	 * @see com.game.dataMgr.BaseDataMgr#init()
	 */
	@Override
	public void init() {
		Map<Integer, StaticRefine> refineMap = staticDataDao.selectRefineMap();
		this.refineMap = refineMap;

		List<StaticRefineLv> refineLvList = staticDataDao.selectRefineLv();
		Map<Integer, Map<Integer, StaticRefineLv>> refineLvMap = new HashMap<Integer, Map<Integer, StaticRefineLv>>();
		for (StaticRefineLv staticRefineLv : refineLvList) {
			int refineId = staticRefineLv.getRefineId();
			int level = staticRefineLv.getLevel();
			Map<Integer, StaticRefineLv> levelMap = refineLvMap.get(refineId);
			if (levelMap == null) {
				levelMap = new HashMap<Integer, StaticRefineLv>();
				refineLvMap.put(refineId, levelMap);
			}
			levelMap.put(level, staticRefineLv);
		}
		this.refineLvMap = refineLvMap;
	}

	public StaticRefine getStaticRefine(int refineId) {
		return refineMap.get(refineId);
	}

	public Map<Integer, StaticRefine> getStaticRefineMap() {
		return refineMap;
	}

	public StaticRefineLv getStaticRefineLv(int refineId, int level) {
		return refineLvMap.get(refineId).get(level);
	}

	public StaticRefine getRefineBuild(int buildingId) {
		Iterator<StaticRefine> it = refineMap.values().iterator();
		while (it.hasNext()) {
			StaticRefine next = it.next();
			if (next.getBuildId() == buildingId) {
				return next;
			}
		}
		return null;
	}
	
	/**
	 * 
	* @Title: getRefineCapacity 
	* @Description: 获得类型为增加存储容量的科技
	* @return  
	* StaticRefine   

	 */
	public StaticRefine getRefineCapacity() {
		Iterator<StaticRefine> it = refineMap.values().iterator();
		while (it.hasNext()) {
			StaticRefine next = it.next();
			if (next.getCapacity() == 1) {
				return next;
			}
		}
		return null;
	}

}
