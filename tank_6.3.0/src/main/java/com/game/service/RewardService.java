package com.game.service;

import com.game.actor.log.LogEventService;
import com.game.actor.role.PlayerEventService;
import com.game.constant.*;
import com.game.dataMgr.*;
import com.game.domain.*;
import com.game.domain.p.*;
import com.game.domain.p.lordequip.LordEquip;
import com.game.domain.s.*;
import com.game.manager.*;
import com.game.pb.BasePb;
import com.game.pb.CommonPb;
import com.game.pb.GamePb3;
import com.game.server.GameServer;
import com.game.util.LogLordHelper;
import com.game.util.LogUtil;
import com.game.util.PbHelper;
import com.game.util.TimeHelper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * @author Tandonghai
 * @date 2018-01-16 16:04
 */
@Service
public class RewardService {
    @Autowired
    private LogEventService logEventService;
    @Autowired
    private StaticActivityDataMgr staticActivityDataMgr;
    @Autowired
    private StaticFunctionPlanDataMgr staticFunctionPlanDataMgr;
    @Autowired
    private ActivityDataManager activityDataManager;
    @Autowired
    private PlayerDataManager playerDataManager;
    @Autowired
    private StaticLordDataMgr staticLordDataMgr;
    @Autowired
    private SecretWeaponService secretWeaponService;
    @Autowired
    private ArenaDataManager arenaDataManager;
    @Autowired
    private ChatService chatService;
    @Autowired
    private PartyDataManager partyDataManager;
    @Autowired
    private PlayerEventService playerEventService;
    @Autowired
    private StaticTankDataMgr staticTankDataMgr;
    @Autowired
    private StaticStaffingDataMgr staticStaffingDataMgr;
    @Autowired
    private RankDataManager rankDataManager;
    @Autowired
    private StaffingDataManager staffingDataManager;
    @Autowired
    private StaticAttackEffectDataMgr staticAttackEffectDataMgr;
    @Autowired
    private StaticHeroDataMgr staticHeroDataMgr;
    @Autowired
    private TacticsService tacticsService;
    @Autowired
    private ActivityKingService activityKingService;
    @Autowired
    private StaticEnergyStoneDataMgr staticEnergyStoneDataMgr;

    /**
     * 增加玩家活动道具
     *
     * @param player
     * @param propId
     * @param count
     * @param from   void
     * @throws @Title: addActivityProp
     * @Description: 增加玩家活动道具
     */
    public void addActivityProp(Player player, int propId, int count, AwardFrom from) {
        StaticActivityProp actProp = staticActivityDataMgr.getActivityPropById(propId);
        if (actProp == null) {
            return;
        }
        int activityId = actProp.getActivityId();
        Activity activity = activityDataManager.getActivityInfo(player, activityId);
        if (activity == null) {
            return;
        }
        Map<Integer, Integer> map = activity.getPropMap();
        if (map == null) {
            map = new HashMap<>();
        }
        if (map.containsKey(propId)) {
            map.put(propId, map.get(propId) + count);
        } else {
            map.put(propId, count);
        }
        LogLordHelper.activityProp(from, activityId, player.account, player.lord, propId, map.get(propId), count);
    }

    /**
     * 扣除玩家活动道具
     *
     * @param player
     * @param count
     * @param from
     * @return
     */
    public int subActivityProp(Player player, int propId, int count, AwardFrom from) {
        StaticActivityProp actProp = staticActivityDataMgr.getActivityPropById(propId);
        if (actProp == null) {
            return 0;
        }
        Activity activity = activityDataManager.getActivityInfo(player, actProp.getActivityId());
        if (activity == null) {
            return 0;
        }
        Map<Integer, Integer> map = activity.getPropMap();
        int hasNum = map.get(propId) - count;
        map.put(propId, hasNum);
        LogLordHelper.activityProp(from, activity.getActivityId(), player.account, player.lord, propId, map.get(propId), -count);
        return hasNum;
    }

    /**
     * Method: subGold
     *
     * @Description: 扣除玩家金币，不写数据库 @param lord @param sub @param type @return @return boolean @throws
     */
    public boolean subGold(Player player, int sub, AwardFrom from) {
        if (sub <= 0) {
            return false;
        }
        Lord lord = player.lord;
        lord.setGold(lord.getGold() - sub);
        lord.setGoldCost(lord.getGoldCost() + sub);
        playerDataManager.updTask(lord.getLordId(), TaskType.COND_COST_GOLD, 1);
        playerDataManager.updTask(lord.getLordId(), TaskType.COND_COST_GOLD2, sub);
        activityDataManager.ActCostGold(lord, sub, ActivityConst.ACT_COST_GOLD);
        activityDataManager.ActCostGold(lord, sub, ActivityConst.ACT_COST_GOLD_MERGE);
        activityDataManager.actConsumeDail(lord, sub);

        LogLordHelper.gold(from, player.account, lord, -sub, 0);
        return true;
    }

    /**
     * 跨服活动中扣除金币
     *
     * @param player
     * @param sub
     * @param from
     * @return boolean
     */
    public boolean subGoldCross(Player player, int sub, AwardFrom from) {
        if (sub < 0) {
            return false;
        }
        Lord lord = player.lord;
        lord.setGold(lord.getGold() - sub);
        lord.setGoldCost(lord.getGoldCost() + sub);
        playerDataManager.updTask(lord.getLordId(), TaskType.COND_COST_GOLD, 1);
        activityDataManager.ActCostGold(lord, sub, ActivityConst.ACT_COST_GOLD);
        activityDataManager.ActCostGold(lord, sub, ActivityConst.ACT_COST_GOLD_MERGE);
        activityDataManager.actConsumeDail(lord, sub);

        LogLordHelper.gold(from, player.account, lord, -sub, 0);
        return true;
    }

    /**
     * @param lord
     * @param sub
     * @return boolean
     * @throws @Title: checkGoldIsEnought
     * @Description: 判断玩家金币是否足够
     */
    public boolean checkGoldIsEnought(Lord lord, long sub) {
        return sub >= 0 && lord.getGold() >= sub;
    }

    /**
     * Method: addGold
     *
     * @Description: 非充值增加玩家金币 @param lord @param add @param type @return @return boolean @throws
     */
    public boolean addGold(Player player, int add, AwardFrom from) {
        if (add <= 0) {
            return false;
        }
        Lord lord = player.lord;
        lord.setGold(lord.getGold() + add);
        lord.setGoldGive(lord.getGoldGive() + add);
        LogLordHelper.gold(from, player.account, lord, add, 0);
        return true;
    }

    /**
     * Method: addHunagbao
     *
     * @Description: 增加荒宝碎片 @param lord @param add @return void @throws
     */
    public void addHunagbao(Player player, int add, AwardFrom from) {
        Lord lord = player.lord;
        lord.setHuangbao(lord.getHuangbao() + add);
        LogLordHelper.huangbao(from, player.account, lord, add, 0);
    }

    /**
     * Method: subHuangbao
     *
     * @Description: 扣除荒宝碎片 @param lord @param sub @return void @throws
     */
    public void subHuangbao(Player player, int sub, AwardFrom from) {
        Lord lord = player.lord;
        lord.setHuangbao(lord.getHuangbao() - sub);
        LogLordHelper.huangbao(from, player.account, lord, -sub, 0);
    }

    /**
     * Method: addBounty
     *
     * @Description: 增加赏金碎片 @param player @param add @return void @throws
     */
    public void addBounty(Player player, int add, AwardFrom from) {
        TeamInstanceInfo instanceInfo = player.getTeamInstanceInfo();
        instanceInfo.setBounty(instanceInfo.getBounty() + add);
        LogLordHelper.bounty(from, player.account, player.lord, add, 0);
    }

    /**
     * Method: subBounty
     *
     * @Description: 扣除赏金碎片 @param player @param sub @return void @throws
     */
    public void subBounty(Player player, int sub, AwardFrom from) {
        TeamInstanceInfo instanceInfo = player.getTeamInstanceInfo();
        instanceInfo.setBounty(instanceInfo.getBounty() - sub);
        LogLordHelper.bounty(from, player.account, player.lord, -sub, 0);
    }

    /**
     * 给玩家增加资源
     *
     * @param player
     * @param type
     * @param add
     * @param from   void
     */
    public void addResource(Player player, int type, long add, AwardFrom from) {
        switch (type) {
            case 1:
                modifyIron(player, add, from);
                break;
            case 2:
                modifyOil(player, add, from);
                break;
            case 3:
                modifyCopper(player, add, from);
                break;
            case 4:
                modifySilicon(player, add, from);
                break;
            case 5:
                modifyStone(player, add, from);
                break;
            default:
                break;
        }
    }

    /**
     * Method: modifyIron
     *
     * @Description: 修改铁资源数量 @param resource @param add @param commit @return void @throws
     */
    public void modifyIron(Player player, long add, AwardFrom from) {
        Resource resource = player.resource;
        if (add > 0) {
            resource.settIron(resource.gettIron() + add);
        }
        resource.setIron(resource.getIron() + add);
        if (add != 0) {
            LogLordHelper.resource(from, player.account, player.lord, player.resource, 1, add);
        }
    }

