package com.game.dataMgr;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import com.game.domain.s.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.game.dao.impl.s.StaticDataDao;
import com.game.util.LogUtil;

/**
 * @author GuiJie
 * @description 作战研究院
 * @created 2017/12/20 10:27
 */
@Component
public class StaticLabDataMgr extends BaseDataMgr {

    @Autowired
    private StaticDataDao staticDataDao;

    /**
     * resourceId对应建筑id
     */
    private static Map<Integer, List<Integer>> resourceArch = new HashMap<>();

    /**
     * 作战研究院 物品表 key ->  itemd
     */
    private Map<Integer, StaticLaboratoryItem> itemConfig = new HashMap<>();
    /**
     * 兵种调配室 奖励表 key -> id
     */
    private Map<Integer, StaticLaboratoryProgress> rewardConfig = new HashMap<>();

    /**
     * 作战研究院 建筑表 key -> 建筑id
     */
    private Map<Integer, StaticLaboratoryResearch> researchConfig = new HashMap<>();
    /**
     * 作战研究院 科技表 key -> 科技id
     */
    private Map<Integer, Map<Integer, StaticLaboratoryTech>> techConfig = new HashMap<>();


    /**
     * 兵种调配室 兵种调配室配置 key1 -> type,key2->skillId,key3->level
     */
    private Map<Integer, Map<Integer, Map<Integer, StaticLaboratoryMilitary>>> graduateConfigMap = new HashMap<>();
    private List<StaticLaboratoryMilitary> graduateConfigList = new ArrayList<>();

    /**
     * 增加特殊属性的技能(属性ID > 1000)
     * KEY -> attId, KEY2 -> 作用类型, Value -> 技能ID列表
     */
    private Map<Integer, Map<Integer, Set<Integer>>> specilAttrSkills = new HashMap<>();


    /**
     * 作战研究院 谍报机构地图 key ->  谍报机构区域的kid
     */
    private Map<Integer, StaticLaboratoryArea> areaConfig = new HashMap<>();

    /**
     * 作战研究院 谍报机构间谍 key ->  间谍id
     */
    private Map<Integer, StaticLaboratorySpy> spyConfig = new HashMap<>();
    /**
     * 作战研究院 谍报机构任务 key ->  任务id
     */
    private Map<Integer, StaticLaboratoryTask> taskConfig = new HashMap<>();


    public Map<Integer, StaticLaboratoryArea> getAreaConfig() {
        return areaConfig;
    }

    /**
     * 获取所有兵种调配室配置
     *
     * @return
     */
    public List<StaticLaboratoryMilitary> getGraduateConfig() {
        return graduateConfigList;

    }

    public Map<Integer, StaticLaboratorySpy> getSpyConfig() {
        return spyConfig;
    }

    public Map<Integer, StaticLaboratoryTask> getTaskConfig() {
        return taskConfig;
    }

