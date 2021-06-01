/**   
 * @Title: StaticCombatDataMgr.java    
 * @Package com.game.dataMgr    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年8月28日 下午1:49:03    
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
import com.game.domain.s.StaticCombat;
import com.game.domain.s.StaticExplore;
import com.game.domain.s.StaticSection;

/**
 * @ClassName: StaticCombatDataMgr
 * @Description: 关卡信息 s_combat
 * @author ZhangJun
 * @date 2015年8月28日 下午1:49:03
 * 
 */
@Component
public class StaticCombatDataMgr extends BaseDataMgr {
	@Autowired
	private StaticDataDao staticDataDao;

	// 普通副本
	private Map<Integer, StaticCombat> combatMap;

	private Map<Integer, StaticSection> sectionMap;

	private StaticSection equipSection;//装备探险

	private StaticSection partSection;//极限探险
	
	private StaticSection extreamSection;//极限探险

	private StaticSection timeSection;//限时副本
	
	private StaticSection militarySection;// 军工副本
	
	private StaticSection energyStoneSection;// 能晶副本
	
	private StaticSection medalSection;

	private StaticSection tacticsSection;//战术大师

	// 探险
	private Map<Integer, StaticExplore> exploreMap;

	/**
	 * Overriding: init
	 * 
	 * @see com.game.dataMgr.BaseDataMgr#init()
	 */
	@Override
	public void init() {
		//Auto-generated method stub
		initSection();
		initCombat();
		initExplore();
	}

	/**
	* @Title: initSection 
	* @Description:   初始化大关卡
	* void 

	 */
	private void initSection() {
		Map<Integer, StaticSection> sectionMap = staticDataDao.selectSection();
		if (sectionMap == null) {
			sectionMap = new HashMap<>();
		}
		this.sectionMap = sectionMap;

		Iterator<StaticSection> it = sectionMap.values().iterator();
		while (it.hasNext()) {
			StaticSection staticSection = (StaticSection) it.next();
			if (staticSection.getType() == 2) {
				equipSection = staticSection;
			} else if (staticSection.getType() == 3) {
				partSection = staticSection;
			} else if (staticSection.getType() == 4) {
				extreamSection = staticSection;
			} else if (staticSection.getType() == 5) {
				timeSection = staticSection;
			} else if (staticSection.getType() == 6) {
				militarySection = staticSection;
			} else if (staticSection.getType() == 8) {
				energyStoneSection = staticSection;
			} else if (staticSection.getType() == 9) {
				medalSection = staticSection;
			} else if (staticSection.getType() == 10) {
				tacticsSection = staticSection;
			}
		}
	}
	/**
	* @Title: initCombat 
	* @Description:   初始化小关
	* void   

	 */
	private void initCombat() {
		List<StaticCombat> list = staticDataDao.selectCombat();
		int preId = 0;
		Map<Integer, StaticCombat> combatMap = new HashMap<>();
		for (StaticCombat staticCombat : list) {
			int combatId = staticCombat.getCombatId();
			combatMap.put(combatId, staticCombat);

			StaticSection staticSection = sectionMap.get(staticCombat.getSectionId());
			if (staticSection.getStartId() == 0) {
				staticSection.setStartId(combatId);
			}
			if (staticSection.getEndId() < combatId) {
				staticSection.setEndId(combatId);
			}

			staticCombat.setPreId(preId);
			preId = staticCombat.getCombatId();
		}
		this.combatMap = combatMap;
	}

	/**
	* @Title: initExplore 
	* @Description:   初始化探险
	* void   

	 */
	private void initExplore() {
		List<StaticExplore> list = staticDataDao.selectExplore();
		int preId1 = 0;
		int preId2 = 0;
		int preId3 = 0;
		int preId4 = 0;
		int preId5 = 0;
		Map<Integer, StaticExplore> exploreMap = new HashMap<>();
		for (StaticExplore staticExplore : list) {
			if (staticExplore.getType() == 1) {
				staticExplore.setPreId(preId1);
				preId1 = staticExplore.getExploreId();
			} else if (staticExplore.getType() == 2) {
				staticExplore.setPreId(preId2);
				preId2 = staticExplore.getExploreId();
			} else if (staticExplore.getType() == 3) {
				staticExplore.setPreId(preId3);
				preId3 = staticExplore.getExploreId();
			} 
			else if (staticExplore.getType() == 4) {
				staticExplore.setPreId(preId4);
				preId4 = staticExplore.getExploreId();
			} else {
				staticExplore.setPreId(preId5);
				preId5 = staticExplore.getExploreId();
			}
			calcDropWeight(staticExplore);
			exploreMap.put(staticExplore.getExploreId(), staticExplore);
		}
		this.exploreMap = exploreMap;
	}

	/**
	* @Title: calcDropWeight 
	* @Description: 计算掉落权重总值
	* @param staticExplore  
	* void   

	 */
	private void calcDropWeight(StaticExplore staticExplore) {
		List<List<Integer>> list = staticExplore.getDropOne();
		if (list != null && !list.isEmpty()) {
			int weight = 0;
			for (List<Integer> one : list) {
				if (one.size() != 4) {
					continue;
				}

				weight += one.get(3);
			}
			staticExplore.setWeight(weight);
		}
	}

    public Map<Integer, StaticCombat> getCombatMap() {
        return combatMap;
    }

    public StaticSection getStaticSection(int sectionId) {
		return sectionMap.get(sectionId);
	}

	public StaticCombat getStaticCombat(int combatId) {
		return combatMap.get(combatId);
	}
	
	public int getStaticCombatSize(){
		return combatMap.size();
	}

	public StaticExplore getStaticExplore(int exploreId) {
		return exploreMap.get(exploreId);
	}

	public StaticSection getEquipSection() {
		return equipSection;
	}

	public StaticSection getPartSection() {
		return partSection;
	}

	public StaticSection getTimeSection() {
		return timeSection;
	}
	
	public StaticSection getExtreamSection() {
		return extreamSection;
	}
	
	public Map<Integer, StaticExplore> getAllExplore() {
		return exploreMap;
	}

	public StaticSection getMilitarySection() {
		return militarySection;
	}

	public StaticSection getEnergyStoneSection() {
		return energyStoneSection;
	}
	
	public StaticSection getMedalSection() {
		return medalSection;
	}

	public StaticSection getTacticsSection() {
		return tacticsSection;
	}
}
