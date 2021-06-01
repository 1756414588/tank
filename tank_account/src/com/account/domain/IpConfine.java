package com.account.domain;

import java.util.Date;

public class IpConfine {
    private int keyId;
    private String ip;
    private int createNum;
    private Date createDate;

    public int getKeyId() {
        return keyId;
    }

    public void setKeyId(int keyId) {
        this.keyId = keyId;
    }

    public String getIp() {
        return ip;
    }

    public void setIp(String ip) {
        this.ip = ip;
    }

    public int getCreateNum() {
        return createNum;
    }

    public void setCreateNum(int createNum) {
        this.createNum = createNum;
    }

    public Date getCreateDate() {
        return createDate;
    }

    public void setCreateDate(Date createDate) {
        this.createDate = createDate;
    }


}
