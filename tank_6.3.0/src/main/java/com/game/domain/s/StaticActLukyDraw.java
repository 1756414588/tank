package com.game.domain.s;

import java.util.List;

/**
 * @author GuiJie
 * @description 幸运奖池
 * @created 2018/03/20 11:27
 */
public class StaticActLukyDraw {

//    CREATE TABLE `s_act_luky_draw` (
//            `lucyId` int(11) NOT NULL COMMENT 'id',
//            `awardId` int(11) NOT NULL COMMENT '活动编号',
//            `goodName` varchar(255) NOT NULL COMMENT '奖池的奖励名称',
//            `reward` varchar(255) NOT NULL COMMENT '奖励类型',
//            `rewardGold` varchar(255) NOT NULL COMMENT '奖池金币百分比数，20表示20%',
//            `type` int(11) NOT NULL COMMENT '1=奖池金币百分比类型，2=常规类型',
//            `weight` int(11) NOT NULL COMMENT '奖池各奖励的权重',
//    PRIMARY KEY (`lucyId`)
//) ENGINE=InnoDB DEFAULT CHARSET=utf8;


    private int lucyId;
    private int awardId;
    private int rewardGold;
    private List<Integer> reward;
    private int type;
    private int weight;
    private int notice;
    private String goodName;

    public int getLucyId() {
        return lucyId;
    }

    public void setLucyId(int lucyId) {
        this.lucyId = lucyId;
    }

    public int getAwardId() {
        return awardId;
    }

    public void setAwardId(int awardId) {
        this.awardId = awardId;
    }

    public int getRewardGold() {
        return rewardGold;
    }

    public void setRewardGold(int rewardGold) {
        this.rewardGold = rewardGold;
    }

    public List<Integer> getReward() {
        return reward;
    }

    public void setReward(List<Integer> reward) {
        this.reward = reward;
    }

    public int getType() {
        return type;
    }

    public void setType(int type) {
        this.type = type;
    }

    public int getWeight() {
        return weight;
    }

    public void setWeight(int weight) {
        this.weight = weight;
    }

    public int getNotice() {
        return notice;
    }

    public void setNotice(int notice) {
        this.notice = notice;
    }

    public String getGoodName() {
        return goodName;
    }

    public void setGoodName(String goodName) {
        this.goodName = goodName;
    }
}
