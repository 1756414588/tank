package com.game.dataMgr;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.game.dao.impl.s.StaticDataDao;
import com.game.domain.s.StaticHonourBuff;
import com.game.domain.s.StaticHonourScoreGold;
import com.game.util.LogUtil;

/**
 * @author: LiFeng
 * @date: 2018年7月30日 上午9:37:18
 * @description:
 */
@Component
public class StaticHonourSurviveMgr extends BaseDataMgr {

	@Autowired
	private StaticDataDao staticDataDao;

	/** key1:阶段，key2:buff类型 */
	private Map<Integer, Map<Integer, StaticHonourBuff>> honourBuff = new HashMap<>();

	private List<StaticHonourScoreGold> honourGold = new ArrayList<>();

	private Map<Integer, StaticHonourScoreGold> honourGoldMap = new HashMap<>();

	@Override
	public void init() {
		try {
			initGold();
			initBuff();
		} catch (Exception e) {
			LogUtil.error("荣耀生存玩法配置出错");
		}
	}

	private void initBuff() {
		Map<Integer, Map<Integer, StaticHonourBuff>> tempBuff = new HashMap<>();
		List<StaticHonourBuff> bufflist = staticDataDao.selectHonourBuffList();
		if (bufflist == null || bufflist.isEmpty()) {
			LogUtil.error("荣耀生存玩法buff配置出错");
			return;
		}
		for (StaticHonourBuff buff : bufflist) {
			int phase = buff.getPhase();
			int type = buff.getType();
			Map<Integer, StaticHonourBuff> map = tempBuff.get(phase);
			if (map == null) {
				map = new HashMap<Integer, StaticHonourBuff>();
				tempBuff.put(phase, map);
			}
			map.put(type, buff);
		}
		honourBuff = tempBuff;
	}

	private void initGold() {
		honourGold.clear();
		honourGoldMap.clear();
		List<StaticHonourScoreGold> scoreGold = staticDataDao.selectHonourScoreGold();
		for (StaticHonourScoreGold gold : scoreGold) {
			honourGoldMap.put(gold.getId(), gold);
		}
		honourGold = scoreGold;
	}

	public StaticHonourBuff getHonourBuff(int phase, int type) {
		Map<Integer, StaticHonourBuff> map = honourBuff.get(phase);
		if (map != null) {
			return map.get(type);
		}
		return null;
	}

	public StaticHonourScoreGold getHonourScoreGoldBySocre(int score) {
		for (StaticHonourScoreGold scoreGold : honourGold) {
			if (score >= scoreGold.getScore1()) {
				return scoreGold;
			}
		}
		return null;
	}

	public StaticHonourScoreGold getHonourScoreGoldByAwardId(int id) {
		return honourGoldMap.get(id);
	}
}
