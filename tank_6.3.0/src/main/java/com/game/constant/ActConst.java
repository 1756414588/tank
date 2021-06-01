package com.game.constant;

/**
 * @author zhangdh
 * @ClassName: ActConst
 * @Description: 荣誉勋章活动常量
 * @date 2017-10-30 15:38
 */
public class ActConst {

    public static int STATUS_IDX0 = 0;
    public static int STAUTS_IDX1 = 1;
    public static int STAUTS_IDX2 = 2;
    public static int STAUTS_IDX3 = 3;

    /**
     * 用来定义Activity对象的statusMap key值
     * {@link com.game.domain.p.Activity statusMap}
     */
//    public static int STATUS_MAP_KEY0 = 0;
//    public static int STATUS_MAP_KEY1 = 1;
//    public static int STATUS_MAP_KEY2 = 2;
//    public static int STATUS_MAP_KEY3 = 3;
//    public static int STATUS_MAP_KEY4 = 4;
//    public static int STATUS_MAP_KEY5 = 5;

    /**
     * 荣誉勋章活动常量定义
     */
    public static class ActMedalofhonor {
        /**
         * 单个坦克宝箱的类型
         */
        public static int TYPE_0 = 0;

        /**
         * 坦克集群宝箱类型
         */
        public static int TYPE_1 = 1;

        /**
         * 单只鸡类型
         */
        public static int TYPE_2 = 2;

        /**
         * 全家桶类型
         */
        public static int TYPE_3 = 3;

        /**
         * 玩家上榜的最低积分
         */
        public static int RANK_SCORE_LESS = 10;

        /**
         * 记录本次活动周期是否已经初始化过荣誉勋章数据
         */
        public static int STATUS_MAP_DATA_INIT = 3;

        /**
         * 记录玩家积分
         */
        public static int STATUS_MAP_SCORE = 4;

        /**
         * VALUE值为1标识已经领取过排名奖励
         */
        public static int STATUS_MAP_RANK_REWARD = 5;

    }

    /**
     * 大富翁活动
     */
    public static class ActMonopolyConst {

        /**
         * 格子长度
         */
        public static int GRID_SIZE = 24;

        /**
         * 空事件
         */
        public static int EVT_EMPTY = 1;

        /**
         * 原点事件ID
         */
        public static int EVT_FINISH = 2;

        /**
         * 获得奖励事件
         */
        public static int EVT_BOX = 3;

        /**
         * 购买事件
         */
        public static int EVT_BUY = 4;

        /**
         * 对话事件
         */
        public static int EVT_DLG = 5;


        /**
         * 玩家当前位置
         */
        public static int STATUS_MAP_POS = 0;

        /**
         * 骰子连续丢中空事件的次数
         */
        public static int STATUS_MAP_EMPTY_CONT = 1;

        /**
         * 本轮游戏中当前购买ID
         */
        public static int STATUS_MAP_BUY_ID = 2;

        /**
         * 已经完成的圈数
         */
        public static int SAVE_MAP_FINISH_COUNT = 0;

        /**
         * 玩家能量
         */
        public static int SAVE_MAP_ENERGY = 1;

        /**
         * 领取免费精力时间
         */
        public static int SAVE_MAP_DRAW_FREE_ENERGY = 2;

        //对话框子事件类型
        public static class EvtDlg {
            //战斗(1)，六芒星(2)，神秘(3)，帐篷(4)，金币(5)
            public static int FIGHT = 1;
            public static int MAGIC = 2;
            public static int MYSTERY = 3;
            public static int TENT = 4;
            public static int GOLD = 5;
        }

        //宝箱类
        public static class EvtBox {
            //配件(1)，军备(2)，装备(3)，能晶(4)，勋章(5)，资源(6)，将领(7)，坦克(8)，骰子(9)
            public static int PART = 1;
            public static int LORD_EQUIP = 2;
            public static int EQUIP = 3;
            public static int ENERGY_STONE = 4;
            public static int MEDAL = 5;
            public static int RESOURCE = 6;
            public static int HERO = 7;
            public static int TANK = 8;
            public static int FIX_DICE = 9;
        }

        //购买类商店
        public static class EvtBuy{
            public static int DEFUALT = 1;
        }

    }
}
