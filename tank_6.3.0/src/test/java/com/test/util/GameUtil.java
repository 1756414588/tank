package com.test.util;

/**
 * 用于日长分析问题
 */
public class GameUtil {


    /**
     * 转换坐标
     *
     * @param pos
     * @return
     */
    public static int[] getPoint(int pos) {
        return new int[]{pos % 600, pos / 600};
    }

    /**
     * 获取玩家serverid
     *
     * @param lordId
     * @return
     */
    public static int getServerId(long lordId) {
        return (int) (lordId % 100000000000L / 10000000L);
    }

    /**
     * 获取渠道id
     *
     * @param lordId
     * @return
     */
    public static int getPlatNo(long lordId) {
        return (int) (lordId / 100000000000L);
    }
}
