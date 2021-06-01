package com.game.dataMgr;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.game.dao.impl.s.StaticDataDao;
import com.game.domain.s.StaticRebelAttr;
import com.game.domain.s.StaticRebelHero;
import com.game.domain.s.StaticRebelTeam;
import com.game.util.CheckNull;
import com.game.util.RandomHelper;

/**
 * @ClassName StaticRebelDataMgr.java
 * @Description 叛军配置
 * @author TanDonghai
 * @date 创建时间：2016年9月6日 下午5:20:26
 *
 */
@Component
public class StaticRebelDataMgr extends BaseDataMgr {
	@Autowired
	private StaticDataDao staticDataDao;

	private Map<Integer, StaticRebelAttr> rebelAttrMap;

	// key:rebelType_lv_tankId
	private Map<String, StaticRebelAttr> attrMap;

	// key:rebelType, value:List<levelUp>
	private Map<Integer, List<Integer>> heroLvMap;

	private Map<Integer, StaticRebelHero> rebelHeroMap;

	// rebelType_levelup
	private Map<String, List<StaticRebelHero>> heroMap;

	private Map<Integer, StaticRebelTeam> rebelTeamMap;

	// key:rebelType_lv
	private Map<String, StaticRebelTeam> teamMap;

	@Override
	public void init() {
		Map<Integer, StaticRebelAttr> rebelAttrMap = staticDataDao.selectRebelAttrMap();
		this.rebelAttrMap = rebelAttrMap;
		Map<String, StaticRebelAttr> attrMap = new HashMap<String, StaticRebelAttr>();
		for (StaticRebelAttr attr : rebelAttrMap.values()) {
			attrMap.put(getMapKey(attr.getTeamType(), attr.getEnemyLevel(), attr.getTankId()), attr);
		}
		this.attrMap = attrMap;

		List<StaticRebelHero> heroList = staticDataDao.selectRebelHeroList();
		Map<Integer, List<Integer>> heroLvMap = new HashMap<Integer, List<Integer>>();
		Map<Integer, StaticRebelHero> rebelHeroMap = new HashMap<Integer, StaticRebelHero>();
		Map<String, List<StaticRebelHero>> heroMap = new HashMap<String, List<StaticRebelHero>>();
		for (StaticRebelHero hero : heroList) {
			List<StaticRebelHero> list = heroMap.get(getMapKey(hero.getTeamType(), hero.getLevelup()));
			if (null == list) {
				list = new ArrayList<StaticRebelHero>();
				heroMap.put(getMapKey(hero.getTeamType(), hero.getLevelup()), list);

			}
			List<Integer> heroLvList = heroLvMap.get(hero.getTeamType());
			if (null == heroLvList) {
				heroLvList = new ArrayList<Integer>();
				heroLvMap.put(hero.getTeamType(), heroLvList);
			}
			if (!heroLvList.contains(new Integer(hero.getLevelup()))) {
				heroLvList.add(hero.getLevelup());
			}

			list.add(hero);
			rebelHeroMap.put(hero.getHeroPick(), hero);
		}
		this.heroLvMap = heroLvMap;
		this.rebelHeroMap = rebelHeroMap;
		this.heroMap = heroMap;

		Map<Integer, StaticRebelTeam> rebelTeamMap = staticDataDao.selectRebelTeamMap();
		this.rebelTeamMap = rebelTeamMap;
		Map<String, StaticRebelTeam> teamMap = new HashMap<String, StaticRebelTeam>();
		for (StaticRebelTeam team : rebelTeamMap.values()) {
			teamMap.put(getMapKey(team.getType(), team.getLevel()), team);
		}
		this.teamMap = teamMap;
	}

	private String getMapKey(int type, int level, int tankId) {
		return type + "_" + level + "_" + tankId;
	}

	private String getMapKey(int type, int level) {
		return type + "_" + level;
	}

	public Map<Integer, StaticRebelAttr> getRebelAttrMap() {
		return rebelAttrMap;
	}

	public StaticRebelAttr getRebelAttr(int rebelType, int lv, int tankId) {
		return attrMap.get(getMapKey(rebelType, lv, tankId));
	}

	public StaticRebelHero getRebelHeroById(int heroPick) {
		return rebelHeroMap.get(heroPick);
	}

	/**
	 * 根据传入等级，确定将领等级段，并在该等级段内随机一个将领数据返回
	 * 
	 * @param rebelType
	 * @param lv
	 * @param selectedList 已经在前面随机出来的，不在参加随机
	 * @return
	 */
	public StaticRebelHero randomHeroByType(int rebelType, int lv, List<StaticRebelHero> selectedList) {
		List<Integer> heroLvList = heroLvMap.get(rebelType);
		if (CheckNull.isEmpty(heroLvList)) {
			return null;
		}

		int lvKey = 0;
		for (Integer lvUp : heroLvList) {
			if (lvUp >= lv) {// 计算对应的叛军将领的等级区段
				lvKey = lvUp;
				break;
			}
		}

		StaticRebelHero hero = null;
		List<StaticRebelHero> list = new ArrayList<>(heroMap.get(getMapKey(rebelType, lvKey)));
		if (!CheckNull.isEmpty(list)) {
			// 去除已随机出的
			list.removeAll(selectedList);

			int totalRight = 0;// 计算总概率
			for (StaticRebelHero h : list) {
				totalRight += h.getRight();
			}

			int temp = 0;
			int right = RandomHelper.randomInSize(totalRight);
			for (StaticRebelHero h : list) {
				temp += h.getRight();
				if (temp >= right) {
					hero = h;
				}
			}
		}

		return hero;
	}

	public Map<Integer, StaticRebelTeam> getRebelTeamMap() {
		return rebelTeamMap;
	}

	public StaticRebelTeam getStaticRebelTeam(int rebelId) {
		return rebelTeamMap.get(rebelId);
	}

	public StaticRebelTeam getRebelTeam(int rebelType, int lv) {
		return teamMap.get(getMapKey(rebelType, lv));
	}
}
