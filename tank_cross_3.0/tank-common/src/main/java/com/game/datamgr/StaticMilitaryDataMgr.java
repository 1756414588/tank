package com.game.datamgr;

import com.game.constant.AttrId;
import com.game.constant.MilitaryScienceId;
import com.game.dao.impl.s.StaticDataDao;
import com.game.domain.s.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * @ClassName: StaticMilitaryDataMgr @Description: TODO
 *
 * @author WanYi
 * @date 2016年5月9日 上午11:04:58
 */
@Component
public class StaticMilitaryDataMgr extends BaseDataMgr {

    @Autowired
    private StaticDataDao staticDataDao;

    @Autowired
    private StaticTankDataMgr staticTankDataMgr;

    private List<StaticMilitary> militartList;

    private List<StaticMilitaryDevelopTree> militaryDevelopTreeList;

    private Map<Integer, StaticMilitaryMaterial> militaryMaterialMap;

    private StaticMilitaryBless staticMilitaryBless;

    /** tankId : 科技信息 */
    private Map<Integer, StaticMilitary> militartMap = new HashMap<Integer, StaticMilitary>();

    /** 效率id,pos */
    private Map<Integer, Integer> productPosMap = new HashMap<>();

    /** tankId,效率id */
    private Map<Integer, Integer> tankIdProductMap = new HashMap<>();

    /** tankId,需要激活的科技id */
    private Map<Integer, Integer> tankIdActivateMap = new HashMap<>();

    /** 科技id:科技等级:属性 */
    private Map<Integer, Map<Integer, StaticMilitaryDevelopTree>> militaryDevelopTreeMap =
            new HashMap<Integer, Map<Integer, StaticMilitaryDevelopTree>>();

    /** tankId:scieneceId:scienceId */
    private Map<Integer, Map<Integer, Integer>> tankIdScieneceIdMap =
            new HashMap<Integer, Map<Integer, Integer>>();

    /** 科技id:tankId */
    private Map<Integer, Integer> scicenceIdTankIdMap = new HashMap<Integer, Integer>();

    /** tankId,格子的位置,解锁的格子索引(表示第几个解锁的格子) */
    private Map<Integer, Map<Integer, Integer>> unLockMap =
            new HashMap<Integer, Map<Integer, Integer>>();

    /**
     * Overriding: init
     *
     */
    @Override
    public void init() {
        militartList = staticDataDao.selectStaticMilitary();
        militaryDevelopTreeList = staticDataDao.selectStaticMilitaryDevelopTree();

        militaryMaterialMap = staticDataDao.selectStaticMilitaryMaterial();

        // 初始化militartMap
        initStaticMilitary();

        // 初始化MilitaryDevelopTree
        initStaticMilitaryDevelopTree();

        staticMilitaryBless = staticDataDao.selectStaticMilitaryBless();
        calcDropWeight(staticMilitaryBless);
    }

    private void calcDropWeight(StaticMilitaryBless staticMilitaryBless) {
        List<List<Integer>> list = staticMilitaryBless.getAwardOne();
        if (list != null && !list.isEmpty()) {
            int weight = 0;
            for (List<Integer> one : list) {
                if (one.size() != 4) {
                    continue;
                }

                weight += one.get(3);
            }
            staticMilitaryBless.setWeight(weight);
        }
    }

    /**
     * Method: initStaticMilitaryDevelopTree @Description: TODO
     *
     * @return void
     * @throws
     */
    private void initStaticMilitaryDevelopTree() {
        for (StaticMilitaryDevelopTree info : militaryDevelopTreeList) {
            Map<Integer, StaticMilitaryDevelopTree> temp = militaryDevelopTreeMap.get(info.getId());
            if (temp == null) {
                temp = new HashMap<Integer, StaticMilitaryDevelopTree>();
                militaryDevelopTreeMap.put(info.getId(), temp);
            }
            temp.put(info.getLevel(), info);

            Map<Integer, Integer> scienceMap = tankIdScieneceIdMap.get(info.getTankId());
            if (scienceMap == null) {
                scienceMap = new HashMap<Integer, Integer>();
                tankIdScieneceIdMap.put(info.getTankId(), scienceMap);
            }
            scienceMap.put(info.getId(), info.getId());

            scicenceIdTankIdMap.put(info.getId(), info.getTankId());

            if (info.getAttrId() == AttrId.ACTIVATE) {
                int tankId = info.getEffect().get(0).get(1);
                tankIdActivateMap.put(tankId, info.getId());
            }
        }
    }

    /**
     * Method: initStaticMilitary @Description: TODO
     *
     * @return void
     * @throws
     */
    private void initStaticMilitary() {
        for (StaticMilitary militart : militartList) {

            initMilitaryUnlockConsumeMap(militart);

            militartMap.put(militart.getTankId(), militart);

            List<List<Integer>> list = militart.getGridStatus();
            int index = 0;
            for (int i = 0; i < list.size(); i++) {
                int status = list.get(i).get(0);

                if (militart.getProductScienceId() != 0) {
                    if (status == MilitaryScienceId.EFFICIENCY) {
                        productPosMap.put(militart.getProductScienceId(), i + 1);
                        tankIdProductMap.put(militart.getTankId(), militart.getProductScienceId());
                    }
                }
                if (status == MilitaryScienceId.LOCK) {
                    Map<Integer, Integer> map = unLockMap.get(militart.getTankId());
                    if (map == null) {
                        map = new HashMap<Integer, Integer>();
                        unLockMap.put(militart.getTankId(), map);
                    }
                    map.put(i + 1, index + 1);
                    index++;
                }
            }
        }
    }

