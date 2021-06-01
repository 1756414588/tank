package com.game.dataMgr.activity;

import com.game.constant.ActivityConst;
import com.game.dao.impl.s.StaticDataDao;
import com.game.dataMgr.BaseDataMgr;
import com.game.dataMgr.StaticActivityDataMgr;
import com.game.domain.s.StaticActRedBag;
import com.game.domain.s.StaticActivityProp;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.*;

/**
 * @author zhangdh
 * @ClassName: StaticActRedBagDataMgr
 * @Description:
 * @date 2018-02-01 16:14
 */
@Component
public class StaticActRedBagDataMgr extends BaseDataMgr {

    @Autowired
    private StaticDataDao staticDataDao;

    @Autowired
    private StaticActivityDataMgr staticActivityDataMgr;

    /**
     * KEY0:活动ID, KEY1: 充值档位, VALUE:充值信息
     */
    private Map<Integer, TreeMap<Integer, StaticActRedBag>> stageMap = new HashMap<>();
    /**
     * KEY0:活动ID, KEY1: 充值金额, VALUE:充值信息
     */
    private Map<Integer, TreeMap<Integer, StaticActRedBag>> moneyMap = new HashMap<>();

    /**
     *根据红包金额进行由大到小的排序
     */
    private List<StaticActivityProp> redBagProps = new ArrayList<>();

    @Override
    public void init() {
        stageMap.clear();
        moneyMap.clear();
        for (StaticActRedBag data : staticDataDao.selectStaticActRedBag()) {
            TreeMap<Integer, StaticActRedBag> sMap = stageMap.get(data.getActivityId());
            if (sMap == null) stageMap.put(data.getActivityId(), sMap = new TreeMap<Integer, StaticActRedBag>());
            sMap.put(data.getStage(), data);

            TreeMap<Integer, StaticActRedBag> mMap = moneyMap.get(data.getActivityId());
            if (mMap == null) moneyMap.put(data.getActivityId(), mMap = new TreeMap<Integer, StaticActRedBag>());
            mMap.put(data.getMoney(), data);
        }

        redBagProps.clear();
        for (Map.Entry<Integer, StaticActivityProp> entry : staticActivityDataMgr.getActivityPropMap().entrySet()) {
            StaticActivityProp data = entry.getValue();
            if (data.getActivityId() == ActivityConst.ACT_GRAB_RED_BAGS) {
                redBagProps.add(data);
            }
        }

        Collections.sort(redBagProps, new Comparator<StaticActivityProp>() {
            @Override
            public int compare(StaticActivityProp o1, StaticActivityProp o2) {
                if (o1.getPrice() > o2.getPrice()) {
                    return -1;
                } else if (o1.getPrice() < o2.getPrice()) {
                    return 1;
                } else {
                    return o1.getId() < o2.getId() ? -1 : o2.getId() > o2.getId() ? 1 : 0;
                }
            }
        });

    }

    public TreeMap<Integer, StaticActRedBag> getStageMap(int activityId) {
        return stageMap.get(activityId);
    }

    public TreeMap<Integer, StaticActRedBag> getMoneyMap(int activityId) {
        return moneyMap.get(activityId);
    }

    public List<StaticActivityProp> getRedBagProps() {
        return redBagProps;
    }

}
