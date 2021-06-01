package com.account.domain;

import java.io.Serializable;

/**
 * Created by pengshuo on 2019/3/11 11:34
 * <br>Description:
 * <br>Modified By:
 * <br>Version:
 *
 * @author pengshuo
 */
public class SaveBehavior implements Serializable {

    private String deviceNo;
    private String platName;
    private String areaId;
    private String lordId;
    private String content;

    public String getDeviceNo() {
        return deviceNo;
    }

    public void setDeviceNo(String deviceNo) {
        this.deviceNo = deviceNo;
    }

    public String getPlatName() {
        return platName;
    }

    public void setPlatName(String platName) {
        this.platName = platName;
    }

    public String getAreaId() {
        return areaId;
    }

    public void setAreaId(String areaId) {
        this.areaId = areaId;
    }

    public String getLordId() {
        return lordId;
    }

    public void setLordId(String lordId) {
        this.lordId = lordId;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public SaveBehavior() {
    }

    public SaveBehavior(String deviceNo, String platName, String areaId, String lordId, String content) {
        this.deviceNo = deviceNo;
        this.platName = platName;
        this.areaId = areaId;
        this.lordId = lordId;
        this.content = content;
    }

    @Override
    public String toString() {
        return "SaveBehavior{" +
                "deviceNo='" + deviceNo + '\'' +
                ", platName='" + platName + '\'' +
                ", areaId='" + areaId + '\'' +
                ", lordId='" + lordId + '\'' +
                ", content='" + content + '\'' +
                '}';
    }
}
