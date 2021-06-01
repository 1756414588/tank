package com.game.domain.s;

import java.util.List;

/**
 * @author zhangdh
 * @ClassName: StaticActPartMasterLottery
 * @Description: 淬炼大师活动中消耗氪金数量抽奖信息
 * @date 2017-05-31 15:47
 */
public class StaticActPartMasterLottery {
    private int id;
    private int count;//抽奖次数
    private int price;//消耗氪金数量
    private int point;//获得积分
    //抽奖信息0-type,1-id,2-数量,3-权重
    private List<List<Integer>> rewards;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getCount() {
        return count;
    }

    public void setCount(int count) {
        this.count = count;
    }

    public int getPrice() {
        return price;
    }

    public void setPrice(int price) {
        this.price = price;
    }

    public int getPoint() {
        return point;
    }

    public void setPoint(int point) {
        this.point = point;
    }

    public List<List<Integer>> getRewards() {
        return rewards;
    }

    public void setRewards(List<List<Integer>> rewards) {
        this.rewards = rewards;
    }
}