    /**
     * Method: modifyOil
     *
     * @Description: 修改石油资源数量 @param resource @param add @param commit @return void @throws
     */
    public void modifyOil(Player player, long add, AwardFrom from) {
        Resource resource = player.resource;
        if (add > 0) {
            resource.settOil(resource.gettOil() + add);
        }
        resource.setOil(resource.getOil() + add);
        if (add != 0) {
            LogLordHelper.resource(from, player.account, player.lord, player.resource, 2, add);
        }
    }

    /**
     * Method: modifyCopper
     *
     * @Description: 修改铜资源数量 @param resource @param add @param commit @return void @throws
     */
    public void modifyCopper(Player player, long add, AwardFrom from) {
        Resource resource = player.resource;
        if (add > 0) {
            resource.settCopper(resource.gettCopper() + add);
        }
        resource.setCopper(resource.getCopper() + add);
        if (add != 0) {
            LogLordHelper.resource(from, player.account, player.lord, player.resource, 3, add);
        }
    }

    /**
     * Method: modifySilicon
     *
     * @Description: 修改硅资源数量 @param resource @param add @param commit @return void @throws
     */
    public void modifySilicon(Player player, long add, AwardFrom from) {
        Resource resource = player.resource;
        if (add > 0) {
            resource.settSilicon(resource.gettSilicon() + add);
        }
        resource.setSilicon(resource.getSilicon() + add);
        if (add != 0) {
            LogLordHelper.resource(from, player.account, player.lord, player.resource, 4, add);
        }
    }

    /**
     * Method: modifyStone
     *
     * @Description: 修改宝石数量 @param resource @param add @param commit @return void @throws
     */
    public CommonPb.Atom2 modifyStone(Player player, long add, AwardFrom from) {
        CommonPb.Atom2.Builder b = CommonPb.Atom2.newBuilder();
        b.setKind(AwardType.RESOURCE).setId(5);
        Resource resource = player.resource;
        if (add > 0) {
            resource.settStone(resource.gettStone() + add);
        }
        resource.setStone(resource.getStone() + add);
        if (add != 0) {
            LogLordHelper.resource(from, player.account, player.lord, player.resource, 5, add);
        }
        b.setCount(resource.getStone());
        return b.build();
    }

    /**
     * 判断资源够不够 Method: checkResourceIsEnought
     *
     * @return @return boolean @throws
     */
    public boolean checkResourceIsEnougth(Resource resource, int type, long num) {
        boolean ret = false;
        switch (type) {
            case 1:
                ret = resource.getIron() >= num;
                break;
            case 2:
                ret = resource.getOil() >= num;
                break;
            case 3:
                ret = resource.getCopper() >= num;
                break;
            case 4:
                ret = resource.getSilicon() >= num;
                break;
            case 5:
                ret = resource.getStone() >= num;
                break;
            default:
                ret = false;
                break;
        }
        return ret;
    }

    /**
     * 判断军工材料够不够 Method: checkMilitaryMaterialIsEnought
     *
     * @param player @param type @param count @return @return boolean @throws
     */
    public boolean checkMilitaryMaterialIsEnougth(Player player, int id, long count) {
        MilitaryMaterial m = player.militaryMaterials.get(id);
        return !(m == null || m.getCount() < count);
    }

    /**
     * 检测配件材料够不够
     *
     * @param player
     * @param id
     * @param count
     * @return
     */
    public boolean checkPartMaterialIsEnougth(Player player, int id, long count) {
        Lord lord = player.lord;
        boolean ret = false;
        switch (id) {
            case 1: // 零件
                ret = lord.getFitting() >= count;
                break;
            case 2: // 记忆金属
                ret = lord.getMetal() >= count;
                break;
            case 3: // 设计蓝图
                ret = lord.getPlan() >= count;
                break;
            case 4: // 金属矿物
                ret = lord.getMineral() >= count;
                break;
            case 5: // 改造工具
                ret = lord.getTool() >= count;
                break;
            case 6: // 改造图纸
                ret = lord.getDraw() >= count;
                break;
            case 7: // 坦克驱动
                ret = lord.getTankDrive() >= count;
                break;
            case 8: // 战车驱动
                ret = lord.getChariotDrive() >= count;
                break;
            case 9: // 火炮驱动
                ret = lord.getArtilleryDrive() >= count;
                break;
            case 10: // 火箭驱动
                ret = lord.getRocketDrive() >= count;
                break;
            default:
                Integer curCount = player.partMatrial.get(id);
                curCount = (curCount == null ? 0 : curCount);
                ret = curCount >= count;
                break;
        }
        return ret;
    }

    /**
     * @param player
     * @param type   物品类型
     * @param id
     * @param count
     * @return boolean
     * @throws @Title: checkPropIsEnougth
     * @Description: 判断物品是否够
     */
    public boolean checkPropIsEnougth(Player player, int type, int id, long count) {
        boolean ret = false;
        switch (type) {
            case AwardType.RESOURCE:
                ret = checkResourceIsEnougth(player.resource, id, count);
                break;
            case AwardType.MILITARY_MATERIAL:
                ret = checkMilitaryMaterialIsEnougth(player, id, count);
                break;
            case AwardType.TANK:
                ret = checkTankIsEnougth(player, id, count);
                break;
            case AwardType.GOLD:
                ret = checkGoldIsEnought(player.lord, count);
                break;
            case AwardType.PROP:
                ret = checkPropIsEnougth(player, id, count);
                break;
            case AwardType.CHIP:
                ret = checkChipIsEnougth(player, id, count);
                break;
            case AwardType.PART_MATERIAL:
                ret = checkPartMaterialIsEnougth(player, id, count);
                break;
            case AwardType.ACTIVITY_PROP:
                ret = checkActivityPropIsEnougth(player, id, count);
                break;
            case AwardType.MEDAL_MATERIAL:
                ret = checkMedalMaterialIsEnougth(player.lord, id, count);
                break;
            case AwardType.MEDAL_CHIP:
                ret = checkMedalChipIsEnougth(player, id, count);
                break;
            case AwardType.LORD_EQUIP_METERIAL:
                ret = checkLordEqupMaterialEnougth(player, id, count);
                break;
            case AwardType.MILITARY_EXPLOIT:
                ret = checkMilitaryExploitEnougth(player, count);
                break;
            case AwardType.LAB_FIGHT:
                ret = checkFightLabEnougth(player, id, (int) count);
                break;
            case AwardType.TACTICS_ITEM:
                ret = checkTacticsItem(player, id, (int) count);
                break;
            case AwardType.TACTICS_SLICE:
                ret = checkTacticsSlice(player, id, (int) count);
                break;
            case AwardType.ENERGY_STONE:
                ret = checkEnergy(player, id, (int) count);
                break;
            default:
                ret = false;
                break;
        }
        return ret;
    }

    /**
     * Method: checkTankIsEnougth 坦克是否足够
     *
     * @param player @param id @param count @return @return boolean @throws
     */
    public boolean checkTankIsEnougth(Player player, int id, long count) {
        Tank tank = player.tanks.get(id);
        return !(tank == null || tank.getCount() < count);
    }

    /**
     * @param player
     * @param id
     * @param count
     * @return boolean
     * @throws @Title: checkPropIsEnougth
     * @Description: 判断玩家物品是否足够 这里指的是对应s_prop表的道具
     */
    public boolean checkPropIsEnougth(Player player, int id, long count) {
        Prop prop = player.props.get(id);
        return !(prop == null || prop.getCount() < count);
    }

    /**
     * 配件碎片是否足够
     *
     * @param player
     * @param id
     * @param count
     * @return boolean
     */
    public boolean checkChipIsEnougth(Player player, int id, long count) {
        Chip chip = player.chips.get(id);
        return !(chip == null || chip.getCount() < count);
    }

    /**
     * @param player
     * @param id
     * @param count
     * @return boolean
     * @throws @Title: checkActivityPropIsEnougth
     * @Description: 判断玩家活动道具是否足够
     */
    public boolean checkActivityPropIsEnougth(Player player, int id, long count) {
        StaticActivityProp prop = staticActivityDataMgr.getActivityPropById(id);
        if (prop == null) {
            return false;
        }
        Activity activity = player.activitys.get(prop.getActivityId());
        if (activity == null) {
            return false;
        }
        Map<Integer, Integer> porpMap = activity.getPropMap();
        if (porpMap == null) {
            return false;
        } else {
            Integer num = porpMap.get(id);
            return num != null && num >= count;
        }
    }

    /**
     * 勋章材料是否足够
     *
     * @param lord
     * @param id
     * @param count
     * @return boolean
     */
    public boolean checkMedalMaterialIsEnougth(Lord lord, int id, long count) {
        boolean ret = false;
        switch (id) {
            case 1: // 洗涤剂
                ret = lord.getDetergent() >= count;
                break;
            case 2: // 研磨石
                ret = lord.getGrindstone() >= count;
                break;
            case 3: // 抛光材料
                ret = lord.getPolishingMtr() >= count;
                break;
            case 4: // 保养油
                ret = lord.getMaintainOil() >= count;
                break;
            case 5: // 打磨石
                ret = lord.getGrindTool() >= count;
                break;
            case 6: // 精密仪器
                ret = lord.getPrecisionInstrument() >= count;
                break;
            case 7: // 神秘石
                ret = lord.getMysteryStone() >= count;
                break;
            case 8: //刚玉磨料
                ret = lord.getCorundumMatrial() >= count;
                break;
            case 9: //惰性气体
                ret = lord.getInertGas() >= count;
                break;
            default:
                ret = false;
                break;
        }
        return ret;
    }

