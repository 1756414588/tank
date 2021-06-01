package com.game.domain.sort;

import com.game.domain.p.Lord;
import com.game.util.UnsafeSortInfo;

/**
 * @author zhangdh
 * @ClassName: FormSort
 * @Description:
 * @date 2017-07-06 13:45
 */
public class FormSort implements UnsafeSortInfo.ISortVO<FormSort> {

    private String key;
    private long fight;
    private int mlr;

    public FormSort(Lord lord) {
        this.key = String.valueOf(lord.getLordId());
        this.fight = lord.getMaxFight();
        this.mlr = lord.getMilitaryRank();
    }

    @Override
    public String getKey() {
        return key;
    }

    @Override
    public long getValue() {
        return fight;
    }

    public int getMlr() {
        return mlr;
    }

    public void setMlr(int mlr) {
        this.mlr = mlr;
    }

    public long getFight() {
        return fight;
    }

    public void setFight(long fight) {
        this.fight = fight;
    }

    @Override
    public int compareTo(FormSort o) {
        if (mlr > o.mlr) {
            return -1;
        } else if (mlr < o.mlr) {
            return 1;
        } else {
            return fight > o.fight ? -1 : fight < o.fight ? 1 : 0;

        }
    }
}
