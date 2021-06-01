package com.game.datamgr;

import com.game.dao.impl.s.StaticDataDao;
import com.game.domain.PEnergyCore;
import com.game.domain.s.StaticCoreAward;
import com.game.domain.s.StaticCoreExp;
import com.game.domain.s.StaticCoreMaterial;
import com.game.fight.domain.AttrData;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * @author yeding
 * @create 2019/3/26 17:53
 * desc:能源核心配置
 */
@Component
public class StaticCoreDataMgr extends BaseDataMgr {

    @Autowired
    private StaticDataDao staticDataDao;

    private Map<Integer, Map<Integer, StaticCoreExp>> expMap = new HashMap<>();

    private Map<Integer, StaticCoreAward> AwardMap = new HashMap<>();

    @Override
    public void init() {
        expMap.clear();
        AwardMap.clear();
        List<StaticCoreExp> expList = this.staticDataDao.selectStaticCoreExp();
        if (expList != null && !expList.isEmpty()) {
            for (StaticCoreExp staticCoreExp : expList) {
                Map<Integer, StaticCoreExp> e_map = expMap.get(staticCoreExp.getLevel());
                if (e_map == null) {
                    e_map = new HashMap<>();
                    expMap.put(staticCoreExp.getLevel(), e_map);
                }
                e_map.put(staticCoreExp.getSection(), staticCoreExp);
            }
        }
        AwardMap = this.staticDataDao.selectStaticCoreAward();
    }

    /**
     * 获取所有奖励配置
     *
     * @return
     */
    public Map<Integer, StaticCoreAward> getAllAwardConfig() {
        return AwardMap;
    }

    /**
     * 根据等级获取全部阶段.
     *
     * @param level
     * @return
     */
    public Map<Integer, StaticCoreExp> getCoreExpBylV(int level) {
        return expMap.get(level);
    }
}