    /**
     * 配件碎片是否足够
     *
     * @param player
     * @param id
     * @param count
     * @return boolean
     */
    public boolean checkMedalChipIsEnougth(Player player, int id, long count) {
        MedalChip chip = player.medalChips.get(id);
        return !(chip == null || chip.getCount() < count);
    }

    /**
     * 军备材料(包含图纸和材料)是否足够
     *
     * @param player
     * @param id
     * @param count
     * @return boolean
     */
    public boolean checkLordEqupMaterialEnougth(Player player, int id, long count) {
        Prop prop = player.leqInfo.getLeqMat().get(id);
        return prop != null && prop.getCount() >= count;
    }

    /**
     * 军工材料是否足够
     *
     * @param player
     * @param count
     * @return boolean
     */
    public boolean checkMilitaryExploitEnougth(Player player, long count) {
        return player.lord.getMilitaryExploit() >= count;
    }

    public boolean checkFightLabEnougth(Player player, int itemId, int count) {
        return player.labInfo.checkItem(itemId, count);
    }

    /**
     * @param player
     * @param propId
     * @param count
     * @param from
     * @return Prop
     * @throws @Title: addProp
     * @Description: 增加玩家道具 这里指的是对应s_prop表的道具
     */
    public Prop addProp(Player player, int propId, int count, AwardFrom from) {
        Prop prop = player.props.get(propId);
        if (prop != null) {
            prop.setCount(count + prop.getCount());
        } else {
            prop = new Prop(propId, count);
            player.props.put(propId, prop);
        }
        LogLordHelper.prop(from, player.account, player.lord, 0, prop.getPropId(), prop.getCount(), count);
        return prop;
    }

    /**
     * Method: subProp
     *
     * @Description: 扣除道具 @param prop @param count @return void @throws
     */
    public void subProp(Player player, Prop prop, int count, AwardFrom from) {
        prop.setCount(prop.getCount() - count);
        LogLordHelper.prop(from, player.account, player.lord, 0, prop.getPropId(), prop.getCount(), -count);
    }

    /**
     * 消耗配件材料
     *
     * @param player
     * @param id
     * @param count
     * @param from
     * @return
     */
    public int subPartMaterial(Player player, int id, int count, AwardFrom from) {
        int num = 0;
        switch (id) {
            case 1:
                num = modifyFitting(player.lord, -count);
                break;
            case 2:
                num = modifyMetal(player.lord, -count);
                break;
            case 3:
                num = modifyPlan(player.lord, -count);
                break;
            case 4:
                num = modifyMineral(player.lord, -count);
                break;
            case 5:
                num = modifyTool(player.lord, -count);
                break;
            case 6:
                num = modifyDraw(player.lord, -count);
                break;
            case 7:
                num = modifyTankDrive(player.lord, -count);
                break;
            case 8:
                num = modifyChariotDrive(player.lord, -count);
                break;
            case 9:
                num = modifyArtilleryDrive(player.lord, -count);
                break;
            case 10:
                num = modifyRocketDrive(player.lord, -count);
                break;
            default:
                num = modifyPartMatrial(player, id, -count);
                break;
        }
        LogLordHelper.partMaterial(from, player.account, player, id, -count, num);
        return num;
    }

    /**
     * Method: modifyFitting
     *
     * @Description: 修改零件数量 @param lord @param add @param commit @return void @throws
     */
    public int modifyFitting(Lord lord, int add) {
        lord.setFitting(lord.getFitting() + add);
        return lord.getFitting();
    }

    /**
     * Method: modifyMetal
     *
     * @Description: 修改记忆金属 @param lord @param add @param commit @return void @throws
     */
    public int modifyMetal(Lord lord, int add) {
        lord.setMetal(lord.getMetal() + add);
        return lord.getMetal();
    }

    /**
     * Method: modifyPlan
     *
     * @Description: 修改设计蓝图数量 @param lord @param add @param commit @return void @throws
     */
    public int modifyPlan(Lord lord, int add) {
        lord.setPlan(lord.getPlan() + add);
        return lord.getPlan();
    }

    /**
     * Method: modifyMineral
     *
     * @Description: 修改金属矿物数量 @param lord @param add @param commit @return void @throws
     */
    public int modifyMineral(Lord lord, int add) {
        lord.setMineral(lord.getMineral() + add);
        return lord.getMineral();
    }

    /**
     * Method: modifyTool
     *
     * @Description: 修改改造工具数量 @param lord @param add @param commit @return void @throws
     */
    public int modifyTool(Lord lord, int add) {
        lord.setTool(lord.getTool() + add);
        return lord.getTool();
    }

    /**
     * Method: modifyDraw
     *
     * @Description: 修改改造图纸数量 @param lord @param add @param commit @return void @throws
     */
    public int modifyDraw(Lord lord, int add) {
        lord.setDraw(lord.getDraw() + add);
        return lord.getDraw();
    }

    /**
     * 修改坦克驱动数量
     *
     * @param lord
     * @param add
     * @return
     */
    public int modifyTankDrive(Lord lord, int add) {
        lord.setTankDrive(lord.getTankDrive() + add);
        return lord.getTankDrive();
    }

    /**
     * 修改战车驱动数量
     *
     * @param lord
     * @param add
     * @return
     */
    public int modifyChariotDrive(Lord lord, int add) {
        lord.setChariotDrive(lord.getChariotDrive() + add);
        return lord.getChariotDrive();
    }

    /**
     * 修改火炮驱动数量
     *
     * @param lord
     * @param add
     * @return
     */
    public int modifyArtilleryDrive(Lord lord, int add) {
        lord.setArtilleryDrive(lord.getArtilleryDrive() + add);
        return lord.getArtilleryDrive();
    }

    /**
     * 修改火箭驱动数量
     *
     * @param lord
     * @param add
     * @return
     */
    public int modifyRocketDrive(Lord lord, int add) {
        lord.setRocketDrive(lord.getRocketDrive() + add);
        return lord.getRocketDrive();
    }

    public int modifyPartMatrial(Player player, int id, int add) {
        Integer count = player.partMatrial.get(id);
        if (count == null) {
            count = 0;
        }
        count += add;
        player.partMatrial.put(id, count);
        return count;
    }

    /**
     * Method: addPartMaterial
     *
     * @Description: 增加配件材料 @param player @param id @param count @return void @throws
     */
    public CommonPb.Atom2 addPartMaterial(Player player, int id, int count, AwardFrom from) {
        CommonPb.Atom2.Builder b = CommonPb.Atom2.newBuilder();
        b.setKind(AwardType.PART_MATERIAL).setId(id);
        switch (id) {
            case 1:
                b.setCount(modifyFitting(player.lord, count));
                break;
            case 2:
                b.setCount(modifyMetal(player.lord, count));
                break;
            case 3:
                b.setCount(modifyPlan(player.lord, count));
                break;
            case 4:
                b.setCount(modifyMineral(player.lord, count));
                break;
            case 5:
                b.setCount(modifyTool(player.lord, count));
                break;
            case 6:
                b.setCount(modifyDraw(player.lord, count));
                break;
            case 7:
                b.setCount(modifyTankDrive(player.lord, count));
                break;
            case 8:
                b.setCount(modifyChariotDrive(player.lord, count));
                break;
            case 9:
                b.setCount(modifyArtilleryDrive(player.lord, count));
                break;
            case 10:
                b.setCount(modifyRocketDrive(player.lord, count));
                break;
            default:
                b.setCount(modifyPartMatrial(player, id, count));
                break;
        }
        LogLordHelper.partMaterial(from, player.account, player, id, count, (int) b.getCount());
        return b.build();
    }

    /**
     * 增加勋章材料
     *
     * @param player
     * @param id
     * @param count
     * @param from
     * @return
     */
    public CommonPb.Atom2 addMedalMaterial(Player player, int id, int count, AwardFrom from) {
        CommonPb.Atom2.Builder b = CommonPb.Atom2.newBuilder();
        b.setKind(AwardType.MEDAL_MATERIAL).setId(id);
        switch (id) {
            case 1:
                b.setCount(modifyDetergent(player.lord, count));
                break;
            case 2:
                b.setCount(modifyGrindstone(player.lord, count));
                break;
            case 3:
                b.setCount(modifyPolishingMtr(player.lord, count));
                break;
            case 4:
                b.setCount(modifyMaintainOil(player.lord, count));
                break;
            case 5:
                b.setCount(modifyGrindTool(player.lord, count));
                break;
            case 6:
                b.setCount(modifyPrecisionInstrument(player.lord, count));
                break;
            case 7:
                b.setCount(modifyMysteryStone(player.lord, count));
                break;
            case 8:
                b.setCount(modifyCorundumMatrial(player.lord, count));
                break;
            case 9:
                b.setCount(modifyInertGas(player.lord, count));
                break;
            default:
                break;
        }
        LogLordHelper.medalMaterial(from, player.account, player.lord, 0, id, count);
        return b.build();
    }

