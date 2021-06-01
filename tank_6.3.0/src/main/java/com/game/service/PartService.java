/**
 * @Title: PartService.java
 * @Package com.game.service
 * @Description:
 * @author ZhangJun
 * @date 2015年8月20日 上午10:09:09
 * @version V1.0
 */
package com.game.service;

import com.alibaba.fastjson.JSON;
import com.game.actor.role.PlayerEventService;
import com.game.constant.*;
import com.game.dataMgr.StaticActivityDataMgr;
import com.game.dataMgr.StaticIniDataMgr;
import com.game.dataMgr.StaticPartDataMgr;
import com.game.dataMgr.StaticVipDataMgr;
import com.game.domain.ActivityBase;
import com.game.domain.Player;
import com.game.domain.p.*;
import com.game.domain.s.*;
import com.game.fight.domain.AttrData;
import com.game.manager.ActivityDataManager;
import com.game.manager.PlayerDataManager;
import com.game.message.handler.ClientHandler;
import com.game.pb.CommonPb;
import com.game.pb.CommonPb.PartSmeltAttr;
import com.game.pb.CommonPb.PartSmeltRecord;
import com.game.pb.CommonPb.TwoInt;
import com.game.pb.GamePb1.*;
import com.game.pb.GamePb4.LockPartRq;
import com.game.pb.GamePb4.LockPartRs;
import com.game.pb.GamePb4.PartQualityUpRq;
import com.game.pb.GamePb4.PartQualityUpRs;
import com.game.pb.GamePb5.*;
import com.game.pb.GamePb6.PartConvertRq;
import com.game.pb.GamePb6.PartConvertRs;
import com.game.util.*;
import org.apache.commons.lang3.RandomUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.Map.Entry;

/**
 * @author ZhangJun
 * @ClassName: PartService
 * @Description: 配件相关逻辑
 * @date 2015年8月20日 上午10:09:09
 */
@Service
public class PartService {
    @Autowired
    private PlayerDataManager playerDataManager;

    @Autowired
    private ActivityDataManager activityDataManager;

    @Autowired
    private StaticPartDataMgr staticPartDataMgr;

    @Autowired
    private StaticVipDataMgr staticVipDataMgr;

    @Autowired
    private StaticActivityDataMgr staticActivityDataMgr;

    @Autowired
    private ChatService chatService;

    @Autowired
    private AttackEffectService attackEffectService;

    @Autowired
    private PlayerEventService playerEventService;
    @Autowired
    private StaticIniDataMgr staticIniDataMgr;

    /**
     * Method: getPart
     *
     * @param handler
     * @return void
     * @throws @Description: 客户端获取配件数据
     */
    public void getPart(ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        GetPartRs.Builder builder = GetPartRs.newBuilder();
        for (int i = 0; i < 5; i++) {
            Map<Integer, Part> map = player.parts.get(i);
            Iterator<Part> it = map.values().iterator();
            while (it.hasNext()) {
                builder.addPart(PbHelper.createPartPb(it.next()));
            }
        }
        handler.sendMsgToPlayer(GetPartRs.ext, builder.build());
    }

    /**
     * Method: getChip
     *
     * @param handler
     * @return void
     * @throws @Description: 客户端获取碎片数据
     */
    public void getChip(ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        GetChipRs.Builder builder = GetChipRs.newBuilder();

        Iterator<Chip> it = player.chips.values().iterator();
        while (it.hasNext()) {
            builder.addChip(PbHelper.createChipPb(it.next()));
        }

        handler.sendMsgToPlayer(GetChipRs.ext, builder.build());
    }

    /**
     * Method: combinePart
     *
     * @param req
     * @param handler
     * @return void
     * @throws @Description: 合成配件
     */
    public void combinePart(CombinePartRq req, ClientHandler handler) {
        int partId = req.getPartId();
        Player player = playerDataManager.getPlayer(handler.getRoleId());

        StaticPart staticPart = staticPartDataMgr.getStaticPart(partId);
        if (staticPart == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }

        Chip chip = player.chips.get(partId);
        Chip whatChip = player.chips.get(901);
        int chipCount = 0;
        int whatCount = 0;
        if (chip != null) {
            chipCount = chip.getCount();
        }

        if (chipCount <= 0) {// 合成必须要有对应的碎片
            handler.sendErrorMsgToPlayer(GameError.CHIP_NOT_ENOUGH);
            return;
        }

        if (whatChip != null) {
            whatCount = whatChip.getCount();
        }

        if (chipCount + whatCount < staticPart.getChipCount()) {
            handler.sendErrorMsgToPlayer(GameError.CHIP_NOT_ENOUGH);
            return;
        }

        int index = partId / 100;
        switch (index) {
            case 10:
            case 11:
                //9-10号配件合成本体碎片数量限制校验
                Map<Integer, Integer> nineOrTenPartCombineChipCountMap = staticIniDataMgr.getNineOrTenPartCombineChipCountMap(SystemId.NINE_TEN_PART_COMBINE_CHIP_COUNT);
                if (nineOrTenPartCombineChipCountMap == null) {
                    handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
                    return;
                }

                Integer maxChipCount = nineOrTenPartCombineChipCountMap.get(staticPart.getQuality());
                if (chipCount < maxChipCount) {
                    handler.sendErrorMsgToPlayer(GameError.CHIP_NOT_ENOUGH);
                    return;
                }
                break;
            default:
                break;
        }

        /**
         * 判断仓库配件数量是否已经达到最大上限
         */
        Map<Integer, Part> storeMap = player.parts.get(0);
        if (storeMap.size() >= PlayerDataManager.PART_STORE_LIMIT) {
            handler.sendErrorMsgToPlayer(GameError.MAX_PART_STORE);
            return;
        }

        if (chipCount >= staticPart.getChipCount()) {
            playerDataManager.subChip(player, chip, staticPart.getChipCount(), AwardFrom.COMBINE_PART);
        } else {
            int count = staticPart.getChipCount() - chipCount;
            if (chipCount > 0) {
                playerDataManager.subChip(player, chip, chipCount, AwardFrom.COMBINE_PART);
            }
            playerDataManager.subChip(player, whatChip, count, AwardFrom.COMBINE_PART);
        }

        Part part = playerDataManager.addPart(player, partId, 0, 0, 0, AwardFrom.COMBINE_PART);

        CombinePartRs.Builder builder = CombinePartRs.newBuilder();
        builder.setPart(PbHelper.createPartPb(part));
        handler.sendMsgToPlayer(CombinePartRs.ext, builder.build());
    }

