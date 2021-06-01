package com.game.dataMgr;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.game.dao.impl.s.StaticDataDao;
import com.game.domain.s.StaticAttackEffect;
import com.game.domain.s.StaticTank;
import com.game.util.LogUtil;

/**
 * @author zhangdh
 * @ClassName: StaticAttackEffectDataMgr
 * @Description:攻击特效
 * @date 2017-11-28 15:12
 */
@Component
public class StaticAttackEffectDataMgr extends BaseDataMgr {

    @Autowired
    private StaticDataDao staticDataDao;

    @Autowired
    private StaticTankDataMgr staticTankDataMgr;

    //特效信息
    private Map<Integer, StaticAttackEffect> effects = new HashMap<>();

    //默认初始化的特效信息, KEY:兵种类型,VALUE:特效信息
    private Map<Integer, StaticAttackEffect> effectDefault = new HashMap<>();

    //支持配件解锁的的特效, KEY:兵种类型,VALUE:特效信息
    private Map<Integer, List<StaticAttackEffect>> effectUnlock = new HashMap<>();

    @Override
    public void init() {
        Map<Integer, StaticAttackEffect> effects0 = staticDataDao.selectStaticAttackEffect();
        for (Map.Entry<Integer, StaticAttackEffect> entry : effects0.entrySet()) {
            StaticAttackEffect data = entry.getValue();
            String scope = data.getScope();
            if (scope != null && !"".equals(scope) && !"-1".equals(scope)) {
                data.setIds(string2Set(scope));
            }
            //设置兵种默认特效
            if (data.getIsDefault() == 1) {
                effectDefault.put(data.getType(), data);
            }
            //配件解锁
            if (data.getUnLockLv() > 0) {
                List<StaticAttackEffect> unLockList = effectUnlock.get(data.getType());
                if (unLockList == null) {
                    effectUnlock.put(data.getType(), unLockList = new ArrayList<StaticAttackEffect>());
                }
                unLockList.add(data);
            }
        }
        effects = effects0;
    }

    /**
     * 根据配件类型获取解锁此配件对应的攻击特效
     *
     * @param type
     * @return
     */
    public List<StaticAttackEffect> getUnlockAttackEffect(int type) {
        List<StaticAttackEffect> list = effectUnlock.get(type);
        if (list == null) {
            LogUtil.error(String.format("not found by part type :%d", type));
        }
        return list;
    }

    public ArrayList<List<StaticAttackEffect>> getEffectUnlock() {
        return new ArrayList<>(effectUnlock.values());
    }

    /**
     * 获取兵种默认开启的特效
     *
     * @param type 兵种类型
     * @return
     */
    public StaticAttackEffect getDefaultEffect(int type) {
        StaticAttackEffect data = effectDefault.get(type);
        if (data == null) {
            LogUtil.error(String.format("not found type :%d, default effect ", type));
        }
        return data;
    }

    public StaticAttackEffect getAttackEffect(int uid) {
        StaticAttackEffect data = effects.get(uid);
        if (data == null) {
            LogUtil.error(String.format("not found attack effect id :%d ", uid));
        }
        return data;
    }

    public Map<Integer, StaticAttackEffect> getEffectDefault() {
        return effectDefault;
    }

    /**
     * 解析类似于如下的字符串配置
     * 101,105_109,301_411,507_520
     *
     * @param value
     * @return
     */
    public Set<Integer> string2Set(String value) {
        Set<Integer> set = new HashSet<>();
        if (value == null || "".equals(value)) return set;
        String[] arr = value.split(",");
        for (String s : arr) {
            String[] ab = s.split("_");
            if (ab.length == 1) {
                set.add(Integer.parseInt(ab[0]));
            } else {
                int start = Integer.parseInt(ab[0]);
                int end = Integer.parseInt(ab[1]);
                for (int i = start; i <= end; i++) {
                    StaticTank tank = staticTankDataMgr.getStaticTank(i);
                    if (tank == null) {
                        LogUtil.error(String.format("Attack effect not found tank id :%d", i));
                    } else {
                        set.add(i);
                    }
                }
            }
        }
        return set;
    }
}
