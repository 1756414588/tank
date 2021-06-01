package com.game.datamgr;

import com.game.dao.impl.s.StaticDataDao;
import com.game.domain.s.StaticCrossShop;
import com.game.domain.s.StaticServerPartyWining;
import com.game.domain.s.StaticSeverWarBetting;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.Map;

@Component
public class StaticCrossDataMgr extends BaseDataMgr {
    @Autowired
    private StaticDataDao staticDataDao;

    private Map<Integer, StaticCrossShop> crossShopMap;

    private Map<Integer, StaticSeverWarBetting> serverWarBettingMap;

    private Map<Integer, StaticServerPartyWining> serverPartyWining;

    @Override
    public void init() {
        Map<Integer, StaticCrossShop> crossShopMap = staticDataDao.selectCrossShopMap();
        this.crossShopMap = crossShopMap;

        Map<Integer, StaticSeverWarBetting> serverWarBettingMap = staticDataDao.selectSeverWarBetting();
        this.serverWarBettingMap = serverWarBettingMap;

        Map<Integer, StaticServerPartyWining> serverPartyWining =
                staticDataDao.selectServerPartyWining();
        this.serverPartyWining = serverPartyWining;
    }


    public StaticCrossShop getStaticCrossShopById(int shopId) {
        return crossShopMap.get(shopId);
    }

    public Map<Integer, StaticCrossShop> getCrossShopMap() {
        return crossShopMap;
    }

    public void setCrossShopMap(Map<Integer, StaticCrossShop> crossShopMap) {
        this.crossShopMap = crossShopMap;
    }

    public Map<Integer, StaticSeverWarBetting> getServerWarBettingMap() {
        return serverWarBettingMap;
    }

    public void setServerWarBettingMap(Map<Integer, StaticSeverWarBetting> serverWarBettingMap) {
        this.serverWarBettingMap = serverWarBettingMap;
    }

    public Map<Integer, StaticServerPartyWining> getServerPartyWining() {
        return serverPartyWining;
    }

    public void setServerPartyWining(Map<Integer, StaticServerPartyWining> serverPartyWining) {
        this.serverPartyWining = serverPartyWining;
    }
}
