package com.game.dataMgr;

import com.game.dao.impl.s.StaticDataDao;
import com.game.domain.s.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * @author GuiJie
 * @description 红色方案
 * @created 2018/03/20 11:32
 */
@Component
public class StaticRedPlanMgr extends BaseDataMgr {

    @Autowired
    private StaticDataDao staticDataDao;

    private Map<Integer, Map<Integer, StaticRedPlanArea>> redAreaConfig = new HashMap<>();
    private Map<Integer, List<StaticRedPlanArea>> redAreaConfigList = new HashMap<>();

    private Map<Integer, Map<Integer, Map<Integer, StaticRedPlanPoint>>> redPointConfig = new HashMap<>();

    private Map<Integer, Map<Integer, StaticRedPlanShop>> redShopConfig = new HashMap<>();
    private Map<Integer, List<StaticRedPlanShop>> redShopConfigList = new HashMap<>();


    private Map<Integer, StaticRedPlanFuel> fuelConfig = new HashMap<>();
    private int maxCount = 0;

    /**
     * 区域对应开始点
     */
    private Map<Integer, Map<Integer, Integer>> startPoint = new HashMap<>();
    /**
     * 区域对应终点
     */
    private Map<Integer, Map<Integer, Integer>> stopPoint = new HashMap<>();

    private StaticRedPlanFuelLimit redPalnConfig;

    @Override
    public void init() {

        redAreaConfig.clear();
        redPointConfig.clear();
        redShopConfig.clear();
        startPoint.clear();
        stopPoint.clear();
        fuelConfig.clear();
        redAreaConfigList.clear();
        redShopConfigList.clear();
        maxCount =0;

        List<StaticRedPlanArea> staticRedPlanAreas = staticDataDao.selectStaticRedPlanArea();

        if (staticRedPlanAreas != null && !staticRedPlanAreas.isEmpty()) {
            for (StaticRedPlanArea c : staticRedPlanAreas) {

                if (!redAreaConfig.containsKey(c.getAwardId())) {
                    redAreaConfig.put(c.getAwardId(), new HashMap<Integer, StaticRedPlanArea>());
                }

                redAreaConfig.get(c.getAwardId()).put(c.getAreaId(), c);

                if (!redAreaConfigList.containsKey(c.getAwardId())) {
                    redAreaConfigList.put(c.getAwardId(), new ArrayList<StaticRedPlanArea>());
                }
                redAreaConfigList.get(c.getAwardId()).add(c);
            }
        }

        List<StaticRedPlanPoint> staticRedPlanPoints = staticDataDao.selectStaticRedPlanPoint();
        if (staticRedPlanPoints != null && !staticRedPlanPoints.isEmpty()) {
            for (StaticRedPlanPoint c : staticRedPlanPoints) {


                if (!redPointConfig.containsKey(c.getAwardId())) {
                    redPointConfig.put(c.getAwardId(), new HashMap<Integer, Map<Integer, StaticRedPlanPoint>>());
                }

                if (!redPointConfig.get(c.getAwardId()).containsKey(c.getAreaInclude())) {
                    redPointConfig.get(c.getAwardId()).put(c.getAreaInclude(), new HashMap<Integer, StaticRedPlanPoint>());
                }
                redPointConfig.get(c.getAwardId()).get(c.getAreaInclude()).put(c.getPid(), c);

                //'type:点的类型，0起点 1终点 2据点 3补给点',
                if (c.getType() == 0) {

                    if (!startPoint.containsKey(c.getAwardId())) {
                        startPoint.put(c.getAwardId(), new HashMap<Integer, Integer>());

                    }
                    startPoint.get(c.getAwardId()).put(c.getAreaInclude(), c.getPid());
                }

                if (c.getType() == 1) {
                    if (!stopPoint.containsKey(c.getAwardId())) {
                        stopPoint.put(c.getAwardId(), new HashMap<Integer, Integer>());
                    }
                    stopPoint.get(c.getAwardId()).put(c.getAreaInclude(), c.getPid());
                }
            }
        }


        List<StaticRedPlanShop> staticRedPlanShops = staticDataDao.selectStaticRedPlanShop();
        if (staticRedPlanShops != null && !staticRedPlanShops.isEmpty()) {
            for (StaticRedPlanShop c : staticRedPlanShops) {

                if (!redShopConfig.containsKey(c.getAwardId())) {
                    redShopConfig.put(c.getAwardId(), new HashMap<Integer, StaticRedPlanShop>());
                }
                redShopConfig.get(c.getAwardId()).put(c.getGoodId(), c);


                if (!redShopConfigList.containsKey(c.getAwardId())) {
                    redShopConfigList.put(c.getAwardId(), new ArrayList<StaticRedPlanShop>());
                }
                redShopConfigList.get(c.getAwardId()).add(c);
            }
        }


        List<StaticRedPlanFuel> staticRedPlanFuels = staticDataDao.selectStaticRedPlanFuel();
        if (staticRedPlanFuels != null && !staticRedPlanFuels.isEmpty()) {
            for (StaticRedPlanFuel c : staticRedPlanFuels) {
                fuelConfig.put(c.getAmount(), c);
                if( c.getAmount() > maxCount ){
                    maxCount = c.getAmount();
                }
            }
        }


        List<StaticRedPlanFuelLimit> staticRedPlanFuelLimits = staticDataDao.selectStaticRedPlanFuelLimit();
        if (staticRedPlanFuelLimits != null && !staticRedPlanFuelLimits.isEmpty()) {
            redPalnConfig = staticRedPlanFuelLimits.get(0);
        }
    }


