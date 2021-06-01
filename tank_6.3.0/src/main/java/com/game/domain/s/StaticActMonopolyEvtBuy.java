package com.game.domain.s;

import com.game.domain.sort.IProb;

import java.util.List;

/**
 * @author zhangdh
 * @ClassName: StaticActMonopolyEvtBuy
 * @Description: 大富翁购买事件详细定义
 * @date 2017-11-30 14:05
 */
public class StaticActMonopolyEvtBuy implements IProb{
    //唯一ID
    private int id;
    //事件ID
    private int eid;
    //权重
    private int prob;
    //展示价格
    private int showGold;
    //购买价格
    private int buyGold;
    //购买物品
    private List<List<Integer>> award;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getEid() {
        return eid;
    }

    public void setEid(int eid) {
        this.eid = eid;
    }

    public int getProb() {
        return prob;
    }

    public void setProb(int prob) {
        this.prob = prob;
    }

    public int getShowGold() {
        return showGold;
    }

    public void setShowGold(int showGold) {
        this.showGold = showGold;
    }

    public int getBuyGold() {
        return buyGold;
    }

    public void setBuyGold(int buyGold) {
        this.buyGold = buyGold;
    }

    public List<List<Integer>> getAward() {
        return award;
    }

    public void setAward(List<List<Integer>> award) {
        this.award = award;
    }
}
