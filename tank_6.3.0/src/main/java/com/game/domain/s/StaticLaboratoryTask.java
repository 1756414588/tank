package com.game.domain.s;

import java.util.List;

/**
 * @author GuiJie
 * @description 描述
 * @created 2018/02/28 10:07
 */
public class StaticLaboratoryTask {
//
//    CREATE TABLE `s_laboratory_task` (
//            `taskId` int(11) NOT NULL COMMENT 'taskId：task表的主键',
//            `name` varchar(255) NOT NULL COMMENT 'name:任务名称',
//            `quality` int(11) NOT NULL COMMENT 'quality:任务的品质和文字颜色',
//            `finishTime` int(11) NOT NULL COMMENT 'finishTime:任务完成所需时间 单位：s',
//            `mustProduce` varchar(255) NOT NULL COMMENT 'mustProduce: 任务的固定产出 配置规则:[type,id,amount]',
//            `couldProduce` varchar(255) NOT NULL COMMENT 'couldProduce:任务的随机产出 配置规则;[type,id,amount,weight]',
//            `description` varchar(255) NOT NULL COMMENT 'description:任务描述',
//    PRIMARY KEY (`taskId`)
//) ENGINE=InnoDB DEFAULT CHARSET=utf8;


    private int taskId;
    private String name;
    private int finishTime;
    private List<List<Integer>> mustProduce;
    private  List<List<Integer>>  couldProduce;

    public int getTaskId() {
        return taskId;
    }

    public void setTaskId(int taskId) {
        this.taskId = taskId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public int getFinishTime() {
        return finishTime;
    }

    public void setFinishTime(int finishTime) {
        this.finishTime = finishTime;
    }

    public List<List<Integer>> getMustProduce() {
        return mustProduce;
    }

    public void setMustProduce(List<List<Integer>> mustProduce) {
        this.mustProduce = mustProduce;
    }

    public List<List<Integer>> getCouldProduce() {
        return couldProduce;
    }

    public void setCouldProduce(List<List<Integer>> couldProduce) {
        this.couldProduce = couldProduce;
    }
}