    /**
     * Method: explodePart
     *
     * @param req
     * @param handler
     * @return void
     * @throws @Description: 分解配件
     */
    public void explodePart(ExplodePartRq req, ClientHandler handler) {
        int keyId = 0;
        // int quality = 0;
        if (req.hasKeyId()) {
            keyId = req.getKeyId();
        }

        Player player = playerDataManager.getPlayer(handler.getRoleId());

        long stoneAdd = 0;
        int fittingAdd = 0;
        int planAdd = 0;
        int mineralAdd = 0;
        int toolAdd = 0;

        List<PartResolve> resolveList = new ArrayList<>();
        if (keyId != 0) {// 分解单个
            Map<Integer, Part> store = player.parts.get(0);
            Part part = store.get(keyId);
            if (part == null) {
                handler.sendErrorMsgToPlayer(GameError.NO_PART);
                return;
            }

            if (part.isLocked()) {
                handler.sendErrorMsgToPlayer(GameError.PART_LOCKED);
                return;
            }

            StaticPart staticPart = staticPartDataMgr.getStaticPart(part.getPartId());
            if (staticPart == null) {
                handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
                return;
            }

            StaticPartUp staticPartUp = staticPartDataMgr.getStaticPartUp(part.getPartId(), part.getUpLv());
            if (staticPartUp == null) {
                handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
                return;
            }

            /**
             * 判断当前配件是否为9-10位的配件
             */
            boolean nineOrTen = checkNineOrTenPart(part);
            StaticPartRefit staticPartRefit = staticPartDataMgr.getStaticPartRefit(staticPart.getQuality(),
                    part.getRefitLv(), nineOrTen);
            if (staticPartRefit == null) {
                handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
                return;
            }

            store.remove(keyId);

            // stoneAdd = staticPartUp.getStoneExplode();
            // fittingAdd = staticPartRefit.getFittingExplode();
            // planAdd = staticPartRefit.getPlanExplode();
            // mineralAdd = staticPartRefit.getMineralExplode();
            // toolAdd = staticPartRefit.getToolExplode();
            Lord lord = player.lord;
            playerDataManager.modifyStone(player, staticPartUp.getStoneExplode(), AwardFrom.EXPLODE_PART);
            playerDataManager.addPartMaterial(player, 1, staticPartRefit.getFittingExplode(), AwardFrom.EXPLODE_PART);
            playerDataManager.addPartMaterial(player, 3, staticPartRefit.getPlanExplode(), AwardFrom.EXPLODE_PART);
            playerDataManager.addPartMaterial(player, 4, staticPartRefit.getMineralExplode(), AwardFrom.EXPLODE_PART);
            playerDataManager.addPartMaterial(player, 5, staticPartRefit.getToolExplode(), AwardFrom.EXPLODE_PART);
            List<CommonPb.Award> awards = new ArrayList<>();
            for (List<Integer> award : staticPartRefit.getExplode()) {
                awards.add(playerDataManager.addAwardBackPb(player, award, AwardFrom.EXPLODE_PART));
            }

            // playerDataManager.modifyPlan(lord, planAdd);
            // playerDataManager.modifyMineral(lord, mineralAdd);
            // playerDataManager.modifyTool(lord, toolAdd);

            ExplodePartRs.Builder builder = ExplodePartRs.newBuilder();
            builder.setFitting(lord.getFitting());
            builder.setPlan(lord.getPlan());
            builder.setMineral(lord.getMineral());
            builder.setTool(lord.getTool());
            builder.setStone(player.resource.getStone());
            builder.addAllAward(awards);
            handler.sendMsgToPlayer(ExplodePartRs.ext, builder.build());
            resolveList.add(new PartResolve(AwardType.PART, staticPart.getQuality(), 1));
            activityDataManager.partResolve(player, resolveList);

            LogLordHelper.part(AwardFrom.EXPLODE_PART, player.account, player.lord, part);
        } else {// 批量分解
            List<Integer> qualites = req.getQualityList();
            Map<Integer, Part> store = player.parts.get(0);
            Iterator<Part> it = store.values().iterator();
            Map<Integer, Map<Integer, Integer>> map = new HashMap<>();
            while (it.hasNext()) {
                Part part = (Part) it.next();
                if (part.isLocked()) {
                    continue;
                }
                StaticPart staticPart = staticPartDataMgr.getStaticPart(part.getPartId());
                if (staticPart == null) {
                    handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
                    return;
                }

                if (qualites.contains(staticPart.getQuality())) {
                    StaticPartUp staticPartUp = staticPartDataMgr.getStaticPartUp(part.getPartId(), part.getUpLv());
                    if (staticPartUp == null) {
                        continue;
                    }

                    /**
                     * 判断当前配件是否为9-10位的配件
                     */
                    boolean nineOrTen = checkNineOrTenPart(part);
                    StaticPartRefit staticPartRefit = staticPartDataMgr.getStaticPartRefit(staticPart.getQuality(),
                            part.getRefitLv(), nineOrTen);
                    if (staticPartRefit == null) {
                        continue;
                    }

                    stoneAdd += staticPartUp.getStoneExplode();
                    fittingAdd += staticPartRefit.getFittingExplode();
                    planAdd += staticPartRefit.getPlanExplode();
                    mineralAdd += staticPartRefit.getMineralExplode();
                    toolAdd += staticPartRefit.getToolExplode();
                    for (List<Integer> award : staticPartRefit.getExplode()) {
                        addMapNum(map, award.get(0), award.get(1), award.get(2));
                    }

                    resolveList.add(new PartResolve(AwardType.PART, staticPart.getQuality(), 1));

                    it.remove();

                    LogLordHelper.part(AwardFrom.EXPLODE_PART, player.account, player.lord, part);
                }
            }

            Lord lord = player.lord;
            playerDataManager.modifyStone(player, stoneAdd, AwardFrom.EXPLODE_PART);

            playerDataManager.addPartMaterial(player, 1, fittingAdd, AwardFrom.EXPLODE_PART);
            playerDataManager.addPartMaterial(player, 3, planAdd, AwardFrom.EXPLODE_PART);
            playerDataManager.addPartMaterial(player, 4, mineralAdd, AwardFrom.EXPLODE_PART);
            playerDataManager.addPartMaterial(player, 5, toolAdd, AwardFrom.EXPLODE_PART);
            List<CommonPb.Award> awards = new ArrayList<>();
            for (Entry<Integer, Map<Integer, Integer>> entry : map.entrySet()) {
                int type = entry.getKey();
                Map<Integer, Integer> entryMap = entry.getValue();
                for (Entry<Integer, Integer> entry1 : entryMap.entrySet()) {
                    List<Integer> award = new ArrayList<>();
                    award.add(type);
                    award.add(entry1.getKey());
                    award.add(entry1.getValue());

                    awards.add(playerDataManager.addAwardBackPb(player, award, AwardFrom.EXPLODE_PART));
                }
            }

            // playerDataManager.modifyFitting(lord, fittingAdd);
            // playerDataManager.modifyPlan(lord, planAdd);
            // playerDataManager.modifyMineral(lord, mineralAdd);
            // playerDataManager.modifyTool(lord, toolAdd);

            activityDataManager.partResolve(player, resolveList);

            playerDataManager.updTask(player, TaskType.COND_PART_EPR, 1);

            attackEffectService.unLockAttackEffect(player);


            ExplodePartRs.Builder builder = ExplodePartRs.newBuilder();
            builder.setFitting(lord.getFitting());
            builder.setPlan(lord.getPlan());
            builder.setMineral(lord.getMineral());
            builder.setTool(lord.getTool());
            builder.setStone(player.resource.getStone());
            builder.addAllAward(awards);
            handler.sendMsgToPlayer(ExplodePartRs.ext, builder.build());
        }

    }

    /**
     * 是否符合穿戴等级
     *
     * @param lv
     * @param index 几号位配件
     * @return boolean
     */
    private boolean canOnPart(int lv, int index) {
        switch (index) {
            case 1:
            case 2:
                if (lv < 18) {
                    return false;
                }
                break;
            case 3:
                if (lv < 20) {
                    return false;
                }
                break;
            case 4:
                if (lv < 25) {
                    return false;
                }
                break;
            case 5:
                if (lv < 30) {
                    return false;
                }
                break;
            case 6:
                if (lv < 40) {
                    return false;
                }
                break;
            case 7:
                if (lv < 55) {
                    return false;
                }
                break;
            case 8:
                if (lv < 60) {
                    return false;
                }
                break;
            case 10:
                //10 ：表示9号位置的配件（数据库中9号位置的配件从1001开始）
                if (lv < 64) {
                    return false;
                }
                break;
            case 11:
                //11 ：表示10号位置的配件（数据库中9号位置的配件从1101开始）
                if (lv < 67) {
                    return false;
                }
                break;
            default:
                return false;
        }

        return true;
    }

