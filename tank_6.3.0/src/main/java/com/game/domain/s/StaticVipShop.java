package com.game.domain.s;

import java.util.List;

/**
 * @author zhangdh
 * @ClassName: StaticVipShop
 * @Description: VIP商店静态数据
 * @date 2017/4/6 18:47
 */
public class StaticVipShop{
    private int gid;
    private int price;//原价
    private int cost;//折扣价
    private int vipLevel;//VIP购买等级限制
    private List<Integer> reward;

    public int getGid() {
        return gid;
    }

    public void setGid(int gid) {
        this.gid = gid;
    }

    public int getPrice() {
        return price;
    }

    public void setPrice(int price) {
        this.price = price;
    }

    public int getCost() {
        return cost;
    }

    public void setCost(int cost) {
        this.cost = cost;
    }

    public int getVipLevel() {
        return vipLevel;
    }

    public void setVipLevel(int vipLevel) {
        this.vipLevel = vipLevel;
    }

    public List<Integer> getReward() {
        return reward;
    }

    public void setReward(List<Integer> reward) {
        this.reward = reward;
    }
}
