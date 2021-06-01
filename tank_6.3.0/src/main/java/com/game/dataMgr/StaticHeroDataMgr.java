package com.game.dataMgr;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.game.dao.impl.s.StaticDataDao;
import com.game.domain.s.StaticHero;
import com.game.domain.s.StaticHeroAwakenSkill;
import com.game.domain.s.StaticHeroPut;

/**
 * @author ChenKui
 * @version 创建时间：2015-9-1 上午11:12:07
 * @Description 将领相关
 */
@Component
public class StaticHeroDataMgr extends BaseDataMgr {
	@Autowired
	private StaticDataDao staticDataDao;

	private Map<Integer, StaticHero> heroMap = new HashMap<>();

	private Map<Integer, StaticHero> awakenHeros = new HashMap<>();

	private Map<Integer, List<StaticHero>> starMapList = new HashMap<>();

	private Map<Integer, List<StaticHero>> starLvMapList = new HashMap<>();
	
	private Map<String, StaticHeroAwakenSkill> heroAwakenSkillMap = new HashMap<>();
	private Map<Integer, StaticHeroAwakenSkill> heroAwakenSkillByIdMap = new HashMap<>();

	private Map<Integer, StaticHeroPut> heroPutMap;
	
	public Map<Integer, StaticHeroPut> getHeroPutMap() {
		return heroPutMap;
	}

	@Override
	public void init() {
		Map<Integer, StaticHero> heroMap = staticDataDao.selectHeroMap();
		this.heroMap = heroMap;

		Iterator<StaticHero> it = heroMap.values().iterator();
		Map<Integer, List<StaticHero>> starMapList = new HashMap<>();
		Map<Integer, List<StaticHero>> starLvMapList = new HashMap<>();
		while (it.hasNext()) {
			StaticHero next = it.next();
			int star = next.getStar();
			List<StaticHero> llList = starMapList.get(star);
			if (llList == null) {
				llList = new ArrayList<StaticHero>();
				starMapList.put(star, llList);
			}
			llList.add(next);

			//判断觉醒将领
            if (next.getAwakenHeroId()>0) {
                StaticHero awakenData = this.heroMap.get(next.getAwakenHeroId());
                if (awakenData != null) {
                    awakenHeros.put(next.getAwakenHeroId(), awakenData);
                }
            }

			if (next.getLevel() != 0 || next.getCompound() != 0) {
				continue;
			}
			List<StaticHero> llLvList = starLvMapList.get(star);
			if (llLvList == null) {
				llLvList = new ArrayList<StaticHero>();
				starLvMapList.put(star, llLvList);
			}
			llLvList.add(next);

        }
		this.starMapList = starMapList;
		this.starLvMapList = starLvMapList;
		
		Map<String, StaticHeroAwakenSkill> heroAwakenSkillMap = new HashMap<String, StaticHeroAwakenSkill>();
		Map<Integer, StaticHeroAwakenSkill> tempHeroAwakenSkillByIdMap = new HashMap<Integer, StaticHeroAwakenSkill>();
		List<StaticHeroAwakenSkill>  heroAwakenSkillList = staticDataDao.selectStaticHeroAwakenSkillList();
		for (StaticHeroAwakenSkill staticHeroAwakenSkill: heroAwakenSkillList) {
			heroAwakenSkillMap.put(getAwakenSkillKey(staticHeroAwakenSkill.getId(), staticHeroAwakenSkill.getLevel()), staticHeroAwakenSkill);
			tempHeroAwakenSkillByIdMap.put(staticHeroAwakenSkill.getId(),staticHeroAwakenSkill);

		}
		this.heroAwakenSkillMap = heroAwakenSkillMap;
		this.heroAwakenSkillByIdMap = tempHeroAwakenSkillByIdMap;

		heroPutMap = staticDataDao.selectHeroPutMap();		
	}

	public StaticHero getStaticHero(int heroId) {
		return heroMap.get(heroId);
	}

	public List<StaticHero> getStarList(int star) {
		return starMapList.get(star);
	}

	public List<StaticHero> getStarListLv(int star) {
		return starLvMapList.get(star);
	}

	public int costSoul(int star) {
		if (star < 1 || star > 4) {
			return 0;
		}
		return starMapList.get(star).get(0).getSoul();
	}
	
	private String getAwakenSkillKey(int id,int level){
		return id + "_" + level;
	}

	public StaticHeroAwakenSkill getHeroAwakenSkill(int id,int level) {
		return heroAwakenSkillMap.get(getAwakenSkillKey(id, level));
	}

	public Map<Integer, StaticHero> getStaticHeroMap(){
	    return heroMap;
    }

    /**
     * 判断一个英雄是不是觉醒英雄
     * @param heroId
     * @return
     */
	public boolean isAwakenHero(int heroId){
	    return awakenHeros.containsKey(heroId);
    }

	public StaticHeroAwakenSkill getHeroAwakenSkillById(int Id) {
		return heroAwakenSkillByIdMap.get(Id);
	}
}
