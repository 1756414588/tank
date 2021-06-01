package com.account.domain;

import java.util.Date;

/**
 * @author TanDonghai
 * @ClassName GameSaveErrorLog.java
 * @Description 游戏服务器提交的数据保存错误日志记录
 * @date 创建时间：2017年1月19日 上午7:32:44
 */
public class GameSaveErrorLog {
    private long logId;
    private int serverId; // 服务器id
    private int dataType; // 被保存失败的数据分类，1 玩家数据，2 军团，3 活动，4 全局，5 挑战，6 举报信息
    private int errorCount; // 已出错次数
    private String errorDesc; // 错误描述
    private Date errorTime; // 错误发生时间
    private Date logTime; // 日志产生时间

    public long getLogId() {
        return logId;
    }

    public void setLogId(long logId) {
        this.logId = logId;
    }

    public int getServerId() {
        return serverId;
    }

    public void setServerId(int serverId) {
        this.serverId = serverId;
    }

    public int getDataType() {
        return dataType;
    }

    public void setDataType(int dataType) {
        this.dataType = dataType;
    }

    public int getErrorCount() {
        return errorCount;
    }

    public void setErrorCount(int errorCount) {
        this.errorCount = errorCount;
    }

    public String getErrorDesc() {
        return errorDesc;
    }

    public void setErrorDesc(String errorDesc) {
        this.errorDesc = errorDesc;
    }

    public Date getErrorTime() {
        return errorTime;
    }

    public void setErrorTime(Date errorTime) {
        this.errorTime = errorTime;
    }

    public Date getLogTime() {
        return logTime;
    }

    public void setLogTime(Date logTime) {
        this.logTime = logTime;
    }

    @Override
    public String toString() {
        return "GameSaveErrorLog [logId=" + logId + ", serverId=" + serverId + ", dataType=" + dataType
                + ", errorCount=" + errorCount + ", errorDesc=" + errorDesc + ", errorTime=" + errorTime + ", logTime="
                + logTime + "]";
    }

}
