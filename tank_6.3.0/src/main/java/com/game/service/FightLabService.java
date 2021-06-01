package com.game.service;

import com.alibaba.fastjson.JSON;
import com.game.constant.AwardFrom;
import com.game.constant.AwardType;
import com.game.constant.GameError;
import com.game.constant.SystemId;
import com.game.dataMgr.StaticFunctionPlanDataMgr;
import com.game.dataMgr.StaticIniDataMgr;
import com.game.dataMgr.StaticLabDataMgr;
import com.game.domain.Player;
import com.game.domain.p.LabProductionInfo;
import com.game.domain.p.Prop;
import com.game.domain.p.SpyInfoData;
import com.game.domain.s.*;
import com.game.manager.PlayerDataManager;
import com.game.message.handler.ClientHandler;
import com.game.pb.CommonPb;
import com.game.pb.CommonPb.SpyTaskReward;
import com.game.pb.GamePb6;
import com.game.pb.GamePb6.GetAllSpyTaskRewardRs;
import com.game.util.LogLordHelper;
import com.game.util.LogUtil;
import com.game.util.LotteryUtil;
import com.game.util.PbHelper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.*;

/**
 * @author GuiJie
 * @description 作战实验室
 * @created 2017/12/19 15:37
 */
@Service
public class FightLabService {
    @Autowired
    private PlayerDataManager playerDataManager;
    @Autowired
    private StaticLabDataMgr staticDataMgr;
    @Autowired
    private StaticFunctionPlanDataMgr staticFunctionPlanDataMgr;
    @Autowired
    private StaticIniDataMgr staticIniDataMgr;

    /**
     * 定时每分钟增加科技粒子
     */
    public void labTimerLogic() {
        //功能未开启
        if (!staticFunctionPlanDataMgr.isFightLabOpen()) {
            return;
        }
        //Iterator<Player> iterator = playerDataManager.getPlayers().values().iterator();
        Iterator<Player> iterator = playerDataManager.getRecThreeMonOnlPlayer().values().iterator();
        while (iterator.hasNext()) {
            Player player = iterator.next();
            try {
                playerTimerLogic(player);
            } catch (Exception e) {
                LogUtil.error(" 作战研究院 资源生产逻辑定时器报错, lordId:" + player.lord.getLordId(), e);
            }
        }
    }

    /**
     * 定时生产资源
     *
     * @param player
     */
    private void playerTimerLogic(Player player) {
        //资源信息
        Map<Integer, Integer> resourceInfo = new HashMap<>(player.labInfo.getResourceInfo());

        if (resourceInfo.isEmpty()) {
            return;
        }

        for (Map.Entry<Integer, Integer> en : resourceInfo.entrySet()) {

            //生产信息
            LabProductionInfo labProInfo = player.labInfo.getLabProInfo(en.getKey());
            if (labProInfo == null || labProInfo.getState() == 0) {
                continue;
            }

            //最大生产时间
            int maxTime = getResourceMaxTime(player, en.getKey());

            int t = labProInfo.getTime();
            //已经生产到最大时间
            if (t >= maxTime) {
                continue;
            }

            Map<Integer, Integer> personInfo = player.labInfo.getPersonInfo();
            int personCount = personInfo.containsKey(en.getKey()) ? personInfo.get(en.getKey()) : 0;

            if (personCount <= 0) {
                continue;
            }

            labProInfo.setTime(labProInfo.getTime() + 60);

            StaticLaboratoryItem resourceConfig = staticDataMgr.getItemConfig(en.getKey());

            int count = en.getValue() + (resourceConfig.getAmountPmm() * personCount);

            player.labInfo.getResourceInfo().put(en.getKey(), count);
        }
    }

    /**
     * 作战实验室获取物品信息
     *
     * @param handler
     */
    public void getFightLabItemInfo(ClientHandler handler) {

        Player player = playerDataManager.getPlayer(handler.getRoleId());

        init(player);

        GamePb6.GetFightLabItemInfoRs.Builder builder = GamePb6.GetFightLabItemInfoRs.newBuilder();

        //物品信息
        Map<Integer, Integer> itemInfo = player.labInfo.getLabItemInfo();
        for (Map.Entry<Integer, Integer> en : itemInfo.entrySet()) {
            builder.addItem(PbHelper.createTwoIntPb(en.getKey(), en.getValue()));
        }

        //资源信息
        Map<Integer, Integer> resourceInfo = player.labInfo.getResourceInfo();

        for (Map.Entry<Integer, Integer> en : resourceInfo.entrySet()) {

            builder.addItem(PbHelper.createTwoIntPb(en.getKey(), en.getValue()));

            LabProductionInfo labProInfo = player.labInfo.getLabProInfo(en.getKey());
            builder.addResource(PbHelper.createThreePb(en.getKey(), labProInfo.getState(), labProInfo.getTime()));
        }

        handler.sendMsgToPlayer(GamePb6.GetFightLabItemInfoRs.ext, builder.build());
    }

    /**
     * 获取每种物品最大生产时间上限 (s)
     *
     * @param resourceTypeId
     * @return
     */
    private int getResourceMaxTime(Player player, int resourceTypeId) {
        StaticLaboratoryItem resourceConfig = staticDataMgr.getItemConfig(resourceTypeId);

        int time = resourceConfig.getMaxProduceTime();
        List<StaticLaboratoryResearch> cs = getStaticLaboratoryResearch(staticDataMgr.getResourceArch(resourceTypeId));
        for (StaticLaboratoryResearch c : cs) {
            if (player.labInfo.getArchInfo().containsKey(c.getId())) {
                time += c.getAddProduceTime();
            }
        }
        return time;
    }

    /**
     * 根据资源id获取
     *
     * @param archIds
     * @return
     */
    private List<StaticLaboratoryResearch> getStaticLaboratoryResearch(List<Integer> archIds) {
        List<StaticLaboratoryResearch> result = new ArrayList<>();
        for (Integer archId : archIds) {
            result.add(staticDataMgr.getResearchConfig(archId));
        }
        return result;
    }

    /**
     * @param player
     * @param resourceTypeId 资源类型
     * @return
     */
    private StaticLaboratoryTech getStaticLaboratoryTechConfig(Player player, int resourceTypeId) {

        Map<Integer, Integer> techInfo = player.labInfo.getTechInfo();
        for (Map.Entry<Integer, Integer> en : techInfo.entrySet()) {
            StaticLaboratoryTech config = staticDataMgr.getTechConfig(en.getKey(), en.getValue());
            if (config.getPreBuilding() == resourceTypeId) {
                return config;
            }
        }

        return null;
    }

    /**
     * 作战实验室获取人员信息 科技信息 建筑信息
     *
     * @param handler
     */

