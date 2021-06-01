package com.game.domain.s;

import java.util.List;

/**
 * @author GuiJie
 * @description 假日碎片
 * @created 2018/03/20 11:27
 */
public class StaticActFestivalPiece {

//    CREATE TABLE `s_act_festival_piece` (
//            `id` int(11) NOT NULL COMMENT '编号id',
//            `awardId` int(11) NOT NULL COMMENT '活动奖励id',
//            `goodName` varchar(255) NOT NULL COMMENT '商品名称',
//            `reward` varchar(255) NOT NULL COMMENT '奖励类型',
//            `identfy` int(11) NOT NULL COMMENT '标识是否为登陆奖励的字段',
//            `cost` varchar(255) NOT NULL COMMENT '兑换/购买消耗',
//            `personNumber` int(11) NOT NULL COMMENT '兑换/购买数量限制',
//            `icon` varchar(255) NOT NULL COMMENT '节日碎片在商店以货币形式展示的图标',
//            `desc` varchar(255) NOT NULL COMMENT '活动2个页卡的名称（支持根据活动配置修改）',
//            `desc2` varchar(255) NOT NULL COMMENT '活动描述，支持根据不同节日修改描述'
//            ) ENGINE=InnoDB DEFAULT CHARSET=utf8;


    private int id;
    private int awardId;
    private int identfy;
    private List<Integer> cost;
    private List<List<Integer>> reward;
    private int personNumber;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getAwardId() {
        return awardId;
    }

    public void setAwardId(int awardId) {
        this.awardId = awardId;
    }

    public int getIdentfy() {
        return identfy;
    }

    public void setIdentfy(int identfy) {
        this.identfy = identfy;
    }


    public List<List<Integer>> getReward() {
        return reward;
    }

    public void setReward(List<List<Integer>> reward) {
        this.reward = reward;
    }

    public int getPersonNumber() {
        return personNumber;
    }

    public void setPersonNumber(int personNumber) {
        this.personNumber = personNumber;
    }

    public List<Integer> getCost() {
        return cost;
    }

    public void setCost(List<Integer> cost) {
        this.cost = cost;
    }
}
