package com.game.server.config.gameServer;

import com.thoughtworks.xstream.annotations.XStreamAlias;
import com.thoughtworks.xstream.annotations.XStreamAsAttribute;
import io.netty.channel.ChannelHandlerContext;

@XStreamAlias("server")
public class Server {
    @XStreamAsAttribute()
    @XStreamAlias("id")
    private int id;

    @XStreamAsAttribute()
    @XStreamAlias("name")
    private String name;

    @XStreamAsAttribute()
    @XStreamAlias("ip")
    private String ip;

    @XStreamAsAttribute()
    @XStreamAlias("httpPort")
    private int httpPort;

    private boolean isConect;

    public ChannelHandlerContext ctx;

    public long sendTime;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getIp() {
        return ip;
    }

    public void setIp(String ip) {
        this.ip = ip;
    }

    public int getHttpPort() {
        return httpPort;
    }

    public void setHttpPort(int httpPort) {
        this.httpPort = httpPort;
    }

    public boolean isConect() {
        return isConect;
    }

    public void setConect(boolean isConect) {
        this.isConect = isConect;
    }

    public ChannelHandlerContext getCtx() {
        return ctx;
    }

    public void setCtx(ChannelHandlerContext ctx) {
        this.ctx = ctx;
    }

    @Override
    public String toString() {
        return "Server{" +
                "id=" + id +
                ", name='" + name + '\'' +
                ", ip='" + ip + '\'' +
                ", httpPort=" + httpPort +
                ", isConect=" + isConect +
                '}';
    }
}
