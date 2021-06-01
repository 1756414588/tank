package com.game.domain.s;

import java.util.List;
import java.util.Map;
import java.util.TreeMap;

/**
 * @author zhangdh
 * @ClassName: StaticActMonopoly
 * @Description: 大富翁
 * @date 2017-11-30 13:57
 */
public class StaticActMonopoly {
    //唯一ID
    private int id;
    //活动ID(awardId)
    private int activityId;
    //单次丢骰子消耗的精力
    private int cost;
    //最大连续走空格的数量,下一次一定走到最近的一个事件格子上去
    private int emptyCont;
    //购买一次精力增加的精力点数
    private int addEnergy;
    //精力价格
    private int energyPrice;
    //活动参与等级限制
    private int lv;
    //免费领取精力值
    private int freeEnergy;
    //骰子的概率,KEY:跑圈数, 骰子的概率
    private TreeMap<Integer, List<Integer>> diceProb;
    //跑圈奖励,KEY:跑圈数, VALUE:奖励列表
    private Map<Integer, List<List<Integer>>> finishAward;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getActivityId() {
        return activityId;
    }

    public void setActivityId(int activityId) {
        this.activityId = activityId;
    }

    public int getEmptyCont() {
        return emptyCont;
    }

    public void setEmptyCont(int emptyCont) {
        this.emptyCont = emptyCont;
    }

    public TreeMap<Integer, List<Integer>> getDiceProb() {
        return diceProb;
    }

    public int getEnergyPrice() {
        return energyPrice;
    }

    public void setEnergyPrice(int energyPrice) {
        this.energyPrice = energyPrice;
    }

    public int getAddEnergy() {
        return addEnergy;
    }

    public void setAddEnergy(int addEnergy) {
        this.addEnergy = addEnergy;
    }

    public int getLv() {
        return lv;
    }

    public void setLv(int lv) {
        this.lv = lv;
    }

    public void setDiceProb(TreeMap<Integer, List<Integer>> diceProb) {
        this.diceProb = diceProb;
    }

    public Map<Integer, List<List<Integer>>> getFinishAward() {
        return finishAward;
    }

    public void setFinishAward(Map<Integer, List<List<Integer>>> finishAward) {
        this.finishAward = finishAward;
    }

    public int getCost() {
        return cost;
    }

    public void setCost(int cost) {
        this.cost = cost;
    }

    public int getFreeEnergy() {
        return freeEnergy;
    }

    public void setFreeEnergy(int freeEnergy) {
        this.freeEnergy = freeEnergy;
    }
}
