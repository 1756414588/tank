package com.game.dataMgr;

import com.game.dao.impl.s.StaticDataDao;
import com.game.domain.s.StaticPeakCost;
import com.game.domain.s.StaticPeakLv;
import com.game.domain.s.StaticPeakSkill;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * @author yeding
 * @create 2019/7/20 2:44
 * @decs
 */
@Component
public class StaticPeakMgr extends BaseDataMgr {
    @Autowired
    private StaticDataDao staticDataDao;


    private Map<Integer, StaticPeakLv> peakLvMap = new HashMap<>();
    private Map<Integer, Map<Integer, StaticPeakCost>> costMap = new HashMap<>();
    private Map<Integer, StaticPeakSkill> peakSkillMap = new HashMap<>();
    public StaticPeakSkill initPeakSkill;

    @Override
    public void init() {
        peakLvMap.clear();
        costMap.clear();
        peakSkillMap.clear();
        this.peakLvMap = staticDataDao.selectPeakLv();
        List<StaticPeakCost> staticPeakCosts = staticDataDao.selectPeakCost();
        for (StaticPeakCost staticPeakCost : staticPeakCosts) {
            Map<Integer, StaticPeakCost> cs = costMap.get(staticPeakCost.getSkillId());
            if (cs == null) {
                cs = new HashMap<>();
                costMap.put(staticPeakCost.getSkillId(), cs);
            }
            cs.put(staticPeakCost.getLoc(), staticPeakCost);
        }
        this.peakSkillMap = staticDataDao.selectPeakSkill();
        for (StaticPeakSkill staticPeakSkill : peakSkillMap.values()) {
            if (staticPeakSkill.getBefore() == null || staticPeakSkill.getBefore().isEmpty()) {
                this.initPeakSkill = staticPeakSkill;
            }
        }
    }

    /**
     * 获取巅峰等级配置
     *
     * @param level
     * @return
     */
    public StaticPeakLv getPeakLv(int level) {
        return peakLvMap.get(level);
    }

    /**
     * 获取消耗
     *
     * @param skillId
     * @return
     */
    public Map<Integer, StaticPeakCost> getPeakCost(int skillId) {
        return costMap.get(skillId);
    }

    public StaticPeakSkill getPeakSkill(int id) {
        return peakSkillMap.get(id);
    }

}
