package com.game.domain.p;

import com.game.constant.AwardFrom;
import com.game.domain.Player;
import com.game.util.LogLordHelper;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * @author GuiJie
 * @description 描述
 * @created 2017/12/19 17:25
 */
public class LabInfo {

    /**
     * 作战研究所物品数量 key itemid，value 数量
     */
    private Map<Integer, Integer> labItemInfo = new HashMap<>();
    /**
     * 建筑信息 key 建筑id，value 是否激活 1 激活
     */
    private Map<Integer, Integer> archInfo = new HashMap<>();
    /**
     * 科技信息 key 科技id，value 等级
     */
    private Map<Integer, Integer> techInfo = new HashMap<>();
    /**
     * 人员信息 key 分配类型，value 数量
     */
    private Map<Integer, Integer> personInfo = new HashMap<>();
    /**
     * 资源信息 key 资源id，value 数量
     */
    private Map<Integer, Integer> resourceInfo = new HashMap<>();

    /**
     * 奖励信息 已经领取奖励的id
     */
    private ArrayList<Integer> rewardInfo = new ArrayList<>();

    /**
     * 研究信息 key 研究类型 value --> key 研究skillId value 等级
     */
    private Map<Integer, Map<Integer, Integer>> graduateInfo = new HashMap<>();

    /**
     * 资源生产信息
     */
    private Map<Integer, LabProductionInfo> labProMap = new HashMap<>();

    /**
     * 间谍信息
     */
    private Map<Integer, SpyInfoData> spyMap = new HashMap<>();


    public void clear() {
        labItemInfo.clear();
        archInfo.clear();
        techInfo.clear();
        personInfo.clear();
        personInfo.clear();
        resourceInfo.clear();
        rewardInfo.clear();
        graduateInfo.clear();
        labProMap.clear();
    }

    /**
     * 添加科技
     *
     * @param techId
     * @param level
     */
    public void addTech(Integer techId, Integer level) {
        techInfo.put(techId, level);
    }

    /**
     * 添加建筑
     *
     * @param archId
     * @param state
     */
    public void addArch(Integer archId, Integer state) {
        archInfo.put(archId, state);
    }

    /**
     * 添加物品
     *
     * @param item
     */
    public void addItem(Player player, AwardFrom from, List<List<Integer>> item) {

        if (item == null || item.isEmpty()) {
            return;
        }

        for (List<Integer> it : item) {
            int itemId = it.get(1);
            int count = it.get(2);

            if (!labItemInfo.containsKey(itemId)) {
                labItemInfo.put(itemId, 0);
            }
            labItemInfo.put(itemId, labItemInfo.get(itemId) + count);
            LogLordHelper.logFightLabItemChange(from, player, 1, itemId, count, labItemInfo.get(itemId));
        }

    }

    /**
     * 添加物品
     *
     * @param itemId
     * @param count
     */
    public void addItem(Player player, AwardFrom from, int itemId, int count) {
        if (!labItemInfo.containsKey(itemId)) {
            labItemInfo.put(itemId, 0);
        }
        labItemInfo.put(itemId, labItemInfo.get(itemId) + count);

        LogLordHelper.logFightLabItemChange(from, player, 1, itemId, count, labItemInfo.get(itemId));
    }


    public boolean checkItem(int itemId, int count) {
        if (!labItemInfo.containsKey(itemId)) {
            return false;
        }

        if (labItemInfo.get(itemId) < count) {
            return false;
        }
        return true;
    }

    /**
     * 验证物品是否足够
     *
     * @param item
     * @return
     */
    public boolean checkItem(List<List<Integer>> item) {
        if (item == null || item.isEmpty()) {
            return true;
        }

        if (labItemInfo.isEmpty()) {
            return false;
        }

        for (List<Integer> it : item) {
            int itemId = it.get(1);
            int count = it.get(2);

            if (!labItemInfo.containsKey(itemId)) {
                return false;
            }

            if (labItemInfo.get(itemId) < count) {
                return false;
            }
        }

        return true;
    }

    /**
     * 扣除物品
     *
     * @param item
     * @return
     */
    public boolean subItem(Player player, AwardFrom from, List<List<Integer>> item) {
        if (!checkItem(item)) {
            return false;
        }
        for (List<Integer> it : item) {
            int itemId = it.get(1);
            int count = it.get(2);
            labItemInfo.put(itemId, labItemInfo.get(itemId) - count);
            LogLordHelper.logFightLabItemChange(from, player, 2, itemId, count, labItemInfo.get(itemId));
        }
        return true;

    }

    /**
     * 扣除物品
     *
     * @param itemId
     * @param count
     */
    public int subItem(Player player, AwardFrom from, int itemId, int count) {
        int c = labItemInfo.get(itemId) - count;
        c = c < 0 ? 0 : c;
        labItemInfo.put(itemId, c);
        LogLordHelper.logFightLabItemChange(from, player, 2, itemId, count, labItemInfo.get(itemId));
        return c;
    }

    public Map<Integer, Integer> getLabItemInfo() {
        return labItemInfo;
    }

    public void setLabItemInfo(Map<Integer, Integer> labItemInfo) {
        this.labItemInfo = labItemInfo;
    }

    public Map<Integer, Integer> getArchInfo() {
        return archInfo;
    }

    public void setArchInfo(Map<Integer, Integer> archInfo) {
        this.archInfo = archInfo;
    }

    public Map<Integer, Integer> getTechInfo() {
        return techInfo;
    }

    public void setTechInfo(Map<Integer, Integer> techInfo) {
        this.techInfo = techInfo;
    }

    public Map<Integer, Integer> getPersonInfo() {
        return personInfo;
    }

    public void setPersonInfo(Map<Integer, Integer> personInfo) {
        this.personInfo = personInfo;
    }

    public Map<Integer, Integer> getResourceInfo() {
        return resourceInfo;
    }

    public void setResourceInfo(Map<Integer, Integer> resourceInfo) {
        this.resourceInfo = resourceInfo;
    }

    public ArrayList<Integer> getRewardInfo() {
        return rewardInfo;
    }

    public void setRewardInfo(ArrayList<Integer> rewardInfo) {
        this.rewardInfo = rewardInfo;
    }

    public Map<Integer, Map<Integer, Integer>> getGraduateInfo() {
        return graduateInfo;
    }

    public void setGraduateInfo(Map<Integer, Map<Integer, Integer>> graduateInfo) {
        this.graduateInfo = graduateInfo;
    }

    public LabProductionInfo getLabProInfo(int resourceId) {
        return labProMap.get(resourceId);
    }

    public Map<Integer, LabProductionInfo> getLabProMap() {
        return labProMap;
    }

    public void setLabProMap(Map<Integer, LabProductionInfo> labProMap) {
        this.labProMap = labProMap;
    }

    public void addLabProInfo(int resourceId, LabProductionInfo info) {
        this.labProMap.put(resourceId, info);
    }

    public Map<Integer, SpyInfoData> getSpyMap() {
        return spyMap;
    }

    public void setSpyMap(Map<Integer, SpyInfoData> spyMap) {
        this.spyMap = spyMap;
    }
}

