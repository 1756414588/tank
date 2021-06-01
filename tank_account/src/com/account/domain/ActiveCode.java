package com.account.domain;

import java.util.Date;

public class ActiveCode {
    private int keyId;
    private long activeCode;
    private int used;
    private int accountKey;
    private Date useDate;

    public int getKeyId() {
        return keyId;
    }

    public void setKeyId(int keyId) {
        this.keyId = keyId;
    }

    public long getActiveCode() {
        return activeCode;
    }

    public void setActiveCode(long activeCode) {
        this.activeCode = activeCode;
    }

    public int getUsed() {
        return used;
    }

    public void setUsed(int used) {
        this.used = used;
    }

    public int getAccountKey() {
        return accountKey;
    }

    public void setAccountKey(int accountKey) {
        this.accountKey = accountKey;
    }

    public Date getUseDate() {
        return useDate;
    }

    public void setUseDate(Date useDate) {
        this.useDate = useDate;
    }

}
