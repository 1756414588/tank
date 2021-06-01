package com.game.datamgr;

import com.game.dao.impl.s.StaticDataDao;
import com.game.domain.s.*;
import com.game.util.RandomHelper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.*;

/**
 * @author ChenKui
 * @version 创建时间：2015-9-10 上午11:12:07
 * @declare
 */
@Component
public class StaticPartyDataMgr extends BaseDataMgr {
    @Autowired
    private StaticDataDao staticDataDao;

    private Map<Integer, Map<Integer, StaticPartyBuildLevel>> buildMap =
            new HashMap<Integer, Map<Integer, StaticPartyBuildLevel>>();

    private Map<Integer, Map<Integer, StaticPartyContribute>> contributeMap =
            new HashMap<Integer, Map<Integer, StaticPartyContribute>>();

    private Map<Integer, StaticPartyLively> livelyMap = new HashMap<Integer, StaticPartyLively>();

    private Map<Integer, StaticPartyProp> propMap = new HashMap<Integer, StaticPartyProp>();

    private Map<Integer, Map<Integer, StaticPartyScience>> scienceMap =
            new HashMap<Integer, Map<Integer, StaticPartyScience>>();

    private Map<Integer, StaticPartyWeal> wealMap = new HashMap<Integer, StaticPartyWeal>();

    private Map<Integer, StaticLiveTask> liveTaskMap = new HashMap<Integer, StaticLiveTask>();

    private Map<Integer, StaticPartyTrend> partyTrendMap = new HashMap<Integer, StaticPartyTrend>();

    private Map<Integer, StaticPartyCombat> partyCombatMap =
            new HashMap<Integer, StaticPartyCombat>();

    private Map<Integer, StaticParty> partyMap = new HashMap<Integer, StaticParty>();

    @Override
    public void init() {
        List<StaticPartyBuildLevel> buildLv = staticDataDao.selectPartyBuildLevel();
        for (StaticPartyBuildLevel e : buildLv) {
            int buildingId = e.getType();
            int buildingLv = e.getBuildLv();
            Map<Integer, StaticPartyBuildLevel> tempMap = buildMap.get(buildingId);
            if (tempMap == null) {
                tempMap = new HashMap<Integer, StaticPartyBuildLevel>();
                buildMap.put(buildingId, tempMap);
            }
            tempMap.put(buildingLv, e);
        }
        livelyMap = staticDataDao.selectPartyLivelyMap();

        List<StaticPartyContribute> contributeList = staticDataDao.selectPartyContribute();
        for (StaticPartyContribute e : contributeList) {
            int resourceId = e.getType();
            int count = e.getCount();
            Map<Integer, StaticPartyContribute> tempMap = contributeMap.get(resourceId);
            if (tempMap == null) {
                tempMap = new HashMap<Integer, StaticPartyContribute>();
                contributeMap.put(resourceId, tempMap);
            }
            tempMap.put(count, e);
        }

        propMap = staticDataDao.selectPartyProp();

        List<StaticPartyScience> scienceLvs = staticDataDao.selectPartyScience();
        for (StaticPartyScience e : scienceLvs) {
            int scienceId = e.getScienceId();
            int scienceLv = e.getScienceLv();
            Map<Integer, StaticPartyScience> tempMap = scienceMap.get(scienceId);
            if (tempMap == null) {
                tempMap = new HashMap<Integer, StaticPartyScience>();
                scienceMap.put(scienceId, tempMap);
            }
            tempMap.put(scienceLv, e);
        }

        wealMap = staticDataDao.selectPartyWealMap();

        liveTaskMap = staticDataDao.selectLiveTaskMap();

        partyTrendMap = staticDataDao.selectTrend();

        partyCombatMap = staticDataDao.selectPartyCombat();

        partyMap = staticDataDao.selectParty();

        initTotalTank();
    }

    private void initTotalTank() {

        Iterator<StaticPartyCombat> it = partyCombatMap.values().iterator();
        while (it.hasNext()) {
            int total = 0;
            StaticPartyCombat staticPartyCombat = (StaticPartyCombat) it.next();
            List<List<Integer>> list = staticPartyCombat.getForm();
            for (List<Integer> one : list) {
                total += one.get(1);
            }
            staticPartyCombat.setTotalTank(total);
        }
    }

    public StaticPartyContribute getStaticContribute(int resourceId, int count) {
        return contributeMap.get(resourceId).get(count);
    }

    public StaticPartyBuildLevel getBuildLevel(int buildingId, int level) {
        return buildMap.get(buildingId).get(level);
    }

    public Map<Integer, StaticPartyProp> getPropMap() {
        return propMap;
    }

    public List<StaticPartyProp> getCommonProp() {
        List<StaticPartyProp> rs = new ArrayList<StaticPartyProp>();
        Iterator<StaticPartyProp> it = propMap.values().iterator();
        while (it.hasNext()) {
            StaticPartyProp next = it.next();
            if (next.getTreasure() == 1) {
                rs.add(next);
            }
        }
        return rs;
    }