    /**
     * Method: onPart
     *
     * @param req
     * @param handler
     * @return void
     * @throws @Description: 穿戴，卸下配件
     */
    public void onPart(OnPartRq req, ClientHandler handler) {
        int keyId = req.getKeyId();
        int pos = 0;
        if (req.hasPos()) {
            pos = req.getPos();
        }

        if (pos < 0 || pos > 4) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }

        Player player = playerDataManager.getPlayer(handler.getRoleId());
        Map<Integer, Part> map = player.parts.get(pos);
        if (CheckNull.isEmpty(map)) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }

        Part part = map.get(keyId);
        if (part == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_PART);
            return;
        }

        StaticPart staticPart = staticPartDataMgr.getStaticPart(part.getPartId());
        if (staticPart == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }

        if (pos == 0) {// 穿上
            int toPos = staticPart.getType();
            Map<Integer, Part> toMap = player.parts.get(toPos);

            int index = part.getPartId() / 100;
            if (!canOnPart(player.lord.getLevel(), index)) {
                handler.sendErrorMsgToPlayer(GameError.LV_NOT_ENOUGH);
                return;
            }

            Iterator<Part> it = toMap.values().iterator();
            while (it.hasNext()) {
                Part putOnPart = it.next();
                if (putOnPart.getPartId() / 100 == index) {
                    // 卸下原来配件
                    it.remove();
                    putOnPart.setPos(0);
                    player.parts.get(0).put(putOnPart.getKeyId(), putOnPart);
                    break;
                }
            }

            part.setPos(toPos);
            map.remove(keyId);
            toMap.put(keyId, part);
        } else {// 卸下
            Map<Integer, Part> storeMap = player.parts.get(0);
            if (storeMap.size() >= PlayerDataManager.PART_STORE_LIMIT) {
                handler.sendErrorMsgToPlayer(GameError.MAX_PART_STORE);
                return;
            }

            part.setPos(0);
            map.remove(keyId);
            player.parts.get(0).put(keyId, part);
        }

        playerDataManager.updateFight(player);

        OnPartRs.Builder builder = OnPartRs.newBuilder();
        handler.sendMsgToPlayer(OnPartRs.ext, builder.build());

        // 重新计算玩家最强实力
        playerEventService.calcStrongestFormAndFight(player);

    }

    /**
     * Method: explodeChip
     *
     * @param req
     * @param handler
     * @return void
     * @throws @Description: 分解碎片
     */
    public void explodeChip(ExplodeChipRq req, ClientHandler handler) {
        int chipId = 0;
        if (req.hasChipId()) {
            chipId = req.getChipId();
        }

        Player player = playerDataManager.getPlayer(handler.getRoleId());

        List<PartResolve> chipList = new ArrayList<>();
        if (chipId != 0) {
            int count = req.getCount();
            if (count < 0) {
                handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
                return;
            }

            Chip chip = player.chips.get(chipId);
            if (chip == null || chip.getCount() < count) {
                handler.sendErrorMsgToPlayer(GameError.CHIP_NOT_ENOUGH);
                return;
            }

            StaticPart staticPart = staticPartDataMgr.getStaticPart(chipId);
            if (staticPart == null) {
                handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
                return;
            }

            int fitting = 0;
            if (staticPart.getQuality() == 2) {// 蓝色
                fitting = 100 * count;
            } else if (staticPart.getQuality() == 3) {// 紫色
                fitting = 200 * count;
            } else if (staticPart.getQuality() == 4) {
                fitting = 1000 * count;
            }

            playerDataManager.subChip(player, chip, count, AwardFrom.EXPLODE_CHIP);

            playerDataManager.addPartMaterial(player, 1, fitting, AwardFrom.EXPLODE_CHIP);
            ExplodeChipRs.Builder builder = ExplodeChipRs.newBuilder();
            builder.setFitting(player.lord.getFitting());
            handler.sendMsgToPlayer(ExplodeChipRs.ext, builder.build());
            chipList.add(new PartResolve(AwardType.CHIP, staticPart.getQuality(), count));
            activityDataManager.partResolve(player, chipList);
        } else {
            List<Integer> qualites = req.getQualityList();
            int fitting = 0;

            Map<Integer, Chip> chips = player.chips;
            Iterator<Chip> it = chips.values().iterator();
            while (it.hasNext()) {
                Chip chip = (Chip) it.next();
                StaticPart staticPart = staticPartDataMgr.getStaticPart(chip.getChipId());
                if (staticPart == null) {
                    handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
                    return;
                }

                int count = chip.getCount();

                if (count <= 0) {
                    continue;
                }

                if (qualites.contains(staticPart.getQuality())) {

                    if (staticPart.getQuality() == 2) {// 蓝色
                        fitting += 100 * count;
                    } else if (staticPart.getQuality() == 3) {// 紫色
                        fitting += 200 * count;
                    } else if (staticPart.getQuality() == 4) {
                        fitting += 1000 * count;
                    }
                    chipList.add(new PartResolve(AwardType.CHIP, staticPart.getQuality(), count));
                    it.remove();
                    LogLordHelper.chip(AwardFrom.EXPLODE_CHIP, player.account, player.lord, chip.getChipId(), 0,
                            -count);
                }
            }
            activityDataManager.partResolve(player, chipList);
            playerDataManager.modifyFitting(player.lord, fitting);
            ExplodeChipRs.Builder builder = ExplodeChipRs.newBuilder();
            builder.setFitting(player.lord.getFitting());
            handler.sendMsgToPlayer(ExplodeChipRs.ext, builder.build());
        }

    }

    /**
     * Method: upPart
     *
     * @param req
     * @param handler
     * @return void
     * @throws @Description: 强化配件
     */
    public void upPart(UpPartRq req, ClientHandler handler) {
        int keyId = req.getKeyId();
        int pos = req.getPos();
        int metal = req.getMetal();
        if (pos < 0 || pos > 4 || metal < 0 || metal > 10) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }

        Player player = playerDataManager.getPlayer(handler.getRoleId());
        Map<Integer, Part> map = player.parts.get(pos);
        if (CheckNull.isEmpty(map)) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }

        Part part = map.get(keyId);
        if (part == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_PART);
            return;
        }

        if (part.getUpLv() >= player.lord.getLevel()) {
            handler.sendErrorMsgToPlayer(GameError.LV_NOT_ENOUGH);
            return;
        }

        if (part.getUpLv() >= Constant.MAX_PART_UP_LV) {
            handler.sendErrorMsgToPlayer(GameError.MAX_PART_UP_LV);
            return;
        }

        StaticPartUp staticPartUp = staticPartDataMgr.getStaticPartUp(part.getPartId(), part.getUpLv() + 1);
        if (staticPartUp == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }
        Resource resource = player.resource;
        if (resource.getStone() < staticPartUp.getStone()) {
            handler.sendErrorMsgToPlayer(GameError.STONE_NOT_ENOUGH);
            return;
        }

        if (metal != 0 && player.lord.getMetal() < metal) {
            handler.sendErrorMsgToPlayer(GameError.METAL_NOT_ENOUGH);
            return;
        }
        boolean success = false;
        int prob = staticPartUp.getProb() + 50 * metal;
        StaticVip staticVip = staticVipDataMgr.getStaticVip(player.lord.getVip());
        if (staticVip != null) {
            prob += (prob * staticVip.getPartProb() / NumberHelper.HUNDRED_INT);
        }

        prob = (prob > NumberHelper.THOUSAND) ? NumberHelper.THOUSAND : prob;
        if (RandomHelper.isHitRangeIn1000(prob)) {
            success = true;
        }

        long costStone = staticPartUp.getStone();

        if (success) {
            part.setUpLv(part.getUpLv() + 1);
        } else {
            float a = activityDataManager.discountActivity(ActivityConst.ACT_PART_EVOLVE, 0);
            costStone *= a / 100f;
        }

        playerDataManager.modifyMetal(player.lord, -metal);
        playerDataManager.modifyStone(player, -costStone, AwardFrom.UP_PART);

        if (pos != 0) {
            playerDataManager.updateFight(player);
        }

        playerDataManager.updTask(player, TaskType.COND_UP_PART, 1);
        playerDataManager.updTask(player, TaskType.COND_USE_STONE, (int) costStone);// 配件强化消耗的水晶
        UpPartRs.Builder builder = UpPartRs.newBuilder();
        builder.setSuccess(success);
        builder.setStone(player.resource.getStone());
        builder.setMetal(player.lord.getMetal());
        handler.sendMsgToPlayer(UpPartRs.ext, builder.build());

        if (success) {// 配件强化
            StaticPart staticPart = staticPartDataMgr.getStaticPart(part.getPartId());
            if (staticPart != null && staticPart.getQuality() >= 2) {
                switch (part.getUpLv()) {
                    case 20:
                    case 40:
                    case 60:
                    case 80:
                    case 85:
                    case 90:
                    case 95:
                    case 100:
                        chatService.sendWorldChat(chatService.createSysChat(SysChatId.PART_UPGRADE, player.lord.getNick(),
                                String.valueOf(part.getPartId()), String.valueOf(part.getUpLv())));
                }
                // if (part.getUpLv() == 20) {
                // chatService.sendWorldChat(chatService.createSysChat(SysChatId.PART_UPGRADE, player.lord.getNick(),
                // String.valueOf(part.getPartId()), "20"));
                // } else if (part.getUpLv() == 40) {
                // chatService.sendWorldChat(chatService.createSysChat(SysChatId.PART_UPGRADE, player.lord.getNick(),
                // String.valueOf(part.getPartId()), "40"));
                // } else if (part.getUpLv() == 60) {
                // chatService.sendWorldChat(chatService.createSysChat(SysChatId.PART_UPGRADE, player.lord.getNick(),
                // String.valueOf(part.getPartId()), "60"));
                // } else if (part.getUpLv() == 80) {
                // chatService.sendWorldChat(chatService.createSysChat(SysChatId.PART_UPGRADE, player.lord.getNick(),
                // String.valueOf(part.getPartId()), "80"));
                // } else if (part.getUpLv() == 85) {
                // chatService.sendWorldChat(chatService.createSysChat(SysChatId.PART_UPGRADE, player.lord.getNick(),
                // String.valueOf(part.getPartId()), "85"));
                // }
            }
            LogLordHelper.part(AwardFrom.UP_PART, player.account, player.lord, part);
            // 重新计算玩家最强实力
            playerEventService.calcStrongestFormAndFight(player);
        }
    }

    /**
     * Method: refitPart
     *
     * @param req
     * @param handler
     * @return void
     * @throws @Description: 改造配件
     */
    public void refitPart(RefitPartRq req, ClientHandler handler) {
        int keyId = req.getKeyId();
        int pos = req.getPos();
        boolean draw = req.getDraw();

        if (pos < 0 || pos > 4) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }

        Player player = playerDataManager.getPlayer(handler.getRoleId());
        Map<Integer, Part> map = player.parts.get(pos);
        if (CheckNull.isEmpty(map)) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }

        Part part = map.get(keyId);
        if (part == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_PART);
            return;
        }

        if (part.getRefitLv() >= Constant.MAX_PART_REFIT_LV) {
            handler.sendErrorMsgToPlayer(GameError.MAX_PART_REFIT_LV);
            return;
        }

        StaticPart staticPart = staticPartDataMgr.getStaticPart(part.getPartId());
        if (staticPart == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }
        boolean nineOrTen = checkNineOrTenPart(part);
        StaticPartRefit staticPartRefit = staticPartDataMgr.getStaticPartRefit(staticPart.getQuality(),
                part.getRefitLv() + 1, nineOrTen);
        if (staticPartRefit == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }

        Lord lord = player.lord;
        int fittingCost = staticPartRefit.getFitting();
        int planCost = staticPartRefit.getPlan();
        int mineralCost = staticPartRefit.getMineral();
        int toolCost = staticPartRefit.getTool();
        if (lord.getFitting() < fittingCost || lord.getPlan() < planCost || lord.getMineral() < mineralCost
                || lord.getTool() < toolCost) {
            handler.sendErrorMsgToPlayer(GameError.INGREDIENT_NOT_ENOUGH);
            return;
        }

        for (List<Integer> award : staticPartRefit.getCost()) {
            if (!playerDataManager.checkPropIsEnougth(player, award.get(0), award.get(1), award.get(2))) {
                handler.sendErrorMsgToPlayer(GameError.INGREDIENT_NOT_ENOUGH);
                return;
            }
        }

        if (draw && lord.getDraw() < 5) {
            handler.sendErrorMsgToPlayer(GameError.DRAW_NOT_ENOUGH);
            return;
        }

        playerDataManager.addPartMaterial(player, 1, -fittingCost, AwardFrom.REFIT_PART);
        playerDataManager.addPartMaterial(player, 3, -planCost, AwardFrom.REFIT_PART);
        playerDataManager.addPartMaterial(player, 4, -mineralCost, AwardFrom.REFIT_PART);
        playerDataManager.addPartMaterial(player, 5, -toolCost, AwardFrom.REFIT_PART);
        for (List<Integer> award : staticPartRefit.getCost()) {
            playerDataManager.subProp(player, award.get(0), award.get(1), award.get(2), AwardFrom.REFIT_PART);
        }

        // playerDataManager.modifyFitting(lord, -fittingCost);
        // playerDataManager.modifyPlan(lord, -planCost);
        // playerDataManager.modifyMineral(lord, -mineralCost);
        // playerDataManager.modifyTool(lord, -toolCost);
        if (draw) {
            playerDataManager.modifyDraw(lord, -5);
        }

        boolean flag = activityDataManager.partEvolve();// 配件进化活动开启之后配件改造不降级

        if (!draw && !flag) {
            int upLv = part.getUpLv() - 3;
            upLv = (upLv > 0) ? upLv : 0;
            part.setUpLv(upLv);
        }

        part.setRefitLv(part.getRefitLv() + 1);
        // partDao.updateLv(part);

        if (pos != 0) {
            playerDataManager.updateFight(player);
        }

        RefitPartRs.Builder builder = RefitPartRs.newBuilder();
        builder.setUpLv(part.getUpLv());
        handler.sendMsgToPlayer(RefitPartRs.ext, builder.build());

        chatService.sendWorldChat(chatService.createSysChat(SysChatId.PART_REFIT, player.lord.getNick(),
                String.valueOf(part.getPartId()), part.getRefitLv() + ""));

        LogLordHelper.part(AwardFrom.REFIT_PART, player.account, player.lord, part);

        // 改造解锁攻击特效
        attackEffectService.checkAndUnLockAttackEffect(player, staticPart.getType(), part.getRefitLv());

        attackEffectService.unLockAttackEffect(player);
        // 重新计算玩家最强实力
        playerEventService.calcStrongestFormAndFight(player);
    }

    /**
     * 检查当前配件是否是9-10号配件
     *
     * @param part
     * @return
     */
    private boolean checkNineOrTenPart(Part part) {
        int index = part.getPartId() / 100;
        if (index >= 10) {
            return true;
        }
        return false;
    }

    /**
     * 锁定配件
     *
     * @param req
     * @param handler
     */
    public void lockPart(LockPartRq req, ClientHandler handler) {
        int keyId = req.getKeyId();
        int pos = req.getPos();
        boolean locked = req.getLocked();

        if (pos < 0 || pos > 4) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }

        Player player = playerDataManager.getPlayer(handler.getRoleId());
        Map<Integer, Part> map = player.parts.get(pos);
        if (CheckNull.isEmpty(map)) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }

        Part part = map.get(keyId);
        if (part == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_PART);
            return;
        }

        StaticPart staticPart = staticPartDataMgr.getStaticPart(part.getPartId());
        if (staticPart == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }

        part.setLocked(locked);

        LockPartRs.Builder builder = LockPartRs.newBuilder();
        builder.setResult(true);
        handler.sendMsgToPlayer(LockPartRs.ext, builder.build());
    }

    /**
     * 每天重置淬炼次数功能已删除
     *
     * @param player void
     */
    private void refreshSmeltTimes(Player player) {
        // int day = TimeHelper.getCurrentDay();
        // if (day != player.smeltDay) {
        // player.smeltDay = day;
        // player.smeltTimes = 0;
        // }
    }

    /**
     * 淬炼炼配件后解锁新属性
     *
     * @param player
     * @param part
     * @param staticPart
     * @param smelting
     * @param handler
     */
    private Map<Integer, Integer> getNewAttr(Player player, Part part, StaticPart staticPart, StaticPartSmelting smelting, ClientHandler handler) {
        // 找出所有已经解锁属性
        Set<Integer> openAttr = new HashSet<>();
        for (Entry<Integer, List<Integer>> entry : staticPart.getS_attr().entrySet()) {
            int attrId = entry.getKey();
            if (!part.getSmeltAttr().containsKey(attrId)) {// 如果之前解锁了，终生解锁
                List<Integer> openCondi = staticPart.getS_attrCondition().get(attrId);
                if (openCondi == null) {
                    handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
                    return null;
                }
                // 强化等级且改造等级
                if (openCondi.get(0) > part.getUpLv() || openCondi.get(1) > part.getRefitLv()) {
                    continue;
                }
            }
            openAttr.add(attrId);
        }
        Map<Integer, Integer> newAttr = new HashMap<>();
        // 如果是蓝色装备全部属性解锁后淬炼一次随机三个属性
        if (staticPart.getQuality() == 2 && openAttr.size() == staticPart.getS_attr().size()) {
            // 舍弃一个随机
            int index = RandomUtils.nextInt(0, openAttr.size());
            int i = 0;
            for (Integer attrId : openAttr) {
                if (i == index) {
                    Integer[] cVal = part.getSmeltAttr().get(attrId);
                    Integer curVal = cVal != null ? cVal[0] : 0;

                    newAttr.put(attrId, curVal);
                    openAttr.remove(attrId);
                    break;
                }
                i++;
            }
        }
        // 属性随机值
        for (Integer attrId : openAttr) {
            Integer[] cVal = part.getSmeltAttr().get(attrId);
            Integer curVal = cVal != null ? cVal[0] : 0;

            // 是上升还是下降
            int totalWeight = smelting.getUp_weight() + smelting.getDown_weight();
            int randomWeight = RandomHelper.randomInSize(totalWeight);
            // //淬炼属性上升概率修正
            // if(player.smeltTimes < Constant.SMELT_MAX_TIMES){
            // randomWeight *= Constant.SMELT_UP_RADIO;
            // player.smeltTimes++;
            // }
            boolean isUp = randomWeight < smelting.getUp_weight();
            if (curVal == 0) {
                isUp = true;
            }
            boolean isF = AttrData.isF(attrId);
            if (isUp) {
                Integer minRangeVal = isF ? smelting.getUp_min().get(0) : smelting.getUp_min().get(1);
                Integer maxRangeVal = isF ? smelting.getUp_max().get(0) : smelting.getUp_max().get(1);
                Integer changeVal = RandomUtils.nextInt(minRangeVal, maxRangeVal + 1);
                curVal += changeVal;
            } else {
                Integer minRangeVal = isF ? smelting.getDown_min().get(0) : smelting.getDown_min().get(1);
                Integer maxRangeVal = isF ? smelting.getDown_max().get(0) : smelting.getDown_max().get(1);
                Integer changeVal = RandomUtils.nextInt(minRangeVal, maxRangeVal + 1);
                curVal -= changeVal;
            }
            //
            Integer maxVal = staticPart.getS_attr().get(attrId).get(part.getSmeltLv());
            if (maxVal == null) {
                handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
                return null;
            }
            if (curVal < 0) {
                curVal = 0;
            }
            if (curVal > maxVal) {
                curVal = maxVal;
            }
            newAttr.put(attrId, curVal);
        }
        return newAttr;
    }

    /**
     * 增加淬炼经验
     */
    private void addSmeltPartExp(Part part, StaticPart staticPart, int exp) {
        if (part.getSmeltLv() >= staticPart.getLvMax()) {
            return;// 满级
        }
        int curExp = part.getSmeltExp() + exp;
        int curLv = part.getSmeltLv();
        while (curLv < staticPart.getLvMax()) {
            int maxExp = staticPart.getSmeltExp().get(curLv);
            if (curExp >= maxExp) {
                curExp -= maxExp;
                curLv++;
            } else {
                break;
            }
        }
        if (part.getSmeltLv() >= staticPart.getLvMax()) {
            curLv = staticPart.getLvMax();
            curExp = 0;
        }
        part.setSmeltLv(curLv);
        part.setSmeltExp(curExp);
    }

    /**
     * 最大熔炼经验
     *
     * @param part
     * @param staticPart
     * @return int
     */
    private int getPartTotalExp(Part part, StaticPart staticPart) {
        int exp = part.getSmeltExp();
        for (int i = 0; i < part.getSmeltLv(); i++) {
            exp += staticPart.getSmeltExp().get(i);
        }
        return exp;
    }

    /**
     * 淬炼配件
     *
     * @param req
     * @param handler
     */
    public void smeltPart(SmeltPartRq req, ClientHandler handler) {
        int keyId = req.getKeyId();
        int pos = req.getPos();

        if (pos < 0 || pos > 4) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }

        Player player = playerDataManager.getPlayer(handler.getRoleId());
        Map<Integer, Part> map = player.parts.get(pos);
        if (CheckNull.isEmpty(map)) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }

        if (player.lord.getLevel() < Constant.SMELT_PLAYER_LV) {
            handler.sendErrorMsgToPlayer(GameError.LV_NOT_ENOUGH);
            return;
        }

        Part part = map.get(keyId);
        if (part == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_PART);
            return;
        }

        StaticPart staticPart = staticPartDataMgr.getStaticPart(part.getPartId());
        if (staticPart == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }

        // 3）蓝紫橙级别配件可淬炼。
        if (staticPart.getQuality() < 2 || staticPart.getLvMax() == 0) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }
        StaticPartSmelting smelting = staticPartDataMgr.getStaticPartSmelting(req.getOption());
        if (smelting == null) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }
        int type = smelting.getCost().get(0);
        int id = smelting.getCost().get(1);
        int count = smelting.getCost().get(2);
        if (!playerDataManager.checkPropIsEnougth(player, type, id, count)) {
            handler.sendErrorMsgToPlayer(GameError.RESOURCE_NOT_ENOUGH);
            return;
        }
        refreshSmeltTimes(player);
        Map<Integer, Integer> newAttr = getNewAttr(player, part, staticPart, smelting, handler);
        if (newAttr == null || newAttr.size() == 0) {
            return;
        }
        for (Entry<Integer, Integer> entry : newAttr.entrySet()) {
            Integer[] cVal = part.getSmeltAttr().get(entry.getKey());
            if (cVal == null) {
                cVal = new Integer[]{0, 0};
                part.getSmeltAttr().put(entry.getKey(), cVal);
            }
            cVal[1] = entry.getValue();
        }
        part.setSaved(false);

        int expMult = getSmeltExpMultInActivity(player, smelting);
        int kryptonCount = getSmeltPartMasterActivity(player, smelting, 1);

        addSmeltPartExp(part, staticPart, smelting.getExp() * expMult);

        CommonPb.Atom2 atom2 = playerDataManager.subProp(player, type, id, count, AwardFrom.SMELT_PART);

        SmeltPartRs.Builder builder = SmeltPartRs.newBuilder();
        builder.setSmeltLv(part.getSmeltLv());
        builder.setSmeltExp(part.getSmeltExp());
        builder.addAtom2(atom2);
        for (Entry<Integer, Integer[]> entry : part.getSmeltAttr().entrySet()) {
            PartSmeltAttr.Builder attr = PartSmeltAttr.newBuilder();
            attr.setId(entry.getKey());
            attr.setVal(entry.getValue()[0]);
            attr.setNewVal(entry.getValue()[1]);
            builder.addAttr(attr);
        }
        builder.setSaved(part.isSaved());
        builder.setExpMult(expMult);
        if (kryptonCount > 0) {
            builder.setKrypton(PbHelper.createAwardPb(AwardType.ACTIVITY_PROP, ActPropIdConst.ID_KRYPTON_GOLD, kryptonCount));
        }
        handler.sendMsgToPlayer(SmeltPartRs.ext, builder.build());
        LogLordHelper.part(AwardFrom.SMELT_PART, player.account, player.lord, part);
    }

    /***
     * 保存淬炼属性
     *
     * @param req
     * @param handler
     */
    public void saveSmeltPart(SaveSmeltPartRq req, ClientHandler handler) {
        int keyId = req.getKeyId();
        int pos = req.getPos();

        if (pos < 0 || pos > 4) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }

        Player player = playerDataManager.getPlayer(handler.getRoleId());
        Map<Integer, Part> map = player.parts.get(pos);
        if (CheckNull.isEmpty(map)) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }

        Part part = map.get(keyId);
        if (part == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_PART);
            return;
        }

        if (!part.isSaved()) {
            for (Entry<Integer, Integer[]> entry : part.getSmeltAttr().entrySet()) {
                entry.getValue()[0] = entry.getValue()[1];
                entry.getValue()[1] = 0;
            }
            part.setSaved(true);
        }

        // 保存成功
        SaveSmeltPartRs.Builder builder = SaveSmeltPartRs.newBuilder();
        for (Entry<Integer, Integer[]> entry : part.getSmeltAttr().entrySet()) {
            PartSmeltAttr.Builder attr = PartSmeltAttr.newBuilder();
            attr.setId(entry.getKey());
            attr.setVal(entry.getValue()[0]);
            attr.setNewVal(entry.getValue()[1]);
            builder.addAttr(attr);
        }
        builder.setSaved(part.isSaved());
        handler.sendMsgToPlayer(SaveSmeltPartRs.ext, builder.build());
        LogLordHelper.part(AwardFrom.SMELT_PART, player.account, player.lord, part);
        // 重新计算玩家最强实力
        if (pos > 0) {
            playerEventService.calcStrongestFormAndFight(player);
        }
    }

    /***
     * 10淬炼
     *
     * @param req
     * @param handler
     */
    public void tenSmeltPart(TenSmeltPartRq req, ClientHandler handler) {
        int keyId = req.getKeyId();
        int pos = req.getPos();
        List<Integer> saveId = req.getSaveAttrIdList();
        int times = req.getTimes();

        if (pos < 0 || pos > 4) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }

        if (times != 10 && times != 100 && times != 1000) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        Map<Integer, Part> map = player.parts.get(pos);
        if (CheckNull.isEmpty(map)) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }

        if (player.lord.getLevel() < Constant.SMELT_PLAYER_LV) {
            handler.sendErrorMsgToPlayer(GameError.LV_NOT_ENOUGH);
            return;
        }

        Part part = map.get(keyId);
        if (part == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_PART);
            return;
        }

        StaticPart staticPart = staticPartDataMgr.getStaticPart(part.getPartId());
        if (staticPart == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }

        // 3）蓝紫橙级别配件可淬炼。
        if (staticPart.getQuality() < 2 || staticPart.getLvMax() == 0) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }
        StaticPartSmelting smelting = staticPartDataMgr.getStaticPartSmelting(req.getOption());
        if (smelting == null) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }
        int type = smelting.getCost().get(0);
        int id = smelting.getCost().get(1);
        long count = smelting.getCost().get(2) * times;
        if (!playerDataManager.checkPropIsEnougth(player, type, id, count)) {
            handler.sendErrorMsgToPlayer(GameError.RESOURCE_NOT_ENOUGH);
            return;
        }
        refreshSmeltTimes(player);
        // 开始前属性
        Map<Integer, Integer> oldAttr = new HashMap<>();
        for (Entry<Integer, Integer[]> entry : part.getSmeltAttr().entrySet()) {
            oldAttr.put(entry.getKey(), entry.getValue()[0]);
        }
        TenSmeltPartRs.Builder builder = TenSmeltPartRs.newBuilder();
        PartSmeltRecord.Builder record = PartSmeltRecord.newBuilder();
        CommonPb.Kv.Builder kvb = CommonPb.Kv.newBuilder();
        // 连续淬炼N次
        int addExp = 0;
        for (int i = 0; i < times; i++) {
            Map<Integer, Integer> newAttr = getNewAttr(player, part, staticPart, smelting, handler);
            if (newAttr == null || newAttr.size() == 0) {
                return;
            }
            record.setSave(false);
            // 满足条件id
            Set<Integer> meetCondiId = new HashSet<>();
            for (Entry<Integer, List<Integer>> entry : staticPart.getS_attr().entrySet()) {// 使用表格的顺序显示
                Integer attrId = entry.getKey();
                if (!newAttr.containsKey(attrId)) {
                    continue;
                }
                Integer newVal = newAttr.get(attrId);
                if (newVal == null) {
                    newVal = 0;
                }
                Integer[] cVal = part.getSmeltAttr().get(attrId);
                int oldVal = cVal != null ? cVal[0] : 0;
                if ((newVal == oldVal || newVal > oldVal) && saveId.contains(attrId)) {
                    meetCondiId.add(attrId);
                }
                PartSmeltAttr.Builder recordAttr = PartSmeltAttr.newBuilder();
                recordAttr.setId(attrId);
                recordAttr.setVal(oldVal);
                recordAttr.setNewVal(newVal);
                record.addAttrs(recordAttr);
            }
            if (saveId.size() == 0) {// 未选择保存方式的洗一次保存一次
                record.setSave(true);
            } else if (meetCondiId.containsAll(saveId)) {// 选择指定方式的 根据指定方式保存
                record.setSave(true);
            }
            if (record.getSave()) {
                for (Entry<Integer, Integer> entry : newAttr.entrySet()) {
                    Integer[] cVal = part.getSmeltAttr().get(entry.getKey());
                    if (cVal == null) {
                        cVal = new Integer[]{0, 0};
                        part.getSmeltAttr().put(entry.getKey(), cVal);
                    }
                    cVal[0] = entry.getValue();
                }
            }
            int mult = getSmeltExpMultInActivity(player, smelting);// 本次淬炼的暴击倍数
            int deltExp = mult * smelting.getExp(); // 本次淬炼增加的经验
            addExp += deltExp;
            kvb.setKey(mult);
            kvb.setValue(deltExp);
            record.setCrit(kvb);
            builder.addRecords(record);
            kvb.clear();
            record.clear();
        }
        // 清除以前未保存数据--没有一次保存的也需要清除
        for (Entry<Integer, Integer[]> entry : part.getSmeltAttr().entrySet()) {
            entry.getValue()[1] = 0;
        }
        part.setSaved(true);
        // 增加淬炼经验
        addSmeltPartExp(part, staticPart, addExp);
        // 淬炼大师活动获得氪金数量
        int kryptonCount = getSmeltPartMasterActivity(player, smelting, times);
        CommonPb.Atom2 atom2 = playerDataManager.subProp(player, type, id, count, AwardFrom.TEN_SMELT_PART);
        // 淬炼结果
        PartSmeltRecord.Builder result = PartSmeltRecord.newBuilder();
        result.setSave(true);
        for (Entry<Integer, List<Integer>> entry : staticPart.getS_attr().entrySet()) {// 使用表格的顺序显示
            int attrId = entry.getKey();
            if (!part.getSmeltAttr().containsKey(attrId)) {
                continue;
            }
            Integer[] cVal = part.getSmeltAttr().get(attrId);
            Integer newVal = cVal != null ? cVal[0] : 0;

            Integer oVal = oldAttr.get(attrId);
            Integer oldVal = oVal != null ? oVal : 0;

            PartSmeltAttr.Builder recordAttr = PartSmeltAttr.newBuilder();
            recordAttr.setId(attrId);
            recordAttr.setVal(oldVal);
            recordAttr.setNewVal(newVal);
            result.addAttrs(recordAttr);
        }
        builder.setResult(result);
        builder.setSmeltLv(part.getSmeltLv());
        builder.setSmeltExp(part.getSmeltExp());
        builder.addAtom2(atom2);
        builder.setSaved(part.isSaved());
        if (kryptonCount > 0) {
            builder.setKrypton(PbHelper.createAwardPb(AwardType.ACTIVITY_PROP, ActPropIdConst.ID_KRYPTON_GOLD, kryptonCount));
        }
        for (Entry<Integer, Integer[]> entry : part.getSmeltAttr().entrySet()) {
            PartSmeltAttr.Builder attr = PartSmeltAttr.newBuilder();
            attr.setId(entry.getKey());
            attr.setVal(entry.getValue()[0]);
            attr.setNewVal(entry.getValue()[1]);
            builder.addAttr(attr);
        }
        handler.sendMsgToPlayer(TenSmeltPartRs.ext, builder.build());
        LogLordHelper.part(AwardFrom.TEN_SMELT_PART, player.account, player.lord, part);
    }

    /**
     * 配件进阶品质
     *
     * @param req
     * @param handler
     */
    public void partQualityUp(PartQualityUpRq req, ClientHandler handler) {
        int keyId = req.getKeyId();
        int pos = req.getPos();

        Player player = playerDataManager.getPlayer(handler.getRoleId());
        Map<Integer, Part> map = player.parts.get(pos);
        if (CheckNull.isEmpty(map)) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }

        Part part = map.get(keyId);
        if (part == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_PART);
            return;
        }

        StaticPartQualityUp staticPartQualityUp = staticPartDataMgr.getStaticPartQualityUp(part.getPartId());
        if (pos < 0 || pos > 4 || staticPartQualityUp == null) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }

        StaticPart staticPart = staticPartDataMgr.getStaticPart(part.getPartId());
        if (staticPart == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }

        if (staticPart.getQuality() != 3 || part.getRefitLv() < 4) { // 非紫色品质 改造等级4以上的 不能进阶
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }

        List<List<Integer>> costlist = staticPartQualityUp.getCostList();
        for (List<Integer> list : costlist) {
            if (!playerDataManager.checkPropIsEnougth(player, list.get(0), list.get(1), list.get(2))) {
                handler.sendErrorMsgToPlayer(GameError.RESOURCE_NOT_ENOUGH);
                return;
            }
        }

        PartQualityUpRs.Builder builder = PartQualityUpRs.newBuilder();

        long discontStone = (long) (staticPartDataMgr.getUpCost(part.getPartId(), part.getUpLv())
                * staticPartQualityUp.getDiscont() / NumberHelper.HUNDRED_INT);

        Map<Integer, Map<Integer, Integer>> mapAward = new HashMap<>();
        /**
         * 判断当前配件是否为9-10位的配件
         */
        boolean nineOrTen = checkNineOrTenPart(part);
        for (int i = 1; i <= part.getRefitLv(); i++) {
            StaticPartRefit staticPartRefit = staticPartDataMgr.getStaticPartRefit(staticPart.getQuality(), i, nineOrTen);
            addMapNum(mapAward, AwardType.PART_MATERIAL, 1, staticPartRefit.getFitting());
            addMapNum(mapAward, AwardType.PART_MATERIAL, 3, staticPartRefit.getPlan());
            addMapNum(mapAward, AwardType.PART_MATERIAL, 4, staticPartRefit.getMineral());
            addMapNum(mapAward, AwardType.PART_MATERIAL, 5, staticPartRefit.getTool());

            for (List<Integer> award : staticPartRefit.getCost()) {
                addMapNum(mapAward, award.get(0), award.get(1), award.get(2));
            }
        }

        List<CommonPb.Award> awards = new ArrayList<>();
        for (Entry<Integer, Map<Integer, Integer>> entry : mapAward.entrySet()) {
            int type = entry.getKey();
            Map<Integer, Integer> entryMap = entry.getValue();
            for (Entry<Integer, Integer> entry1 : entryMap.entrySet()) {
                List<Integer> award = new ArrayList<>();
                award.add(type);
                award.add(entry1.getKey());
                award.add(entry1.getValue());

                awards.add(playerDataManager.addAwardBackPb(player, award, AwardFrom.UP_PART_QUALITY));
            }
        }
        builder.addAllAward(awards);
        builder.addAtom2(playerDataManager.modifyStone(player, discontStone, AwardFrom.UP_PART_QUALITY));
        for (List<Integer> list2 : costlist) {
            builder.addAtom2(playerDataManager.subProp(player, list2.get(0), list2.get(1), list2.get(2),
                    AwardFrom.UP_PART_QUALITY));
        }
        int totolExp = getPartTotalExp(part, staticPart); // 计算之前的总共的淬炼经验
        part.setPartId(staticPartQualityUp.getTransformPart());
        part.setUpLv(0);
        part.setRefitLv(0);
        part.setSmeltLv(0);
        part.setSmeltExp(0);
        addSmeltPartExp(part, staticPartDataMgr.getStaticPart(staticPartQualityUp.getTransformPart()), totolExp); // 从新换算淬炼等级
        builder.setPartId(part.getPartId());
        builder.setUpLv(part.getUpLv());
        builder.setRefitLv(part.getRefitLv());
        builder.setSmeltExp(part.getSmeltExp());
        builder.setSmeltLv(part.getSmeltLv());
        handler.sendMsgToPlayer(PartQualityUpRs.ext, builder.build());
        LogLordHelper.part(AwardFrom.UP_PART_QUALITY, player.account, player.lord, part);

        if (pos > 0) {
            // 重新计算玩家最强实力
            playerEventService.calcStrongestFormAndFight(player);
        }

        chatService.sendWorldChat(chatService.createSysChat(SysChatId.PART_QUALITY_UP, player.lord.getNick(),
                String.valueOf(staticPartQualityUp.getPartId()),
                String.valueOf(staticPartQualityUp.getTransformPart())));
    }

    /**
     * 增加物品数量
     *
     * @param map   key1=type key2=id value2=count
     * @param type
     * @param id
     * @param count void
     */
    private void addMapNum(Map<Integer, Map<Integer, Integer>> map, int type, int id, int count) {
        if (count <= 0) {
            return;
        }
        Map<Integer, Integer> map2 = map.get(type);
        if (map2 == null) {
            map2 = new HashMap<>();
            map.put(type, map2);
        }
        Integer curCount = map2.get(id);
        if (curCount == null) {
            curCount = 0;
        }
        curCount += count;
        map2.put(id, curCount);
    }

    /**
     * 获取参与活动后的淬炼经验
     *
     * @param player
     * @return
     * @StaticPartSmelting 淬炼配置
     */
    private int getSmeltExpMultInActivity(Player player, StaticPartSmelting partSmelting) {
        Activity smeltExpCritAct = activityDataManager.getActivityInfo(player, ActivityConst.ACT_SMELT_CRIT_EXP);
        if (smeltExpCritAct == null) {
            return 1;
        }
        TreeMap<Integer, StaticActPartCrit> critMap = staticActivityDataMgr.getPartCritMap(ActivityConst.ACT_SMELT_CRIT_EXP);
        StaticActPartCrit data = critMap != null ? critMap.get(partSmelting.getKind()) : null;
        if (data == null) {
            return partSmelting.getExp();
        }
        List<Integer> list = RandomHelper.getRandomByWeight(data.getCrit(), 1);
        return list.get(0);

    }

    /**
     * 淬炼大师活动
     *
     * @param player
     */
    private int getSmeltPartMasterActivity(Player player, StaticPartSmelting partSmelting, int times) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_PART_SMELT_MASTER);
        if (activityBase == null || activityBase.getStep() != ActivityConst.OPEN_STEP)
            return 0;
        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_PART_SMELT_MASTER);
        if (activity == null)
            return 0;
        StaticActPartMaster data = staticActivityDataMgr.getPartSmeltMaster(partSmelting.getKind());
        if (data == null)
            return 0;
        int totalNumber = 0;
        for (int i = 0; i < times; i++) {
            int randomNumber = RandomHelper.getRandomByWeight(data.getProb(), 1).get(0);
            if (randomNumber > 0) {
                totalNumber += randomNumber;
            }
        }
        Integer oldCount = activity.getPropMap().get(ActPropIdConst.ID_KRYPTON_GOLD);
        activity.getPropMap().put(ActPropIdConst.ID_KRYPTON_GOLD, (oldCount != null ? oldCount : 0) + totalNumber);
        return totalNumber;
    }

    /**
     * 配件转换
     *
     * @param handler
     * @param rq
     */
    public void partConvert(ClientHandler handler, PartConvertRq rq) {
        int pos = rq.getPos();
        int pos2 = rq.getPos2();

        Player player = playerDataManager.getPlayer(handler.getRoleId());

        // 配件转换开放等级限制
        if (player.lord.getLevel() < 60) {
            handler.sendErrorMsgToPlayer(GameError.PART_LEVEL_NOT_ENOUGH);
            return;
        }

        // vip等级限制
        if (player.lord.getVip() < 5) {
            handler.sendErrorMsgToPlayer(GameError.PART_VIP_NOT_ENOUGH);
            return;
        }

        Map<Integer, Part> map = player.parts.get(pos);
        Map<Integer, Part> map2 = player.parts.get(pos2);

        // 只能转换已装配的配件，对于仓库中的配件不支持
        if (CheckNull.isEmpty(map) || CheckNull.isEmpty(map2) || pos == 0 || pos2 == 0 || pos == pos2) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }

        List<TwoInt> keyIds = rq.getKeyIdsList();

        int gold = 0;

        // 计算需要花费的金币总额
        for (TwoInt keyId : keyIds) {
            int keyId1 = keyId.getV1();
            int keyId2 = keyId.getV2();
            Part part1 = map.get(keyId1);
            Part part2 = map2.get(keyId2);

            if (part1 == null || part2 == null) {
                handler.sendErrorMsgToPlayer(GameError.NO_PART);
                return;
            }

            if (!part1.isSaved() || !part2.isSaved()) {
                handler.sendErrorMsgToPlayer(GameError.PART_LOCKED);
                return;
            }

            if (part1.isLocked() || part2.isLocked()) {
                handler.sendErrorMsgToPlayer(GameError.PART_LOCKED);
                return;
            }

            StaticPart staticPart1 = staticPartDataMgr.getStaticPart(part1.getPartId());
            StaticPart staticPart2 = staticPartDataMgr.getStaticPart(part2.getPartId());

            if (staticPart1 == null || staticPart2 == null) {
                handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
                return;
            }

            // 配件品质要求
            if (staticPart1.getQuality() < 3 || staticPart2.getQuality() < 3) {
                handler.sendErrorMsgToPlayer(GameError.PART_QUALITY_NOT_ENOUGH);
                return;
            }

            // 根据策划配表，两者相差100则表示不是同一个部位
            if (Math.abs(part1.getPartId() - part2.getPartId()) >= 100) {
                handler.sendErrorMsgToPlayer(GameError.PART_NOT_SAME_POS);
                return;
            }

            if (staticPart1.getQuality() > 3 || staticPart2.getQuality() > 3) {
                gold += 800;
            } else {
                gold += 500;
            }
        }

        // 金币不足以完成转换需求
        if (player.lord.getGold() < gold) {
            handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
            return;
        }

        // 扣除金币
        playerDataManager.subGold(player, gold, AwardFrom.PART_CONVERT);

        PartConvertRs.Builder builder = PartConvertRs.newBuilder();


        for (TwoInt keyId : keyIds) {
            int keyId1 = keyId.getV1();
            int keyId2 = keyId.getV2();
            Part part1 = map.get(keyId1);
            Part part2 = map2.get(keyId2);

            StaticPart staticPart1 = staticPartDataMgr.getStaticPart(part1.getPartId());
            StaticPart staticPart2 = staticPartDataMgr.getStaticPart(part2.getPartId());

            LogUtil.common("partConvert start : roleId=" + player.lord.getLordId() + " keyId=" + keyId + " pos=" + pos
                    + " partId=" + part1.getPartId() + " " + JSON.toJSONString(part1) + " " + " keyId=" + keyId2
                    + " pos=" + pos2 + " partId=" + part2.getPartId() + " " + JSON.toJSONString(part2));

            // 不同品质的配件转换后，需要更改 partId 以与配置表对应(根据策划表写死)
            if (staticPart1.getQuality() > staticPart2.getQuality()) {
                part1.setPartId(part1.getPartId() - 1);
                part2.setPartId(part2.getPartId() + 1);
            } else if (staticPart1.getQuality() < staticPart2.getQuality()) {
                part1.setPartId(part1.getPartId() + 1);
                part2.setPartId(part2.getPartId() - 1);
            }

            Part tempPart = new Part(part1.getKeyId(), part1.getPartId(), part1.getUpLv(), part1.getRefitLv(),
                    part1.getPos(), part1.isLocked(), part1.getSmeltLv(), part1.getSmeltExp(), part1.getSmeltAttr(),
                    part1.isSaved());

            part1.partConvert(part2);
            part2.partConvert(tempPart);

            LogUtil.common("partConvert finish : roleId=" + player.lord.getLordId() + " keyId=" + keyId + " pos=" + pos
                    + " partId=" + part1.getPartId() + " " + JSON.toJSONString(part1) + " " + " keyId=" + keyId2
                    + " pos=" + pos2 + " partId=" + part2.getPartId() + " " + JSON.toJSONString(part2));

            builder.addNewPartId(PbHelper.createTwoIntPb(part1.getKeyId(), part1.getPartId()));
            builder.addNewPartId(PbHelper.createTwoIntPb(part2.getKeyId(), part2.getPartId()));
        }

        builder.setGold(player.lord.getGold());
        handler.sendMsgToPlayer(PartConvertRs.ext, builder.build());

        attackEffectService.unLockAttackEffect(player);

    }
}
