package com.game.domain.s;

/**
 * @ClassName:StaticSkin
 * @author zc
 * @Description:基地外观配置表
 * @date 2017年7月19日
 */
public class StaticSkin {
    private int id;
    private int category;// 类别（1为普通，2为特殊）
    private int quality;// 品质（1-6分别对应白绿蓝紫橙红）
    private int canbuy;// 是否可购买（0为不可以，1为可以）
    private int cansee;// 未拥有时，是否可见（0为不可以，1为可以）
    private int effectId;
    private int effectivetime;// 持续时间（单位：秒。0为永久）
    private int item;// 对应道具id
    private int price;// 价格
    private int type;// 1 皮肤 2 铭牌 3 聊天气泡
    private int vip;// vip激活等级

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getCategory() {
        return category;
    }

    public void setCategory(int category) {
        this.category = category;
    }

    public int getQuality() {
        return quality;
    }

    public void setQuality(int quality) {
        this.quality = quality;
    }

    public int getCanbuy() {
        return canbuy;
    }

    public void setCanbuy(int canbuy) {
        this.canbuy = canbuy;
    }

    public int getCansee() {
        return cansee;
    }

    public void setCansee(int cansee) {
        this.cansee = cansee;
    }

    public int getEffectId() {
        return effectId;
    }

    public void setEffectId(int effectId) {
        this.effectId = effectId;
    }

    public int getEffectivetime() {
        return effectivetime;
    }

    public void setEffectivetime(int effectivetime) {
        this.effectivetime = effectivetime;
    }

    public int getItem() {
        return item;
    }

    public void setItem(int item) {
        this.item = item;
    }

    public int getPrice() {
        return price;
    }

    public void setPrice(int price) {
        this.price = price;
    }

    public int getType() {
        return type;
    }

    public void setType(int type) {
        this.type = type;
    }

    public int getVip() {
        return vip;
    }

    public void setVip(int vip) {
        this.vip = vip;
    }
}
