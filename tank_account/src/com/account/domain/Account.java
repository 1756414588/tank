package com.account.domain;

import java.util.Date;

public class Account {
    private int keyId;
    private int platNo;
    private String platId;
    private int childNo;
    private int forbid;
    private int active;
    private String baseVersion;
    private String versionNo;
    private String account;
    private String passwd;
    private int white;
    private int firstSvr;
    private int secondSvr;
    private int thirdSvr;
    private String token;
    private String deviceNo;
    private Date loginDate;
    private Date createDate;

    public int getKeyId() {
        return keyId;
    }

    public void setKeyId(int keyId) {
        this.keyId = keyId;
    }

    public int getPlatNo() {
        return platNo;
    }

    public void setPlatNo(int platNo) {
        this.platNo = platNo;
    }

    public String getPlatId() {
        return platId;
    }

    public void setPlatId(String platId) {
        this.platId = platId;
    }

    public int getForbid() {
        return forbid;
    }

    public void setForbid(int forbid) {
        this.forbid = forbid;
    }

    public String getVersionNo() {
        return versionNo;
    }

    public void setVersionNo(String versionNo) {
        this.versionNo = versionNo;
    }

    public String getAccount() {
        return account;
    }

    public void setAccount(String account) {
        this.account = account;
    }

    public String getPasswd() {
        return passwd;
    }

    public void setPasswd(String passwd) {
        this.passwd = passwd;
    }

    public int getFirstSvr() {
        return firstSvr;
    }

    public void setFirstSvr(int firstSvr) {
        this.firstSvr = firstSvr;
    }

    public int getSecondSvr() {
        return secondSvr;
    }

    public void setSecondSvr(int secondSvr) {
        this.secondSvr = secondSvr;
    }

    public int getThirdSvr() {
        return thirdSvr;
    }

    public void setThirdSvr(int thirdSvr) {
        this.thirdSvr = thirdSvr;
    }

    public Date getCreateDate() {
        return createDate;
    }

    public void setCreateDate(Date createDate) {
        this.createDate = createDate;
    }

    public int getWhite() {
        return white;
    }

    public void setWhite(int white) {
        this.white = white;
    }

    public String getToken() {
        return token;
    }

    public void setToken(String token) {
        this.token = token;
    }

    public String getBaseVersion() {
        return baseVersion;
    }

    public void setBaseVersion(String baseVersion) {
        this.baseVersion = baseVersion;
    }

    public String getDeviceNo() {
        return deviceNo;
    }

    public void setDeviceNo(String deviceNo) {
        this.deviceNo = deviceNo;
    }

    public Date getLoginDate() {
        return loginDate;
    }

    public void setLoginDate(Date loginDate) {
        this.loginDate = loginDate;
    }

    public int getActive() {
        return active;
    }

    public void setActive(int active) {
        this.active = active;
    }

    public int getChildNo() {
        return childNo;
    }

    public void setChildNo(int childNo) {
        this.childNo = childNo;
    }
}