    /**
     * 减少勋章材料
     *
     * @param player
     * @param id
     * @param count
     * @param from
     * @return
     */
    public int subMedalMaterial(Player player, int id, int count, AwardFrom from) {
        int num = 0;
        switch (id) {
            case 1:
                num = modifyDetergent(player.lord, -count);
                break;
            case 2:
                num = modifyGrindstone(player.lord, -count);
                break;
            case 3:
                num = modifyPolishingMtr(player.lord, -count);
                break;
            case 4:
                num = modifyMaintainOil(player.lord, -count);
                break;
            case 5:
                num = modifyGrindTool(player.lord, -count);
                break;
            case 6:
                num = modifyPrecisionInstrument(player.lord, -count);
                break;
            case 7:
                num = modifyMysteryStone(player.lord, -count);
                break;
            case 8:
                num = modifyCorundumMatrial(player.lord, -count);
                break;
            case 9:
                num = modifyInertGas(player.lord, -count);
                break;
            default:
                break;
        }
        LogLordHelper.medalMaterial(from, player.account, player.lord, 0, id, -count);
        return num;
    }

    /**
     * 洗涤剂
     */
    public int modifyDetergent(Lord lord, int add) {
        lord.setDetergent(lord.getDetergent() + add);
        return lord.getDetergent();
    }

    /**
     * 研磨石
     */
    public int modifyGrindstone(Lord lord, int add) {
        lord.setGrindstone(lord.getGrindstone() + add);
        return lord.getGrindstone();
    }

    /**
     * 抛光材料
     */
    public int modifyPolishingMtr(Lord lord, int add) {
        lord.setPolishingMtr(lord.getPolishingMtr() + add);
        return lord.getPolishingMtr();
    }

    /**
     * 保养油
     */
    public int modifyMaintainOil(Lord lord, int add) {
        lord.setMaintainOil(lord.getMaintainOil() + add);
        return lord.getMaintainOil();
    }

    /**
     * 打磨工具
     */
    public int modifyGrindTool(Lord lord, int add) {
        lord.setGrindTool(lord.getGrindTool() + add);
        return lord.getGrindTool();
    }

    /**
     * 精密仪器
     */
    public int modifyPrecisionInstrument(Lord lord, int add) {
        lord.setPrecisionInstrument(lord.getPrecisionInstrument() + add);
        return lord.getPrecisionInstrument();
    }

    /**
     * 神秘石
     */
    public int modifyMysteryStone(Lord lord, int add) {
        lord.setMysteryStone(lord.getMysteryStone() + add);
        return lord.getMysteryStone();
    }

    /**
     * 刚玉磨料
     */
    public int modifyCorundumMatrial(Lord lord, int add) {
        lord.setCorundumMatrial(lord.getCorundumMatrial() + add);
        return lord.getCorundumMatrial();
    }

    /**
     * 惰性气体
     */
    public int modifyInertGas(Lord lord, int add) {
        lord.setInertGas(lord.getInertGas() + add);
        return lord.getInertGas();
    }


    /**
     * Method: addAward
     *
     * @Description: 通用加属性、物品、数据 @param player @param type @param id @param count @param from @return void @throws
     */
    public int addAward(Player player, int type, int id, long count, AwardFrom from) {
        Account account = player.account;
        Lord lord = player.lord;
        switch (type) {
            case AwardType.EXP:
                addExp(player, count);
                break;
            case AwardType.PROS:
                addPros(player, (int) count);
                break;
            case AwardType.FAME:
                addFame(player, (int) count, from);
                break;
            case AwardType.HONOUR:
                break;
            case AwardType.PROP:
                addProp(player, id, (int) count, from);
                break;
            case AwardType.EQUIP:
                return addEquip(player, id, (int) count, 0, from).getKeyId();
            case AwardType.PART:
                return addPart(player, id, 0, 0, 0, from).getKeyId();
            case AwardType.CHIP:
                addChip(player, id, (int) count, from);
                break;
            case AwardType.PART_MATERIAL:
                addPartMaterial(player, id, (int) count, from);
                break;
            case AwardType.SCORE:
                addArenaScore(player, (int) count, from);
                break;
            case AwardType.CONTRIBUTION: {
                long lordId = player.lord.getLordId();
                Member member = partyDataManager.getMemberById(lordId);
                if (member != null && member.getPartyId() != 0) {
                    member.setDonate(member.getDonate() + (int) count);
                    member.setWeekAllDonate(member.getWeekAllDonate() + (int) count);
                    LogLordHelper.contribution(from, account, lord, member.getDonate(), member.getWeekAllDonate(), (int) count);
                }
                break;
            }
            case AwardType.HUANGBAO:
                addHunagbao(player, (int) count, from);
                break;
            case AwardType.TANK:
                addTank(player, id, (int) count, from);
                break;
            case AwardType.HERO:

                Hero hero = addHero(player, id, (int) count, from);
                if (hero == null) {
                    return id;
                }
                return hero.getKeyId();
            case AwardType.GOLD:
                addGold(player, (int) count, from);
                break;
            case AwardType.RESOURCE:
                addResource(player, id, count, from);
                break;
            case AwardType.PARTY_BUILD:
                long lordId = player.lord.getLordId();
                PartyData partyData = partyDataManager.getPartyByLordId(lordId);
                if (partyData != null) {
                    addPartyBuild(partyData, (int) count);
                }
                break;
            case AwardType.POWER:
                addPower(player.lord, (int) count);
                break;
            case AwardType.MILITARY_MATERIAL:
                addMilitaryMaterial(player, id, count, from);
                break;
            case AwardType.ENERGY_STONE:// 能晶
                addEnergyStone(player, id, (int) count, from);
                break;
            case AwardType.EXPLOIT:// 功勋值
                updateExploit(player, (int) count, from);
                break;
            case AwardType.STAFFING:// 编制经验
                addStaffingExp(player, (int) count);
                break;
            case AwardType.BUFF:// buff
                playerDataManager.addEffect(player, id, (int) count);
                break;
            case AwardType.ACTIVITY_PROP: // 活动虚拟道具
                addActivityProp(player, id, (int) count, from);
                break;
            case AwardType.MEDAL:
                return addMedal(player, id, 0, 0, 0, from).getKeyId();
            case AwardType.MEDAL_CHIP:
                addMedalChip(player, id, (int) count, from);
                break;
            case AwardType.MEDAL_MATERIAL:
                addMedalMaterial(player, id, (int) count, from);
                break;
            case AwardType.AWARK_HERO:
                return addAwakenHero(player, id, from).getKeyId();
            case AwardType.LORD_EQUIP:
                return addLordEquip(player, id, from).getKeyId();
            case AwardType.LORD_EQUIP_METERIAL:
                addLordEquipMaterial(player, id, (int) count, from);
                break;
            case AwardType.MILITARY_EXPLOIT:
                addMilitaryExploit(player, id, (int) count, from);
                break;
            case AwardType.ATTACK_EFFECT:
                addAttackEffect(player, id, from);
                break;
            case AwardType.LAB_FIGHT:
                addLabFightItem(player, id, (int) count, from);
                break;
            case AwardType.BOUNTY:
                addBounty(player, (int) count, from);
                break;
            case AwardType.TACTICS:
                return addTactics(player, id, (int) count, from).getKeyId();
            case AwardType.TACTICS_SLICE:
                addTacticsSlice(player, id, (int) count, from);
                break;
            case AwardType.TACTICS_ITEM:
                addTacticsItem(player, id, (int) count, from);
                break;
            default:
                break;
        }
        return 0;
    }

    /**
     * Method: addExp
     *
     * @Description: 增加经验 @param player @param add @return void @throws
     */
    public boolean addExp(Player player, long add) {
        if (player.effects.containsKey(EffectType.ADD_STAFFING_ADEXP1)) {
            add *= 1.004;
        }
        if (player.effects.containsKey(EffectType.ADD_STAFFING_ADEXP2)) {
            add *= 1.008;
        }
        if (player.effects.containsKey(EffectType.ADD_STAFFING_ADEXP3)) {
            add *= 1.012;
        }
        if (player.effects.containsKey(EffectType.ADD_STAFFING_ADEXP4)) {
            add *= 1.016;
        }
        if (player.effects.containsKey(EffectType.ADD_STAFFING_ADEXP5)) {
            add *= 1.02;
        }
        if (player.effects.containsKey(EffectType.ADD_BACK_EXP)) {
            add *= 1.02;
        }
        if (player.effects.containsKey(EffectType.LEVEL_EXP_UP)) {
            List<List<Float>> buff = Constant.LEVEL_EXP_BUFF;
            for (List<Float> level : buff) {
                if (player.lord.getLevel() <= level.get(1) && player.lord.getLevel() >= level.get(0)) {
                    add *= (1 + level.get(2));
                    break;
                }
            }
        }
        boolean b = staticLordDataMgr.addExp(player, add);
        if (b) {
            playerDataManager.updDay7ActSchedule(player, 16, player.lord.getLevel());
            playerDataManager.checkEquipExpOverflow(player);
            secretWeaponService.checkLevelUp(player);
            // 向Gdps 发送升级记录
            logEventService.sendRoleUp2Gdps(player);
        }
        return b;
    }

    /**
     * 增加繁荣度
     *
     * @param player
     * @param add    void
     */
    public void addPros(Player player, int add) {
        int oldPros = player.lord.getPros();
        int pros = oldPros + add;
        if (pros > player.lord.getProsMax()) {
            pros = player.lord.getProsMax();
        }

        player.lord.setPros(pros);

        // 增加繁荣度之后处理
        playerDataManager.afterAddPros(player, oldPros, pros);
        playerDataManager.outOfRuins(player);
    }

