package com.account.plat.impl.mzUnicom;

public class ResultMsg {

    private String gameaccount;//游戏账号，长度<=64，联网必填
    private String imei;//设备标识，联网必填，单机尽量上报
    private String macaddress;//MAC地址去掉冒号，联网必填，单机尽量
    private String ipaddress;//IP地址，去掉点号，补零到每地址段3位，如：192168000001，联网必填，单机尽量
    private String serviceid;//12位沃商店计费点（业务代码），必填
    private String channelid;//渠道ID，必填，如00012243
    private String cpid;//沃商店CPID，必填
    private String ordertime;//订单时间戳，14位时间格式，联网必填，单机尽量yyyyMMddhhmmss
    private String appversion;//应用版本号，必填，长度<=32
    private String orderId10;
    private String orderId32;

    public String getOrderId10() {
        return orderId10;
    }

    public void setOrderId10(String orderId10) {
        this.orderId10 = orderId10;
    }

    public String getOrderId32() {
        return orderId32;
    }

    public void setOrderId32(String orderId32) {
        this.orderId32 = orderId32;
    }

    public String getGameaccount() {
        return gameaccount;
    }

    public void setGameaccount(String gameaccount) {
        this.gameaccount = gameaccount;
    }

    public String getImei() {
        return imei;
    }

    public void setImei(String imei) {
        this.imei = imei;
    }

    public String getMacaddress() {
        return macaddress;
    }

    public void setMacaddress(String macaddress) {
        this.macaddress = macaddress;
    }

    public String getIpaddress() {
        return ipaddress;
    }

    public void setIpaddress(String ipaddress) {
        this.ipaddress = ipaddress;
    }

    public String getServiceid() {
        return serviceid;
    }

    public void setServiceid(String serviceid) {
        this.serviceid = serviceid;
    }

    public String getChannelid() {
        return channelid;
    }

    public void setChannelid(String channelid) {
        this.channelid = channelid;
    }

    public String getCpid() {
        return cpid;
    }

    public void setCpid(String cpid) {
        this.cpid = cpid;
    }

    public String getOrdertime() {
        return ordertime;
    }

    public void setOrdertime(String ordertime) {
        this.ordertime = ordertime;
    }

    public String getAppversion() {
        return appversion;
    }

    public void setAppversion(String appversion) {
        this.appversion = appversion;
    }
}
