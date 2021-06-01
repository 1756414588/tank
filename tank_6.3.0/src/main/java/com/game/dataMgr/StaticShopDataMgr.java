package com.game.dataMgr;

import com.game.dao.impl.s.StaticDataDao;
import com.game.domain.s.StaticTreasureShop;
import com.game.domain.s.StaticVipShop;
import com.game.domain.s.StaticWorldShop;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * @ClassName StaticShopDataMgr.java
 * @Description 商店数据管理类
 * @author TanDonghai
 * @date 创建时间：2016年8月3日 下午4:43:03
 *
 */
@Component
public class StaticShopDataMgr extends BaseDataMgr {
	@Autowired
	private StaticDataDao staticDataDao;

	/** 荒宝兑换商店（宝物商店）配置数据，按开服周分类, key:openWeek */
	private Map<Integer, List<StaticTreasureShop>> treasureShopMap = new HashMap<Integer, List<StaticTreasureShop>>();

	/** 所有的宝物商店配置数据， key:treasureId */
	private Map<Integer, StaticTreasureShop> allTreasureShopMap = new HashMap<Integer, StaticTreasureShop>();

	/** VIP商店信息, KEY:商品ID*/
	private Map<Integer, StaticVipShop> vipShopMap = new HashMap<>();

	/** 世界商店信息, KEY:商品ID*/
	private Map<Integer, StaticWorldShop> worldShopMap = new HashMap<>();

	@Override
	public void init() {
		List<StaticTreasureShop> allTreasureList = staticDataDao.selectTreasureShop();
		List<StaticTreasureShop> treasureList;
		Map<Integer, StaticTreasureShop> allTreasureShopMap = new HashMap<Integer, StaticTreasureShop>();
		Map<Integer, List<StaticTreasureShop>> treasureShopMap = new HashMap<Integer, List<StaticTreasureShop>>();
		for (StaticTreasureShop shop : allTreasureList) {
			treasureList = treasureShopMap.get(shop.getOpenWeek());
			if (null == treasureList) {
				treasureList = new ArrayList<>();
				treasureShopMap.put(shop.getOpenWeek(), treasureList);
			}
			treasureList.add(shop);
			allTreasureShopMap.put(shop.getTreasureId(), shop);
		}
		this.treasureShopMap = treasureShopMap;
		this.allTreasureShopMap = allTreasureShopMap;
		this.vipShopMap = staticDataDao.selectVipShopMap();
		this.worldShopMap = staticDataDao.selectWorldShopMap();
    }

	public StaticTreasureShop getTreasureShopById(int treasureId) {
		return allTreasureShopMap.get(treasureId);
	}

	/**
	 * 根据开服周数，获取本周的宝物商店商品信息
	 * 
	 * @param openServerWeek
	 * @return
	 */
	public List<StaticTreasureShop> getTreasureShopByWeek(int openServerWeek) {
		return treasureShopMap.get(openServerWeek);
	}

    public Map<Integer, StaticVipShop> getVipShopMap() {
        return vipShopMap;
    }

    public Map<Integer, StaticWorldShop> getWorldShopMap() {
        return worldShopMap;
    }
}