    public void getFightLabInfo(ClientHandler handler) {

        Player player = playerDataManager.getPlayer(handler.getRoleId());

        init(player);

        GamePb6.GetFightLabInfoRs.Builder builder = GamePb6.GetFightLabInfoRs.newBuilder();

        //人员空闲人数
        builder.setFreeCount(getPersonFreeCount(player));

        //各种类型分配人数
        Map<Integer, Integer> personInfo = player.labInfo.getPersonInfo();
        //单个类型人数上限判断
        Map<Integer, Integer> typeMaxCount = getPersonTypeMaxCount(player);
        for (Map.Entry<Integer, Integer> en : personInfo.entrySet()) {
            builder.addPresonCount(PbHelper.createThreePb(en.getKey(), en.getValue(), typeMaxCount.get(en.getKey())));
        }

        //科技
        Map<Integer, Integer> techInfo = player.labInfo.getTechInfo();
        for (Map.Entry<Integer, Integer> en : techInfo.entrySet()) {
            builder.addTechInfo(PbHelper.createTwoIntPb(en.getKey(), en.getValue()));
        }

        //建筑
        Map<Integer, Integer> archInfo = player.labInfo.getArchInfo();
        for (Map.Entry<Integer, Integer> en : archInfo.entrySet()) {
            builder.addArchInfo(PbHelper.createTwoIntPb(en.getKey(), en.getValue()));
        }
        handler.sendMsgToPlayer(GamePb6.GetFightLabInfoRs.ext, builder.build());
    }

    /**
     * 作战实验室 建筑激活
     *
     * @param rq
     * @param handler
     */

    public void actFightLabArchAct(GamePb6.ActFightLabArchActRq rq, ClientHandler handler) {

        int actId = rq.getActId();
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        Map<Integer, Integer> archInfo = player.labInfo.getArchInfo();

        //已经激活
        if (archInfo.containsKey(actId) && archInfo.get(actId) == 1) {
            return;
        }

        StaticLaboratoryResearch config = staticDataMgr.getResearchConfig(actId);
        if (config == null) {
            return;
        }
        //前置建筑是否激活
        List<Integer> preBuilding = config.getPreBuilding();
        if (preBuilding != null && !preBuilding.isEmpty()) {
            for (Integer id : preBuilding) {
                if (!archInfo.containsKey(id) || archInfo.get(id) != 1) {
                    return;
                }
            }
        }

        //物品是否足够
        if (!checkItem(player, config.getItemConsume())) {
            return;
        }

        decrItem(player, AwardFrom.LAB_FIGHT_ARCHACT, config.getItemConsume());

        actArch(player, actId);

        LogLordHelper.logfightLabArchAct(AwardFrom.LAB_FIGHT_ARCHACT, player, actId);

        GamePb6.ActFightLabArchActRs.Builder builder = GamePb6.ActFightLabArchActRs.newBuilder();

        builder.setArchInfo(PbHelper.createTwoIntPb(actId, 1));

        //同步物品
        List<List<Integer>> itemConsume = config.getItemConsume();
        for (List<Integer> item : itemConsume) {
            int type = item.get(0);
            int itemId = item.get(1);
            builder.addItemInfo(PbHelper.createThreePb(type, itemId, getItemCount(player, type, itemId)));
        }

        //影响的科技
        List<StaticLaboratoryTech> configs = staticDataMgr.getTechConfigs(actId);
        List<Integer> techIds = new ArrayList<>();
        if (configs != null && !configs.isEmpty()) {
            for (StaticLaboratoryTech c : configs) {
                if (!techIds.contains(c.getTechId())) {
                    techIds.add(c.getTechId());
                }
            }
        }

        if (!techIds.isEmpty()) {
            Map<Integer, Integer> techInfo = player.labInfo.getTechInfo();
            int techId = techIds.get(0);
            builder.setTechInfo(PbHelper.createTwoIntPb(techId, techInfo.get(techId)));
        }

        //单个类型人数上限判断
        Map<Integer, Integer> typeMaxCount = getPersonTypeMaxCount(player);
        Map<Integer, Integer> personInfo = player.labInfo.getPersonInfo();
        for (Map.Entry<Integer, Integer> e : personInfo.entrySet()) {
            //各种类型分配人数
            builder.addPresonCount(PbHelper.createThreePb(e.getKey(), e.getValue(), typeMaxCount.get(e.getKey())));

            //资源生产状态
            LabProductionInfo labProInfo = player.labInfo.getLabProInfo(e.getKey());
            builder.addResource(PbHelper.createThreePb(e.getKey(), labProInfo.getState(), labProInfo.getTime()));

        }

        handler.sendMsgToPlayer(GamePb6.ActFightLabArchActRs.ext, builder.build());
    }

    /**
     * 作战实验室 科技升级
     *
     * @param rq
     * @param handler
     */
    public void upFightLabTechUpLevel(GamePb6.UpFightLabTechUpLevelRq rq, ClientHandler handler) {

        int techId = rq.getTechId();
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        Map<Integer, Integer> techInfo = player.labInfo.getTechInfo();
        //未激活
        if (!techInfo.containsKey(techId)) {
            return;
        }
        StaticLaboratoryTech config = staticDataMgr.getTechConfig(techId, techInfo.get(techId) + 1);
        //满级
        if (config == null) {
            return;
        }

        //物品是否足够
        if (!checkItem(player, config.getItemConsume())) {
            return;
        }

        decrItem(player, AwardFrom.LAB_FIGHT_TECHUP, config.getItemConsume());

        player.labInfo.addTech(techId, techInfo.get(techId) + 1);

        LogLordHelper.logfightLabTechUpgradeLevel(AwardFrom.LAB_FIGHT_TECHUP, player, techId, techInfo.get(techId));

        GamePb6.UpFightLabTechUpLevelRs.Builder builder = GamePb6.UpFightLabTechUpLevelRs.newBuilder();
        builder.setTechId(techId);
        builder.setLevel(techInfo.get(techId));
        builder.setFreeCount(getPersonFreeCount(player));

        List<List<Integer>> itemConsume = config.getItemConsume();
        for (List<Integer> item : itemConsume) {
            int type = item.get(0);
            int itemId = item.get(1);
            builder.addItemInfo(PbHelper.createThreePb(type, itemId, getItemCount(player, type, itemId)));
        }

        handler.sendMsgToPlayer(GamePb6.UpFightLabTechUpLevelRs.ext, builder.build());

    }

    /**
     * 兼容以前的数据
     *
     * @param player
     */
    private void resetPerson(Player player) {
        Map<Integer, Integer> person = new HashMap<>(player.labInfo.getPersonInfo());
        //单个类型人数上限判断
        Map<Integer, Integer> typeMaxCount = getPersonTypeMaxCount(player);

        for (Map.Entry<Integer, Integer> t : person.entrySet()) {
            if (t.getValue() > typeMaxCount.get(t.getKey())) {
                player.labInfo.getPersonInfo().put(t.getKey(), 0);
                StaticLaboratoryItem resourceConfig = staticDataMgr.getItemConfig(t.getKey());
                //分配数值倍数
                if (typeMaxCount.get(t.getKey()) % resourceConfig.getMinP() != 0) {
                    player.labInfo.getPersonInfo().put(t.getKey(), 0);
                }
            }
        }

    }