    /**
     * Method: addFame
     *
     * @Description: 加声望 @param lord @param add @return @return boolean @throws
     */
    public boolean addFame(Player player, int add, AwardFrom from) {
        Lord lord = player.lord;
        // 修改成读取表
        boolean up = staticLordDataMgr.addFame(lord, add);
        int fameLv = lord.getFameLv();
        if (up && fameLv >= 15) {
            chatService.sendWorldChat(chatService.createSysChat(SysChatId.FAME_UP, lord.getNick(), String.valueOf(fameLv)));
        }

        LogLordHelper.fame(from, player.account, lord, lord.getFameLv(), lord.getFame(), add);
        return up;
    }

    /**
     * 加装备
     *
     * @param player
     * @param equipId
     * @param lv
     * @param pos
     * @param from
     * @return
     */
    public Equip addEquip(Player player, int equipId, int lv, int pos, AwardFrom from) {
        int level = lv > 0 ? Math.min(lv, player.lord.getLevel()) : 1;
        Equip equip = new Equip(player.maxKey(), equipId, level, 0, pos);
        player.equips.get(pos).put(equip.getKeyId(), equip);
        LogLordHelper.equip(from, player.account, player.lord, equip.getKeyId(), equipId, lv, 0);
        return equip;
    }

    /**
     * 加配件
     *
     * @param player
     * @param partId
     * @param pos
     * @param strengthLv
     * @param refitLv
     * @param from
     * @return
     */
    public Part addPart(Player player, int partId, int pos, int strengthLv, int refitLv, AwardFrom from) {
        Part part = new Part(player.maxKey(), partId, strengthLv, refitLv, pos, false, 0, 0, new HashMap<Integer, Integer[]>(), true);
        player.parts.get(pos).put(part.getKeyId(), part);
        LogLordHelper.part(from, player.account, player.lord, part);
        return part;
    }

    /**
     * Method: addChip
     *
     * @Description: 加配件碎片 @param player @param chipId @param count @return @return Chip @throws
     */
    public Chip addChip(Player player, int chipId, int count, AwardFrom from) {
        Chip chip = player.chips.get(chipId);
        if (chip != null) {
            chip.setCount(count + chip.getCount());
        } else {
            chip = new Chip(chipId, count);
            player.chips.put(chipId, chip);
        }
        LogLordHelper.chip(from, player.account, player.lord, chip.getChipId(), chip.getCount(), count);
        return chip;
    }

    /**
     * Method: addArenaScore
     *
     * @Description: 加竞技场积分 @param player @param count @return void @throws
     */
    public void addArenaScore(Player player, int count, AwardFrom from) {
        Arena arena = arenaDataManager.getArena(player.roleId);
        if (arena != null) {
            arena.setScore(arena.getScore() + count);
            LogLordHelper.arena(from, player.account, player.lord, 0, arena.getScore(), count);
        }
    }

    /**
     * Method: addTank
     *
     * @Description: 增加坦克 @param player @param tankId @param count @return @return Tank @throws
     */
    public Tank addTank(Player player, int tankId, int count, AwardFrom from) {
        Tank tank = player.tanks.get(tankId);
        if (tank != null) {
            tank.setCount(count + tank.getCount());
        } else {
            tank = new Tank(tankId, count, 0);
            player.tanks.put(tankId, tank);
        }
        LogLordHelper.tank(from, player.account, player.lord, tankId, tank.getCount(), count, 0, 0);
        if (staticTankDataMgr.isGoldTank(tankId)) {// 活动金币坦克更新最大实力
            playerEventService.calcStrongestFormAndFight(player);
        } else {
            StaticTank staticTank = staticTankDataMgr.getStaticTank(tankId);
            if (staticTank != null && staticTank.getCanBuild() == 0) {
                int flv = Math.max(player.building.getFactory1(), player.building.getFactory2());
                if (flv >= staticTank.getFactoryLv() && player.lord.getLevel() >= staticTank.getLordLv()) {
                    playerEventService.calcStrongestFormAndFight(player);
                }
            }
        }
        return tank;
    }

    /**
     * Method: addHero
     *
     * @Description: 增加武将 @param player @param heroId @param count @return @return Hero @throws
     */
    public Hero addHero(Player player, int heroId, int count, AwardFrom from) {

        StaticHero staticHero = staticHeroDataMgr.getStaticHero(heroId);

        Hero hero = player.heros.get(heroId);
        if (hero != null) {

            if (player.herosExpiredTime.containsKey(heroId) && staticHero.getSkillId() == 22) {
                if (count < 0) {
                    hero.setCount(hero.getCount() + count);
                }

            } else {
                hero.setCount(hero.getCount() + count);
            }
            if (count < 0 && hero.getCount() <= 0) {
                player.heros.remove(heroId);
            }

        } else {

            if (player.herosExpiredTime.containsKey(heroId) && staticHero.getSkillId() == 22) {

                if (!AwardFrom.MAIL_ATTACH.equals(from) && !AwardFrom.CROSS_RANK_AWARD.equals(from)) {
                    hero = new Hero(heroId, heroId, count);
                    player.heros.put(hero.getHeroId(), hero);
                }

            } else {

                hero = new Hero(heroId, heroId, count);
                player.heros.put(hero.getHeroId(), hero);
            }

        }

        if (staticHero != null) {
            if (staticHero.getTime() > 0) {
                if (player.herosExpiredTime.containsKey(heroId)) {

                    if ((AwardFrom.MAIL_ATTACH.equals(from) || AwardFrom.CROSS_RANK_AWARD.equals(from)) && staticHero.getSkillId() == 22) {
                        long time = (staticHero.getTime() * 60 * 1000L);

                        long endTime = player.herosExpiredTime.get(heroId) + time;
                        if (hero != null) {
                            hero.setEndTime(endTime);
                        }
                        player.herosExpiredTime.put(heroId, endTime);
                    } else {
                        if (hero != null) {
                            hero.setEndTime(player.herosExpiredTime.get(heroId));
                        }

                    }

                } else {
                    long time = (staticHero.getTime() * 60 * 1000L);
                    long endTime = System.currentTimeMillis() + time;
                    if (hero != null) {
                        hero.setEndTime(endTime);
                    }
                    player.herosExpiredTime.put(heroId, endTime);
                }
            }

            if (staticHero.getSkillId() == 22) {
                if (player.herosCdTime.containsKey(heroId)) {
                    if (hero != null) {
                        hero.setCd(player.herosCdTime.get(heroId));
                    }
                }
            }

        }
        if (hero != null) {
            LogLordHelper.hero(from, player.account, player.lord, heroId, hero.getCount(), count, hero.getEndTime(), hero.getCd());
        } else {
            LogLordHelper.hero(from, player.account, player.lord, heroId, 1, count, 0, 0);
        }

        return hero;
    }

    /**
     * 军团建筑升级
     *
     * @param partyData
     * @param build     void
     */
    public void addPartyBuild(PartyData partyData, int build) {
        if (partyData == null) {
            return;
        }
        partyData.setBuild(partyData.getBuild() + build);
    }

    /**
     * Method: addPower
     *
     * @Description: 增加能量 @param lord @param add @return void @throws
     */
    public void addPower(Lord lord, int add) {
        if (add <= 0) {
            return;
        }
        int power = lord.getPower() + add;
        power = power > PowerConst.POWER_MAX ? PowerConst.POWER_MAX : power;
        lord.setPower(power);
    }

    /**
     * Method: addMilitaryMaterial 获得军工材料
     *
     * @param player @param id @param count @return void @throws
     */
    public MilitaryMaterial addMilitaryMaterial(Player player, int id, long count, AwardFrom from) {
        MilitaryMaterial m = player.militaryMaterials.get(id);
        if (count >= 0) {
            if (m != null) {
                m.setCount(m.getCount() + count);
            } else {
                m = new MilitaryMaterial(id, count);
                player.militaryMaterials.put(id, m);
            }
            LogLordHelper.militaryMaterial(from, player.account, player.lord, id, m.getCount(), count);
        }
        return m;
    }

    /**
     * 增加能晶
     *
     * @param player
     * @param stoneId 能晶id，须保证传入的能晶id是有配置的
     * @param count   增加的数量，正数
     * @param from
     */
    public void addEnergyStone(Player player, int stoneId, int count, AwardFrom from) {
        if (null != player && count > 0) {
            Prop prop = player.energyStone.get(stoneId);
            if (null == prop) {
                prop = new Prop(stoneId, count);
                player.energyStone.put(stoneId, prop);
            } else {
                prop.setCount(prop.getCount() + count);
            }
            LogLordHelper.energyStone(from, player.account, player.lord, stoneId, prop.getCount(), count);
        }
    }

    /**
     * 更新玩家的功勋值
     *
     * @param player
     * @param count
     * @param from
     * @return
     */
    public boolean updateExploit(Player player, int count, AwardFrom from) {
        Lord lord = player.lord;
        if (count < 0 && lord.getExploit() + count < 0) {
            return false;
        }

        if (count > 0 && lord.getExploit() + count > Integer.MAX_VALUE) {
            return false;
        }

        lord.setExploit(lord.getExploit() + count);
        LogLordHelper.exploit(from, player.account, lord, lord.getExploit(), count);
        return true;
    }

