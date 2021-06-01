package com.game.domain.p;

import java.util.LinkedList;

/**
 * @author GuiJie
 * @description 描述
 * @created 2018/04/17 14:56
 */
public class LuckyGlobalInfo {

    private int poolGold=0;

    private String version="";
    
    private LinkedList<ActLuckyPoolLog> luckyLog = new LinkedList<>();

    public String getVersion() {
        return version;
    }

    public void setVersion(String version) {
        this.version = version;
    }

    public int getPoolGold() {
        return poolGold;
    }

    public void setPoolGold(int poolGold) {
        this.poolGold = poolGold;
    }

	public LinkedList<ActLuckyPoolLog> getLuckyLog() {
		return luckyLog;
	}

	public void setLuckyLog(LinkedList<ActLuckyPoolLog> luckyLog) {
		this.luckyLog = luckyLog;
	}

    
}
