package com.hundredcent.game.aop.persistence.player;

import com.hundredcent.game.aop.AopConstant;
import com.hundredcent.game.aop.persistence.IPersistenceConfig;

/**
 * @author Tandonghai
 * @date 2018-01-20 17:29
 */
public class PlayerPersistenceConfig implements IPersistenceConfig {

    public PlayerPersistenceConfig() {
    }

    /**
     * 设置配置数据
     *
     * @param config
     */
    public void setConfigData(PlayerPersistenceConfig config) {
        if (null == config) {
            return;
        }

        if (config.isOfflinePlayerQueueRefresh() != offlinePlayerQueueRefresh) {
            setOfflinePlayerQueueRefresh(config.isOfflinePlayerQueueRefresh());
        }
        if (config.getOfflinePlayerQueueRefreshPeriod() > 0) {
            setOfflinePlayerQueueRefreshPeriod(config.getOfflinePlayerQueueRefreshPeriod());
        }
        if (config.getIdleSaveSize() > 0) {
            setIdleSaveSize(config.getIdleSaveSize());
        }
        if (config.getIdleSaveThreshold() > 0) {
            setIdleSaveThreshold(config.getIdleSaveThreshold());
        }
        if (config.getPlayerSaveDelay() > 0) {
            setPlayerSaveDelay(config.getPlayerSaveDelay());
        }
        if (config.getCyclePlayerSavePeriod() > 0) {
            setCyclePlayerSavePeriod(config.getCyclePlayerSavePeriod());
        }
        if (config.getWeekInactiveDataSavePeriod() > 0) {
            setWeekInactiveDataSavePeriod(config.getWeekInactiveDataSavePeriod());
        }
        if (config.getImmediateSaveCount() > 0) {
            setImmediateSaveCount(config.getImmediateSaveCount());
        }
        if (config.getCycleSaveCount() > 0) {
            setCycleSaveCount(config.getCycleSaveCount());
        }
        if (config.getIdleSaveCount() > 0) {
            setIdleSaveCount(config.idleSaveCount);
        }
    }

    /**
     * 是否开启定时任务，去检查离线玩家的队列等信息是否改变，该值默认开启
     */
    protected boolean offlinePlayerQueueRefresh = true;

    /**
     * 检查离线玩家队列信息的定时任务执行周期，单位：秒
     */
    protected int offlinePlayerQueueRefreshPeriod = 5 * 60;

    /**
     * 闲时保存计算当前是否处于空闲的数值长度（该值决定最多取多少值参与计算）
     */
    protected int idleSaveSize = 60;

    /**
     * 闲时保存，判断当前是否处于空闲的阈值
     */
    protected int idleSaveThreshold = 30;

    /**
     * 服务器启动时，玩家数据首次保存延迟时间，单位：秒
     */
    protected int playerSaveDelay = 3 * 60;

    /**
     * 在线玩家数据保存周期，单位：秒
     */
    protected int onlinePlayerSavePeriod = 5 * 60;

    /**
     * 不超过一天不在线玩家一般单次保存数据周期，单位：秒
     */
    protected int cyclePlayerSavePeriod = 10 * AopConstant.MINUTE_SECONDS;

    /**
     * 超过一天不到一周不活跃玩家数据保存周期，单位：秒
     */
    protected int dayInactiveDataSavePeriod = 30 * AopConstant.MINUTE_SECONDS;

    /**
     * 超过一周到一个月不活跃玩家数据保存周期，单位：秒
     */
    protected int weekInactiveDataSavePeriod = 24 * AopConstant.HOUR_SECONDS;

    /**
     * 超过一个月不活跃玩家数据保存周期，单位：秒
     */
    protected int monthInactiveDataSavePeriod = 7 * 24 * AopConstant.HOUR_SECONDS;


    /**
     * 单次最大保存玩家数据数量
     */
    protected int immediateSaveCount = 500;

    /**
     * 不在线玩家单次定时任务最大保存数量
     */
    protected int cycleSaveCount = 100;

    /**
     * 闲时保存玩家单次定时任务最大保存数量
     */
    protected int idleSaveCount = 80;

    public boolean isOfflinePlayerQueueRefresh() {
        return offlinePlayerQueueRefresh;
    }

