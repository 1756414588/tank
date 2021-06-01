package com.hundredcent.game.aop.domain;

/**
 * domain类接口的顶级接口，申明一些domain类接口都需要实现的方法，该类不直接暴露在外，避免domain类直接实现该类
 *
 * @author Tandonghai
 * @date 2018-01-20 17:06
 */
public interface ISave {

    /**
     * 返回对象唯一标识id
     *
     * @return
     */
    long objectId();

    /**
     * 定时刷新一些重要数据信息，用于判断是否需要提升保存优先级
     *
     * @return
     */
    boolean refreshImportant();

    /**
     * 获取下次保存时间
     *
     * @return
     */
    int getNextSaveTime();

    /**
     * 设置下次数据保存时间
     *
     * @param nextSaveTime
     */
    void nextSaveTime(int nextSaveTime);

    /**
     * 是否需要立即保存数据，该值与下次保存时间无关，仅与当前数据保存优先级有关
     *
     * @return
     */
    boolean isImmediateSave();

    /**
     * 判断是否是长期不用变更的死数据
     *
     * @return
     */
    boolean isActive();
}
