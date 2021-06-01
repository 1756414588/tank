package com.game.service.teaminstance;

/**
 * @author : LiFeng
 * @date :
 * @description :
 */
public class TeamConstant {
    // 未就绪状态
    public static final int UN_READY = -1;
    // 就绪状态
    public static final int READY = 0;
    // 队伍已解散
    public static final int DISMISS = 1;
    // 队伍人数最大限制
    public static final int TEAM_LIMIT = 3;
    // 对队伍的操作类型
    public static final int CREATE_TEAM = 1; //创建队伍
    public static final int FIND_TEAM = 2; //寻找队伍
    public static final int LEAVE_TEAM = 3; //离开队伍
    public static final int KICK_OUT = 4; //踢出队伍
    public static final int JOIN_TEAM = 5; //加入队伍
    public static final int DISMISS_TEAM = 6; //解散队伍
    public static final int SET_FORM = 7; //设置阵型
    public static final int CHANGE_ORDER = 8; //交换顺序
}