    public void setOfflinePlayerQueueRefresh(boolean offlinePlayerQueueRefresh) {
        this.offlinePlayerQueueRefresh = offlinePlayerQueueRefresh;
    }

    public int getOfflinePlayerQueueRefreshPeriod() {
        return offlinePlayerQueueRefreshPeriod;
    }

    public void setOfflinePlayerQueueRefreshPeriod(int offlinePlayerQueueRefreshPeriod) {
        this.offlinePlayerQueueRefreshPeriod = offlinePlayerQueueRefreshPeriod;
    }

    @Override
    public int getIdleSaveSize() {
        return idleSaveSize;
    }

    public void setIdleSaveSize(int idleSaveSize) {
        this.idleSaveSize = idleSaveSize;
    }

    @Override
    public int getIdleSaveThreshold() {
        return idleSaveThreshold;
    }

    public void setIdleSaveThreshold(int idleSaveThreshold) {
        this.idleSaveThreshold = idleSaveThreshold;
    }

    public int getPlayerSaveDelay() {
        return playerSaveDelay;
    }

    public void setPlayerSaveDelay(int playerSaveDelay) {
        this.playerSaveDelay = playerSaveDelay;
    }

    public int getCyclePlayerSavePeriod() {
        return cyclePlayerSavePeriod;
    }

    public void setCyclePlayerSavePeriod(int cyclePlayerSavePeriod) {
        this.cyclePlayerSavePeriod = cyclePlayerSavePeriod;
    }

    public int getOnlinePlayerSavePeriod() {
        return onlinePlayerSavePeriod;
    }

    public void setOnlinePlayerSavePeriod(int onlinePlayerSavePeriod) {
        this.onlinePlayerSavePeriod = onlinePlayerSavePeriod;
    }

    public int getWeekInactiveDataSavePeriod() {
        return weekInactiveDataSavePeriod;
    }

    public void setWeekInactiveDataSavePeriod(int weekInactiveDataSavePeriod) {
        this.weekInactiveDataSavePeriod = weekInactiveDataSavePeriod;
    }

    public int getMonthInactiveDataSavePeriod() {
        return monthInactiveDataSavePeriod;
    }

    public void setMonthInactiveDataSavePeriod(int monthInactiveDataSavePeriod) {
        this.monthInactiveDataSavePeriod = monthInactiveDataSavePeriod;
    }

    public int getImmediateSaveCount() {
        return immediateSaveCount;
    }

    public void setImmediateSaveCount(int immediateSaveCount) {
        this.immediateSaveCount = immediateSaveCount;
    }

    public int getCycleSaveCount() {
        return cycleSaveCount;
    }

    public void setCycleSaveCount(int cycleSaveCount) {
        this.cycleSaveCount = cycleSaveCount;
    }

    public int getIdleSaveCount() {
        return idleSaveCount;
    }

    public void setIdleSaveCount(int idleSaveCount) {
        this.idleSaveCount = idleSaveCount;
    }

    public int getDayInactiveDataSavePeriod() {
        return dayInactiveDataSavePeriod;
    }

    public void setDayInactiveDataSavePeriod(int dayInactiveDataSavePeriod) {
        this.dayInactiveDataSavePeriod = dayInactiveDataSavePeriod;
    }

    @Override
    public String toString() {
        return "PlayerPersistenceConfig [offlinePlayerQueueRefresh=" + offlinePlayerQueueRefresh + ", offlinePlayerQueueRefreshPeriod=" + offlinePlayerQueueRefreshPeriod + ", idleSaveSize=" + idleSaveSize
                + ", idleSaveThreshold=" + idleSaveThreshold + ", playerSaveDelay=" + playerSaveDelay + ", onlinePlayerSavePeriod=" + onlinePlayerSavePeriod + ", cyclePlayerSavePeriod=" + cyclePlayerSavePeriod
                + ", dayInactiveDataSavePeriod=" + dayInactiveDataSavePeriod + ", weekInactiveDataSavePeriod=" + weekInactiveDataSavePeriod + ", monthInactiveDataSavePeriod=" + monthInactiveDataSavePeriod
                + ", immediateSaveCount=" + immediateSaveCount + ", cycleSaveCount=" + cycleSaveCount + ", idleSaveCount=" + idleSaveCount + "]";
    }


}
