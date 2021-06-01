package com.game.service;

import com.game.datamgr.StaticTacticsDataMgr;
import com.game.domain.p.TowInt;
import com.game.domain.s.StaticTank;
import com.game.domain.s.tactics.StaticTactics;
import com.game.domain.s.tactics.StaticTacticsTacticsRestrict;
import com.game.domain.s.tactics.StaticTacticsTankSuit;
import com.game.fight.domain.Fighter;
import com.game.fight.domain.Force;
import com.game.util.LogUtil;
import com.game.util.MapUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Component
public class TacticsService {

  @Autowired private StaticTacticsDataMgr staticTacticsDataMgr;

  /**
   * 战术基础属性
   *
   * @param tacticsList
   * @return
   */
  public Map<Integer, Integer> getBaseAttribute(List<TowInt> tacticsList) {
    Map<Integer, Integer> result = new HashMap<>();
    if (tacticsList.isEmpty()) {
      return result;
    }

    // 基础属性 每个部队可装配6个战术 装配战术后，战术携带的属性，附加到当前部队上，战斗时生效
    for (TowInt e : tacticsList) {
      StaticTactics tacticsConfig = staticTacticsDataMgr.getTacticsConfig(e.getKey());
      MapUtil.addMapValue(result, tacticsConfig.getAttrBase());
      MapUtil.multipleAttribute(result, e.getValue(), tacticsConfig.getAttrLv());
    }
    return result;
  }

  /**
   * 战术 全部装配单一效果战术属性
   *
   * @param tacticsList
   * @return
   */
  public Map<Integer, Integer> getTaozhaungAttribute(List<TowInt> tacticsList) {
    Map<Integer, Integer> result = new HashMap<>();
    if (tacticsList.isEmpty()) {
      return result;
    }
    // 全部装配单一效果战术，可触发战术套效果 额外增加全兵种的属性
    int tacticstype = getTacticstype(tacticsList);
    StaticTacticsTacticsRestrict tacticsTacticsRestrictConfig =
        staticTacticsDataMgr.getTacticsTacticsRestrictConfig(tacticstype);
    if (tacticsTacticsRestrictConfig != null) {
      MapUtil.addMapValue(result, tacticsTacticsRestrictConfig.getAttrSuit());
    }
    return result;
  }

  /**
   * 根据玩家战术 获取战术类型 如果不全一样 就返回0
   *
   * @param tacticsList
   * @return
   */
  private int getTacticstype(List<TowInt> tacticsList) {

    if (tacticsList.size() != 6) {
      return 0;
    }

    int tacticstype = 0;

    for (TowInt e : tacticsList) {
      StaticTactics tacticsConfig = staticTacticsDataMgr.getTacticsConfig(e.getKey());
      if (tacticstype == 0) {
        tacticstype = tacticsConfig.getTacticstype();
      }
      if (tacticstype != tacticsConfig.getTacticstype()) {
        return 0;
      }
    }
    return tacticstype;
  }

  /**
   * 兵种套属性
   *
   * @param tacticsList
   * @return
   */
  public Map<Integer, Integer> getTankTypeAttribute(
          List<TowInt> tacticsList, StaticTank staticTank) {

    Map<Integer, Integer> result = new HashMap<>();
    StaticTacticsTankSuit config = getTankTypeAttributeConfig(tacticsList);
    if (config == null) {
      return result;
    }

    if (config.getEffectTank() == staticTank.getType() || config.getEffectTank() == 5) {
      MapUtil.addMapValue(result, config.getAttrUp());
    }

    return result;
  }

  /**
   * 兵种套属性
   *
   * @param tacticsList
   * @return
   */
  public StaticTacticsTankSuit getTankTypeAttributeConfig(List<TowInt> tacticsList) {

    if (tacticsList.isEmpty() || tacticsList.size() != 6) {
      return null;
    }

    int quality = getQuality(tacticsList);

    if (quality == 0) {
      return null;
    }

    int tankType = getTankType(tacticsList);
    if (tankType == 0) {
      return null;
    }

    int tacticsType = getTacticstype(tacticsList);
    if (tacticsType == 0) {
      return null;
    }

    StaticTacticsTankSuit config =
        staticTacticsDataMgr.getStaticTacticsTankSuitConfig(quality, tacticsType, tankType);
    return config;
  }