    /**
     * Method: initMilitaryUnlockConsumeMap @Description: TODO
     *
     * @param militart
     * @return void
     * @throws
     */
    private void initMilitaryUnlockConsumeMap(StaticMilitary militart) {
        List<List<Integer>> list = militart.getUnLockConsume();
        for (List<Integer> list2 : list) {
            if (list2.size() > 0) {
                int index = list2.get(0);

                List<List<Integer>> templist = militart.getUnLockConsumeMap().get(index);
                if (templist == null) {
                    templist = new ArrayList<List<Integer>>();
                    militart.getUnLockConsumeMap().put(index, templist);
                }
                templist.add(list2);
            }
        }
    }

    /**
     * 通过效率id 获取 存储的位置 Method: getPosByProductId @Description: TODO
     *
     * @param scienceId
     * @return
     * @return int
     * @throws
     */
    public Integer getPosByProductId(int scienceId) {
        return productPosMap.get(scienceId);
    }

    /**
     * 根据坦克id判断类别 Method: getTankBigType @Description: 坦克大类型(1坦克 、 2战车 、 3火炮 、 4火箭 、 5金币坦克 、 6金币战车 、
     * 7金币火炮 、 8 、 金币火箭)<br>
     * 根据tankType 和 canBuild 划分
     *
     * @param tankId
     * @return
     * @return int
     * @throws
     */
    public int getTankBigType(int tankId) {
        StaticTank staticTank = staticTankDataMgr.getStaticTank(tankId);
        int ret = staticTank.getType();
        if (staticTank.getCanBuild() == 1) {
            ret += 4;
        }
        return ret;
    }

    public Map<Integer, Map<Integer, StaticMilitaryDevelopTree>> getMilitaryDevelopTreeMap() {
        return militaryDevelopTreeMap;
    }

    public Map<Integer, Map<Integer, Integer>> getTankIdScieneceIdMap() {
        return tankIdScieneceIdMap;
    }

    /**
     * 通过科技id获取坦克id Method: getTankIdByScienceId @Description: TODO
     *
     * @param scienceId
     * @return
     * @return int
     * @throws
     */
    public int getTankIdByScienceId(int scienceId) {
        return scicenceIdTankIdMap.get(scienceId);
    }

    public StaticMilitary getStaticMilitaryByTankId(int tankId) {
        return militartMap.get(tankId);
    }

    /**
     * 通过科技id，level 获取科技树信息 Method: getStaticMilitaryDevelopTree @Description: TODO
     *
     * @param scieneceId
     * @param level
     * @return
     * @return StaticMilitaryDevelopTree
     * @throws
     */
    public StaticMilitaryDevelopTree getStaticMilitaryDevelopTree(int scieneceId, int level) {
        return militaryDevelopTreeMap.get(scieneceId).get(level);
    }

    /**
     * 获取科技最大等级 Method: getMaxScienceLevel @Description: TODO
     *
     * @param scienceId
     * @return
     * @return int
     * @throws
     */
    public int getMaxScienceLevel(int scienceId) {
        return militaryDevelopTreeMap.get(scienceId).size();
    }

    public List<StaticMilitary> getMilitartList() {
        return militartList;
    }

    /**
     * 通过id获取军工材料 Method: getStaticMilitaryMaterial @Description: TODO
     *
     * @param id
     * @return
     * @return StaticMilitaryMaterial
     * @throws
     */
    public StaticMilitaryMaterial getStaticMilitaryMaterial(int id) {
        return militaryMaterialMap.get(id);
    }

    /**
     * 获取效率id Method: getProductId @Description: TODO
     *
     * @param tankId
     * @return
     * @return Integer
     * @throws
     */
    public Integer getProductId(int tankId) {
        return tankIdProductMap.get(tankId);
    }

    /**
     * 通过tankId 获取激活的科技Id Method: getAcitveId @Description: TODO
     *
     * @param tankId
     * @return
     * @return Integer
     * @throws
     */
    public Integer getAcitveId(int tankId) {
        return tankIdActivateMap.get(tankId);
    }

    /**
     * 通过tankid,pos 获取解锁的格子索引 Method: getUnLockIndex @Description: TODO
     *
     * @param tankId
     * @param pos
     * @return
     * @return Integer
     * @throws
     */
    public Integer getUnLockIndex(int tankId, int pos) {
        Map<Integer, Integer> map = unLockMap.get(tankId);
        if (map == null) {
            return null;
        }
        return map.get(pos);
    }

    public StaticMilitaryBless getStaticMilitaryBless() {
        return staticMilitaryBless;
    }
}
