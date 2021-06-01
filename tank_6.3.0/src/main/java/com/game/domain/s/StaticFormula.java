package com.game.domain.s;

import java.util.List;

/**
 * @author zhangdh
 * @ClassName: StaticFormula
 * @Description: 游戏内的合成公式
 * @date 2017/4/20 14:58
 */
public class StaticFormula {
    private int id;//公式ID
    private int type;//公式类型
    private List<List<Integer>> reward;//合成物品信息
    private int level;//合成需要的等级
    private int prosLv;//需要的世界繁荣度
    private int period;//合成需要的时间
    private int cdPrice;//每分钟CD价格
    private List<List<Integer>> materials;//合成消耗的材料
    private List<List<Integer>> rslFix;//分解获得固定材料
    private List<List<Integer>> rslRadom;//分解获得随机材料

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getLevel() {
        return level;
    }

    public void setLevel(int level) {
        this.level = level;
    }

    public int getProsLv() {
        return prosLv;
    }

    public void setProsLv(int prosLv) {
        this.prosLv = prosLv;
    }

    public List<List<Integer>> getMaterials() {
        return materials;
    }

    public void setMaterials(List<List<Integer>> materials) {
        this.materials = materials;
    }

    public List<List<Integer>> getReward() {
        return reward;
    }

    public void setReward(List<List<Integer>> reward) {
        this.reward = reward;
    }

    public List<List<Integer>> getRslFix() {
        return rslFix;
    }

    public void setRslFix(List<List<Integer>> rslFix) {
        this.rslFix = rslFix;
    }

    public List<List<Integer>> getRslRadom() {
        return rslRadom;
    }

    public void setRslRadom(List<List<Integer>> rslRadom) {
        this.rslRadom = rslRadom;
    }

    public int getPeriod() {
        return period;
    }

    public void setPeriod(int period) {
        this.period = period;
    }

    public int getCdPrice() {
        return cdPrice;
    }

    public void setCdPrice(int cdPrice) {
        this.cdPrice = cdPrice;
    }

    public int getType() {
        return type;
    }

    public void setType(int type) {
        this.type = type;
    }
}
