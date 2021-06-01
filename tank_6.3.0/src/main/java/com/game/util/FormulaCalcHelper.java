package com.game.util;

/**
 * @author zhangdh
 * @ClassName: FormulaCalcHelper
 * @Description: 公式辅助
 * @date 2017-06-14 11:46
 */
public final class FormulaCalcHelper {

    /**
     * 飞艇相关的公式
     */
    public final static class Airship{

        /**
         * 修复飞艇需要的资源，公式:
         * @param lv 世界等级
         * @param baseCount
         * @return
         */
        public static int calcRebuildResouceCount(int lv, int baseCount) {
            double f = (Math.pow(lv, 2) + 1) * (Math.pow(lv, 0.5) + 1);
            return (int) (baseCount * f);
        }


    }

}