    public List<StaticPartyProp> getPartyShopProp() {
        List<StaticPartyProp> rs = new ArrayList<StaticPartyProp>();
        List<int[]> tempList = new ArrayList<int[]>();
        Iterator<StaticPartyProp> it = propMap.values().iterator();
        while (it.hasNext()) {
            StaticPartyProp next = it.next();
            if (next.getTreasure() == 2) {
                int[] entity = {next.getKeyId(), next.getProbability()};
                tempList.add(entity);
            }
        }
        // 随机3个珍品
        for (int i = 0; i < 3; i++) {
            int seeds[] = {0, 0};
            for (int[] e : tempList) {
                seeds[0] += e[1];
            }
            seeds[0] = RandomHelper.randomInSize(seeds[0]);
            Iterator<int[]> its = tempList.iterator();
            while (its.hasNext()) {
                int[] pp = its.next();
                seeds[1] += pp[1];
                if (seeds[0] < seeds[1]) {
                    rs.add(getStaticPartyProp(pp[0]));
                    its.remove();
                    break;
                }
            }
        }
        return rs;
    }

    public StaticPartyProp getStaticPartyProp(int keyId) {
        return propMap.get(keyId);
    }

    public StaticPartyWeal getStaticWeal(int wealLv) {
        return wealMap.get(wealLv);
    }

    public StaticPartyScience getPartyScience(int scienceId, int level) {
        return scienceMap.get(scienceId).get(level);
    }

    public Map<Integer, StaticPartyLively> getLivelyMap() {
        return livelyMap;
    }

    public StaticLiveTask getLiveTask(int taskId) {
        return liveTaskMap.get(taskId);
    }

    public Map<Integer, StaticLiveTask> getLiveTaskMap() {
        return liveTaskMap;
    }

    public Map<Integer, Map<Integer, StaticPartyScience>> getScienceMap() {
        return scienceMap;
    }

    public int costLively(int lively) {
        StaticPartyLively maxLive = getMaxLive();
        if (maxLive != null && maxLive.getLivelyExp() <= lively) {
            lively = lively - maxLive.getCostLively();
            lively = lively < 0 ? 0 : lively;
            return lively;
        }

        int size = livelyMap.size();
        StaticPartyLively entity = null;
        for (int i = 0; i < size; i++) {
            StaticPartyLively ee = livelyMap.get(i + 1);
            if (lively <= ee.getLivelyExp()) {
                entity = ee;
                break;
            }
        }
        if (entity != null) {
            lively = lively - entity.getCostLively();
            lively = lively < 0 ? 0 : lively;
        }
        return lively;
    }

    public StaticPartyLively getMaxLive() {
        StaticPartyLively max = null;
        Iterator<StaticPartyLively> it = livelyMap.values().iterator();
        while (it.hasNext()) {
            StaticPartyLively next = it.next();
            if (max == null) {
                max = next;
            } else {
                if (next.getLivelyExp() > max.getLivelyExp()) {
                    max = next;
                }
            }
        }
        return max;
    }

    public int getPartyLiveBuild(int lively) {
        StaticPartyLively maxLive = getMaxLive();
        if (maxLive != null && maxLive.getLivelyExp() <= lively) {
            return maxLive.getScience();
        }

        int size = livelyMap.size();
        StaticPartyLively entity = null;
        for (int i = 0; i < size; i++) {
            StaticPartyLively ee = livelyMap.get(i + 1);
            if (lively <= ee.getLivelyExp()) {
                entity = ee;
                break;
            }
        }
        if (entity != null) {
            return entity.getScience();
        }
        return 1;
    }

    public int getPartyLiveResource(int lively) {
        int size = livelyMap.size();
        StaticPartyLively entity = null;
        for (int i = 0; i < size; i++) {
            StaticPartyLively ee = livelyMap.get(i + 1);
            if (lively <= ee.getLivelyExp()) {
                entity = ee;
                break;
            }
        }

        if (entity != null) {
            return entity.getResource();
        } else {
            StaticPartyLively ee = livelyMap.get(size);
            if (ee.getLivelyExp() <= lively) {
                return ee.getResource();
            }
        }
        return 0;
    }

    public List<StaticPartyScience> getInitScience() {
        List<StaticPartyScience> rs = new ArrayList<StaticPartyScience>();
        Iterator<Map<Integer, StaticPartyScience>> it = scienceMap.values().iterator();
        while (it.hasNext()) {
            Map<Integer, StaticPartyScience> map = it.next();
            rs.add(map.get(0));
        }
        return rs;
    }

    public StaticPartyTrend getPartyTrend(int trendId) {
        return partyTrendMap.get(trendId);
    }

    public StaticPartyCombat getPartyCombat(int combatId) {
        return partyCombatMap.get(combatId);
    }

    public Map<Integer, StaticPartyCombat> getPartyCombatMap() {
        return partyCombatMap;
    }

    public int getLvNum(int lv) {
        if (partyMap.containsKey(lv)) {
            return partyMap.get(lv).getPartyNum();
        }
        return 0;
    }
}
