package com.game.domain.p.repair;

/**
 * @author zhangdh
 * @ClassName: ReissueItem
 * @Description: 处理玩家装甲风暴问题
 * 问题描述: 客户端免费抽奖按钮没有更新,导致玩家在不知情的前提条件下,消耗了金币抽奖,
 * 处理方法: 运营决定扣除玩家在活动中活动到的资源(坦克和道具),并将消耗的金币以邮件的形式返还给玩家
 *          1. p_reissue_items表中记录了玩家参与活动获得到的资源信息和在活动中消耗的金币信息
 *          2.只扣除玩家tanks列表中与props中含有的坦克与道具,如果不足则不扣除坦克与资源且不予返还金币
 * @date 2017-07-03 15:10
 */
public class ReissueItem {
    //服务器ID
    private int serverId;
    //角色ID
    private long lordId;
    //角色昵称
    private String nick;
    //需要扣除坦克ID为25的数量
    private int tank25;
    //需要扣除坦克ID为99的数量
    private int tank99;
    //需要扣除道具ID为200的数量
    private int prop200;
    //需要返还给玩家的金币数量
    private int gold;
    //1-已经返还金币了
    private int backGold;

    public int getServerId() {
        return serverId;
    }

    public void setServerId(int serverId) {
        this.serverId = serverId;
    }

    public long getLordId() {
        return lordId;
    }

    public void setLordId(long lordId) {
        this.lordId = lordId;
    }

    public int getBackGold() {
        return backGold;
    }

    public void setBackGold(int backGold) {
        this.backGold = backGold;
    }

    public String getNick() {
        return nick;
    }

    public void setNick(String nick) {
        this.nick = nick;
    }

    public int getTank25() {
        return tank25;
    }

    public void setTank25(int tank25) {
        this.tank25 = tank25;
    }

    public int getTank99() {
        return tank99;
    }

    public void setTank99(int tank99) {
        this.tank99 = tank99;
    }

    public int getProp200() {
        return prop200;
    }

    public void setProp200(int prop200) {
        this.prop200 = prop200;
    }

    public int getGold() {
        return gold;
    }

    public void setGold(int gold) {
        this.gold = gold;
    }
}
