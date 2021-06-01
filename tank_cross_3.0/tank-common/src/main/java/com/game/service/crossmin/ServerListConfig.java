package com.game.service.crossmin;

import com.alibaba.fastjson.annotation.JSONField;

/**
 * @author ：Liu Gui Jie
 * @date ：Created in 2019/3/28 17:43
 * @description：server list config
 */
public class ServerListConfig {

    private int id;
    private String name;
    private String url;
    private int hot;
    @JSONField(name = "new")
    private int newServer;
    private int stop;
    private int show;
    private String socketURL;
    private int port;
    private int review;

    private long sendTime;


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

    public String getUrl() {
        return url;
    }

    public void setUrl(String url) {
        this.url = url;
    }

    public int getHot() {
        return hot;
    }

    public void setHot(int hot) {
        this.hot = hot;
    }

    public int getNewServer() {
        return newServer;
    }

    public void setNewServer(int newServer) {
        this.newServer = newServer;
    }

    public int getStop() {
        return stop;
    }

    public void setStop(int stop) {
        this.stop = stop;
    }

    public int getShow() {
        return show;
    }

    public void setShow(int show) {
        this.show = show;
    }

    public String getSocketURL() {
        return socketURL;
    }

    public void setSocketURL(String socketURL) {
        this.socketURL = socketURL;
    }

    public int getPort() {
        return port;
    }

    public void setPort(int port) {
        this.port = port;
    }

    public int getReview() {
        return review;
    }

    public void setReview(int review) {
        this.review = review;
    }

    public long getSendTime() {
        return sendTime;
    }

    public void setSendTime(long sendTime) {
        this.sendTime = sendTime;
    }
}
