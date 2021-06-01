package com.game.domain.s;

import java.util.List;

public class StaticActivityPartyWar {

//    CREATE TABLE `s_activity_partywar` (
//            `Id` int(11) NOT NULL COMMENT 'ID',
//            `awardId` int(11) DEFAULT NULL COMMENT '奖励id',
//            `eventType` int(11) DEFAULT NULL COMMENT '事件类型，如1-军团夺得第1名',
//            `eventCondition` int(11) DEFAULT NULL COMMENT '事件达成条件',
//            `award` varchar(255) DEFAULT NULL COMMENT '奖励',
//            `desc` varchar(255) DEFAULT NULL COMMENT '描述',
//    PRIMARY KEY (`Id`)
//) ENGINE=InnoDB DEFAULT CHARSET=utf8;


    private int Id;
    private int awardId;
    private int eventType;
    private int eventCondition;
    private List<List<Integer>> award;

    public int getId() {
        return Id;
    }

    public void setId(int id) {
        Id = id;
    }

    public int getAwardId() {
        return awardId;
    }

    public void setAwardId(int awardId) {
        this.awardId = awardId;
    }

    public int getEventType() {
        return eventType;
    }

    public void setEventType(int eventType) {
        this.eventType = eventType;
    }

    public int getEventCondition() {
        return eventCondition;
    }

    public void setEventCondition(int eventCondition) {
        this.eventCondition = eventCondition;
    }

    public List<List<Integer>> getAward() {
        return award;
    }

    public void setAward(List<List<Integer>> award) {
        this.award = award;
    }
}
