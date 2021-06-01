package com.game.domain.s;

import java.util.List;

/**
 * @author GuiJie
 * @description 描述
 * @created 2018/02/28 10:01
 */
public class StaticLaboratoryArea {

//    CREATE TABLE `s_laboratory_area` (
//            `areaId` int(11) NOT NULL COMMENT 'areaId：谍报机构区域的kid',
//            `name` varchar(255) NOT NULL COMMENT 'name：区域名称',
//            `ifUnlock` int(11) NOT NULL COMMENT 'ifUnlock：是否默认解锁 1：默认已解锁 2：默认未解锁',
//            `cost` int(11) NOT NULL COMMENT '解锁该区域所需金币数',
//            `task` varchar(255) NOT NULL COMMENT '任务库和权重，配置规则[taskId,weight]，对应s_laboratory_task表',
//            `refreshCost` int(11) NOT NULL COMMENT 'refreshCost:该地区任务刷新价格',
//    PRIMARY KEY (`areaId`)
//) ENGINE=InnoDB DEFAULT CHARSET=utf8;

    private int areaId;
    private String name;
    private int ifUnlock;
    private int cost;
    private List<List<Integer>> task;
    private int refreshCost;

    public int getAreaId() {
        return areaId;
    }

    public void setAreaId(int areaId) {
        this.areaId = areaId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public int getIfUnlock() {
        return ifUnlock;
    }

    public void setIfUnlock(int ifUnlock) {
        this.ifUnlock = ifUnlock;
    }

    public int getCost() {
        return cost;
    }

    public void setCost(int cost) {
        this.cost = cost;
    }

    public List<List<Integer>> getTask() {
        return task;
    }

    public void setTask(List<List<Integer>> task) {
        this.task = task;
    }

    public int getRefreshCost() {
        return refreshCost;
    }

    public void setRefreshCost(int refreshCost) {
        this.refreshCost = refreshCost;
    }
}
