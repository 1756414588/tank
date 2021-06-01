package com.game.dataMgr;

import com.game.constant.AwardType;
import com.game.dao.impl.s.StaticDataDao;
import com.game.domain.s.tactics.*;
import com.game.util.ListHelper;
import com.game.util.LogUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.*;

@Component
public class StaticTacticsDataMgr extends BaseDataMgr {

    @Autowired
    private StaticDataDao staticDataDao;

    private Map<Integer, StaticTactics> tacticsConfig = new HashMap<>();
    private Map<Integer, StaticTacticsTacticsRestrict> tacticsTacticsRestrictConfig = new HashMap<>();
    private Map<Integer, Map<Integer, StaticTacticsUplv>> tacticsUplvConfig = new HashMap<>();
    private Map<Integer, Map<Integer, Map<Integer, StaticTacticsBreak>>> tacticsBreakConfig = new HashMap<>();
    private Map<Integer, Map<Integer, Map<Integer, StaticTacticsTankSuit>>> tacticsTankSuitConfig = new HashMap<>();
    private Map<Integer, Integer> maxUpLevel = new HashMap<>();

    @Override
    public void init() {
        try {
            initConfig();
        } catch (Exception e) {
            LogUtil.error(e);
        }
    }


    /**
     * 解析配置
     */
    private void initConfig() {

        {
            Map<Integer, StaticTactics> tempTacticsConfig = new HashMap<>();
            List<StaticTactics> staticTacticsList = staticDataDao.selectStaticTactics();
            for (StaticTactics s : staticTacticsList) {
                tempTacticsConfig.put(s.getTacticsId(), s);
            }
            tacticsConfig.clear();
            tacticsConfig = tempTacticsConfig;

        }


        {

            Map<Integer, StaticTacticsTacticsRestrict> temptacticsTacticsRestrictConfig = new HashMap<>();
            List<StaticTacticsTacticsRestrict> tacticsTacticsRestrictList = staticDataDao.selectStaticTacticsTacticsRestrict();
            for (StaticTacticsTacticsRestrict s : tacticsTacticsRestrictList) {
                temptacticsTacticsRestrictConfig.put(s.getTacticsType1(), s);
            }
            tacticsTacticsRestrictConfig.clear();
            tacticsTacticsRestrictConfig = temptacticsTacticsRestrictConfig;

        }


        {
            Map<Integer, Map<Integer, StaticTacticsUplv>> tempTtacticsUplvConfig = new HashMap<>();
            List<StaticTacticsUplv> tacticsUplvList = staticDataDao.selectStaticTacticsUplv();
            for (StaticTacticsUplv s : tacticsUplvList) {

                if (!tempTtacticsUplvConfig.containsKey(s.getQuality())) {
                    tempTtacticsUplvConfig.put(s.getQuality(), new HashMap<Integer, StaticTacticsUplv>());
                }
                tempTtacticsUplvConfig.get(s.getQuality()).put(s.getLv(), s);

                if (!maxUpLevel.containsKey(s.getQuality())) {
                    maxUpLevel.put(s.getQuality(), 0);
                }

                if (maxUpLevel.get(s.getQuality()) < s.getLv()) {
                    maxUpLevel.put(s.getQuality(), s.getLv());
                }

            }
            tacticsUplvConfig.clear();
            tacticsUplvConfig = tempTtacticsUplvConfig;
        }


        {
            Map<Integer, Map<Integer, Map<Integer, StaticTacticsBreak>>> tempTacticsBreakConfig = new HashMap<>();
            List<StaticTacticsBreak> tacticsBreakList = staticDataDao.selectStaticTacticsBreak();
            for (StaticTacticsBreak s : tacticsBreakList) {

                if (!tempTacticsBreakConfig.containsKey(s.getQuality())) {
                    tempTacticsBreakConfig.put(s.getQuality(), new HashMap<Integer, Map<Integer, StaticTacticsBreak>>());
                }

                if (!tempTacticsBreakConfig.get(s.getQuality()).containsKey(s.getTacticsType())) {
                    tempTacticsBreakConfig.get(s.getQuality()).put(s.getTacticsType(), new HashMap<Integer, StaticTacticsBreak>());
                }

                tempTacticsBreakConfig.get(s.getQuality()).get(s.getTacticsType()).put(s.getLv(), s);
            }
            tacticsBreakConfig.clear();
            tacticsBreakConfig = tempTacticsBreakConfig;
        }


        {

            Map<Integer, Map<Integer, Map<Integer, StaticTacticsTankSuit>>> tempTacticsTankSuitConfig = new HashMap<>();
            List<StaticTacticsTankSuit> tacticsTankSuitkList = staticDataDao.selectStaticTacticsTankSuit();
            for (StaticTacticsTankSuit s : tacticsTankSuitkList) {

                if (!tempTacticsTankSuitConfig.containsKey(s.getQuality())) {
                    tempTacticsTankSuitConfig.put(s.getQuality(), new HashMap<Integer, Map<Integer, StaticTacticsTankSuit>>());
                }

                if (!tempTacticsTankSuitConfig.get(s.getQuality()).containsKey(s.getTacticsType())) {
                    tempTacticsTankSuitConfig.get(s.getQuality()).put(s.getTacticsType(), new HashMap<Integer, StaticTacticsTankSuit>());
                }

                tempTacticsTankSuitConfig.get(s.getQuality()).get(s.getTacticsType()).put(s.getTankType(), s);
            }
            tacticsTankSuitConfig.clear();
            tacticsTankSuitConfig = tempTacticsTankSuitConfig;

        }


    }