    /**
     * 增加玩家编制经验
     *
     * @param player
     * @param exp    void
     */
    public void addStaffingExp(Player player, int exp) {
        if (!TimeHelper.isStaffingOpen()) { // 未开启编制 经验预存
            player.lord.setStaffingSaveExp(player.lord.getStaffingSaveExp() + exp);
            return;
        }
        staticStaffingDataMgr.addStaffingExp(player.lord, exp);

        rankDataManager.setStaffing(player.lord);

        player.lord.setStaffing(calcStaffing(player));

        playerDataManager.synStaffingToPlayer(player);
    }

    /**
     * 根据玩家当前编制等级 得到编制类型
     *
     * @param player
     * @return int
     */
    public int calcStaffing(Player player) {
        return staffingDataManager.calcStaffing(player);
    }

    /**
     * 增加勋章
     */
    public Medal addMedal(Player player, int medalId, int pos, int strengthLv, int refitLv, AwardFrom from) {
        Medal medal = new Medal(player.maxKey(), medalId, strengthLv, refitLv, pos, 0, false);
        player.medals.get(pos).put(medal.getKeyId(), medal);
        LogLordHelper.medal(from, player.account, player.lord, medal, 0);
        addMedalBouns(player, medalId, 0, from);
        return medal;
    }

    /**
     * 增加勋章展厅
     */
    public MedalBouns addMedalBouns(Player player, int medalId, int state, AwardFrom from) {
        Map<Integer, MedalBouns> map = player.medalBounss.get(state);
        if (map.containsKey(medalId)) {
            return null;
        }
        MedalBouns medalBouns = new MedalBouns(medalId, state);
        map.put(medalId, medalBouns);
        LogLordHelper.medalBouns(from, player.account, player.lord, medalBouns);
        return medalBouns;
    }

    /**
     * 增加勋章碎片
     */
    public MedalChip addMedalChip(Player player, int chipId, int count, AwardFrom from) {
        MedalChip chip = player.medalChips.get(chipId);
        if (chip != null) {
            chip.setCount(count + chip.getCount());
        } else {
            chip = new MedalChip(chipId, count);
            player.medalChips.put(chipId, chip);
        }
        LogLordHelper.medalChip(from, player.account, player.lord, chip.getChipId(), chip.getCount(), count);
        return chip;
    }

    /**
     * 增加觉醒将领
     *
     * @param player
     * @param heroId
     * @param from
     * @return AwakenHero
     */
    public AwakenHero addAwakenHero(Player player, int heroId, AwardFrom from) {
        AwakenHero hero = new AwakenHero(player.maxKey(), heroId);
        player.awakenHeros.put(hero.getKeyId(), hero);
        LogLordHelper.awakenHero(from, player.account, player.lord, hero, 0);
        return hero;
    }

    /**
     * 加指挥官装备
     *
     * @param player
     * @param equipId
     * @param from
     * @return
     */
    public LordEquip addLordEquip(Player player, int equipId, AwardFrom from) {
        LordEquip leq = new LordEquip(player.maxKey(), equipId);
        player.leqInfo.getStoreLordEquips().put(leq.getKeyId(), leq);

        LogLordHelper.lordEquip(from, player.account, player.lord, leq.getKeyId(), leq.getEquipId());
        return leq;
    }

    /**
     * 增加军备材料
     *
     * @param player
     * @param id
     * @param add
     * @param from
     */
    public void addLordEquipMaterial(Player player, int id, int add, AwardFrom from) {
        if (add < 0) {
            LogUtil.error(String.format("add Lord equip Material error id :%d, add acount :%d, from :%d", id, add, from.getCode()));
            return;
        }
        Prop prop = player.leqInfo.getLeqMat().get(id);
        if (prop == null)
            player.leqInfo.getLeqMat().put(id, prop = new Prop(id, 0));
        prop.setCount(prop.getCount() + add);
        LogLordHelper.lordEquipMaterial(from, player.account, player.lord, id, add, prop.getCount());
    }

    /**
     * 增加军功
     *
     * @param player
     * @param id
     * @param add
     * @param from
     */
    public void addMilitaryExploit(Player player, int id, int add, AwardFrom from) {
        if (staticFunctionPlanDataMgr.isMilitaryRankOpen()) {// 功能开启
            Lord lord = player.lord;
            int today = TimeHelper.getCurrentDay();
            int mpltGetToday = playerDataManager.getMpltGetToday(lord, today);
            // 今天军功剩余获取数量

            //如果xx活動开启中 军工上限翻倍
            int mpltLimitEveryDay = Constant.MPLT_LIMIT_EVERY_DAY;
            float mul = 0;
            if (activityKingService.isOpen(3)) {
                mul += 1;
            }
            ActivityBase base = staticActivityDataMgr.getActivityById(ActivityConst.ACT_DOUBLE_MULT);
            if (base != null && base.getStep() == ActivityConst.OPEN_STEP) {
                mul += 1;
            }

            if (player.effects.containsKey(EffectType.REBEL_3001)) {
                mul += 0.5f;
            }
            int addMpl = (int) (mpltLimitEveryDay * mul);
            mpltLimitEveryDay += addMpl;
            int todayLimitRemain = Math.max(mpltLimitEveryDay - mpltGetToday, 0);
            add = Math.min(add, todayLimitRemain);
            long mpltLimit = staticLordDataMgr.getMilitaryRankMpltLimit(lord.getMilitaryRank());
            lord.setMilitaryExploit(Math.min(lord.getMilitaryExploit() + add, mpltLimit));
            lord.setLastMpltDay(today);
            lord.setMpltGetToday(mpltGetToday + add);
            LogLordHelper.militaryExploitChange(from, player.account, player.lord, lord.getMilitaryExploit(), add, mpltLimit, todayLimitRemain);
            activityKingService.updateData(player, 3, 0, add);//最强王者活动
        }
    }

    /**
     * 获得新攻击特效，如果特效比原先使用的特效ID大，就特换原来特效
     *
     * @param player
     * @param id
     * @param from
     */
    public void addAttackEffect(Player player, int id, AwardFrom from) {
        if (staticFunctionPlanDataMgr.isAttackEffectOpen()) {
            StaticAttackEffect data = staticAttackEffectDataMgr.getAttackEffect(id);
            if (data != null) {
                AttackEffect effect = player.atkEffects.get(data.getType());
                if (effect == null) {
                    player.atkEffects.put(data.getType(), effect = new AttackEffect(data.getType(), data.getEid()));
                } else {
                    if (!effect.getUnlock().contains(data.getEid())) {
                        effect.getUnlock().add(data.getEid());
                        effect.setUseId(data.getEid());
                        LogLordHelper.logAttackEffectChange(from, player, effect, id);
                    }
                }
            }
        }
    }

    /**
     * 添加作战研究院物品
     *
     * @param player
     * @param id
     * @param count
     * @param from
     */
    public void addLabFightItem(Player player, int id, int count, AwardFrom from) {

        if (id >= 201 && id <= 204) {
            player.labInfo.addItem(player, from, id, count);
        }

        if (id >= 101 && id <= 104 && player.labInfo.getResourceInfo().containsKey(id)) {
            player.labInfo.getResourceInfo().put(id, player.labInfo.getResourceInfo().get(id) + count);
        }
    }

    /**
     * Method: subProp
     *
     * @Description: 消耗物品 @return void @throws
     */
    public CommonPb.Atom2 subProp(Player player, int type, int id, long count, AwardFrom from) {
        CommonPb.Atom2.Builder b = CommonPb.Atom2.newBuilder();
        b.setKind(type).setId(id);
        switch (type) {
            case AwardType.RESOURCE:
                subResource(player, id, count, from);
                b.setCount(getResourceNum(player.resource, id));
                break;
            case AwardType.MILITARY_MATERIAL:
                MilitaryMaterial m = subMilitaryMaterial(player, id, count, from);
                b.setCount(m.getCount());
                break;
            case AwardType.TANK:
                Tank tank = player.tanks.get(id);
                subTank(player, tank, (int) count, from);
                b.setCount(tank.getCount());
                break;
            case AwardType.GOLD:
                subGold(player, (int) count, from);
                b.setCount(player.lord.getGold());
                break;
            case AwardType.ENERGY_STONE:// 能晶
                subEnergyStone(player, id, (int) count, from);
                b.setCount(player.energyStone.get(id).getCount());
                break;
            case AwardType.PROP:
                Prop prop = player.props.get(id);
                subProp(player, prop, (int) count, from);
                b.setCount(prop.getCount());
                break;
            case AwardType.CHIP:
                Chip chip = player.chips.get(id);
                subChip(player, chip, (int) count, from);
                b.setCount(chip.getCount());
                break;
            case AwardType.PART_MATERIAL:
                b.setCount(subPartMaterial(player, id, (int) count, from));
                break;
            case AwardType.ACTIVITY_PROP:
                b.setCount(subActivityProp(player, id, (int) count, from));
                break;
            case AwardType.MEDAL_MATERIAL:
                b.setCount(subMedalMaterial(player, id, (int) count, from));
                break;
            case AwardType.LORD_EQUIP_METERIAL:
                b.setCount(subLordEquipMaterial(player, id, (int) count, from));
                break;
            case AwardType.MILITARY_EXPLOIT:// 扣除军功
                subMilitaryExploit(player, (int) count, from);
                b.setCount(player.lord.getMilitaryExploit());
                break;
            case AwardType.ATTACK_EFFECT:
                subAttackEffect(player, id, from);
                break;
            case AwardType.LAB_FIGHT:
                b.setCount(subLabFightItem(player, id, (int) count, from));
                break;

            case AwardType.TACTICS:
                removeTactics(player, id, from);
                break;
            case AwardType.TACTICS_SLICE:
                b.setCount(removeTacticsSlice(player, id, (int) count, from));
                break;
            case AwardType.TACTICS_ITEM:
                b.setCount(removeTacticsItem(player, id, (int) count, from));
                break;
            case AwardType.MEDAL_CHIP:
                MedalChip medalChip = player.medalChips.get(id);
                subMedalChip(player, medalChip, (int) count, from);
                b.setCount(medalChip.getCount());
                break;
            default:
                break;
        }
        return b.build();
    }

