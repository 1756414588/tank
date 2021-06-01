package com.game.dataMgr;

import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.game.dao.impl.s.StaticDataDao;
import com.game.domain.s.StaticCrossShop;
import com.game.domain.s.StaticCrossTrend;
import com.game.domain.s.StaticSeverWarBetting;
/**
* @ClassName: StaticCrossDataMgr 
* @Description: 跨服战配置相关
* @author
 */
@Component
public class StaticCrossDataMgr extends BaseDataMgr {
	@Autowired
	private StaticDataDao staticDataDao;

	private Map<Integer, StaticCrossShop> crossShopMap;

	private Map<Integer, StaticCrossTrend> crossTrendMap;

	Map<Integer, StaticSeverWarBetting> serverWarBettingMap;

	@Override
	public void init() {
		Map<Integer, StaticCrossShop> crossShopMap = staticDataDao.selectCrossShopMap();
		this.crossShopMap = crossShopMap;

		Map<Integer, StaticCrossTrend> crossTrendMap = staticDataDao.selectCrossTrendMap();
		this.crossTrendMap = crossTrendMap;

		Map<Integer, StaticSeverWarBetting> serverWarBettingMap = staticDataDao.selectSeverWarBetting();
		this.serverWarBettingMap = serverWarBettingMap;
	}

	public StaticCrossShop getStaticCrossShopById(int shopId) {
		return crossShopMap.get(shopId);
	}

	public StaticCrossTrend getCrossTrendById(int trendId) {
		return crossTrendMap.get(trendId);
	}

	public Map<Integer, StaticSeverWarBetting> getServerWarBettingMap() {
		return serverWarBettingMap;
	}

}
