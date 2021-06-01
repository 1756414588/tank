package com.test.tools.domain;

import com.game.domain.s.StaticActivityPlan;
import com.game.util.UnsafeSortInfo;

/**
 * @author zhangdh
 * @ClassName: ActivityPlanSort
 * @Description:
 * @date 2017-11-11 14:20
 */
public class ActivityPlanSort implements UnsafeSortInfo.ISortVO<ActivityPlanSort> {
    public StaticActivityPlan plan;

    @Override
    public String getKey() {
        return String.valueOf(plan.getKeyId());
    }

    @Override
    public long getValue() {
        return 0;
    }

    @Override
    public int compareTo(ActivityPlanSort o) {
        if (plan.getBeginTime().before(o.plan.getBeginTime())) {
            return -1;
        } else if (plan.getBeginTime().after(o.plan.getBeginTime())) {
            return 1;
        } else {
            if (plan.getKeyId() < o.plan.getKeyId()) {
                return -1;
            } else if (plan.getKeyId() > o.plan.getKeyId()) {
                return 1;
            } else {
                return 0;
            }
        }
    }
}