    /**
     * 扣减玩家勋章碎片
     *
     * @param player
     * @param medalChip
     * @param count
     * @param from
     */
    private void subMedalChip(Player player, MedalChip medalChip, int count, AwardFrom from) {
        if (null != player && count > 0) {
            if (null != medalChip && medalChip.getCount() >= count) {
                medalChip.setCount(medalChip.getCount() - count);
                LogLordHelper.medalChip(from, player.account, player.lord, medalChip.getChipId(), medalChip.getCount(), -count);
            }
        }
    }

    /**
     * Method: subResource 扣除资源
     *
     * @param player @param id @param count @return void @throws
     */
    private Resource subResource(Player player, int type, long count, AwardFrom from) {
        Resource resource = player.resource;
        switch (type) {
            case 1:
                resource.setIron(resource.getIron() - count);
                break;
            case 2:
                resource.setOil(resource.getOil() - count);
                break;
            case 3:
                resource.setCopper(resource.getCopper() - count);
                break;
            case 4:
                resource.setSilicon(resource.getSilicon() - count);
                break;
            case 5:
                resource.setStone(resource.getStone() - count);
                break;
            default:
                break;
        }
        LogLordHelper.resource(from, player.account, player.lord, resource, type, count);
        return resource;
    }

    /**
     * 玩家某种资源数量
     *
     * @param resource
     * @param id       资源编号
     * @return long
     */
    private long getResourceNum(Resource resource, int id) {
        long ret = 0;
        switch (id) {
            case 1:
                ret = resource.getIron();
                break;
            case 2:
                ret = resource.getOil();
                break;
            case 3:
                ret = resource.getCopper();
                break;
            case 4:
                ret = resource.getSilicon();
                break;
            case 5:
                ret = resource.getStone();
                break;
            default:
                break;
        }
        return ret;
    }

    /**
     * Method: subMilitaryMaterial 扣除军工材料
     *
     * @param player @param id @param count @return void @throws
     */
    public MilitaryMaterial subMilitaryMaterial(Player player, int id, long count, AwardFrom from) {
        MilitaryMaterial m = player.militaryMaterials.get(id);
        if (m != null) {
            m.setCount(m.getCount() - count);
            LogLordHelper.militaryMaterial(from, player.account, player.lord, id, m.getCount(), -count);
        }
        return m;
    }

    /**
     * Method: subTank
     *
     * @Description: 扣除坦克 @param player @param tank @param count @param from @return void @throws
     */
    public Tank subTank(Player player, Tank tank, int count, AwardFrom from) {
        tank.setCount(tank.getCount() - count);
        LogLordHelper.tank(from, player.account, player.lord, tank.getTankId(), tank.getCount(), -count, -count, 0);
        return tank;
    }

    /**
     * 扣除玩家一定数量的能晶
     *
     * @param player
     * @param stoneId 能晶id，须保证传入的能晶id是有配置的
     * @param count   扣除的数量，正数，须保证扣除的数量不大于玩家当前剩余的数量
     */
    public void subEnergyStone(Player player, int stoneId, int count, AwardFrom from) {
        if (null != player && count > 0) {
            Prop prop = player.energyStone.get(stoneId);
            if (null != prop && prop.getCount() >= count) {
                prop.setCount(prop.getCount() - count);
                LogLordHelper.energyStone(from, player.account, player.lord, stoneId, prop.getCount(), -count);
            }
        }
    }

    /**
     * 扣除配件碎片
     *
     * @param player
     * @param chip
     * @param count
     * @param from
     * @return
     */
    public boolean subChip(Player player, Chip chip, int count, AwardFrom from) {
        if (chip != null && chip.getCount() >= count) {
            chip.setCount(chip.getCount() - count);
            LogLordHelper.chip(from, player.account, player.lord, chip.getChipId(), chip.getCount(), -count);
            return true;
        }
        return false;
    }

    /**
     * 扣除军备材料, 如果背包中材料数量不足将会抛出 IllegalArgumentException 异常
     *
     * @param player
     * @param id
     * @param count
     * @param from
     * @return
     */
    public int subLordEquipMaterial(Player player, int id, int count, AwardFrom from) {
        Prop prop = player.leqInfo.getLeqMat().get(id);
        if (prop == null || count <= 0 || prop.getCount() < count) {
            throw new IllegalArgumentException(String.format("lord id :%d, sub lord equip materail error, id :%d, sub count :%d, total:%d",
                    player.lord.getLordId(), id, count, prop == null ? 0 : prop.getCount()));
        }
        prop.setCount(prop.getCount() - count);
        LogLordHelper.lordEquipMaterial(from, player.account, player.lord, id, -count, prop.getCount());
        return prop.getCount();
    }

    /**
     * 扣除军功
     *
     * @param player
     * @param sub
     * @param from
     * @return
     */
    public boolean subMilitaryExploit(Player player, int sub, AwardFrom from) {
        if (staticFunctionPlanDataMgr.isMilitaryRankOpen()) {
            Lord lord = player.lord;
            if (sub < 0) {
                LogUtil.error(
                        String.format("lord id :%d, sub military exploit error ---> sub :%d <0, from :%d ", lord.getLordId(), sub, from.getCode()));
                return false;
            }
            if (lord.getMilitaryExploit() < sub) {
                throw new IllegalArgumentException("sub value greater than lord.getMilitaryExploit()");
            }
            // 军功每日获取上限
            int mpltGetToday = playerDataManager.getMpltGetToday(lord, TimeHelper.getCurrentDay());
            int mpltLimitEveryDay = Constant.MPLT_LIMIT_EVERY_DAY;
            float mul = 0;
            if (activityKingService.isOpen(3)) {
                mul += 1;
            }
            ActivityBase base = staticActivityDataMgr.getActivityById(ActivityConst.ACT_DOUBLE_MULT);
            if (base != null && base.getStep() == ActivityConst.OPEN_STEP) {
                mul += 1;
            }

            if (player.effects.containsKey(EffectType.REBEL_3001)) {
                mul += 0.5f;
            }
            int addMpl = (int) (mpltLimitEveryDay * mul);
            mpltLimitEveryDay += addMpl;
            int mpltGetTodayRemain = Math.max(mpltLimitEveryDay - mpltGetToday, 0);
            // 军衔所对应的军功获取上限
            long mpltLimit = staticLordDataMgr.getMilitaryRankMpltLimit(lord.getMilitaryRank());
            lord.setMilitaryExploit(Math.min(lord.getMilitaryExploit() - sub, mpltLimit));
            LogLordHelper.militaryExploitChange(from, player.account, player.lord, lord.getMilitaryExploit(), -sub, mpltLimit, mpltGetTodayRemain);
            return true;
        }
        return false;
    }

    /**
     * 删除玩家指定特效
     *
     * @param player
     * @param id
     * @param from
     */
    public void subAttackEffect(Player player, int id, AwardFrom from) {
        StaticAttackEffect data = staticAttackEffectDataMgr.getAttackEffect(id);
        if (data != null) {
            AttackEffect effect = player.atkEffects.get(data.getType());
            if (effect != null) {
                effect.getUnlock().remove(data.getEid());
                if (effect.getUseId() == data.getEid()) {
                    int useId = !effect.getUnlock().isEmpty() ? effect.getUnlock().iterator().next() : 0;
                    effect.setUseId(useId);
                    LogLordHelper.logAttackEffectChange(from, player, effect, id);
                }
            }
        }
    }

    /**
     * 减少作战研究院物品
     *
     * @param player
     * @param id
     * @param count
     * @param from
     */
    public int subLabFightItem(Player player, int id, int count, AwardFrom from) {
        return player.labInfo.subItem(player, from, id, count);
    }

    /**
     * Method: addAwardList
     *
     * @Description: 加一组物品 @param player @param awards @param from @return void @throws
     */
    public void addAwardList(Player player, List<List<Integer>> awards, AwardFrom from) {
        for (int i = 0; i < awards.size(); i++) {
            List<Integer> award = awards.get(i);
            if (award.size() != 3) {
                continue;
            }
            addAward(player, award.get(0), award.get(1), award.get(2), from);
        }
    }

    /**
     * 给玩家增加奖励并返回奖励对象
     *
     * @param player
     * @param award
     * @param from
     * @return CommonPb.Award
     */
    public CommonPb.Award addAwardBackPb(Player player, List<Integer> award, AwardFrom from) {
        if (award.size() == 3) {
            int type = award.get(0);
            int id = award.get(1);
            int count = award.get(2);
            int keyId = addAward(player, type, id, count, from);
            return PbHelper.createAwardPb(type, id, count, keyId);
        }
        return null;
    }

