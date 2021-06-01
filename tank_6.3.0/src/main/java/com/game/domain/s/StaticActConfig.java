package com.game.domain.s;

import java.util.List;

/**
 * @author GuiJie
 * @description 描述
 * @created 2018/04/21 13:49
 */
public class StaticActConfig {

//    CREATE TABLE `s_act_config` (
//            `configId` int(11) NOT NULL COMMENT '配置id',
//            `activityId` int(11) NOT NULL COMMENT '活动id',
//            `awardId` int(11) unsigned NOT NULL COMMENT '奖励id',
//            `data1` int(11) unsigned NOT NULL COMMENT '配置1，配置为单个数值或者不配置',
//            `data2` varchar(255) NOT NULL COMMENT '配置2，配置类型为字符串型或者不配',
//            `desc` varchar(255) NOT NULL COMMENT '纯注释',
//    PRIMARY KEY (`configId`)
//) ENGINE=InnoDB DEFAULT CHARSET=utf8;

    private int configId;
    private int activityId;
    private int awardId;
    private int data1;
    private List<Integer> data2;


    public int getConfigId() {
        return configId;
    }

    public void setConfigId(int configId) {
        this.configId = configId;
    }

    public int getActivityId() {
        return activityId;
    }

    public void setActivityId(int activityId) {
        this.activityId = activityId;
    }

    public int getAwardId() {
        return awardId;
    }

    public void setAwardId(int awardId) {
        this.awardId = awardId;
    }

    public int getData1() {
        return data1;
    }

    public void setData1(int data1) {
        this.data1 = data1;
    }

    public List<Integer> getData2() {
        return data2;
    }

    public void setData2(List<Integer> data2) {
        this.data2 = data2;
    }
}
