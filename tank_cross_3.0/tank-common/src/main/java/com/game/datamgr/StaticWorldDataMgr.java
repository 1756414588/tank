/**
 * @Title: StaticWorldDataMgr.java
 * @Package com.game.dataMgr
 * @Description:
 * @author ZhangJun
 * @date 2015年9月15日 下午12:06:57
 * @version V1.0
 */
package com.game.datamgr;

import com.game.dao.impl.s.StaticDataDao;
import com.game.domain.s.*;
import com.game.util.LogUtil;
import com.game.util.RandomHelper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.*;
import java.util.Map.Entry;

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

    private Map<Integer, StaticMine> seniorMineMap;

    private Map<Integer, Map<Integer, StaticMineLv>> mineLvMap = new HashMap<>();

    private List<StaticSlot> slots;

    // MAP<LV, LIST>
    private Map<Integer, List<StaticMineForm>> formMap;

    // KEY0:等级,KEY1:品质,VALUE:矿点品质信息
    private TreeMap<Integer, TreeMap<Integer, StaticMineQuality>> lqMap;


    /**
     * Overriding: init
     *
     */
    @Override
    public void init() {
        this.seniorMineMap = staticDataDao.selectCrossMineSenior();

        List<StaticMineLv> mineLvMap = staticDataDao.selectMineLv();
        for (StaticMineLv cong : mineLvMap) {
            if (!this.mineLvMap.containsKey(cong.getType())) {
                this.mineLvMap.put(cong.getType(), new HashMap<Integer, StaticMineLv>());
            }
            this.mineLvMap.get(cong.getType()).put(cong.getLv(), cong);
        }
        this.slots = staticDataDao.selectSlot();
        initForm();
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

    public StaticMine getSeniorMine(int pos) {
        return seniorMineMap.get(pos);
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

    /**
     * 跨服军矿矿等级
     *
     * @param mineLv
     * @return
     */
    public StaticMineLv getCrossMineLvSenior(int mineLv) {
        return getStaticMineLv(3, mineLv);
    }

}