    /**
     * Method: addAwardAndBack
     *
     * @Description: 加一组物品, 并返回pb数据 @param player @param drop @param from @return @return List<Award> @throws
     */
    public List<CommonPb.Award> addAwardsBackPb(Player player, List<List<Integer>> drop, AwardFrom from) {
        List<CommonPb.Award> awards = new ArrayList<>();
        if (drop != null && !drop.isEmpty()) {
            int type = 0;
            int id = 0;
            int count = 0;
            int keyId = 0;
            for (List<Integer> award : drop) {
                if (award.size() != 3) {
                    continue;
                }

                type = award.get(0);
                id = award.get(1);
                count = award.get(2);
                keyId = addAward(player, type, id, count, from);
                awards.add(PbHelper.createAwardPb(type, id, count, keyId));
            }
        }
        return awards;
    }

    /**
     * Method: checkTank
     *
     * @Description: 检查阵型中的坦克是否足够 @param player @param form @param tankCount @return @return boolean @throws
     */
    public boolean checkTank(Player player, Form form, int tankCount) {
        int totalTank = 0;
        int count = 0;
        Map<Integer, Integer> formTanks = new HashMap<Integer, Integer>();

        int[] p = form.p;
        int[] c = form.c;
        for (int i = 0; i < p.length; i++) {
            if (p[i] > 0) {
                count = addTankMapCount(formTanks, p[i], c[i], tankCount);
                totalTank += count;
                c[i] = count;
            }
        }

        Map<Integer, Tank> tanks = player.tanks;
        if (form.getType() >= FormType.DRILL_1 && form.getType() <= FormType.DRILL_3) {
            tanks = player.drillTanks;// 红蓝大战的坦克单独计算
        }
        for (Map.Entry<Integer, Integer> entry : formTanks.entrySet()) {
            Tank tank = tanks.get(entry.getKey());
            if (tank == null || tank.getCount() < entry.getValue()) {
                return false;
            }
        }
        return totalTank != 0;
    }

    /**
     * 往部队阵容中添加最大数量的坦克
     *
     * @param formTanks
     * @param tankId
     * @param count
     * @param maxCount
     * @return int
     */
    public int addTankMapCount(Map<Integer, Integer> formTanks, int tankId, int count, int maxCount) {
        if (count < 0) {
            return 0;
        }

        if (count > maxCount) {
            count = maxCount;
        }

        if (formTanks.containsKey(tankId)) {
            formTanks.put(tankId, formTanks.get(tankId) + count);
        } else {
            formTanks.put(tankId, count);
        }

        return count;
    }

    /**
     * 资源增加同步到玩家
     *
     * @param target
     * @param type
     * @param count  void
     */
    public void synResourceToPlayer(Player target, int type, int count) {
        if (target != null && target.isLogin) {
            GamePb3.SynResourceRq.Builder builder = GamePb3.SynResourceRq.newBuilder();
            switch (type) {
                case 1:
                    builder.setIron(count);
                    break;
                case 2:
                    builder.setOil(count);
                    break;
                case 3:
                    builder.setCopper(count);
                    break;
                case 4:
                    builder.setSilicon(count);
                    break;
                case 5:
                    builder.setStone(count);
                    break;
                default:
                    return;
            }

            BasePb.Base.Builder msg = PbHelper.createSynBase(GamePb3.SynResourceRq.EXT_FIELD_NUMBER, GamePb3.SynResourceRq.ext, builder.build());
            GameServer.getInstance().synMsgToPlayer(target.ctx, msg);
        }
    }

    public void synResourceToPlayer(Player target, long r1, long r2, long r3, long r4, long r5) {
        if (target != null && target.isLogin) {
            GamePb3.SynResourceRq.Builder builder = GamePb3.SynResourceRq.newBuilder();
            builder.setIron(r1);
            builder.setOil(r2);
            builder.setCopper(r3);
            builder.setSilicon(r4);
            builder.setStone(r5);

            BasePb.Base.Builder msg = PbHelper.createSynBase(GamePb3.SynResourceRq.EXT_FIELD_NUMBER, GamePb3.SynResourceRq.ext, builder.build());
            GameServer.getInstance().synMsgToPlayer(target.ctx, msg);
        }
    }


    /**
     * 添加物品
     *
     * @param player
     * @param from
     * @param cost
     */
    public void addItem(Player player, AwardFrom from, List<List<Integer>> cost) {
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
     * 验证物品是否足够
     *
     * @param player
     * @param cost
     * @return
     */
    public boolean checkItem(Player player, List<List<Integer>> cost) {
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
     * 消耗物品
     *
     * @param player
     * @param from
     * @param cost
     * @return
     */
    public boolean decrItem(Player player, AwardFrom from, List<List<Integer>> cost) {
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
     * 添加一个战术
     *
     * @param player
     * @param id
     * @param count
     * @param from
     */
    public Tactics addTactics(Player player, int id, int count, AwardFrom from) {
        return tacticsService.addTactics(player, id, count, from);
    }

    /**
     * 删除一个战术
     *
     * @param player
     * @param keyId
     * @param from
     */
    public void removeTactics(Player player, int keyId, AwardFrom from) {
        tacticsService.removeTactics(player, keyId, from);
    }

    public void addTacticsSlice(Player player, int id, int count, AwardFrom from) {
        tacticsService.addTacticsSlice(player, id, count, from);
    }

    public int removeTacticsSlice(Player player, int id, int count, AwardFrom from) {
        return tacticsService.removeTacticsSlice(player, id, count, from);
    }

    public void addTacticsItem(Player player, int id, int count, AwardFrom from) {
        tacticsService.addTacticsItem(player, id, count, from);
    }

    public int removeTacticsItem(Player player, int id, int count, AwardFrom from) {
        return tacticsService.removeTacticsItem(player, id, count, from);
    }

    public boolean checkTacticsItem(Player player, int id, int count) {
        return tacticsService.checkTacticsItem(player, id, count);
    }

    public boolean checkTacticsSlice(Player player, int id, int count) {
        return tacticsService.checkTacticsSlice(player, id, count);
    }

    public boolean checkEnergy(Player player, int id, int count) {
        return player.energyStone.get(id) == null ? false : player.energyStone.get(id).getCount() >= count;
    }


    /**
     * 检测开启该等级的能源核心系统条件
     *
     * @param player
     * @param type
     * @param cond
     * @return
     */
    public boolean checkEnergyCoreCondition(Player player, int type, int cond) {
        int level = 0;
        switch (type) {
            case EnergyCoreConst.ROLE_LEVEL:
                level = player.lord.getLevel();
                break;
            case EnergyCoreConst.ENERGY_LEVEL:
                Map<Integer, Map<Integer, EnergyStoneInlay>> energyInlay = player.energyInlay;
                for (Map<Integer, EnergyStoneInlay> integerEnergyStoneInlayMap : energyInlay.values()) {
                    for (EnergyStoneInlay energyStoneInlay : integerEnergyStoneInlayMap.values()) {
                        if (energyStoneInlay.getStoneId() > 0) {
                            StaticEnergyStone stone = staticEnergyStoneDataMgr.getEnergyStoneById(energyStoneInlay.getStoneId());
                            level += stone.getLevel();
                        }
                    }
                }
                break;
            case EnergyCoreConst.EQUIP_LEVEL:
                Map<Integer, Map<Integer, Equip>> equips = player.equips;
                for (int i = 1; i < 7; i++) {
                    Map<Integer, Equip> maps = equips.get(i);
                    if (maps != null && !maps.isEmpty()) {
                        for (Equip equip : maps.values()) {
                            level += equip.getLv();
                        }
                    }
                }
                break;
            case EnergyCoreConst.QUEN_LEVEL:
                Map<Integer, Map<Integer, Part>> p_map = player.parts;
                for (int i = 1; i < 5; i++) {
                    Map<Integer, Part> maps = p_map.get(i);
                    if (maps != null && !maps.isEmpty()) {
                        for (Part part : maps.values()) {
                            if (part.getPos() != 0) {
                                level += part.getSmeltLv();
                            }
                        }
                    }
                }
                break;
            case EnergyCoreConst.EQUIPSTAR_LEVEL:
                Map<Integer, Map<Integer, Equip>> eq = player.equips;
                for (int i = 1; i < 7; i++) {
                    Map<Integer, Equip> maps = eq.get(i);
                    if (maps != null && !maps.isEmpty()) {
                        for (Equip equip : maps.values()) {
                            level += equip.getStarlv();
                        }
                    }
                }
                break;
            case EnergyCoreConst.METRA_LEVEL:
                Map<Integer, Medal> medals = player.medals.get(1);
                if (medals != null && !medals.isEmpty()) {
                    for (Medal medal : medals.values()) {
                        if (medal.getPos() > 0) {
                            level += medal.getUpLv();
                        }
                    }
                }
                break;
            case EnergyCoreConst.POLI_LEVEL:

                Map<Integer, Medal> ms = player.medals.get(1);
                if (ms != null && !ms.isEmpty()) {
                    for (Medal medal : ms.values()) {
                        if (medal.getPos() > 0) {
                            level += medal.getRefitLv();
                        }
                    }
                }
                break;
        }
        return level >= cond;
    }
}
