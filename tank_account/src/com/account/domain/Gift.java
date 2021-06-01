/**
 * @Title: Gift.java
 * @Package com.account.domain
 * @Description: TODO
 * @author ZhangJun
 * @date 2015年10月23日 上午11:35:49
 * @version V1.0
 */
package com.account.domain;

import java.util.Date;

/**
 * @ClassName: Gift
 * @Description: TODO
 * @author ZhangJun
 * @date 2015年10月23日 上午11:35:49
 *
 */
public class Gift {
    private int giftId;
    private String giftName;
    private Date beginTime;
    private Date endTime;
    private int valid;
    private String gift;
    private int reuse;
    private Date createTime;

    public int getGiftId() {
        return giftId;
    }

    public void setGiftId(int giftId) {
        this.giftId = giftId;
    }

    public Date getBeginTime() {
        return beginTime;
    }

    public void setBeginTime(Date beginTime) {
        this.beginTime = beginTime;
    }

    public Date getEndTime() {
        return endTime;
    }

    public void setEndTime(Date endTime) {
        this.endTime = endTime;
    }

    public int getValid() {
        return valid;
    }

    public void setValid(int valid) {
        this.valid = valid;
    }

    public String getGift() {
        return gift;
    }

    public void setGift(String gift) {
        this.gift = gift;
    }

    public Date getCreateTime() {
        return createTime;
    }

    public void setCreateTime(Date createTime) {
        this.createTime = createTime;
    }

    public String getGiftName() {
        return giftName;
    }

    public void setGiftName(String giftName) {
        this.giftName = giftName;
    }

    public int getReuse() {
        return reuse;
    }

    public void setReuse(int reuse) {
        this.reuse = reuse;
    }

}
