/**
 * @Title: GiftCode.java
 * @Package com.account.domain
 * @Description: TODO
 * @author ZhangJun
 * @date 2015年10月23日 上午11:35:58
 * @version V1.0
 */
package com.account.domain;

import java.util.Date;

/**
 * @ClassName: GiftCode
 * @Description: TODO
 * @author ZhangJun
 * @date 2015年10月23日 上午11:35:58
 *
 */
public class GiftCode {
    private int keyId;
    private int giftId;
    private String giftCode;
    private int serverId;
    private long lordId;
    private String platNo;
    private Date useTime;
    private String mark;

    public int getKeyId() {
        return keyId;
    }

    public void setKeyId(int keyId) {
        this.keyId = keyId;
    }

    public int getGiftId() {
        return giftId;
    }

    public void setGiftId(int giftId) {
        this.giftId = giftId;
    }

    public String getGiftCode() {
        return giftCode;
    }

    public void setGiftCode(String giftCode) {
        this.giftCode = giftCode;
    }

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

    public String getPlatNo() {
        return platNo;
    }

    public void setPlatNo(String platNo) {
        this.platNo = platNo;
    }

    public Date getUseTime() {
        return useTime;
    }

    public void setUseTime(Date useTime) {
        this.useTime = useTime;
    }

    public void setMark(String mark) {
        this.mark = mark;
    }

    public String getMark() {
        return this.mark;
    }
}