    /**
     * 获取 兵种调配室配置
     *
     * @param type    类型
     * @param skillId skillId
     * @param level   等级
     * @return
     */
    public StaticLaboratoryMilitary getGraduateConfig(int type, int skillId, int level) {

        Map<Integer, Map<Integer, StaticLaboratoryMilitary>> typeMap = graduateConfigMap.get(type);

        Map<Integer, StaticLaboratoryMilitary> skillMap = typeMap != null ? typeMap.get(skillId) : null;

        StaticLaboratoryMilitary config = skillMap != null ? skillMap.get(level) : null;

//        if (config == null) {
//            LogUtil.error(String.format("作战研究院 StaticLaboratoryMilitary config is null type=%d , skillId = %d ,level = %d", type, skillId, level));
//        }

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
            LogUtil.error(String.format("tech config not found techId :%d, level :%d", techId, level));
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

        Map<Integer, StaticLaboratoryItem> tempItemConfig = new HashMap<>();
        Map<Integer, StaticLaboratoryResearch> tempResearchConfig = new HashMap<>();
        Map<Integer, Map<Integer, StaticLaboratoryTech>> tempTechConfig = new HashMap<>();
        Map<Integer, Map<Integer, Map<Integer, StaticLaboratoryMilitary>>> tmepGraduateConfigMap = new HashMap<>();
        List<StaticLaboratoryMilitary> tempGraduateConfigList = new ArrayList<>();
        Map<Integer, Map<Integer, Set<Integer>>> tempSpecilAttrSkills = new HashMap<>();
        Map<Integer, StaticLaboratoryArea> tempAreaConfig = new HashMap<>();
        Map<Integer, StaticLaboratoryTask> tempTaskConfig = new HashMap<>();
        Map<Integer, StaticLaboratorySpy> tempSpyConfig = new HashMap<>();


        List<StaticLaboratoryItem> staticLaboratoryItemConf = staticDataDao.selectLaboratoryItem();
        if (staticLaboratoryItemConf != null && !staticLaboratoryItemConf.isEmpty()) {
            for (StaticLaboratoryItem c : staticLaboratoryItemConf) {
                tempItemConfig.put(c.getId(), c);
            }
        }


        Map<Integer, StaticLaboratoryProgress> tempRewardConfig = new HashMap<>();
        List<StaticLaboratoryProgress> staticLaboratoryProgressConf = staticDataDao.selectLaboratoryProgress();
        if (staticLaboratoryProgressConf != null && !staticLaboratoryProgressConf.isEmpty()) {
            for (StaticLaboratoryProgress c : staticLaboratoryProgressConf) {
                tempRewardConfig.put(c.getId(), c);
            }
        }


        List<StaticLaboratoryResearch> staticLaboratoryResearchConf = staticDataDao.selectLaboratoryResearch();
        if (staticLaboratoryResearchConf != null && !staticLaboratoryResearchConf.isEmpty()) {
            for (StaticLaboratoryResearch c : staticLaboratoryResearchConf) {
                tempResearchConfig.put(c.getId(), c);
            }
        }


        List<StaticLaboratoryTech> staticLaboratoryTechConf = staticDataDao.selecLtaboratoryTech();
        if (staticLaboratoryTechConf != null && !staticLaboratoryTechConf.isEmpty()) {
            for (StaticLaboratoryTech c : staticLaboratoryTechConf) {

                if (!tempTechConfig.containsKey(c.getTechId())) {
                    tempTechConfig.put(c.getTechId(), new HashMap<Integer, StaticLaboratoryTech>());
                }
                tempTechConfig.get(c.getTechId()).put(c.getTechLv(), c);
            }
        }


        List<StaticLaboratoryMilitary> staticLaboratoryMilitaryConf = staticDataDao.selectLaboratoryMilitary();

        if (staticLaboratoryMilitaryConf != null && !staticLaboratoryMilitaryConf.isEmpty()) {

            tempGraduateConfigList = staticLaboratoryMilitaryConf;

            for (StaticLaboratoryMilitary c : staticLaboratoryMilitaryConf) {

                if (!tmepGraduateConfigMap.containsKey(c.getType())) {
                    tmepGraduateConfigMap.put(c.getType(), new HashMap<Integer, Map<Integer, StaticLaboratoryMilitary>>());
                }

                if (!tmepGraduateConfigMap.get(c.getType()).containsKey(c.getSkillId())) {
                    tmepGraduateConfigMap.get(c.getType()).put(c.getSkillId(), new HashMap<Integer, StaticLaboratoryMilitary>());
                }
                tmepGraduateConfigMap.get(c.getType()).get(c.getSkillId()).put(c.getLv(), c);

                //特殊属性对应技能ID加载
                if (c.getEffect() != null) {
                    for (List<Integer> effect : c.getEffect()) {
                        int attId = effect.get(0);
                        if (attId > 1000) {
                            Map<Integer, Set<Integer>> typeMap = tempSpecilAttrSkills.get(attId);
                            if (typeMap == null) {
                                tempSpecilAttrSkills.put(attId, typeMap = new HashMap<Integer, Set<Integer>>());
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


        List<StaticLaboratoryArea> staticLaboratoryAreaConfig = staticDataDao.selectStaticLaboratoryArea();

        if (staticLaboratoryAreaConfig != null && !staticLaboratoryAreaConfig.isEmpty()) {

            for (StaticLaboratoryArea config : staticLaboratoryAreaConfig) {
                tempAreaConfig.put(config.getAreaId(), config);
            }
        }


        List<StaticLaboratorySpy> staticLaboratorySpyConfig = staticDataDao.selectStaticLaboratorySpy();
        if (staticLaboratorySpyConfig != null && !staticLaboratorySpyConfig.isEmpty()) {
            for (StaticLaboratorySpy config : staticLaboratorySpyConfig) {
                tempSpyConfig.put(config.getSpyId(), config);
            }
        }


        List<StaticLaboratoryTask> staticLaboratoryTaskConfig = staticDataDao.selectStaticLaboratoryTask();
        if (staticLaboratoryTaskConfig != null && !staticLaboratoryTaskConfig.isEmpty()) {
            for (StaticLaboratoryTask config : staticLaboratoryTaskConfig) {
                tempTaskConfig.put(config.getTaskId(), config);
            }
        }


        this.itemConfig.clear();
        this.rewardConfig.clear();
        this.researchConfig.clear();
        this.graduateConfigMap.clear();
        this.areaConfig.clear();
        this.spyConfig.clear();
        this.taskConfig.clear();
        this.specilAttrSkills.clear();
        this.graduateConfigList.clear();
        this.techConfig.clear();


        this.itemConfig = tempItemConfig;
        this.rewardConfig = tempRewardConfig;
        this.researchConfig = tempResearchConfig;
        this.techConfig = tempTechConfig;
        this.graduateConfigMap = tmepGraduateConfigMap;
        this.graduateConfigList = tempGraduateConfigList;
        this.specilAttrSkills = tempSpecilAttrSkills;
        this.areaConfig = tempAreaConfig;
        this.spyConfig = tempSpyConfig;
        this.taskConfig = tempTaskConfig;

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

    /**
     * 资源id对应物品id
     */
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
