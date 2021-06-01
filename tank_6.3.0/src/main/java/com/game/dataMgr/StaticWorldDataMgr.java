/**
 * @Title: StaticWorldDataMgr.java
 * @Package com.game.dataMgr
 * @Description:
 * @author ZhangJun
 * @date 2015年9月15日 下午12:06:57
 * @version V1.0
 */
package com.game.dataMgr;

import java.util.*;
import java.util.Map.Entry;

import com.game.domain.s.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.game.dao.impl.s.StaticDataDao;
import com.game.util.LogUtil;
import com.game.util.RandomHelper;

/**
 * @author ZhangJun
 * @ClassName: StaticWorldDataMgr
 * @Description: 世界地图相关配置
 * @date 2015年9月15日 下午12:06:57
 */
@Component
public class StaticWorldDataMgr extends BaseDataMgr {
    @Autowired
    private StaticDataDao staticDataDao;

    private Map<Integer, StaticMine> mineMap;

    private Map<Integer, StaticMine> seniorMineMap;

    private Map<Integer, StaticScout> scoutMap;

    private Map<Integer, Map<Integer, StaticMineLv>> mineLvMap = new HashMap<>();

    private List<StaticSlot> slots;

    // MAP<LV, LIST>
    private Map<Integer, List<StaticMineForm>> formMap;

    // KEY0:等级,KEY1:品质,VALUE:矿点品质信息
    private TreeMap<Integer, TreeMap<Integer, StaticMineQuality>> lqMap;

    private Map<Integer, StaticAirship> airshipMap;


    private Map<Integer, StaticScoutBonus> scoutBonus = new HashMap<>();
    private Map<Integer, StaticScoutfreeze> scoutfreeze = new HashMap<>();

    private StaticScoutBonus staticScoutBonus;
    private StaticScoutfreeze staticScoutfreeze;


    private List<StaticWorldMine> worldMine = new ArrayList<>();
    private List<StaticWorldMineSpeed> worldMineSpeed = new ArrayList<>();

    /**
     * 跨服军矿配置
     */
    private Map<Integer, StaticMine> crossSeniorMineMap;

    /**
     * Overriding: init
     *
     * @see com.game.dataMgr.BaseDataMgr#init()
     */
    @Override
    public void init() {
        this.mineMap = staticDataDao.selectMine();
        this.seniorMineMap = staticDataDao.selectMineSenior();
        this.scoutMap = staticDataDao.selectScout();

        this.worldMine = staticDataDao.selectWorldMineLv();

        this.crossSeniorMineMap = staticDataDao.selectCrossMine();

        Collections.sort(worldMine, new Comparator<StaticWorldMine>() {
            @Override
            public int compare(StaticWorldMine o1, StaticWorldMine o2) {

                if( o2.getWorldExp() > o1.getWorldExp()){
                    return 1;
                }
                if( o2.getWorldExp() < o1.getWorldExp()){
                    return -1;
                }

                return 0;
            }
        });

        List<StaticMineLv> mineLvMap = staticDataDao.selectMineLv();
        for (StaticMineLv cong : mineLvMap) {
            if (!this.mineLvMap.containsKey(cong.getType())) {
                this.mineLvMap.put(cong.getType(), new HashMap<Integer, StaticMineLv>());
            }
            this.mineLvMap.get(cong.getType()).put(cong.getLv(), cong);
        }

        this.worldMineSpeed = staticDataDao.selectStaticWorldMineSpeed();

        Collections.sort(worldMineSpeed, new Comparator<StaticWorldMineSpeed>() {
            @Override
            public int compare(StaticWorldMineSpeed o1, StaticWorldMineSpeed o2) {
                return o1.getId() - o2.getId();
            }
        });

        this.slots = staticDataDao.selectSlot();
        this.airshipMap = staticDataDao.selectStaticAirshipMap();

        initForm();
        initMineQuality();


        List<StaticScoutBonus> staticScoutBonuses = staticDataDao.selectStaticScoutBonus();
        scoutBonus.clear();
        if (staticScoutBonuses != null && !staticScoutBonuses.isEmpty()) {
            for (StaticScoutBonus c : staticScoutBonuses) {
                scoutBonus.put(c.getLv(), c);
            }

            staticScoutBonus = staticScoutBonuses.get(staticScoutBonuses.size() - 1);
        }


        List<StaticScoutfreeze> StaticScoutfreezes = staticDataDao.selectStaticScoutfreeze();
        scoutfreeze.clear();
        if (StaticScoutfreezes != null && !StaticScoutfreezes.isEmpty()) {
            for (StaticScoutfreeze c : StaticScoutfreezes) {
                scoutfreeze.put(c.getTime(), c);
            }

            staticScoutfreeze = StaticScoutfreezes.get(StaticScoutfreezes.size() - 1);

        }


    }

