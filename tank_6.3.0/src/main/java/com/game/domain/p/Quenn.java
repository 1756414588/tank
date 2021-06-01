package com.game.domain.p;
/**
 * 超时空财团商品
 * @author 丁文渊
 * 上午11:04:07
 */
public class Quenn {
    /**  道具大类 */
    private int type;
    /**  道具编号 */
    private int id;
    public int getType() {
        return type;
    }
    public void setType(int type) {
        this.type = type;
    }
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
    public int getDesc() {
        return desc;
    }
    public void setDesc(int desc) {
        this.desc = desc;
    }
    public int getSold() {
        return sold;
    }
    public void setSold(int sold) {
        this.sold = sold;
    }
    public int getDis() {
        return dis;
    }
    public void setDis(int dis) {
        this.dis = dis;
    }
    public int getPrice() {
        return price;
    }
    public void setPrice(int price) {
        this.price = price;
    }
    public int getEspecial() {
        return especial;
    }
    public void setEspecial(int especial) {
        this.especial = especial;
    }
    /**  道具数量 */
    private int count;
    /**  道具名称 */
    private int desc;
    /**  是否售罄 */
    private int sold;
    /**  折扣 */
    private int dis;
    /**  折扣后价格 */
    private int price;
    /** 是否为特殊道具 */
    private int especial;
}
