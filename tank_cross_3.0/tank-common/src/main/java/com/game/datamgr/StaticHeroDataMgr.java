package com.game.datamgr;

import com.game.dao.impl.s.StaticDataDao;
import com.game.domain.s.StaticHero;
import com.game.domain.s.StaticHeroAwakenSkill;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.*;

/**
 * @author ChenKui
 * @version 创建时间：2015-9-1 上午11:12:07
 * @declare
 */
@Component
public class StaticHeroDataMgr extends BaseDataMgr {
  @Autowired private StaticDataDao staticDataDao;

  private Map<Integer, StaticHero> heroMap = new HashMap<Integer, StaticHero>();

  private Map<Integer, List<StaticHero>> starMapList = new HashMap<Integer, List<StaticHero>>();

  private Map<Integer, List<StaticHero>> starLvMapList = new HashMap<Integer, List<StaticHero>>();

  private Map<String, StaticHeroAwakenSkill> heroAwakenSkillMap =
      new HashMap<String, StaticHeroAwakenSkill>();
  private Map<Integer, StaticHeroAwakenSkill> heroAwakenSkillByIdMap = new HashMap<>();

  @Override
  public void init() {
    heroMap = staticDataDao.selectHeroMap();
    Iterator<StaticHero> it = heroMap.values().iterator();
    while (it.hasNext()) {
      StaticHero next = it.next();
      int star = next.getStar();
      List<StaticHero> llList = starMapList.get(star);
      if (llList == null) {
        llList = new ArrayList<StaticHero>();
        starMapList.put(star, llList);
      }

      llList.add(next);

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
    Map<Integer, StaticHeroAwakenSkill> tempHeroAwakenSkillByIdMap =
        new HashMap<Integer, StaticHeroAwakenSkill>();

    Map<String, StaticHeroAwakenSkill> heroAwakenSkillMap =
        new HashMap<String, StaticHeroAwakenSkill>();
    List<StaticHeroAwakenSkill> heroAwakenSkillList =
        staticDataDao.selectStaticHeroAwakenSkillList();
    for (StaticHeroAwakenSkill staticHeroAwakenSkill : heroAwakenSkillList) {
      heroAwakenSkillMap.put(
          getAwakenSkillKey(staticHeroAwakenSkill.getId(), staticHeroAwakenSkill.getLevel()),
          staticHeroAwakenSkill);
      tempHeroAwakenSkillByIdMap.put(staticHeroAwakenSkill.getId(), staticHeroAwakenSkill);
    }
    this.heroAwakenSkillMap = heroAwakenSkillMap;
    this.heroAwakenSkillByIdMap = tempHeroAwakenSkillByIdMap;
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

  private String getAwakenSkillKey(int id, int level) {
    return id + "_" + level;
  }

  public StaticHeroAwakenSkill getHeroAwakenSkill(int id, int level) {
    return heroAwakenSkillMap.get(getAwakenSkillKey(id, level));
  }

  public StaticHeroAwakenSkill getHeroAwakenSkillById(int Id) {
    return heroAwakenSkillByIdMap.get(Id);
  }
}
