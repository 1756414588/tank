package com.game.domain.s;

/**
 * @ClassName:StaticActQuinn
 * @author 丁文渊
 * @Description:对应s_act_Quinn表 超时空财团
 * @date 2017年9月11日
 */
public class StaticActQuinn {
    /** 编号*/
    private int id;
    /**对应同一个activityId下不同的奖励*/
    private int awardid;
    /**类型，1-4对应贸易界面中的1-4号道具栏。100，对应兑换界面中的道具栏*/
    private int type;
    /**出售的道具[大类,小类,数量]*/
    private Integer[] item;
    /**价格（原价）*/
    private int price;
    /**单个道具出现概率*/
    private int probability;
    /**折扣[几折,出现几率]*/
    private Integer[][]  discount;
    /**是否为特殊道具（0为不是，1为是）*/
    private int especial;
    /**道具名称*/
    private String desc;
    public String getDesc() {
        return desc;
    }
    public void setDesc(String desc) {
        this.desc = desc;
    }
    public int getEspecial() {
        return especial;
    }
    public void setEspecial(int especial) {
        this.especial = especial;
    }

    public int getProbability() {
        return probability;
    }
    public void setProbability(int probability) {
        this.probability = probability;
    }
    public int getPrice() {
        return price;
    }
    public void setPrice(int price) {
        this.price = price;
    }
    public Integer[] getItem() {
        return item;
    }
    public void setItem(Integer[] item) {
        this.item = item;
    }
    public int getType() {
        return type;
    }
    public void setType(int type) {
        this.type = type;
    }
    public int getAwardid() {
        return awardid;
    }
    public void setAwardid(int awardid) {
        this.awardid = awardid;
    }
    public int getId() {
        return id;
    }
    public void setId(int id) {
        this.id = id;
    }
    public Integer[][] getDiscount() {
        return discount;
    }
    public void setDiscount(Integer[][] discount) {
        this.discount = discount;
    }
}