    /**
     * 万能碎片
     *
     * @return
     */
    public StaticTactics getWanNengTacticsConfig() {
        return tacticsConfig.get(901);
    }

    public List<StaticTactics> getTacticsConfigAll() {
        return new ArrayList<>(tacticsConfig.values());
    }

    public StaticTactics getTacticsConfig(int tacticsId) {
        return tacticsConfig.get(tacticsId);
    }

    public StaticTacticsTacticsRestrict getTacticsTacticsRestrictConfig(int tacticsType) {
        return tacticsTacticsRestrictConfig.get(tacticsType);
    }

    public StaticTacticsUplv getTacticsUplvConfig(int quality, int level) {
        if (!tacticsUplvConfig.containsKey(quality)) {
            return null;
        }
        return tacticsUplvConfig.get(quality).get(level);
    }


    /**
     * 获取突破返还的碎片
     *
     * @param quality
     * @param level
     * @param isTp
     * @param tacticsType
     * @return
     */
    public List<List<Integer>> getTpItem(int tacticsId, int quality, int level, boolean isTp, int tacticsType, float bl) {

        Map<Integer, StaticTacticsUplv> uplvMap = tacticsUplvConfig.get(quality);
        Collection<StaticTacticsUplv> values = uplvMap.values();


        List<List<Integer>> result = new ArrayList<>();

        for (StaticTacticsUplv config : values) {

            if (isTp) {
                if (config.getLv() <= level && config.getBreakOn() == 1) {

                    StaticTacticsBreak breakConfig = getStaticTacticsBreakConfig(quality, tacticsType, config.getLv());
                    if (breakConfig != null) {

                        result.addAll(breakConfig.getBreakNeed());
                        ArrayList<Integer> arrayList = new ArrayList<>();
                        arrayList.add(AwardType.TACTICS_SLICE);
                        arrayList.add(tacticsId);
                        arrayList.add(breakConfig.getBreakChips());
                        result.add(arrayList);

                    }
                }
            } else {
                if (config.getLv() < level && config.getBreakOn() == 1) {
                    StaticTacticsBreak breakConfig = getStaticTacticsBreakConfig(quality, tacticsType, config.getLv());
                    if (breakConfig != null) {
                        result.addAll(new ArrayList<>(breakConfig.getBreakNeed()));

                        ArrayList<Integer> arrayList = new ArrayList<>();
                        arrayList.add(AwardType.TACTICS_SLICE);
                        arrayList.add(tacticsId);
                        arrayList.add(breakConfig.getBreakChips());
                        result.add(arrayList);
                    }
                }
            }
        }


        if (result.isEmpty()) {
            return result;
        }

        Map<Integer, Map<Integer, Integer>> mapItem = new HashMap<>();

        for (List<Integer> list : result) {
            int type = list.get(0);
            int itemId = list.get(1);
            int itemCount = list.get(2);
            if (!mapItem.containsKey(type)) {
                mapItem.put(type, new HashMap<Integer, Integer>());
            }
            if (!mapItem.get(type).containsKey(itemId)) {
                mapItem.get(type).put(itemId, 0);
            }
            mapItem.get(type).put(itemId, mapItem.get(type).get(itemId) + itemCount);
        }

        List<List<Integer>> newResult = new ArrayList<>();
        for (Integer type : mapItem.keySet()) {
            Set<Map.Entry<Integer, Integer>> entries = mapItem.get(type).entrySet();
            for (Map.Entry<Integer, Integer> e : entries) {
                List<Integer> temp = new ArrayList<>();
                temp.add(type);
                temp.add(e.getKey());
                Integer count = (int) Math.ceil(e.getValue() * bl);
                temp.add(count);
                newResult.add(temp);
            }
        }
        return newResult;
    }

    public StaticTacticsBreak getStaticTacticsBreakConfig(int quality, int tacticsType, int level) {
        if (!tacticsBreakConfig.containsKey(quality)) {
            return null;
        }

        if (!tacticsBreakConfig.get(quality).containsKey(tacticsType)) {
            return null;
        }
        return tacticsBreakConfig.get(quality).get(tacticsType).get(level);
    }


    public StaticTacticsTankSuit getStaticTacticsTankSuitConfig(int quality, int tacticsType, int tankType) {
        if (!tacticsTankSuitConfig.containsKey(quality)) {
            return null;
        }

        if (!tacticsTankSuitConfig.get(quality).containsKey(tacticsType)) {
            return null;
        }

        return tacticsTankSuitConfig.get(quality).get(tacticsType).get(tankType);
    }

    public int getMaxUpLevel(int quality) {
        if (!maxUpLevel.containsKey(quality)) {
            return 0;
        }
        return maxUpLevel.get(quality);
    }
}