    /**
     * 作战实验室设置人员信息
     *
     * @param rq
     * @param handler
     */
    public void setFightLabPersonCount(GamePb6.SetFightLabPersonCountRq rq, ClientHandler handler) {

        List<CommonPb.TwoInt> pcount = rq.getPresonCountList();
        Player player = playerDataManager.getPlayer(handler.getRoleId());

        Map<Integer, Integer> personInfo = player.labInfo.getPersonInfo();

        Map<Integer, Integer> person = new HashMap<>(player.labInfo.getPersonInfo());

        for (CommonPb.TwoInt t : pcount) {

            if (t.getV2() < 0) {
                return;
            }

            StaticLaboratoryItem resourceConfig = staticDataMgr.getItemConfig(t.getV1());

            //分配数值倍数
            if (t.getV2() % resourceConfig.getMinP() != 0) {
                return;
            }

            //没有激活的也设置了人数
            if (!personInfo.containsKey(t.getV1()) && t.getV2() > 0) {
                return;
            }

            //过滤掉没有激活的
            if (!personInfo.containsKey(t.getV1()) && t.getV2() == 0) {
                continue;
            }
            person.put(t.getV1(), t.getV2());
        }

        //总人数判断
        int allCount = 0;
        for (Integer val : person.values()) {
            allCount += val;
        }
        if (allCount > getPersonMaxCount(player)) {
            return;
        }

        //单个类型人数上限判断
        Map<Integer, Integer> typeMaxCount = getPersonTypeMaxCount(player);
        for (Map.Entry<Integer, Integer> t : person.entrySet()) {
            if (t.getValue() > typeMaxCount.get(t.getKey())) {
                return;
            }
        }

        GamePb6.SetFightLabPersonCountRs.Builder builder = GamePb6.SetFightLabPersonCountRs.newBuilder();

        //设置人员数
        for (Map.Entry<Integer, Integer> t : person.entrySet()) {
            personInfo.put(t.getKey(), t.getValue());

            LabProductionInfo labProInfo = player.labInfo.getLabProInfo(t.getKey());
            //刷新状态
            if (t.getValue() > 0) {
                labProInfo.setState(1);
            } else {
                labProInfo.setState(0);
            }

            //资源生产状态
            builder.addResource(PbHelper.createThreePb(t.getKey(), labProInfo.getState(), labProInfo.getTime()));

            //各种类型分配人数
            builder.addPresonCount(PbHelper.createThreePb(t.getKey(), t.getValue(), typeMaxCount.get(t.getKey())));
        }

        builder.setFreeCount(getPersonFreeCount(player));
        handler.sendMsgToPlayer(GamePb6.SetFightLabPersonCountRs.ext, builder.build());
    }

    /**
     * 作战实验室 领取生产的资源
     *
     * @param rq
     * @param handler
     */
    public void getFightLabResource(GamePb6.GetFightLabResourceRq rq, ClientHandler handler) {

        int resourctId = rq.getResourceId();

        Player player = playerDataManager.getPlayer(handler.getRoleId());

        StaticLaboratoryTech config = getStaticLaboratoryTechConfig(player, resourctId);

        Map<Integer, Integer> resourceInfo = player.labInfo.getResourceInfo();

        //现有数量
        int count = resourceInfo.get(resourctId);

        if (count <= 0) {
            return;
        }

        if (config != null) {
            if (count < config.getComposeEfficiency()) {
                return;
            }
        }

        //能合成的数量
        int itemCount = count;

        if (config != null) {
            itemCount = count / config.getComposeEfficiency();
        }

        //剩余数量

        if (config != null) {
            count = count - (itemCount * config.getComposeEfficiency());
        } else {
            count = 0;
        }

        //重置生产时间
        LabProductionInfo labProInfo = player.labInfo.getLabProInfo(resourctId);
        labProInfo.setTime(0);

        //设置新数量
        resourceInfo.put(resourctId, count);
        int itemId = staticDataMgr.getResourceItemid(resourctId);

        //添加物品
        player.labInfo.addItem(player, AwardFrom.LAB_FIGHT_RESOURCE, itemId, itemCount);

        GamePb6.GetFightLabResourceRs.Builder builder = GamePb6.GetFightLabResourceRs.newBuilder();

        builder.addResource(PbHelper.createThreePb(labProInfo.getResourceId(), labProInfo.getState(), labProInfo.getTime()));
        builder.addItemInfo(PbHelper.createThreePb(AwardType.LAB_FIGHT, itemId, player.labInfo.getLabItemInfo().get(itemId)));
        builder.addItemInfo(PbHelper.createThreePb(AwardType.LAB_FIGHT, resourctId, player.labInfo.getResourceInfo().get(resourctId)));
        handler.sendMsgToPlayer(GamePb6.GetFightLabResourceRs.ext, builder.build());
    }

    /**
     * 获取总人数
     *
     * @param player
     * @return
     */
    private int getPersonMaxCount(Player player) {

        Map<Integer, Integer> techInfo = player.labInfo.getTechInfo();
        //4类型是增加项目总人数

        int maxCount = 0;
        for (Map.Entry<Integer, Integer> en : techInfo.entrySet()) {
            StaticLaboratoryTech conf = staticDataMgr.getTechConfig(en.getKey(), techInfo.get(en.getKey()));
            maxCount += conf.getMaxPersonNumber();
        }
        return maxCount;
    }

    /**
     * 获取空闲人数
     *
     * @param player
     * @return
     */
    private int getPersonFreeCount(Player player) {

        //各种类型分配人数
        Map<Integer, Integer> resourceInfo = player.labInfo.getPersonInfo();
        int count = 0;
        for (Map.Entry<Integer, Integer> en : resourceInfo.entrySet()) {
            count += en.getValue();
        }

        return getPersonMaxCount(player) - count;
    }

    /**
     * 获取单个类型总人数上限
     *
     * @param player
     * @return
     */
    private Map<Integer, Integer> getPersonTypeMaxCount(Player player) {

        Map<Integer, Integer> result = new HashMap<>();

        Map<Integer, Integer> techInfo = player.labInfo.getTechInfo();

        int maxCount = 0;
        for (Map.Entry<Integer, Integer> en : techInfo.entrySet()) {
            StaticLaboratoryTech conf = staticDataMgr.getTechConfig(en.getKey(), techInfo.get(en.getKey()));
            maxCount += conf.getPersonNumberLimit();
        }

        Map<Integer, Integer> resourceInfo = player.labInfo.getPersonInfo();
        for (Map.Entry<Integer, Integer> en : resourceInfo.entrySet()) {
            StaticLaboratoryItem resourceConfig = staticDataMgr.getItemConfig(en.getKey());
            result.put(en.getKey(), maxCount + resourceConfig.getPersonLimit());
        }

        return result;
    }

    /**
     * 初始化
     *
     * @param player
     */
    private void init(Player player) {

        //科技
        List<StaticLaboratoryTech> techConfigs = staticDataMgr.getTechConfigs(0);
        for (StaticLaboratoryTech c : techConfigs) {
            if (c.getPreBuilding() == 0 && !player.labInfo.getTechInfo().containsKey(c.getTechId())) {
                player.labInfo.addTech(c.getTechId(), 0);
            }
        }

        //建筑
        Map<Integer, Integer> archInfo = player.labInfo.getArchInfo();
        if (archInfo.isEmpty()) {
            List<StaticLaboratoryResearch> configs = staticDataMgr.getResearchConfigs();
            for (StaticLaboratoryResearch c : configs) {
                if (c.getIfUnlock() == 1) {
                    actArch(player, c.getId());
                }
            }
        }

        //设置研究人数
        Map<Integer, Integer> resourceInfo = player.labInfo.getResourceInfo();
        if (!resourceInfo.isEmpty()) {
            for (Integer resourceId : resourceInfo.keySet()) {
                if (!player.labInfo.getPersonInfo().containsKey(resourceId)) {
                    player.labInfo.getPersonInfo().put(resourceId, 0);
                }

                //生产状态初始化
                LabProductionInfo labProInfo = player.labInfo.getLabProInfo(resourceId);
                if (labProInfo == null) {
                    labProInfo = new LabProductionInfo(resourceId, 0, 0);
                    if (player.labInfo.getPersonInfo().get(resourceId) != 0) {
                        labProInfo.setState(1);
                    }
                    player.labInfo.addLabProInfo(resourceId, labProInfo);
                }
            }
        }

        //初始化物品
        Map<Integer, Integer> labItemInfo = player.labInfo.getLabItemInfo();
        List<StaticLaboratoryItem> itemConfigs = staticDataMgr.getItemConfigs();
        for (StaticLaboratoryItem c : itemConfigs) {
            if (c.getIfPieces() == 0 && !labItemInfo.containsKey(c.getId())) {
                labItemInfo.put(c.getId(), 0);
            }
        }

        resetPerson(player);

    }

