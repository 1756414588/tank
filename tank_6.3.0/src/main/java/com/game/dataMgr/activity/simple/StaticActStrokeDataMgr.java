package com.game.dataMgr.activity.simple;

import com.game.dao.impl.s.StaticDataDao;
import com.game.dataMgr.BaseDataMgr;
import com.game.domain.s.StaticActStroke;
import com.game.util.LogUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.HashMap;
import java.util.Map;

/**
 * @author zhangdh
 * @ClassName: StaticActStrokeDataMgr
 * @Description: 闪击行动配置信息
 * @date 2018-01-17 18:53
 */
@Component
public class StaticActStrokeDataMgr extends BaseDataMgr {
    @Autowired
    private StaticDataDao staticDataDao;

    //KEY0:活动唯一ID, KEY1:唯一ID,VALUE:配置对象
    private Map<Integer, Map<Integer, StaticActStroke>> strokeMap = new HashMap<>();

    @Override
    public void init() {
        strokeMap.clear();
        for (StaticActStroke data : staticDataDao.selectStaticActStroke()) {
            Map<Integer, StaticActStroke> map = strokeMap.get(data.getActivityId());
            if (map == null) strokeMap.put(data.getActivityId(), map = new HashMap<Integer, StaticActStroke>());
            map.put(data.getId(), data);
        }
    }

    /**
     * 获取闪击行动活动配置信息
     * @param keyId
     * @return
     */
    public Map<Integer, StaticActStroke> getStaticActStroke(int keyId){
        Map<Integer, StaticActStroke> dataMap = strokeMap.get(keyId);
        if (dataMap==null){
            LogUtil.error("not found Act Stroke config, activityId :"+keyId);
        }
        return dataMap;
    }
}
