/**
 * @Title: GiftCodeExt.java
 * @Package com.account.domain
 * @Description: TODO
 * @author ZhangJun
 * @date 2015年11月12日 下午3:06:47
 * @version V1.0
 */
package com.account.domain;

import java.util.Date;

/**
 * @ClassName: GiftCodeExt
 * @Description: TODO
 * @author ZhangJun
 * @date 2015年11月12日 下午3:06:47
 *
 */
public class GiftCodeExt {
    private int keyId;
    private String giftCode;
    private int serverId;
    private long lordId;
    private int platNo;
    private Date useTime;

    public int getKeyId() {
        return keyId;
    }

    public void setKeyId(int keyId) {
        this.keyId = keyId;
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

    public int getPlatNo() {
        return platNo;
    }

    public void setPlatNo(int platNo) {
        this.platNo = platNo;
    }

    public Date getUseTime() {
        return useTime;
    }

    public void setUseTime(Date useTime) {
        this.useTime = useTime;
    }


}