    /**
     * 资源生产激活
     *
     * @param player
     * @param actId
     */
    private void actResource(Player player, int actId) {
        List<StaticLaboratoryResearch> configs = staticDataMgr.getResearchConfigs();
        for (StaticLaboratoryResearch c : configs) {
            if (c.getType() == 1 && c.getId() == actId) {
                if (!player.labInfo.getResourceInfo().containsKey(c.getId())) {
                    player.labInfo.getResourceInfo().put(c.getId(), 0);
                    player.labInfo.addLabProInfo(c.getId(), new LabProductionInfo(c.getId(), 0, 0));
                    player.labInfo.getPersonInfo().put(c.getId(), 0);
                }
            }
        }
    }

    /**
     * 激活建筑
     *
     * @param player
     * @param actId
     */
    private void actArch(Player player, int actId) {

        player.labInfo.addArch(actId, 1);

        //激活建筑关联激活科技
        List<StaticLaboratoryTech> configs = staticDataMgr.getTechConfigs(actId);
        if (!configs.isEmpty()) {
            for (StaticLaboratoryTech c : configs) {
                if (!player.labInfo.getTechInfo().containsKey(c.getTechId())) {
                    player.labInfo.addTech(c.getTechId(), 0);
                }
            }
        }

        //资源激活
        actResource(player, actId);
    }

    /**
     * 作战实验室 获取深度研究所信息
     *
     * @param rq
     * @param handler
     */
    public void getFightLabGraduateInfo(GamePb6.GetFightLabGraduateInfoRq rq, ClientHandler handler) {

        Player player = playerDataManager.getPlayer(handler.getRoleId());

        initGraduate(player);

        Map<Integer, Map<Integer, Integer>> infoMap = player.labInfo.getGraduateInfo();

        GamePb6.GetFightLabGraduateInfoRs.Builder builder = GamePb6.GetFightLabGraduateInfoRs.newBuilder();

        for (Map.Entry<Integer, Map<Integer, Integer>> typeInfo : infoMap.entrySet()) {
            Map<Integer, Integer> info = infoMap.get(typeInfo.getKey());
            for (Map.Entry<Integer, Integer> skillInfo : info.entrySet()) {
                builder.addInfo(PbHelper.createThreePb(typeInfo.getKey(), skillInfo.getKey(), skillInfo.getValue()));
            }
        }
        List<Integer> rewardInfo = player.labInfo.getRewardInfo();
        int cid = 0;
        builder.setRewardId(cid);
        for (Integer id : rewardInfo) {
            if (id > cid) {
                cid = id;
                builder.setRewardId(id);
            }

        }
        handler.sendMsgToPlayer(GamePb6.GetFightLabGraduateInfoRs.ext, builder.build());
    }

    /**
     * 初始化
     *
     * @param player
     */
    private void initGraduate(Player player) {

        if (!player.labInfo.getGraduateInfo().isEmpty()) {
            return;
        }
        List<StaticLaboratoryMilitary> config = staticDataMgr.getGraduateConfig();
        for (StaticLaboratoryMilitary c : config) {
            if (!player.labInfo.getGraduateInfo().containsKey(c.getType())) {
                player.labInfo.getGraduateInfo().put(c.getType(), new HashMap<Integer, Integer>());
            }
            if (!player.labInfo.getGraduateInfo().get(c.getType()).containsKey(c.getSkillId())) {
                player.labInfo.getGraduateInfo().get(c.getType()).put(c.getSkillId(), 0);
            }

        }

    }

    /**
     * 作战实验室 深度研究所 升级
     *
     * @param rq
     * @param handler
     */
    public void upFightLabGraduateUp(GamePb6.UpFightLabGraduateUpRq rq, ClientHandler handler) {

        int type = rq.getType();
        int skillId = rq.getSkillId();
        Player player = playerDataManager.getPlayer(handler.getRoleId());

        Map<Integer, Map<Integer, Integer>> info = player.labInfo.getGraduateInfo();

        Map<Integer, Integer> in = info.get(type);

        StaticLaboratoryMilitary config = staticDataMgr.getGraduateConfig(type, skillId, in.get(skillId) + 1);

        if (config == null) {
            return;
        }

        //前置条件判断
        List<List<Integer>> perSkill = config.getPerSkill();

        if (perSkill != null && !perSkill.isEmpty()) {
            for (List<Integer> i : perSkill) {
                if (in.get(i.get(0)) < i.get(1)) {
                    return;
                }
            }
        }

        List<List<Integer>> cost = config.getCost();

        if (!checkItem(player, cost)) {
            return;
        }

        if (!decrItem(player, AwardFrom.LAB_FIGHT_LABGRADUATEUP, cost)) {
            return;
        }

        in.put(skillId, in.get(skillId) + 1);

        LogLordHelper.logfightLabGraduate(AwardFrom.LAB_FIGHT_LABGRADUATEUP, player, skillId, in.get(skillId));

        GamePb6.UpFightLabGraduateUpRs.Builder builder = GamePb6.UpFightLabGraduateUpRs.newBuilder();
        builder.setLevel(in.get(skillId));
        builder.setSkillId(skillId);
        builder.setType(type);

        for (List<Integer> it : cost) {
            int tt = it.get(0);
            int itemId = it.get(1);
            builder.addDearItemInfo(PbHelper.createThreePb(tt, itemId, getItemCount(player, tt, itemId)));
        }
        handler.sendMsgToPlayer(GamePb6.UpFightLabGraduateUpRs.ext, builder.build());

        //影响被动

    }

    /**
     * 重置
     *
     * @param rq
     * @param handler
     */
    public void resetFightLabGraduateUp(GamePb6.ResetFightLabGraduateUpRq rq, ClientHandler handler) {

        int type = rq.getType();
        Player player = playerDataManager.getPlayer(handler.getRoleId());

        StaticSystem constant = staticIniDataMgr.getSystemConstantById(SystemId.LAB_VIP);

        if (player.lord.getVip() < Integer.valueOf(constant.getValue())) {
            handler.sendErrorMsgToPlayer(GameError.VIP_NOT_ENOUGH);
            return;
        }

        Map<Integer, Map<Integer, Integer>> info = player.labInfo.getGraduateInfo();
        Map<Integer, Integer> infoMap = info.get(type);

        if (infoMap == null || infoMap.isEmpty()) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }

        Map<Integer, Integer> itemMap = new HashMap<>();