  /**
   * 兵种套品质，品质向下兼容（如5个紫色，1个蓝色，则是蓝色兵种套效果）
   *
   * @param tacticsList
   * @return
   */
  private int getQuality(List<TowInt> tacticsList) {

    if (tacticsList.size() != 6) {
      return 0;
    }

    int quality = 0;
    for (TowInt e : tacticsList) {
      StaticTactics tacticsConfig = staticTacticsDataMgr.getTacticsConfig(e.getKey());
      if (quality == 0 || tacticsConfig.getQuality() < quality) {
        quality = tacticsConfig.getQuality();
      }
    }
    return quality;
  }

  /**
   * 兵种套类型，1-战车，2-坦克，3-火炮，4-火箭，5-全部
   *
   * @param tacticsList
   * @return
   */
  public int getTankType(List<TowInt> tacticsList) {

    if (tacticsList.size() != 6) {
      return 0;
    }

    int tankType = 0;

    for (TowInt e : tacticsList) {
      StaticTactics tacticsConfig = staticTacticsDataMgr.getTacticsConfig(e.getKey());
      if (tankType == 0) {
        tankType = tacticsConfig.getTanktype();
      }
      if (tankType != tacticsConfig.getTanktype()) {
        return 0;
      }
    }
    return tankType;
  }

  /**
   * 战术套属性 克制属性 如果不克制就没有这个属性
   *
   * @param attacker 攻击方
   * @param defencer 防御方
   */
  public void calTacticsRestrictAttribute(Fighter attacker, Fighter defencer) {

    try {
      // 佩戴着不同的战术效果是没有额外加成的
      if (attacker.tacticsList.size() != 6 || defencer.tacticsList.size() != 6) {
        return;
      }

      // 攻击方
      int attackerTacticstype = getTacticstype(attacker.tacticsList);

      if (attackerTacticstype == 0) {
        return;
      }

      // 防守方
      int defencerTacticsType = getTacticstype(defencer.tacticsList);
      if (0 == defencerTacticsType) {
        return;
      }

      // 攻击方克制了防守方 增加属性
      {
        StaticTacticsTacticsRestrict attackertConfig =
            staticTacticsDataMgr.getTacticsTacticsRestrictConfig(attackerTacticstype);
        // 说明没有克制   克制类型不同 说明没有克制
        if (attackertConfig != null && defencerTacticsType == attackertConfig.getTacticsType2()) {

          // 说明克制了 克制时，装配属性额外提高x%
          Map<Integer, Integer> attackerAttribute = new HashMap<>();
          Map<Integer, Integer> baseAttribute = getBaseAttribute(attacker.tacticsList);
          float odds = (float) (attackertConfig.getAttrUp() / 100.0f);
          MapUtil.multipleAttribute(baseAttribute, odds, attackerAttribute);

          Force[] forces = attacker.forces;
          for (Force force : forces) {
            if (force != null) {
              for (Map.Entry<Integer, Integer> e : attackerAttribute.entrySet()) {
                force.attrData.addValue(e.getKey(), e.getValue());
              }
            }
          }
        }
      }

      // 防守方克制了进攻方增加属性
      {
        StaticTacticsTacticsRestrict defencerConfig =
            staticTacticsDataMgr.getTacticsTacticsRestrictConfig(defencerTacticsType);

        // 说明没有克制
        if (defencerConfig != null && attackerTacticstype == defencerConfig.getTacticsType2()) {
          // 克制类型不同 说明没有克制

          // 说明克制了 克制时，装配属性额外提高x%
          Map<Integer, Integer> defencerAttribute = new HashMap<>();

          Map<Integer, Integer> attr = getBaseAttribute(defencer.tacticsList);

          MapUtil.multipleAttribute(
              attr, (float) (defencerConfig.getAttrUp() / 100.0f), defencerAttribute);

          Force[] forces = defencer.forces;
          for (Force force : forces) {
            if (force != null) {
              for (Map.Entry<Integer, Integer> e : defencerAttribute.entrySet()) {
                force.attrData.addValue(e.getKey(), e.getValue());
              }
            }
          }
        }
      }
    } catch (Exception e) {
      LogUtil.error(e);
    }
  }
}
