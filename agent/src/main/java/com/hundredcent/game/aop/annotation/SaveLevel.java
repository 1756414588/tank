package com.hundredcent.game.aop.annotation;

/**
 * 数据保存优先级枚举类
 *
 * @author Tandonghai
 * @date 2018-01-12 16:55
 */
public enum SaveLevel {

    /**
     * 立即保存军团，跟player不一样 军团会有最多4分钟的保存延时
     */
    IMMEDIATE_PARTY,

    /**
     * 立即保存，将在下次定时保存任务执行时保存
     */
    IMMEDIATE,

    /**
     * 闲时保存，表示服务器保存逻辑只要处于闲置（是否处于限制状态判断受具体的算法影响），立即保存
     */
    IDLE,

    /**
     * 不在线玩家，数据变动可能性很低的数据，对应该等级
     */
    CYCLE,

    /**
     * 服务器运行期间，基本不保存
     */
    NEVER, ;

}
