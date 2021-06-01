package com.game.datamgr;

import com.game.dao.impl.s.StaticDataDao;
import com.game.domain.s.StaticBuff;
import com.game.domain.s.StaticSkill;
import com.game.domain.s.StaticTank;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

@Component
public class StaticTankDataMgr extends BaseDataMgr {
    @Autowired
    private StaticDataDao staticDataDao;

    private Map<Integer, StaticTank> tankMap;

    private Map<Integer, StaticBuff> buffMap;

    private Map<Integer, StaticSkill> skillMap;

    /**
     * Overriding: init
     */
    @Override
    public void init() {
        // TODO Auto-generated method stub
        tankMap = staticDataDao.selectTank();
        buffMap = staticDataDao.selectBuff();
        skillMap = staticDataDao.selectSkill();
        initTankAura();
    }

    public void initTankAura() {
        Iterator<StaticTank> it = tankMap.values().iterator();
        while (it.hasNext()) {
            StaticTank staticTank = (StaticTank) it.next();
            List<Integer> aura = staticTank.getAura();
            ArrayList<StaticBuff> list = new ArrayList<>();
            if (aura != null && !aura.isEmpty()) {
                for (Integer buffId : aura) {
                    list.add(buffMap.get(buffId));
                }
            }
            staticTank.setBuffs(list);
        }
    }

    public StaticTank getStaticTank(int tankId) {
        return tankMap.get(tankId);
    }

    public StaticSkill getStaticSkill(int skillId) {
        return skillMap.get(skillId);
    }

    public Map<Integer, StaticTank> getTankMap() {
        return tankMap;
    }
}
