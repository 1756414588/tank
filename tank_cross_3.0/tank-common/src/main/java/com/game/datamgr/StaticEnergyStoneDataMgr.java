package com.game.datamgr;

import com.game.dao.impl.s.StaticDataDao;
import com.game.domain.p.EnergyStoneInlay;
import com.game.domain.s.StaticAltarBoss;
import com.game.domain.s.StaticEnergyHiddenAttr;
import com.game.domain.s.StaticEnergyStone;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.Map;

/**
 * @author TanDonghai @ClassName StaticEnergyStoneDataMgr @Description 能晶配置数据管理类
 * @date 创建时间：2016年7月12日 下午3:25:41
 */
@Component
public class StaticEnergyStoneDataMgr extends BaseDataMgr {
  @Autowired private StaticDataDao staticDataDao;

  /** 能晶配置信息, key:stoneId */
  private Map<Integer, StaticEnergyStone> stoneMap;

  /** 能晶隐藏属性 */
  private Map<Integer, StaticEnergyHiddenAttr> hiddenMap;

  /** 祭坛和祭坛BOSS的配置数据, key:lv */
  private Map<Integer, StaticAltarBoss> altarBossMap;

  @Override
  public void init() {
    stoneMap = staticDataDao.selectEnergyStoneMap();

    hiddenMap = staticDataDao.selectEnergyHiddenAttrMap();

    altarBossMap = staticDataDao.selectAltarBossMap();
  }

  /**
   * 根据传入的等级获取对应的祭坛或祭坛BOSS配置数据
   *
   * @param lv
   * @return 如果传入的等级不正确，可能返回null
   */
  public StaticAltarBoss getAltarBossDataByLv(int lv) {
    return altarBossMap.get(lv);
  }

  /**
   * 根据能晶id获取能晶配置信息
   *
   * @param stoneId 能晶id
   * @return 如果没有对应的能晶信息，会返回null
   */
  public StaticEnergyStone getEnergyStoneById(int stoneId) {
    return stoneMap.get(stoneId);
  }

  /**
   * 获取镶嵌信息对应的可激活的隐藏属性加成，如果没有可激活属性，返回null
   *
   * @param its 能晶镶嵌信息
   * @return
   */
  public List<List<Integer>> getEnergyHiddenAttrByStone(Collection<EnergyStoneInlay> its) {
    if (null != its) {
      List<Integer> stoneLevelList = new ArrayList<Integer>(); // 记录所有镶嵌的能晶的等级
      for (EnergyStoneInlay inlay : its) {
        StaticEnergyStone stone = getEnergyStoneById(inlay.getStoneId());
        if (null != stone) {
          stoneLevelList.add(stone.getLevel());
        }
      }

      List<List<Integer>> attr = new ArrayList<>();

      for (StaticEnergyHiddenAttr hidden : hiddenMap.values()) {
        List<Integer> ruleList = hidden.getRuleList();
        int needLevel = ruleList.get(1); // 激活该隐藏属性需要的能晶等级
        int needNum = ruleList.get(0); // 激活该隐藏属性需要达到等级的能晶数量
        int fitNum = 0; // 记录已满足条件的个数
        for (Integer stoneLevel : stoneLevelList) {
          if (stoneLevel >= needLevel) {
            fitNum++;
          }
        }
        if (fitNum >= needNum) {
          attr.addAll(hidden.getEffectList());
        }
      }
      return attr;
    }
    return null;
  }
}
