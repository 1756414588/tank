package com.game.constant;

public class CrossPartyConst {
    /**
     * 跨服军团报名要求排名前三
     */
    public static int reg_rank = 3;

    public static int group_A = 1;
    public static int group_B = 2;
    public static int group_C = 3;
    public static int group_D = 4;

    public static int group_E = 5;

    public static int WIN_JIFEN = 30;
    public static int FAIL_JIFEN = 10;

    public static int FINAL_WIN_JIFEN = 60;
    public static int FINAL_FAIL_JIFEN = 20;

    // 小组赛前6名
    public static int group_up_q_rank = 6;

    public static String groupName = "小组赛";
    public static String finalName = "决赛";

    public static String groupA = "A";
    public static String groupB = "B";
    public static String groupC = "C";
    public static String groupD = "D";

    public static int MaxJifen = 5000;

    /**
     * 阶段
     *
     * @author wanyi
     */
    public interface STAGE {
        int STAGE_1 = 1; // 第一天
        int STAGE_2 = 2; // 第二天
        int STAGE_3 = 3; // 第三天
        int STAGE_4 = 4; // 第四天
        int STAGE_5 = 5; // 第五天
    }

    /**
     * 不能领取
     */
    public static int receive_reward_cant = 1;
    /**
     * 可以领取
     */
    public static int receive_reward_can = 2;
    /**
     * 已经领取
     */
    public static int receive_reward_haveReceive = 3;

    public interface State {
        /**
         * 开始
         */
        int begin = 1;
        /**
         * 结束
         */
        int end = 2;
    }

    public interface CP_FAME_TYPE {
        int top1 = 1;
        int top2 = 2;
        int top3 = 3;
        int jifenTop1 = 4;
        int lianshengTop1 = 5;
    }
}
