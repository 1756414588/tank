package com.game.service.crossmin;

import io.netty.channel.ChannelHandlerContext;

/**
 * @author ：Liu Gui Jie
 * @date ：Created in 2019/4/18 14:03
 * @description：
 */
public class Session {

    private int serverId;

    private ChannelHandlerContext ctx;


    /**
     * socket 是否连接
     */
    private boolean crossMinSocket = false;
    /**
     * rpc是否连接
     */
    private boolean crossMinRpc = false;

    /**
     * 通知游戏服连接时间 保证单位时间内只通知一次
     */
    private long sendTimeSocket;

    private String ServerName;

    public long getSendTimeSocket() {
        return sendTimeSocket;
    }

    public void setSendTimeSocket(long sendTimeSocket) {
        this.sendTimeSocket = sendTimeSocket;
    }

    public int getServerId() {
        return serverId;
    }

    public void setServerId(int serverId) {
        this.serverId = serverId;
    }

    public ChannelHandlerContext getCtx() {
        return ctx;
    }

    public void setCtx(ChannelHandlerContext ctx) {
        this.ctx = ctx;
    }

    public boolean isCrossMinSocket() {
        return crossMinSocket;
    }

    public void setCrossMinSocket(boolean crossMinSocket) {
        this.crossMinSocket = crossMinSocket;
    }

    public boolean isCrossMinRpc() {
        return crossMinRpc;
    }

    public void setCrossMinRpc(boolean crossMinRpc) {
        this.crossMinRpc = crossMinRpc;
    }

    public String getServerName() {
        return ServerName;
    }

    public void setServerName(String serverName) {
        ServerName = serverName;
    }
}
