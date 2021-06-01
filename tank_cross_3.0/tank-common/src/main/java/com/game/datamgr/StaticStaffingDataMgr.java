package com.game.datamgr;

import com.game.dao.impl.s.StaticDataDao;
import com.game.domain.s.StaticStaffing;
import com.game.domain.s.StaticStaffingLv;
import com.game.domain.s.StaticStaffingWorld;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.Map;

/**
 * @author ZhangJun
 * @ClassName: StaticStaffingDataMgr @Description: TODO
 * @date 2016年3月10日 下午5:16:02
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
     */
    @Override
    public void init() {
        lvMap = staticDataDao.selectStaffingLv();
        staffingMap = staticDataDao.selectStaffing();
        worldMap = staticDataDao.selectStaffingWorld();
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

    public StaticStaffing calcStaffing(int lv, int ranks) {
        StaticStaffing staticStaffing = null;
        int id = 1;
        while (id <= 11) {
            StaticStaffing staffing = staffingMap.get(id);
            if (lv >= staffing.getStaffingLv() && ranks >= staffing.getRank()) {
                staticStaffing = staffing;
                id++;
                continue;
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