    public StaticRedPlanArea getRedAreaConfig(int activateId, int areaId) {
        return redAreaConfig.get(activateId).get(areaId);
    }

    public List<StaticRedPlanArea> getRedAreaConfig(int activateId) {
        return new ArrayList<>(redAreaConfig.get(activateId).values());
    }

    public StaticRedPlanPoint getRedPointConfig(int activateId, int areaId, int pointId) {
        return redPointConfig.get(activateId).get(areaId).get(pointId);
    }

    public List<StaticRedPlanPoint> getRedPointConfig(int activateId, int areaId) {
        Map<Integer, Map<Integer, StaticRedPlanPoint>> integerMapMap = redPointConfig.get(activateId);
        Map<Integer, StaticRedPlanPoint> map = integerMapMap.get(areaId);
        if (map == null) {
            return null;
        }
        return new ArrayList<>(map.values());
    }

    public StaticRedPlanShop getRedShopConfig(int activateId, int goodsId) {
        return redShopConfig.get(activateId).get(goodsId);
    }

    /**
     * 获取区域开始点
     *
     * @param areaId
     * @return
     */
    public int getStartPoint(int activateId, int areaId) {
        Map<Integer, Integer> map = startPoint.get(activateId);
        Integer pointId = map.get(areaId);
        return pointId == null ? 0 : pointId;
    }

    /**
     * 获取区域终点
     *
     * @param areaId
     * @return
     */
    public int getStopPoint(int activateId, int areaId) {
        Map<Integer, Integer> map = stopPoint.get(activateId);
        Integer pointId = map.get(areaId);
        return pointId == null ? 0 : pointId;
    }

    public StaticRedPlanFuel getFuelConfig(int count) {
        if (fuelConfig.containsKey(count)) {
            return fuelConfig.get(count);
        }
        return fuelConfig.get(maxCount);
    }

    public List<StaticRedPlanArea> getRedAreaConfigList(int activateId) {
        return redAreaConfigList.get(activateId);
    }

    /**
     * 获取上一个
     *
     * @param activateId
     * @param areaId
     * @return
     */
    public StaticRedPlanArea getBeforeRedAreaConfig(int activateId, int areaId) {
        List<StaticRedPlanArea> staticRedPlanAreas = redAreaConfigList.get(activateId);
        StaticRedPlanArea redAreaConfig = getRedAreaConfig(activateId, areaId);
        int indexOf = staticRedPlanAreas.indexOf(redAreaConfig);
        if (indexOf - 1 < 0) {
            return null;
        }
        return staticRedPlanAreas.get(indexOf - 1);
    }

    public List<StaticRedPlanShop> getRedShopConfigList(int activateId) {
        return redShopConfigList.get(activateId);
    }

    public StaticRedPlanFuelLimit getRedPalnConfig() {
        return redPalnConfig;
    }
}