    public StaticScoutfreeze getStaticScoutfreeze(int time) {
        StaticScoutfreeze s = scoutfreeze.get(time);
        if (s == null) {
            s = staticScoutfreeze;
        }
        return s;
    }

    public StaticScoutBonus getStaticScoutBonus(int lv) {
        StaticScoutBonus s = scoutBonus.get(lv);
        if (s == null) {
            s = staticScoutBonus;
        }
        return s;
    }

    public void setStaticScoutBonus(StaticScoutBonus staticScoutBonus) {
        this.staticScoutBonus = staticScoutBonus;
    }

    /**
     * @Title: initForm
     * @Description: 矿点部队信息 void
     */
    private void initForm() {
        List<StaticMineForm> list = staticDataDao.selectMineForm();
        Map<Integer, List<StaticMineForm>> formMap = new HashMap<Integer, List<StaticMineForm>>();
        for (StaticMineForm staticMineForm : list) {
            // checkForm(staticMineForm);
            List<StaticMineForm> one = formMap.get(staticMineForm.getLv());
            if (one == null) {
                one = new ArrayList<>();
                formMap.put(staticMineForm.getLv(), one);
            }

            one.add(staticMineForm);
        }
        this.formMap = formMap;
    }

    /**
     * 加载世界地图矿点品质信息
     */
    private void initMineQuality() {
        Map<Integer, StaticMineQuality> allMap = staticDataDao.selectMineQulity();
        TreeMap<Integer, TreeMap<Integer, StaticMineQuality>> lqMap0 = new TreeMap<>();
        for (Entry<Integer, StaticMineQuality> entry : allMap.entrySet()) {
            StaticMineQuality data = entry.getValue();
            TreeMap<Integer, StaticMineQuality> lqMap = lqMap0.get(data.getMineLv());
            if (lqMap == null) {
                lqMap0.put(data.getMineLv(), lqMap = new TreeMap<>());
            }
            lqMap.put(data.getQuality(), data);
        }
        this.lqMap = lqMap0;
    }

    public boolean checkForm(StaticMineForm staticMineForm) {
        int formCount = 0;
        for (List<Integer> e : staticMineForm.getForm()) {
            if (!e.isEmpty()) {
                formCount++;
            }
        }

        int attrCount = 0;
        for (List<Integer> e : staticMineForm.getAttr()) {
            if (!e.isEmpty()) {
                attrCount++;
            }
        }

        if (formCount != attrCount) {
            System.err.println("check StaticMineForm " + staticMineForm.getKeyId() + " |" + formCount + " " + attrCount);
            return false;
        }

        return true;
    }

    public StaticMine getMine(int pos) {
        return mineMap.get(pos);
    }

    public StaticMine getSeniorMine(int pos) {
        return seniorMineMap.get(pos);
    }

    public StaticScout getScout(int lv) {
        return scoutMap.get(lv);
    }

    /**
     * 获得指定矿点等级的随机阵容
     *
     * @param lv
     * @return StaticMineForm
     */
    public StaticMineForm randomForm(int lv) {
        List<StaticMineForm> one = formMap.get(lv);
        return one.get(RandomHelper.randomInSize(one.size()));
    }


