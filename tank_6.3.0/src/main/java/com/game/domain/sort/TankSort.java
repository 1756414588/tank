package com.game.domain.sort;

import com.game.domain.p.Tank;
import com.game.domain.s.StaticTank;

/**
 * @author zhangdh
 * @ClassName: TankSort
 * @Description:
 * @date 2017-06-21 11:40
 */
public class TankSort extends Tank implements Comparable<TankSort> {

    private StaticTank staticTank;
    private int fight;

    public TankSort(StaticTank staticTank, int count, int fight) {
        super(staticTank.getTankId(), count, 0);
        this.staticTank = staticTank;
        this.fight = fight;
    }

    public StaticTank getStaticTank() {
        return staticTank;
    }

    public void setStaticTank(StaticTank staticTank) {
        this.staticTank = staticTank;
    }

    @Override
    public int compareTo(TankSort o) {
        return o == null || fight > o.fight ? -1 : fight < o.fight ? 1 : 0;
    }

    @Override
    public String toString() {
        return "TankSort{" +
                "tankId=" + tankId +
                ", count=" + count +
                ", fight=" + fight +
                '}';
    }
}
