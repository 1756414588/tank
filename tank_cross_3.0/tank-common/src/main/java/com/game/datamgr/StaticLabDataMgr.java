package com.game.datamgr;

import com.game.dao.impl.s.StaticDataDao;
import com.game.domain.s.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.*;

/**
 * @author GuiJie
 * @description 作战研究院
 * @created 2017/12/20 10:27
 */
@Component
public class StaticLabDataMgr extends BaseDataMgr {

  @Autowired private StaticDataDao staticDataDao;

  /** resourceId对应建筑id */
  private static Map<Integer, List<Integer>> resourceArch = new HashMap<>();

  /** 作战研究院 物品表 key -> itemd */
  private Map<Integer, StaticLaboratoryItem> itemConfig = new HashMap<>();
  /** 兵种调配室 奖励表 key -> id */
  private Map<Integer, StaticLaboratoryProgress> rewardConfig = new HashMap<>();

  /** 作战研究院 建筑表 key -> 建筑id */
  private Map<Integer, StaticLaboratoryResearch> researchConfig = new HashMap<>();
  /** 作战研究院 科技表 key -> 科技id */
  private Map<Integer, Map<Integer, StaticLaboratoryTech>> techConfig = new HashMap<>();

  /** 兵种调配室 兵种调配室配置 key1 -> type,key2->skillId,key3->level */
  private Map<Integer, Map<Integer, Map<Integer, StaticLaboratoryMilitary>>> graduateConfigMap =
      new HashMap<>();

  private List<StaticLaboratoryMilitary> graduateConfigList = new ArrayList<>();

  /** 增加特殊属性的技能(属性ID > 1000) KEY -> attId, KEY2 -> 作用类型, Value -> 技能ID列表 */
  private Map<Integer, Map<Integer, Set<Integer>>> specilAttrSkills = new HashMap<>();

  /**
   * 获取所有兵种调配室配置
   *
   * @return
   */
  public List<StaticLaboratoryMilitary> getGraduateConfig() {
    return graduateConfigList;
  }

  /**
   * 获取 兵种调配室配置
   *
   * @param type 类型
   * @param skillId skillId
   * @param level 等级
   * @return
   */
  public StaticLaboratoryMilitary getGraduateConfig(int type, int skillId, int level) {

    Map<Integer, Map<Integer, StaticLaboratoryMilitary>> typeMap = graduateConfigMap.get(type);

    Map<Integer, StaticLaboratoryMilitary> skillMap = typeMap != null ? typeMap.get(skillId) : null;

    StaticLaboratoryMilitary config = skillMap != null ? skillMap.get(level) : null;

    return config;
  }

  /**
   * 获取对指定特殊属性有加成的技能列表
   *
   * @param specilAttId
   * @return
   */
  public Map<Integer, Set<Integer>> getSpecilSkillList(int specilAttId) {
    return specilAttrSkills.get(specilAttId);
  }

  /**
   * 获取物品配置
   *
   * @param resourceId
   * @return
   */
  public StaticLaboratoryItem getItemConfig(int resourceId) {
    return itemConfig.get(resourceId);
  }

  /**
   * 获取物品配置
   *
   * @return
   */
  public List<StaticLaboratoryItem> getItemConfigs() {
    return new ArrayList<>(itemConfig.values());
  }

  /**
   * 获取兵种调配室奖励配置
   *
   * @return
   */
  public List<StaticLaboratoryProgress> getRewardConfig() {
    return new ArrayList<>(rewardConfig.values());
  }

  /**
   * 获取科技信息
   *
   * @param techId
   * @param level
   * @return
   */
  public StaticLaboratoryTech getTechConfig(int techId, int level) {
    if (!techConfig.containsKey(techId)) {
      return null;
    }
    return techConfig.get(techId).get(level);
  }

  /**
   * 获取科技信息
   *
   * @param actId 这个是建筑id
   * @return
   */
  public List<StaticLaboratoryTech> getTechConfigs(int actId) {
    List<StaticLaboratoryTech> result = new ArrayList<>();

    for (Integer id : techConfig.keySet()) {
      Map<Integer, StaticLaboratoryTech> c = techConfig.get(id);
      for (StaticLaboratoryTech conf : c.values()) {
        if (conf.getPreBuilding() == actId) {
          result.add(conf);
        }
      }
    }

    return result;
  }

  /**
   * 获取建筑信息
   *
   * @param archId
   * @return
   */
  public StaticLaboratoryResearch getResearchConfig(int archId) {
    return researchConfig.get(archId);
  }

  /**
   * 获取建筑信息
   *
   * @return
   */
  public List<StaticLaboratoryResearch> getResearchConfigs() {
    return new ArrayList<>(researchConfig.values());
  }