    /**
     * 世界矿等级
     *
     * @param baseMineLv 矿点的基础等级
     * @param worldLv    世界矿点编制等级
     * @return
     */
    public StaticMineLv getStaticMineLvWolrd(int baseMineLv, int worldLv) {
        return getStaticMineLv(1, baseMineLv + worldLv);
    }

    /**
     * 军矿矿等级
     *
     * @param mineLv
     * @return
     */
    public StaticMineLv getStaticMineLvSenior(int mineLv, int worldLv) {
        return getStaticMineLv(2, mineLv+worldLv);
    }


    private StaticMineLv getStaticMineLv(int type, int mineLv) {
        Map<Integer, StaticMineLv> mineLvMap = this.mineLvMap.get(type);
        return mineLvMap.get(mineLv);
    }

    /**
     * Method: getSlot
     *
     * @param playerNumber
     * @return int
     * @Description: 根据地图上的玩家数量，分配新进入地图玩家的slot(0 ~ 399)
     */
    public int getSlot(int playerNumber) {
        int index = playerNumber / 400;
        if (index > 199) {
            return RandomHelper.randomInSize(400);
        } else {
            // return 125;
            StaticSlot staticSlot = slots.get(index);
            if (playerNumber % 2 == 0) {
                return staticSlot.getSlotA();
            } else {
                return staticSlot.getSlotB();
            }
        }
    }

    public StaticMineQuality getStaticWorldMineQuality(int lv, int qua) {
        Map<Integer, StaticMineQuality> qMap = lqMap.get(lv);
        StaticMineQuality data = qMap != null ? qMap.get(qua) : null;
        if (data == null) {
            LogUtil.error(String.format("not found lv :%d, qua :%d mine", lv, qua));
        }
        return data;
    }

    public boolean isMaxQuality(int lv, int qua) {
        TreeMap<Integer, StaticMineQuality> qMap = lqMap.get(lv);
        if (qMap == null) {
            LogUtil.error(String.format("not found lv :%d qua list ", lv));
            return true;// 数据异常不让升级
        }
        return qua >= qMap.lastKey();
    }

    public boolean isMinQulity(int lv, int qua) {
        TreeMap<Integer, StaticMineQuality> qMap = lqMap.get(lv);
        if (qMap == null) {
            LogUtil.error(String.format("not found lv :%d qua list ", lv));
            return true;
        }
        return qua <= qMap.firstKey();
    }

    public Map<Integer, StaticAirship> getAirshipMap() {
        return airshipMap;
    }

    /**
     * 根据地图位置找到飞艇
     *
     * @param pos
     * @return
     */
    public StaticAirship getStaticAirshipByPos(int pos) {
        for (Entry<Integer, StaticAirship> entry : airshipMap.entrySet()) {
            if (entry.getValue().getPos() == pos)
                return entry.getValue();
        }
        return null;
    }


    /**
     * 获取世界编辑经验配置等级
     *
     * @param exp
     * @return
     */
    public StaticWorldMine getStaticWorldMine(long exp) {

        if (exp < 0) {
            exp = 0;
        }

        for (StaticWorldMine c : worldMine) {
            if (exp >= c.getWorldExp()) {
                return c;
            }
        }
        return null;
    }


    public float getWorldMineSpeed(long exp) {
        for (StaticWorldMineSpeed w : worldMineSpeed) {
            if (exp >= w.getCapBegin() && exp <= w.getCapEnd()) {
                float s = ((w.getA() / 10000000000.0f) * exp + (w.getB() / 1000.0f)) * 100;
                return s;
            }
        }
        return 0;
    }


    /**
     * 获取跨服军矿配置
     * @param pos
     * @return
     */
    public StaticMine getCrossSeniorMine(int pos) {
        return crossSeniorMineMap.get(pos);
    }


    /**
     * 军矿矿等级
     *
     * @param mineLv
     * @return
     */
    public StaticMineLv getCrossMineLvSenior(int mineLv) {
        return getStaticMineLv(3, mineLv);
    }
}
