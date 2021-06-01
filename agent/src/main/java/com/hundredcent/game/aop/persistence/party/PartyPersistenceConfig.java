package com.hundredcent.game.aop.persistence.party;

import com.hundredcent.game.aop.persistence.IPersistenceConfig;

/**
 * @author dingwenyuan
 * @date 2018-01-20 17:29
 */
public class PartyPersistenceConfig implements IPersistenceConfig {

    public PartyPersistenceConfig() {
    }

    /**
     * 设置配置数据
     *
     * @param config
     */
    public void setConfigData(PartyPersistenceConfig config) {
        if (null == config) {
            return;
        }

        if (config.getIdleSaveSize() > 0) {
            setIdleSaveSize(config.getIdleSaveSize());
        }
        if (config.getIdleSaveThreshold() > 0) {
            setIdleSaveThreshold(config.getIdleSaveThreshold());
        }

        if (config.getPartySavePeriod() > 0) {
            setPartySavePeriod(config.getPartySavePeriod());
        }

        if (config.getMaxSaveCount() > 0) {
            setMaxSaveCount(config.getMaxSaveCount());
        }

    }

    /**
     * 闲时保存计算当前是否处于空闲的数值长度（该值决定最多取多少值参与计算）
     */
    protected int idleSaveSize = 60;

    /**
     * 闲时保存，判断当前是否处于空闲的阈值
     */
    protected int idleSaveThreshold = 30;

    /**
     * 默认数据保存周期，单位：秒
     */
    protected int partySavePeriod = 222;

    /**
     * 单次最大任务数量
     */
    protected int maxSaveCount = 80;

    public int getMaxSaveCount() {
        return maxSaveCount;
    }

    public void setMaxSaveCount(int maxSaveCount) {
        this.maxSaveCount = maxSaveCount;
    }

    public int getPartySavePeriod() {
        return partySavePeriod;
    }

    public void setPartySavePeriod(int partySavePeriod) {
        this.partySavePeriod = partySavePeriod;
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

    @Override
    public String toString() {
        return "PartyPersistenceConfig{idleSaveSize=" + idleSaveSize + ", idleSaveThreshold=" + idleSaveThreshold + ", partySavePeriod=" + partySavePeriod + ", maxSaveCount=" + maxSaveCount + "}";
    }

}
