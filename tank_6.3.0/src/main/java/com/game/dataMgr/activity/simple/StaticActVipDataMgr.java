package com.game.dataMgr.activity.simple;

import com.game.dao.impl.s.StaticDataDao;
import com.game.dataMgr.BaseDataMgr;
import com.game.domain.s.StaticActVipCount;
import com.game.util.LogUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.HashMap;
import java.util.Map;

/**
 * @author zhangdh
 * @ClassName: StaticActVipDataMgr
 * @Description: 大咖带队活动配置
 * @date 2018-01-17 17:14
 */
@Component
public class StaticActVipDataMgr extends BaseDataMgr {

    @Autowired
    private StaticDataDao staticDataDao;

    //KEY0:活动唯一ID, KEY1:VIP等级, VALUE:活动配置
    private Map<Integer, Map<Integer, StaticActVipCount>> actMap = new HashMap<>();

    @Override
    public void init() {
        actMap.clear();
        for (StaticActVipCount data : staticDataDao.selectStaticActVipCount()) {
            Map<Integer, StaticActVipCount> vipMap = actMap.get(data.getActivityId());
            if (vipMap == null) actMap.put(data.getActivityId(), vipMap = new HashMap<Integer, StaticActVipCount>());
            vipMap.put(data.getVip(), data);
        }
    }

    /**
     * 获取活动配置信息
     *
     * @param activityId
     * @return
     */
    public Map<Integer, StaticActVipCount> getActVipCountMap(int activityId) {
        Map<Integer, StaticActVipCount> dataMap = actMap.get(activityId);
        if (dataMap == null) {
            LogUtil.error(String.format("not found act vip count config activityId :%d", activityId));
        }
        return dataMap;
    }
}
