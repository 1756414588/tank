package com.game.dataMgr;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.game.dao.impl.s.StaticDataDao;
import com.game.domain.s.StaticTankConvert;
import com.game.util.CheckNull;
import com.game.util.LogUtil;

/**
 * @author: LiFeng
 * @date:
 * @description:
 */
@Component
public class StaticTankConvertDataMgr extends BaseDataMgr {

	@Autowired
	private StaticDataDao staticDataDao;

	private Map<Integer, List<StaticTankConvert>> convertMap = new HashMap<>();

	public List<StaticTankConvert> getTankConvertListByAwardId(int awardId) {
		return convertMap.get(awardId);
	}
	
	public StaticTankConvert getTankConvertConfig(int awardId, int tankId) {
		List<StaticTankConvert> list = getTankConvertListByAwardId(awardId);
		for(StaticTankConvert config : list) {
			if(config.getTankId() == tankId) {
				return config;
			}
		}
		return null;
	}

	@Override
	public void init() {
		try {
			initConvertMap();
		} catch (Exception e) {
			LogUtil.error("坦克转换解析配置出错", e);
		}
	}

	private void initConvertMap() {
		Map<Integer, List<StaticTankConvert>> tempConvertMap = new HashMap<>();
		List<StaticTankConvert> config = staticDataDao.selectStaticTankConvert();

		if (!CheckNull.isEmpty(config)) {
			for (StaticTankConvert tankConvert : config) {
				List<StaticTankConvert> list = tempConvertMap.get(tankConvert.getAwardId());
				if (list == null) {
					list = new ArrayList<StaticTankConvert>();
					tempConvertMap.put(tankConvert.getAwardId(), list);
				}
				list.add(tankConvert);
			}
		}

		this.convertMap.clear();
		this.convertMap = tempConvertMap;
	}

}
