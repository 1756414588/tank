package com.game.dataMgr;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.game.dao.impl.s.StaticDataDao;
import com.game.domain.s.StaticDrillBuff;
import com.game.domain.s.StaticDrillFeat;
import com.game.domain.s.StaticDrillShop;

/**
 * @ClassName StaticDrillDataManager.java
 * @Description 红蓝大战相关
 * @author TanDonghai
 * @date 创建时间：2016年8月15日 上午10:19:36
 *
 */
@Component
public class StaticDrillDataManager extends BaseDataMgr {
	@Autowired
	private StaticDataDao staticDataDao;

	/** 军演商店商品信息, key:shopId */
	private Map<Integer, StaticDrillShop> drillShopMap;

	/** 演习进修的buff, key1:buffId, key2:buffLv */
	private Map<Integer, Map<Integer, StaticDrillBuff>> drillBuffMap = new HashMap<>();

	/** 红蓝大战击毁坦克获得的功勋值配置信息, key:tankId */
	private Map<Integer, StaticDrillFeat> drillFeatMap;

	@Override
	public void init() {
		Map<Integer, StaticDrillShop> drillShopMap = staticDataDao.selectDrillShopMap();
		this.drillShopMap = drillShopMap;

		Map<Integer, StaticDrillFeat> drillFeatMap = staticDataDao.selectDrillFeatMap();
		this.drillFeatMap = drillFeatMap;

		List<StaticDrillBuff> buffList = staticDataDao.selectDrillBuffList();
		Map<Integer, Map<Integer, StaticDrillBuff>> drillBuffMap = new HashMap<>();
		for (StaticDrillBuff buff : buffList) {
			Map<Integer, StaticDrillBuff> map = drillBuffMap.get(buff.getBuffId());
			if (null == map) {
				map = new HashMap<>();
				drillBuffMap.put(buff.getBuffId(), map);
			}
			map.put(buff.getLv(), buff);
		}
		this.drillBuffMap = drillBuffMap;
	}

	public StaticDrillShop getDrillShopById(int shopId) {
		return drillShopMap.get(shopId);
	}

	public Map<Integer, StaticDrillShop> getDrillShopMap() {
		return drillShopMap;
	}

	public Set<Integer> getDrillBuffIdSet() {
		return drillBuffMap.keySet();
	}

	public StaticDrillBuff getDrillBuffByIdAndLv(int buffId, int lv) {
		Map<Integer, StaticDrillBuff> map = drillBuffMap.get(buffId);
		if (null == map) {
			return null;
		}

		return map.get(lv);
	}

	/**
	 * 获取演习进修buff的最高等级，由于buff是从0级开始，所以用不buff的记录数量-1
	 * 
	 * @param buffId
	 * @return
	 */
	public int getDrillBuffMaxLv(int buffId) {
		Map<Integer, StaticDrillBuff> map = drillBuffMap.get(buffId);
		if (null == map) {
			return 0;
		}
		return map.size() - 1;
	}

	public float getExploitByTankId(int tankId) {
		StaticDrillFeat feat = drillFeatMap.get(tankId);
		if (null == feat) {
			return 0;
		}
		return feat.getFeat();
	}
}