  @Override
  public void init() {

    List<StaticLaboratoryItem> staticLaboratoryItemConf = staticDataDao.selectLaboratoryItem();
    if (staticLaboratoryItemConf != null && !staticLaboratoryItemConf.isEmpty()) {
      for (StaticLaboratoryItem c : staticLaboratoryItemConf) {
        itemConfig.put(c.getId(), c);
      }
    }

    List<StaticLaboratoryProgress> staticLaboratoryProgressConf =
        staticDataDao.selectLaboratoryProgress();
    if (staticLaboratoryProgressConf != null && !staticLaboratoryProgressConf.isEmpty()) {
      for (StaticLaboratoryProgress c : staticLaboratoryProgressConf) {
        rewardConfig.put(c.getId(), c);
      }
    }

    List<StaticLaboratoryResearch> staticLaboratoryResearchConf =
        staticDataDao.selectLaboratoryResearch();
    if (staticLaboratoryResearchConf != null && !staticLaboratoryResearchConf.isEmpty()) {
      for (StaticLaboratoryResearch c : staticLaboratoryResearchConf) {
        researchConfig.put(c.getId(), c);
      }
    }

    List<StaticLaboratoryTech> staticLaboratoryTechConf = staticDataDao.selecLtaboratoryTech();
    if (staticLaboratoryTechConf != null && !staticLaboratoryTechConf.isEmpty()) {
      for (StaticLaboratoryTech c : staticLaboratoryTechConf) {

        if (!techConfig.containsKey(c.getTechId())) {
          techConfig.put(c.getTechId(), new HashMap<Integer, StaticLaboratoryTech>());
        }
        techConfig.get(c.getTechId()).put(c.getTechLv(), c);
      }
    }

    List<StaticLaboratoryMilitary> staticLaboratoryMilitaryConf =
        staticDataDao.selectLaboratoryMilitary();

    if (staticLaboratoryMilitaryConf != null && !staticLaboratoryMilitaryConf.isEmpty()) {

      graduateConfigList = staticLaboratoryMilitaryConf;

      for (StaticLaboratoryMilitary c : staticLaboratoryMilitaryConf) {

        if (!graduateConfigMap.containsKey(c.getType())) {
          graduateConfigMap.put(
              c.getType(), new HashMap<Integer, Map<Integer, StaticLaboratoryMilitary>>());
        }

        if (!graduateConfigMap.get(c.getType()).containsKey(c.getSkillId())) {
          graduateConfigMap
              .get(c.getType())
              .put(c.getSkillId(), new HashMap<Integer, StaticLaboratoryMilitary>());
        }
        graduateConfigMap.get(c.getType()).get(c.getSkillId()).put(c.getLv(), c);

        // 特殊属性对应技能ID加载
        if (c.getEffect() != null) {
          for (List<Integer> effect : c.getEffect()) {
            int attId = effect.get(0);
            if (attId > 1000) {
              Map<Integer, Set<Integer>> typeMap = specilAttrSkills.get(attId);
              if (typeMap == null) {
                specilAttrSkills.put(attId, typeMap = new HashMap<Integer, Set<Integer>>());
              }
              Set<Integer> sklSet = typeMap.get(c.getType());
              if (sklSet == null) {
                typeMap.put(c.getType(), sklSet = new HashSet<Integer>());
              }
              sklSet.add(c.getSkillId());
            }
          }
        }
      }
    }
  }

  static {
    List<Integer> val101 = new ArrayList<Integer>();
    val101.add(101);
    val101.add(201);
    val101.add(301);
    resourceArch.put(101, val101);

    List<Integer> val102 = new ArrayList<Integer>();
    val102.add(102);
    val102.add(202);
    val102.add(301);
    resourceArch.put(102, val102);

    List<Integer> val103 = new ArrayList<Integer>();
    val103.add(103);
    val103.add(203);
    val103.add(301);
    resourceArch.put(103, val103);

    List<Integer> val104 = new ArrayList<Integer>();
    val104.add(104);
    val104.add(204);
    val104.add(301);
    resourceArch.put(104, val104);
  }

  /**
   * 根据资源id获取影响该资源的建筑id
   *
   * @param resourceTypeId
   * @return
   */
  public List<Integer> getResourceArch(int resourceTypeId) {
    return resourceArch.get(resourceTypeId);
  }

  /** 资源id对应物品id */
  private static Map<Integer, Integer> resourceItemId = new HashMap<>();

  static {
    resourceItemId.put(101, 201);
    resourceItemId.put(102, 202);
    resourceItemId.put(103, 203);
    resourceItemId.put(104, 204);
  }

  /**
   * 更具资源id获取物品id
   *
   * @param resourceTypeId
   * @return
   */
  public Integer getResourceItemid(int resourceTypeId) {
    return resourceItemId.get(resourceTypeId);
  }
}
