package com.hundredcent.game.aop.domain;

/**
 * @author Tandonghai
 * @date 2018-01-12 18:29
 */
public interface IPlayerSave extends ISave {
    
    
    /**
     * 玩家当前是否在线
     *
     * @return
     */
    boolean canIdelSave();

    /**
     * 玩家当前是否在线
     *
     * @return
     */
    boolean isOnline();

    /**
     * 获取玩家上次离线时间
     *
     * @return
     */
    int getOfflineTime();

    /**
     * 玩家登录
     *
     * @param now
     */
    void playerLogin(int now);

    /**
     * 玩家登出
     */
    void playerLogout();
}
