package com.game.dataMgr;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.game.dao.impl.s.StaticDataDao;
import com.game.domain.s.StaticCost;

/**
 * @author ChenKui
 * @version 创建时间：2015-9-1 下午3:47:07
 * @Description: 英雄招募消耗
 */
@Component
public class StaticCostDataMgr extends BaseDataMgr {

	@Autowired
	private StaticDataDao staticDataDao;

	private Map<Integer, List<StaticCost>> costMap = new HashMap<Integer, List<StaticCost>>();

	@Override
	public void init() {
		List<StaticCost> costList = staticDataDao.selectCost();
		Map<Integer, List<StaticCost>> costMap = new HashMap<Integer, List<StaticCost>>();
		for (StaticCost staticCost : costList) {
			int costId = staticCost.getCostId();
			List<StaticCost> costll = costMap.get(costId);
			if (costll == null) {
				costll = new ArrayList<StaticCost>();
				costMap.put(costId, costll);
			}
			costll.add(staticCost);
		}
		this.costMap = costMap;
	}

	public StaticCost getCost(int costId, int count, int number) {
		List<StaticCost> costList = costMap.get(costId);
		StaticCost rs = new StaticCost();
		int maxCount = 0;
		int costCount = 0;
		StaticCost maxCost = null;
		for (StaticCost staticCost : costList) {
			int temp = staticCost.getCount();
			if (temp > maxCount) {
				maxCount = temp;
				maxCost = staticCost;
			}
			if (temp >= count && temp < count + number) {
				rs.setPrice(rs.getPrice() + staticCost.getPrice());
				costCount++;
			}
		}
		if (maxCount != 0 && number - costCount > 0) {
			rs.setPrice(rs.getPrice() + maxCost.getPrice() * (number - costCount));
		}
		return rs;
	}

	public StaticCost getCost(int costId, int count) {
		List<StaticCost> costList = costMap.get(costId);
		for (StaticCost staticCost : costList) {
			if (staticCost.getCount() == count) {
				return staticCost;
			}
		}
		return costList.get(costList.size() - 1);
	}
}
