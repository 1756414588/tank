package com.game.server.config.gameServer;

import com.thoughtworks.xstream.annotations.XStreamAlias;
import com.thoughtworks.xstream.annotations.XStreamImplicit;

import java.util.List;

@XStreamAlias("servers")
public class GameServerConfig {
    @XStreamImplicit
    private List<Server> list;

    public List<Server> getList() {
        return list;
    }

    public void setList(List<Server> list) {
        this.list = list;
    }

}
