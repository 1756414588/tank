package com.account.domain;

public class Advertise {
    private int keyId;

    private int platNo;

    private String idfa;

    private String ip;

    private String callbackUrl;

    private boolean activated;

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

    public String getIdfa() {
        return idfa;
    }

    public void setIdfa(String idfa) {
        this.idfa = idfa;
    }

    public String getIp() {
        return ip;
    }

    public void setIp(String ip) {
        this.ip = ip;
    }

    public String getCallbackUrl() {
        return callbackUrl;
    }

    public void setCallbackUrl(String callbackUrl) {
        this.callbackUrl = callbackUrl;
    }

    public boolean isActivated() {
        return activated;
    }

    public void setActivated(boolean activated) {
        this.activated = activated;
    }

    @Override
    public String toString() {
        return "Advertise [keyId=" + keyId + ", platNo=" + platNo + ", idfa=" + idfa + ", ip=" + ip + ", callbackUrl="
                + callbackUrl + ", activated=" + activated + "]";
    }
}
