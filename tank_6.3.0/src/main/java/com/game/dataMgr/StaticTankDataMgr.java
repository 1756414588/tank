/**   
 * @Title: StaticTankDataMgr.java    
 * @Package com.game.dataMgr    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年7月17日 下午2:20:20    
 * @version V1.0   
 */
package com.game.dataMgr;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.game.dao.impl.s.StaticDataDao;
import com.game.domain.s.StaticBuff;
import com.game.domain.s.StaticSkill;
import com.game.domain.s.StaticTank;
import com.game.util.LogUtil;

/**
 * @ClassName: StaticTankDataMgr
 * @Description: 坦克相关配置
 * @author ZhangJun
 * @date 2015年7月17日 下午2:20:20
 * 
 */
@Component
public class StaticTankDataMgr extends BaseDataMgr {
	@Autowired
	private StaticDataDao staticDataDao;

	private TreeMap<Integer, StaticTank> tankMap = new TreeMap<>();

	//KEY1:坦克类型, KEY2:坦克ID 玩家能生产的坦克列表
    private Map<Integer, TreeMap<Integer, StaticTank>> buildTanks = new HashMap<>();



	private Map<Integer, StaticBuff> buffMap;

	private Map<Integer, StaticSkill> skillMap;

	/**
	 * Overriding: init
	 * 
	 * @see com.game.dataMgr.BaseDataMgr#init()
	 */
	@Override
	public void init() {
        this.buffMap = staticDataDao.selectBuff();
        this.skillMap = staticDataDao.selectSkill();
        initTank();
		initTankAura();
	}

    /**
     * 初始化坦克
     */
	private void initTank() {
        tankMap.clear();
        tankMap.putAll(staticDataDao.selectTank());
        for (Map.Entry<Integer, StaticTank> entry : tankMap.entrySet()) {
            StaticTank data = entry.getValue();
            if (data.getCanBuild() == 0) {
                TreeMap<Integer, StaticTank> tanks = buildTanks.get(data.getType());
                if (tanks == null) buildTanks.put(data.getType(), tanks = new TreeMap<Integer, StaticTank>());
                tanks.put(data.getTankId(), data);
            }
        }
    }

	/**
	* @Title: initTankAura 
	* @Description:   加载坦克光环配置
	* void   

	 */
	public void initTankAura() {
        Iterator<StaticTank> it = tankMap.values().iterator();
        while (it.hasNext()) {
            StaticTank staticTank = (StaticTank) it.next();
            List<Integer> aura = staticTank.getAura();
            ArrayList<StaticBuff> list = new ArrayList<>();
            if (aura != null && !aura.isEmpty()) {
                for (Integer buffId : aura) {
                    StaticBuff buffData = buffMap.get(buffId);
                    if (buffData != null) {
                        list.add(buffData);
                    } else {
                        LogUtil.error(String.format("tank id :%d, not found tank aura :%d", staticTank.getTankId(), buffId));
                    }
                }
            }
            staticTank.setBuffs(list);
        }
    }

    /**
     * 根据坦克类型,获取该类型可生产的最牛逼的坦克
     * @param lv 角色等级
     * @param flv 坦克工厂最高等级
     * @param tys 坦克类型 {@link com.game.constant.TankType}
     * @return
     */
	public Map<Integer, StaticTank> getCanBuildMaxTank4Type(int lv, int flv, int ...tys) {
        Map<Integer, StaticTank> findMap = new HashMap<>();
        for (int ty : tys) {
            TreeMap<Integer, StaticTank> tanks = buildTanks.get(ty);
            if (tanks == null) {
                LogUtil.error(String.format("not found type :%d tank", ty));
            } else {
                for (Map.Entry<Integer, StaticTank> entry : tanks.descendingMap().entrySet()) {
                    StaticTank data = entry.getValue();
                    if (lv >= data.getLordLv() && flv >= data.getFactoryLv()) {
                        findMap.put(ty, data);
                        break;
                    }
                }
            }
            StaticTank data = findMap.get(ty);
            if (data == null && flv > 10) {
                LogUtil.error(String.format("not found can build tank ty :%d, lv :%d, flv :%d ", ty, lv, flv));
            }
        }
        return findMap;
    }


	/**
	* @Title: getStaticTank 
	* @Description: 
	* @param tankId
	* @return  
	* StaticTank   

	 */
	public StaticTank getStaticTank(int tankId) {
        StaticTank tank = tankMap.get(tankId);
        if (tank == null) {
            LogUtil.error(String.format("not found tank :%d", tankId));
        }
        return tank;
    }

    /**
     * 是否是活动或者抽奖投放的坦克
     * @param tankId
     * @return
     */
	public boolean isGoldTank(int tankId) {
        StaticTank data = tankMap.get(tankId);
        return data != null && data.getCanBuild() > 0 && data.getDestroyMilitary() > 0;
    }

    /**
     * 是否能建造此坦克
     * @param tankId
     * @param lv
     * @param flv
     * @return
     */
    public boolean isCanBuild(int tankId, int lv, int flv) {
        StaticTank data = tankMap.get(tankId);
        return data != null && data.getCanBuild() == 0
                && flv >= data.getFactoryLv() && lv >= data.getLordLv();
    }

	public StaticSkill getStaticSkill(int skillId) {
		return skillMap.get(skillId);
	}

    public Map<Integer, StaticTank> getTankMap() {
        return tankMap;
    }
}