        List<List<Integer>> addItem = new ArrayList<>();
        for (Map.Entry<Integer, Integer> e : infoMap.entrySet()) {
            if (e.getValue() > 0) {
                for (int level = e.getValue(); level > 0; level--) {
                    StaticLaboratoryMilitary config = staticDataMgr.getGraduateConfig(type, e.getKey(), level);
                    List<List<Integer>> cost = config.getCost();
                    addItem.addAll(cost);
                    for (List<Integer> list : cost) {
                        if (!itemMap.containsKey(list.get(1))) {
                            itemMap.put(list.get(1), 0);
                        }
                        itemMap.put(list.get(1), itemMap.get(list.get(1)) + list.get(2));
                    }

                }
            }
        }

        if (itemMap == null || itemMap.isEmpty()) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }

        int gold = 0;

        for (Map.Entry<Integer, Integer> e : itemMap.entrySet()) {

            StaticLaboratoryItem itemConfig = staticDataMgr.getItemConfig(e.getKey());

            float f = itemConfig.getRevertPrice() / 1000000f;
            gold += Math.ceil(f * e.getValue());
        }

        if (player.lord.getGold() < gold) {
            handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
            return;
        }

        for (Integer e : new ArrayList<>(infoMap.keySet())) {
            infoMap.put(e, 0);
        }

        playerDataManager.subGold(player, gold, AwardFrom.LAB_FIGHT_RESET);

        addItem(player, AwardFrom.LAB_FIGHT_RESET, addItem);

        GamePb6.ResetFightLabGraduateUpRs.Builder builder = GamePb6.ResetFightLabGraduateUpRs.newBuilder();

        builder.setGold(player.lord.getGold());
        //同步物品
        for (Integer itemId : itemMap.keySet()) {
            builder.addItemInfo(PbHelper.createThreePb(AwardType.LAB_FIGHT, itemId, getItemCount(player, AwardType.LAB_FIGHT, itemId)));
        }

        for (Map.Entry<Integer, Map<Integer, Integer>> typeInfo : player.labInfo.getGraduateInfo().entrySet()) {
            Map<Integer, Integer> in = typeInfo.getValue();
            for (Map.Entry<Integer, Integer> skillInfo : in.entrySet()) {
                builder.addInfo(PbHelper.createThreePb(typeInfo.getKey(), skillInfo.getKey(), skillInfo.getValue()));
            }
        }
        handler.sendMsgToPlayer(GamePb6.ResetFightLabGraduateUpRs.ext, builder.build());

    }

    /**
     * 消耗物品
     *
     * @param player
     * @param from
     * @param cost
     * @return
     */
    private boolean decrItem(Player player, AwardFrom from, List<List<Integer>> cost) {
        if (!checkItem(player, cost)) {
            return false;
        }

        for (List<Integer> it : cost) {

            int type = it.get(0);
            int itemId = it.get(1);
            int count = it.get(2);
            playerDataManager.subProp(player, type, itemId, count, from);
        }

        return true;
    }

    /**
     * 验证物品是否足够
     *
     * @param player
     * @param cost
     * @return
     */
    private boolean checkItem(Player player, List<List<Integer>> cost) {
        if (cost == null || cost.isEmpty()) {
            return true;
        }

        for (List<Integer> it : cost) {

            int type = it.get(0);
            int itemId = it.get(1);
            int count = it.get(2);

            boolean enougth = playerDataManager.checkPropIsEnougth(player, type, itemId, count);
            if (!enougth) {
                return false;
            }

        }

        return true;
    }

    /**
     * 作战实验室 获取领取奖励信息
     *
     * @param rq
     * @param handler
     */
    public void getFightLabGraduateReward(GamePb6.GetFightLabGraduateRewardRq rq, ClientHandler handler) {

        Player player = playerDataManager.getPlayer(handler.getRoleId());

        Map<Integer, Map<Integer, Integer>> info = player.labInfo.getGraduateInfo();

        int allLevel = getAllLevel(info);

        List<Integer> rewardList = player.labInfo.getRewardInfo();
        StaticLaboratoryProgress con = null;

        List<StaticLaboratoryProgress> config = staticDataMgr.getRewardConfig();
        for (StaticLaboratoryProgress c : config) {

            List<Integer> progress = c.getProgress();

            if (allLevel >= progress.get(1) && !rewardList.contains(c.getId())) {
                con = c;
                break;
            }
        }

        if (con == null) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }

        player.labInfo.getRewardInfo().add(con.getId());

        addItem(player, AwardFrom.LAB_FIGHT_LABGRADUATE_REWARD, con.getAward());

        GamePb6.GetFightLabGraduateRewardRs.Builder builder = GamePb6.GetFightLabGraduateRewardRs.newBuilder();

        List<Integer> rewardInfo = player.labInfo.getRewardInfo();
        int cid = 0;
        builder.setRewardId(cid);
        for (Integer id : rewardInfo) {
            if (id > cid) {
                cid = id;
                builder.setRewardId(id);
            }

        }

        List<List<Integer>> award = con.getAward();

        for (List<Integer> it : award) {
            int type = it.get(0);
            int itemId = it.get(1);
            int count = it.get(2);
            builder.addAward(PbHelper.createAwardPb(type, itemId, count));
        }

        handler.sendMsgToPlayer(GamePb6.GetFightLabGraduateRewardRs.ext, builder.build());

    }

    private int getItemCount(Player player, int type, int itemId) {
        if (type == AwardType.PROP) {
            Prop prop = player.props.get(itemId);
            return prop == null ? 0 : prop.getCount();
        }

        if (type == AwardType.LAB_FIGHT) {
            Integer count = player.labInfo.getLabItemInfo().get(itemId);
            return count == null ? 0 : count.intValue();
        }

        if (type == AwardType.GOLD) {
            return player.lord.getGold();
        }
        return 0;
    }

    private void addItem(Player player, AwardFrom from, List<List<Integer>> cost) {
        if (cost == null || cost.isEmpty()) {
            return;
        }

        for (List<Integer> it : cost) {
            int type = it.get(0);
            int itemId = it.get(1);
            int count = it.get(2);
            playerDataManager.addAward(player, type, itemId, count, from);
        }
    }

    /**
     * 获取所有技能总登记
     *
     * @param info
     * @return
     */
    private int getAllLevel(Map<Integer, Map<Integer, Integer>> info) {
        int a = 0;
        for (Map.Entry<Integer, Map<Integer, Integer>> e : info.entrySet()) {
            Map<Integer, Integer> en = e.getValue();
            for (Map.Entry<Integer, Integer> v : en.entrySet()) {
                StaticLaboratoryMilitary config = staticDataMgr.getGraduateConfig(e.getKey(), v.getKey(), v.getValue() + 1);
                if (config == null) {
                    a++;
                }
            }
        }
        return a;
    }

    /**
     * 判断坦克生产所需的研究所科技技能是否已经解锁
     *
     * @param player
     * @param staticTank
     * @return
     */
    public boolean isTankBuildOpen(Player player, StaticTank staticTank) {
        if (staticTank.getFightLabSkill() <= 0)
            return true;
        Map<Integer, Integer> skillMap = player.labInfo.getGraduateInfo().get(staticTank.getType());
        Integer skillLv = skillMap != null ? skillMap.get(staticTank.getFightLabSkill()) : null;
        return skillLv != null && skillLv > 0;
    }

    /**
     * 获取作战实验室对指定属性的加成
     *
     * @param player
     * @param specilAttrId
     * @return 加成数值
     */
    public int getSpecilAttrAdd(Player player, int specilAttrId) {
        int attrAdd = 0;
        Map<Integer, Set<Integer>> typeMap = staticDataMgr.getSpecilSkillList(specilAttrId);
        if (typeMap == null || typeMap.isEmpty())
            return attrAdd;//此属性没有任何加成技能
        Map<Integer, Map<Integer, Integer>> grdMap = player.labInfo.getGraduateInfo();
        for (Map.Entry<Integer, Set<Integer>> entry : typeMap.entrySet()) {
            Map<Integer, Integer> sklMap = grdMap.get(entry.getKey());
            if (sklMap == null || sklMap.isEmpty())
                continue;//指定类型的技能集合不存在

            for (Integer skillId : entry.getValue()) {
                Integer skillLv = sklMap.get(skillId);
                if (skillLv == null || skillLv == 0)
                    continue;//技能未学习

                StaticLaboratoryMilitary data = staticDataMgr.getGraduateConfig(entry.getKey(), skillId, skillLv);
                List<List<Integer>> effects = data != null ? data.getEffect() : null;
                if (effects == null || effects.isEmpty())
                    continue;//技能效果未配置

                //累加技能属性
                for (List<Integer> effect : data.getEffect()) {
                    if (effect.get(0) == specilAttrId) {
                        attrAdd += effect.get(1);
                    }
                }
            }
        }
        return attrAdd;
    }

    /**
     * gm添加物品
     *
     * @param player
     * @param itemId
     * @param count
     */
    public void gmAddItem(Player player, int itemId, int count) {

        if (itemId >= 201 && itemId <= 204) {
            player.labInfo.addItem(player, AwardFrom.GM_SEND, itemId, count);
        }

        if (itemId >= 101 && itemId <= 104 && player.labInfo.getResourceInfo().containsKey(itemId)) {
            player.labInfo.getResourceInfo().put(itemId, player.labInfo.getResourceInfo().get(itemId) + count);
        }

    }

    /**
     * gm 添加生产时间
     *
     * @param player
     * @param time
     */
    public void gmAddProTime(Player player, int time) {
        if (time > 0) {
            for (int i = 0; i < time; i++) {
                playerTimerLogic(player);
            }
        }
    }

    public void gmSkillFull(Player player) {
        Map<Integer, Map<Integer, Integer>> labMap = player.labInfo.getGraduateInfo();
        for (StaticLaboratoryMilitary lab : staticDataMgr.getGraduateConfig()) {
            Map<Integer, Integer> tyMap = labMap.get(lab.getType());
            if (tyMap == null)
                labMap.put(lab.getType(), tyMap = new HashMap<Integer, Integer>());
            Integer maxLv = tyMap.get(lab.getSkillId());
            if (maxLv == null || lab.getLv() > maxLv) {
                tyMap.put(lab.getSkillId(), maxLv);
            }
        }
    }

    //*********************************间谍机构********************************************************

    /**
     * 作战实验室 获取间谍信息
     *
     * @param rq
     * @param handler
     */
    public void getSpyInfo(GamePb6.GetFightLabSpyInfoRq rq, ClientHandler handler) {

        Player player = playerDataManager.getPlayer(handler.getRoleId());

        spyInit(player);

        Map<Integer, SpyInfoData> spyMap = player.labInfo.getSpyMap();
        GamePb6.GetFightLabSpyInfoRs.Builder builder = GamePb6.GetFightLabSpyInfoRs.newBuilder();

        for (SpyInfoData spy : spyMap.values()) {
            CommonPb.SpyInfo.Builder spyInfo = CommonPb.SpyInfo.newBuilder();
            spyInfo.setAreaId(spy.getAreaId());
            spyInfo.setState(spy.getState());
            spyInfo.setTaskId(spy.getTaskId());
            spyInfo.setTime(getSpyTime(spy));
            spyInfo.setSpyId(spy.getSpyId());
            builder.addSpyinfo(spyInfo);

        }

        handler.sendMsgToPlayer(GamePb6.GetFightLabSpyInfoRs.ext, builder.build());
    }

    /**
     * 初始化
     *
     * @param player
     */
    private void spyInit(Player player) {
        Map<Integer, SpyInfoData> spyMap = player.labInfo.getSpyMap();
        Map<Integer, StaticLaboratoryArea> areaConfig = staticDataMgr.getAreaConfig();
        for (StaticLaboratoryArea config : areaConfig.values()) {
            if (!spyMap.containsKey(config.getAreaId())) {

                SpyInfoData spy = new SpyInfoData();

                spy.setAreaId(config.getAreaId());

                if (config.getIfUnlock() == 0) {
                    spy.setState(2);//2待接任务
                } else {
                    spy.setState(0);
                }

                spy.setTaskId(refreshTask(0, config.getAreaId()));
                spy.setTime(0);
                spyMap.put(config.getAreaId(), spy);
            }
        }

        //刷新状态
        refState(player);
        //刷新任务状态
        refreshTaskState(player);
    }

    /**
     * 刷新状态
     *
     * @param player
     */
    private void refState(Player player) {

        Map<Integer, StaticLaboratoryArea> areaConfig = staticDataMgr.getAreaConfig();
        Map<Integer, SpyInfoData> spyMap = player.labInfo.getSpyMap();
        //更改状态  1可以解锁
        for (SpyInfoData s : spyMap.values()) {

            if (s.getState() != 0) {
                continue;
            }

            StaticLaboratoryArea config = areaConfig.get(s.getAreaId());
            if (config.getIfUnlock() != 0 && spyMap.containsKey(config.getIfUnlock())) {
                SpyInfoData spyInfo = spyMap.get(config.getIfUnlock());
                if (spyInfo.getState() >= 2) {
                    s.setState(1);
                }
            }
        }
    }

    /**
     * 随机一个任务
     *
     * @param oldTaskId 上一个任务id
     * @param areaId
     * @return
     */
    private int refreshTask(int oldTaskId, int areaId) {
        Map<Integer, StaticLaboratoryArea> areaConfig = staticDataMgr.getAreaConfig();
        StaticLaboratoryArea config = areaConfig.get(areaId);
        List<List<Integer>> task = config.getTask();
        Map<Integer, Float> taskMap = new HashMap<>();
        for (List<Integer> t : task) {
            if (t.get(0) == oldTaskId) {
                continue;
            }
            taskMap.put(t.get(0), new Float(t.get(1)));
        }

        return LotteryUtil.getRandomKey(taskMap);
    }

    /**
     * 作战实验室 间谍地图激活
     *
     * @param rq
     * @param handler
     */
    public void actArea(GamePb6.ActFightLabSpyAreaRq rq, ClientHandler handler) {

        int areaId = rq.getAreaId();
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        Map<Integer, SpyInfoData> spyMap = player.labInfo.getSpyMap();
        SpyInfoData spyInfo = spyMap.get(areaId);
        //激活条件未达到
        if (spyInfo.getState() != 1) {
            return;
        }

        Map<Integer, StaticLaboratoryArea> areaConfig = staticDataMgr.getAreaConfig();
        StaticLaboratoryArea config = areaConfig.get(areaId);

        //金币不足
        if (player.lord.getGold() < config.getCost()) {
            return;
        }

        boolean subGold = playerDataManager.subGold(player, config.getCost(), AwardFrom.LAB_FIGHT_SPY_ACTAREA);
        if (!subGold) {
            return;
        }

        spyInfo.setState(2);
        spyInfo.setTaskId(refreshTask(0, areaId));

        refState(player);

        GamePb6.ActFightLabSpyAreaRs.Builder builder = GamePb6.ActFightLabSpyAreaRs.newBuilder();

        CommonPb.SpyInfo.Builder s = CommonPb.SpyInfo.newBuilder();
        s.setAreaId(spyInfo.getAreaId());
        s.setState(spyInfo.getState());
        s.setTaskId(spyInfo.getTaskId());
        s.setTime(getSpyTime(spyInfo));
        builder.setSpyinfo(s);
        builder.setGold(player.lord.getGold());
        handler.sendMsgToPlayer(GamePb6.ActFightLabSpyAreaRs.ext, builder.build());
    }

    /**
     * 作战实验室 间谍任务刷新
     *
     * @param rq
     * @param handler
     */
    public void refreshSpyTask(GamePb6.RefFightLabSpyTaskRq rq, ClientHandler handler) {
        int areaId = rq.getAreaId();
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        Map<Integer, SpyInfoData> spyMap = player.labInfo.getSpyMap();
        SpyInfoData spyInfo = spyMap.get(areaId);
        //不能刷新
        if (spyInfo.getState() != 2) {
            return;
        }
        Map<Integer, StaticLaboratoryArea> areaConfig = staticDataMgr.getAreaConfig();
        StaticLaboratoryArea config = areaConfig.get(areaId);

        //金币不足
        if (player.lord.getGold() < config.getRefreshCost()) {
            return;
        }

        boolean subGold = playerDataManager.subGold(player, config.getRefreshCost(), AwardFrom.LAB_FIGHT_SPY_REF_TASK);
        if (!subGold) {
            return;
        }

        spyInfo.setTaskId(refreshTask(spyInfo.getTaskId(), areaId));

        GamePb6.RefFightLabSpyTaskRs.Builder builder = GamePb6.RefFightLabSpyTaskRs.newBuilder();
        builder.setTaskId(spyInfo.getTaskId());
        builder.setGold(player.lord.getGold());
        handler.sendMsgToPlayer(GamePb6.RefFightLabSpyTaskRs.ext, builder.build());
    }

    /**
     * 作战实验室 间谍任务派遣
     *
     * @param rq
     * @param handler
     */
    public void actSpyTask(GamePb6.ActFightLabSpyTaskRq rq, ClientHandler handler) {
        int areaId = rq.getAreaId();
        int spyId = rq.getSpyId();

        Player player = playerDataManager.getPlayer(handler.getRoleId());
        Map<Integer, SpyInfoData> spyMap = player.labInfo.getSpyMap();
        SpyInfoData spyInfo = spyMap.get(areaId);
        //不能刷新
        if (spyInfo.getState() != 2) {
            return;
        }

        Map<Integer, StaticLaboratorySpy> spyConfig = staticDataMgr.getSpyConfig();
        StaticLaboratorySpy config = spyConfig.get(spyId);

        if (config.getCost() > 0) {

            //金币不足
            if (player.lord.getGold() < config.getCost()) {
                return;
            }

            boolean subGold = playerDataManager.subGold(player, config.getCost(), AwardFrom.LAB_FIGHT_SPY_TASK);
            if (!subGold) {
                return;
            }
        }

        spyInfo.setState(3);
        spyInfo.setSpyId(spyId);
        spyInfo.setTime((int) (System.currentTimeMillis() / 1000));

        GamePb6.ActFightLabSpyTaskRs.Builder builder = GamePb6.ActFightLabSpyTaskRs.newBuilder();

        CommonPb.SpyInfo.Builder s = CommonPb.SpyInfo.newBuilder();
        s.setAreaId(spyInfo.getAreaId());
        s.setState(spyInfo.getState());
        s.setTaskId(spyInfo.getTaskId());
        s.setTime(getSpyTime(spyInfo));
        s.setSpyId(spyInfo.getSpyId());

        builder.setGold(player.lord.getGold());
        handler.sendMsgToPlayer(GamePb6.ActFightLabSpyTaskRs.ext, builder.build());
    }

    /**
     * 获取剩余时间
     *
     * @param spyInfo
     * @return
     */
    private int getSpyTime(SpyInfoData spyInfo) {

        if (spyInfo.getSpyId() == 0) {
            return 0;
        }

        Map<Integer, StaticLaboratoryTask> taskConfig = staticDataMgr.getTaskConfig();
        StaticLaboratoryTask config = taskConfig.get(spyInfo.getTaskId());

        if (config == null) {
            LogUtil.error("FightLabService.getSpyTime is null " + JSON.toJSONString(spyInfo));
        }

        int t = (int) (System.currentTimeMillis() / 1000) - spyInfo.getTime();

        if (t > config.getFinishTime()) {
            return 0;
        } else {
            return config.getFinishTime() - t;
        }

    }

    /**
     * 刷新任务状态
     *
     * @param player
     */
    private void refreshTaskState(Player player) {
        Map<Integer, SpyInfoData> spyMap = player.labInfo.getSpyMap();
        for (SpyInfoData s : spyMap.values()) {
            if (s.getState() == 3) {
                int spyTime = getSpyTime(s);
                if (spyTime == 0) {
                    s.setState(4);
                }
            }
        }
    }

    public void getSpyTaskAllReward(ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        refreshTaskState(player);
        Map<Integer, SpyInfoData> spyMap = player.labInfo.getSpyMap();
        GetAllSpyTaskRewardRs.Builder builder = GetAllSpyTaskRewardRs.newBuilder();
        int i = 0;
        try {
            for (SpyInfoData spyInfo : spyMap.values()) {
                int awardLevel = 0;
                if (spyInfo.getState() != 4) {
                    continue;
                }
                i++;
                SpyTaskReward.Builder taskReward = SpyTaskReward.newBuilder();
                taskReward.setAreaId(spyInfo.getAreaId());
                taskReward.setAwardLevel(awardLevel);
                Map<Integer, StaticLaboratoryTask> taskConfigMap = staticDataMgr.getTaskConfig();
                StaticLaboratoryTask taskConfig = taskConfigMap.get(spyInfo.getTaskId());
                Map<Integer, StaticLaboratorySpy> spyConfigMap = staticDataMgr.getSpyConfig();
                StaticLaboratorySpy spyConfig = spyConfigMap.get(spyInfo.getSpyId());

                //固定产出
                List<List<Integer>> mustProduce = taskConfig.getMustProduce();
                List<List<Integer>> mustProduceReward = new ArrayList<>();
                for (List<Integer> items : mustProduce) {
                    List<Integer> item = new ArrayList<>();
                    item.add(items.get(0));
                    item.add(items.get(1));
                    int count = (int) Math.ceil(((int) items.get(2) * (1.0f + (spyConfig.getSpyAbility() / 100.0f))));
                    item.add(count);
                    mustProduceReward.add(item);
                    CommonPb.Award awardPb = PbHelper.createAwardPb(item.get(0), item.get(1), item.get(2));
                    taskReward.addAward(awardPb);
                }
                addItem(player, AwardFrom.LAB_FIGHT_SPY_TASK_REWARD, mustProduceReward);

                //随机产出
                List<List<Integer>> couldProduce = taskConfig.getCouldProduce();
                Map<List<Integer>, Float> rewMap = new HashMap<>();
                for (List<Integer> items : couldProduce) {
                    float bl = items.get(3) * (1.0f + (spyConfig.getExploreAbility() / 100.0f));
                    rewMap.put(items, bl);
                }
                List<Integer> randomItem = LotteryUtil.getRandomItem(rewMap);

                if (randomItem != null) {
                    awardLevel = 1;
                    taskReward.setAwardLevel(awardLevel);
                    List<Integer> item = new ArrayList<>();
                    item.add(randomItem.get(0));
                    item.add(randomItem.get(1));
                    item.add(randomItem.get(2));

                    List<List<Integer>> couldProduceItem = new ArrayList<>();
                    couldProduceItem.add(item);
                    addItem(player, AwardFrom.LAB_FIGHT_SPY_TASK_REWARD_LOTTERY, couldProduceItem);

                    CommonPb.Award awardPb = PbHelper.createAwardPb(item.get(0), item.get(1), item.get(2));
                    taskReward.addAward(awardPb);
                }

                builder.addTaskAward(taskReward);

                spyInfo.setState(2);
                spyInfo.setTime(0);
                spyInfo.setSpyId(0);
                spyInfo.setTaskId(refreshTask(spyInfo.getTaskId(), spyInfo.getAreaId()));
            }
        } catch (Exception e) {
            e.printStackTrace();
            LogUtil.error("一键领取作战实验室奖励报错 | nick : " + player.lord.getNick(), e);
        }
        if (i == 0) {
            handler.sendErrorMsgToPlayer(GameError.ACT_AWARD_COND_LIMIT);
            return;
        }
        handler.sendMsgToPlayer(GetAllSpyTaskRewardRs.ext, builder.build());
    }

    /**
     * 作战实验室 间谍任务领取奖励
     *
     * @param rq
     * @param handler
     */
    public void getSpyTaskReward(GamePb6.GctFightLabSpyTaskRewardRq rq, ClientHandler handler) {
        int areaId = rq.getAreaId();
        Player player = playerDataManager.getPlayer(handler.getRoleId());

        refreshTaskState(player);

        Map<Integer, SpyInfoData> spyMap = player.labInfo.getSpyMap();
        SpyInfoData spyInfo = spyMap.get(areaId);

        if (spyInfo.getState() != 4) {
            return;
        }

        Map<Integer, StaticLaboratoryTask> taskConfigMap = staticDataMgr.getTaskConfig();
        StaticLaboratoryTask config = taskConfigMap.get(spyInfo.getTaskId());

        Map<Integer, StaticLaboratorySpy> spyConfigMap = staticDataMgr.getSpyConfig();
        StaticLaboratorySpy spyConfig = spyConfigMap.get(spyInfo.getSpyId());

        spyInfo.setState(2);
        spyInfo.setTime(0);
        spyInfo.setSpyId(0);
        spyInfo.setTaskId(refreshTask(spyInfo.getTaskId(), spyInfo.getAreaId()));

        GamePb6.GctFightLabSpyTaskRewardRs.Builder builder = GamePb6.GctFightLabSpyTaskRewardRs.newBuilder();

        int awardLevel = 0;

        //固定产出
        List<List<Integer>> mustProduce = config.getMustProduce();
        List<List<Integer>> mustProduceReward = new ArrayList<>();

        for (List<Integer> items : mustProduce) {
            List<Integer> item = new ArrayList<>();
            item.add(items.get(0));
            item.add(items.get(1));
            int count = (int) Math.ceil(((int) items.get(2) * (1.0f + (spyConfig.getSpyAbility() / 100.0f))));
            item.add(count);

            mustProduceReward.add(item);

            CommonPb.Award awardPb = PbHelper.createAwardPb(item.get(0), item.get(1), item.get(2));
            builder.addAward(awardPb);
        }

        addItem(player, AwardFrom.LAB_FIGHT_SPY_TASK_REWARD, mustProduceReward);

        //随机产出
        List<List<Integer>> couldProduce = config.getCouldProduce();
        Map<List<Integer>, Float> rewMap = new HashMap<>();
        for (List<Integer> items : couldProduce) {
            float bl = items.get(3) * (1.0f + (spyConfig.getExploreAbility() / 100.0f));
            rewMap.put(items, bl);
        }
        List<Integer> randomItem = LotteryUtil.getRandomItem(rewMap);

        if (randomItem != null) {

            awardLevel = 1;
            List<Integer> item = new ArrayList<>();
            item.add(randomItem.get(0));
            item.add(randomItem.get(1));
            item.add(randomItem.get(2));

            List<List<Integer>> couldProduceItem = new ArrayList<>();
            couldProduceItem.add(item);
            addItem(player, AwardFrom.LAB_FIGHT_SPY_TASK_REWARD_LOTTERY, couldProduceItem);

            CommonPb.Award awardPb = PbHelper.createAwardPb(item.get(0), item.get(1), item.get(2));
            builder.addAward(awardPb);
        }

        builder.setAwardLevel(awardLevel);
        handler.sendMsgToPlayer(GamePb6.GctFightLabSpyTaskRewardRs.ext, builder.build());

    }

    /**
     * 每晚十二点定时刷新任务
     */
    public void spyTaskTimerLogic() {

//		Calendar calendar = java.util.Calendar.getInstance();
//		int hour = calendar.get(Calendar.HOUR_OF_DAY);
//		int minute = calendar.get(Calendar.MINUTE);
//		int second = calendar.get(Calendar.SECOND);
//
//		if (hour == 23 && minute == 59 && second == 59) {
        Iterator<Player> iterator = playerDataManager.getPlayers().values().iterator();

        while (iterator.hasNext()) {
            Player player = iterator.next();

            try {
                refreshSpyTaskTimerLogic(player);
            } catch (Exception e) {
                LogUtil.error(" 作战研究院 间谍任务刷新, lordId:" + player.lord.getLordId(), e);
            }
        }
//		}

    }

    /**
     * 间谍任务刷新
     *
     * @param player
     */
    private void refreshSpyTaskTimerLogic(Player player) {

        Map<Integer, SpyInfoData> spyMap = player.labInfo.getSpyMap();
        if (!spyMap.isEmpty()) {
            for (SpyInfoData s : spyMap.values()) {
                if (s.getState() == 2) {
                    s.setTaskId(refreshTask(s.getTaskId(), s.getAreaId()));
                }
            }
        }
    }

    /**
     * gm把作战实验都设置成满级
     *
     * @param player
     */
    public void gmSetFightLabGraduateLevel(Player player) {

        List<StaticLaboratoryMilitary> configsss = staticDataMgr.getGraduateConfig();
        for (StaticLaboratoryMilitary c : configsss) {
            if (!player.labInfo.getGraduateInfo().containsKey(c.getType())) {
                player.labInfo.getGraduateInfo().put(c.getType(), new HashMap<Integer, Integer>());
            }
            if (!player.labInfo.getGraduateInfo().get(c.getType()).containsKey(c.getSkillId())) {
                player.labInfo.getGraduateInfo().get(c.getType()).put(c.getSkillId(), 0);
            }

            player.labInfo.getGraduateInfo().get(c.getType()).put(c.getSkillId(), c.getLv());

        }
    }

}
