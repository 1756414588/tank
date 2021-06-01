package com.game.domain.sort;

/**
 * @author zhangdh
 * @ClassName: IntValueSort
 * @Description:
 * @date 2017-07-05 17:19
 */
public class IntValueSort implements Comparable<IntValueSort> {
    private int v;

    public IntValueSort(int v) {
        this.v = v;
    }

    @Override
    public int compareTo(IntValueSort o) {
        return v > o.v ? 1 : v < o.v ? -1 : 0;
    }
}
