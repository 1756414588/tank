/**
 * @Title: StaticBuildingDataMgr.java @Package com.game.dataMgr @Description: TODO
 * @author ZhangJun
 * @date 2015年7月20日 下午3:47:31
 * @version V1.0
 */
package com.game.datamgr;

import com.game.dao.impl.s.StaticDataDao;
import com.game.domain.s.StaticBuilding;
import com.game.domain.s.StaticBuildingLv;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * @author ZhangJun
 * @ClassName: StaticBuildingDataMgr @Description: TODO
 * @date 2015年7月20日 下午3:47:31
 */
@Component
public class StaticBuildingDataMgr extends BaseDataMgr {
    @Autowired
    private StaticDataDao staticDataDao;

    private Map<Integer, StaticBuilding> buildingMap;

    /**
     * @Fields levelMap : MAP<buildingId, MAP<buildingLevel, StaticBuildingLevel>>
     */
    private Map<Integer, Map<Integer, StaticBuildingLv>> levelMap;

    /**
     * Overriding: init
     */
    @Override
    public void init() {
        buildingMap = staticDataDao.selectBuilding();
        initLevel();
    }

    private void calcLevelAdd(List<StaticBuildingLv> list) {
        for (StaticBuildingLv buildingLevel : list) {
            int preLv = buildingLevel.getLevel() - 1;
            if (preLv == 0) {
                buildingLevel.setStoneOutAdd(buildingLevel.getStoneOut());
                buildingLevel.setIronOutAdd(buildingLevel.getIronOut());
                buildingLevel.setOilOutAdd(buildingLevel.getOilOut());
                buildingLevel.setCopperOutAdd(buildingLevel.getCopperOut());
                buildingLevel.setSiliconOutAdd(buildingLevel.getSiliconOut());

                buildingLevel.setStoneMaxAdd(buildingLevel.getStoneMax());
                buildingLevel.setIronMaxAdd(buildingLevel.getIronMax());
                buildingLevel.setOilMaxAdd(buildingLevel.getOilMax());
                buildingLevel.setCopperMaxAdd(buildingLevel.getCopperMax());
                buildingLevel.setSiliconMaxAdd(buildingLevel.getSiliconMax());
            } else {

                StaticBuildingLv pre = levelMap.get(buildingLevel.getBuildingId()).get(preLv);
                if (pre == null) {
                    continue;
                }

                buildingLevel.setStoneOutAdd(buildingLevel.getStoneOut() - pre.getStoneOut());
                buildingLevel.setIronOutAdd(buildingLevel.getIronOut() - pre.getIronOut());
                buildingLevel.setOilOutAdd(buildingLevel.getOilOut() - pre.getOilOut());
                buildingLevel.setCopperOutAdd(buildingLevel.getCopperOut() - pre.getCopperOut());
                buildingLevel.setSiliconOutAdd(buildingLevel.getSiliconOut() - pre.getSiliconOut());

                buildingLevel.setStoneMaxAdd(buildingLevel.getStoneMax() - pre.getStoneMax());
                buildingLevel.setIronMaxAdd(buildingLevel.getIronMax() - pre.getIronMax());
                buildingLevel.setOilMaxAdd(buildingLevel.getOilMax() - pre.getOilMax());
                buildingLevel.setCopperMaxAdd(buildingLevel.getCopperMax() - pre.getCopperMax());
                buildingLevel.setSiliconMaxAdd(buildingLevel.getSiliconMax() - pre.getSiliconMax());
            }
        }
    }

    private void initLevel() {
        levelMap = new HashMap<Integer, Map<Integer, StaticBuildingLv>>();
        List<StaticBuildingLv> list = staticDataDao.selectBuildingLv();
        for (StaticBuildingLv buildingLevel : list) {
            Map<Integer, StaticBuildingLv> indexIdMap = levelMap.get(buildingLevel.getBuildingId());
            if (indexIdMap == null) {
                indexIdMap = new HashMap<>();
                levelMap.put(buildingLevel.getBuildingId(), indexIdMap);
            }

            indexIdMap.put(buildingLevel.getLevel(), buildingLevel);
        }

        calcLevelAdd(list);
    }

    public StaticBuilding getStaticBuilding(int buildingId) {
        return buildingMap.get(buildingId);
    }

    public StaticBuildingLv getStaticBuildingLevel(int buildingId, int buildLevel) {
        Map<Integer, StaticBuildingLv> indexIdMap = levelMap.get(buildingId);
        if (indexIdMap != null) {
            return indexIdMap.get(buildLevel);
        }
        return null;
    }
}
