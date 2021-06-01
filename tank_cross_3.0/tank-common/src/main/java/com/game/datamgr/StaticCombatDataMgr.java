/**
 * @Title: StaticCombatDataMgr.java @Package com.game.dataMgr @Description: TODO
 * @author ZhangJun
 * @date 2015年8月28日 下午1:49:03
 * @version V1.0
 */
package com.game.datamgr;

import com.game.dao.impl.s.StaticDataDao;
import com.game.domain.s.StaticCombat;
import com.game.domain.s.StaticExplore;
import com.game.domain.s.StaticSection;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

/**
 * @author ZhangJun
 * @ClassName: StaticCombatDataMgr @Description: TODO
 * @date 2015年8月28日 下午1:49:03
 */
@Component
public class StaticCombatDataMgr extends BaseDataMgr {
    @Autowired
    private StaticDataDao staticDataDao;

    // 普通副本
    private Map<Integer, StaticCombat> combatMap;

    private Map<Integer, StaticSection> sectionMap;

    private StaticSection equipSection;

    private StaticSection partSection;

    private StaticSection timeSection;

    private StaticSection militarySection; // 军工副本

    private StaticSection energyStoneSection; // 能晶副本

    // 探险
    private Map<Integer, StaticExplore> exploreMap;

    /**
     * Overriding: init
     */
    @Override
    public void init() {
        initSection();
        initCombat();
        initExplore();
    }

    private void initSection() {
        sectionMap = staticDataDao.selectSection();
        if (sectionMap == null) {
            sectionMap = new HashMap<>();
        }

        Iterator<StaticSection> it = sectionMap.values().iterator();
        while (it.hasNext()) {
            StaticSection staticSection = (StaticSection) it.next();
            if (staticSection.getType() == 2) {
                equipSection = staticSection;
            } else if (staticSection.getType() == 3) {
                partSection = staticSection;
            } else if (staticSection.getType() == 4) {
                timeSection = staticSection;
            } else if (staticSection.getType() == 6) {
                militarySection = staticSection;
            } else if (staticSection.getType() == 8) {
                energyStoneSection = staticSection;
            }
        }
    }

    private void initCombat() {
        combatMap = new HashMap<>();
        List<StaticCombat> list = staticDataDao.selectCombat();
        int preId = 0;
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
    }

    private void initExplore() {
        exploreMap = new HashMap<>();
        List<StaticExplore> list = staticDataDao.selectExplore();
        int preId1 = 0;
        int preId2 = 0;
        int preId3 = 0;
        int preId4 = 0;
        int preId5 = 0;
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
            } else if (staticExplore.getType() == 4) {
                staticExplore.setPreId(preId4);
                preId4 = staticExplore.getExploreId();
            } else {
                staticExplore.setPreId(preId5);
                preId5 = staticExplore.getExploreId();
            }
            calcDropWeight(staticExplore);
            exploreMap.put(staticExplore.getExploreId(), staticExplore);
        }
    }

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

    public StaticSection getStaticSection(int sectionId) {
        return sectionMap.get(sectionId);
    }

    public StaticCombat getStaticCombat(int combatId) {
        return combatMap.get(combatId);
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

    public Map<Integer, StaticExplore> getAllExplore() {
        return exploreMap;
    }

    public StaticSection getMilitarySection() {
        return militarySection;
    }

    public StaticSection getEnergyStoneSection() {
        return energyStoneSection;
    }
}
