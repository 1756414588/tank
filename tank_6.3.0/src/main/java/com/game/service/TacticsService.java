package com.game.service;

import com.game.constant.AwardFrom;
import com.game.constant.AwardType;
import com.game.constant.GameError;
import com.game.dataMgr.StaticTacticsDataMgr;
import com.game.domain.Player;
import com.game.domain.p.*;
import com.game.domain.s.StaticTank;
import com.game.domain.s.tactics.*;
import com.game.fight.domain.AttrData;
import com.game.fight.domain.Fighter;
import com.game.fight.domain.Force;
import com.game.manager.PlayerDataManager;
import com.game.manager.SeniorMineDataManager;
import com.game.manager.WorldDataManager;
import com.game.message.handler.ClientHandler;
import com.game.pb.BasePb;
import com.game.pb.CommonPb;
import com.game.pb.GamePb6;
import com.game.server.GameServer;
import com.game.util.LogLordHelper;
import com.game.util.LogUtil;
import com.game.util.MapUtil;
import com.game.util.PbHelper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.*;

/**
 * 战术大师
 */
@Service
public class TacticsService {

    @Autowired
    private StaticTacticsDataMgr staticTacticsDataMgr;
    @Autowired
    private PlayerDataManager playerDataManager;
    @Autowired
    private RewardService rewardService;
    @Autowired
    private FightService fightService;
    @Autowired
    private WorldDataManager worldDataManager;
    @Autowired
    private SeniorMineDataManager mineDataManager;

    /**
     * 获取战术
     *
     * @param rq
     * @param handler
     */
    public void getTacticsRq(GamePb6.GetTacticsRq rq, ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());

        TacticsInfo tacticsInfo = player.tacticsInfo;

        GamePb6.GetTacticsRs.Builder builder = GamePb6.GetTacticsRs.newBuilder();

        Collection<Tactics> tactics = tacticsInfo.getTacticsMap().values();


        //战术
        for (Tactics t : tactics) {
            builder.addTactics(PbHelper.createTactics(t));
        }

        //碎片
        Set<Map.Entry<Integer, Integer>> entries = tacticsInfo.getTacticsSliceMap().entrySet();
        for (Map.Entry<Integer, Integer> e : entries) {
            builder.addTacticsSlice(PbHelper.createTwoIntPb(e.getKey(), e.getValue()));
        }


        //战术材料
        Set<Map.Entry<Integer, Integer>> items = tacticsInfo.getTacticsItemMap().entrySet();
        for (Map.Entry<Integer, Integer> e : items) {
            builder.addTacticsItem(PbHelper.createTwoIntPb(e.getKey(), e.getValue()));
        }

        Map<Integer, List<Integer>> tacticsForm = tacticsInfo.getTacticsForm();
        for (Integer index : tacticsForm.keySet()) {
            CommonPb.TacticsForm.Builder builder1 = CommonPb.TacticsForm.newBuilder();
            builder1.setIndex(index);
            builder1.addAllKeyId(new ArrayList<>(tacticsForm.get(index)));
            builder.addFacticsForm(builder1.build());
        }

        handler.sendMsgToPlayer(GamePb6.GetTacticsRs.ext, builder.build());

    }

    /**
     * 升级
     *
     * @param rq
     * @param handler
     */
    public void upgradeTacticsRq(GamePb6.UpgradeTacticsRq rq, ClientHandler handler) {

        int keyId = rq.getKeyId();
        List<Integer> consumeKeyIdList = rq.getConsumeKeyIdList();
        List<CommonPb.TwoInt> tacticsSliceList = rq.getTacticsSliceList();

        Player player = playerDataManager.getPlayer(handler.getRoleId());
        TacticsInfo tacticsInfo = player.tacticsInfo;
        Tactics tactics = tacticsInfo.getTactics(keyId);
        //数据校验
        if (tactics == null) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }


        //数据校验
        if (consumeKeyIdList.isEmpty() && tacticsSliceList.isEmpty()) {
            StaticTactics consumeTacticsConfig = staticTacticsDataMgr.getTacticsConfig(tactics.getTacticsId());
            StaticTacticsUplv tacticsUplvConfig = staticTacticsDataMgr.getTacticsUplvConfig(consumeTacticsConfig.getQuality(), tactics.getLv());
            if (tactics.getExp() < tacticsUplvConfig.getExpNeed()) {
                handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
                return;
            }
        }

        if (consumeKeyIdList.contains(keyId)) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }


        StaticTactics tacticsConfig = staticTacticsDataMgr.getTacticsConfig(tactics.getTacticsId());

        //说明已经满级了
        if (staticTacticsDataMgr.getTacticsUplvConfig(tacticsConfig.getQuality(), tactics.getLv() + 1) == null) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }


        StaticTacticsUplv tacticsUplvConfig = staticTacticsDataMgr.getTacticsUplvConfig(tacticsConfig.getQuality(), tactics.getLv());

        //说明需要突破了 不能在升级
        if (tacticsUplvConfig.getBreakOn() == 1 && tactics.getState() == 0) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }

        GamePb6.UpgradeTacticsRs.Builder builder = GamePb6.UpgradeTacticsRs.newBuilder();


        List<List<Integer>> item = new ArrayList<>();

        List<Integer> refKeyId = new ArrayList<>();

        //消耗升级
        for (Integer consumeKeyId : consumeKeyIdList) {
            Tactics consumeTactics1 = tacticsInfo.getTactics(consumeKeyId);
            if (consumeTactics1 != null && consumeTactics1.getBind() == 0) {


                //说明已经满级了不需要再吞噬了
                if (staticTacticsDataMgr.getTacticsUplvConfig(tacticsConfig.getQuality(), tactics.getLv() + 1) == null) {
                    continue;
                }

                StaticTactics consumeTacticsConfig = staticTacticsDataMgr.getTacticsConfig(consumeTactics1.getTacticsId());
                StaticTacticsUplv consumeTacticsUplvConfig = staticTacticsDataMgr.getTacticsUplvConfig(consumeTacticsConfig.getQuality(), consumeTactics1.getLv());

                //增加exp
                tactics.setExp(tactics.getExp() + consumeTactics1.getExp() + consumeTacticsUplvConfig.getExpOffer());

                //删除吞噬的战术
                removeTactics(player, consumeKeyId, AwardFrom.UPGRADE_TACTICS);

                List<List<Integer>> tpItem = staticTacticsDataMgr.getTpItem(consumeTactics1.getTacticsId(), consumeTacticsConfig.getQuality(), consumeTactics1.getLv(), consumeTactics1.getState() == 1, consumeTacticsConfig.getTacticstype(), 0.8f);
                if (tpItem != null) {
                    item.addAll(tpItem);
                }

                //做升级
                upgradeLevel(tactics, player);

                builder.addConsumeKeyId(consumeKeyId);
                refKeyId.add(consumeKeyId);
            }
        }


        //消耗升级
        for (CommonPb.TwoInt slice : tacticsSliceList) {

            int sliceId = slice.getV1();
            int sliceCount = slice.getV2();

            int itemCount = 0;

            if (tacticsInfo.getTacticsSliceMap().containsKey(sliceId)) {
                itemCount = tacticsInfo.getTacticsSliceMap().get(sliceId);
            }

            if (itemCount < sliceCount) {
                continue;
            }


            //说明已经满级了不需要再吞噬了
            if (staticTacticsDataMgr.getTacticsUplvConfig(tacticsConfig.getQuality(), tactics.getLv() + 1) == null) {
                continue;
            }
            StaticTactics consumeTacticsConfig = staticTacticsDataMgr.getTacticsConfig(sliceId);
            //增加exp
            tactics.setExp(tactics.getExp() + consumeTacticsConfig.getChipExpOffer() * sliceCount);

            removeTacticsSlice(player, sliceId, sliceCount, AwardFrom.UPGRADE_TACTICS);
            //做升级
            upgradeLevel(tactics, player);

        }

        if (consumeKeyIdList.isEmpty() && tacticsSliceList.isEmpty()) {
            //做升级
            upgradeLevel(tactics, player);
        }


        if (!item.isEmpty()) {
            rewardService.addItem(player, AwardFrom.UPGRADE_TACTICS, item);
            for (List<Integer> it : item) {
                int type = it.get(0);
                int count = it.get(2);
                int itemId = it.get(1);
                builder.addAward(PbHelper.createAwardPb(type, itemId, count));
            }
        }


        //如果佩戴的战术被消耗了 就刷新这个阵型
        refreshForm(player, refKeyId);

        //碎片
        Set<Map.Entry<Integer, Integer>> entries = tacticsInfo.getTacticsSliceMap().entrySet();
        for (Map.Entry<Integer, Integer> e : entries) {
            builder.addTacticsSlice(PbHelper.createTwoIntPb(e.getKey(), e.getValue()));
        }
        builder.setTactics(PbHelper.createTactics(tactics));
        handler.sendMsgToPlayer(GamePb6.UpgradeTacticsRs.ext, builder.build());

    }


    /**
     * 递归升级
     *
     * @param tactics
     */
    public void upgradeLevel(Tactics tactics, Player player) {
        StaticTactics tacticsConfig = staticTacticsDataMgr.getTacticsConfig(tactics.getTacticsId());
        StaticTacticsUplv tacticsUplvConfig = staticTacticsDataMgr.getTacticsUplvConfig(tacticsConfig.getQuality(), tactics.getLv());

        //说明需要突破了 保存exp  不在升级
        if (tacticsUplvConfig.getBreakOn() == 1) {
            if (tactics.getState() == 0) {
                return;
            }
        }

        //如果exp够升级 就需要做升级操作
        if (tactics.getExp() >= tacticsUplvConfig.getExpNeed()) {
            //满级经验溢出的 不在做升级操作
            if (staticTacticsDataMgr.getTacticsUplvConfig(tacticsConfig.getQuality(), tactics.getLv() + 1) == null) {
                return;
            }
            tactics.setState(0);
            tactics.setLv(tactics.getLv() + 1);
            tactics.setExp(tactics.getExp() - tacticsUplvConfig.getExpNeed());
            //打印升级日志
            LogLordHelper.tacticsChange(AwardFrom.UPGRADE_TACTICS, player, 3, tactics);
            //exp >0 在做一次升级操作
            if (tactics.getExp() > 0) {
                upgradeLevel(tactics, player);
            }

        }
    }


    /**
     * 突破
     *
     * @param rq
     * @param handler
     */
    public void tpTacticsRq(GamePb6.TpTacticsRq rq, ClientHandler handler) {
        int keyId = rq.getKeyId();
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        TacticsInfo tacticsInfo = player.tacticsInfo;
        Tactics tactics = tacticsInfo.getTactics(keyId);

        //参数校验
        if (tactics == null) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }

        StaticTactics tacticsConfig = staticTacticsDataMgr.getTacticsConfig(tactics.getTacticsId());
        StaticTacticsUplv tacticsUplvConfig = staticTacticsDataMgr.getTacticsUplvConfig(tacticsConfig.getQuality(), tactics.getLv());


        //不符合突破
        if (tacticsUplvConfig.getBreakOn() != 1 || tactics.getState() == 1) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }

        StaticTacticsBreak tacticsBreakConfig = staticTacticsDataMgr.getStaticTacticsBreakConfig(tacticsConfig.getQuality(), tacticsConfig.getTacticstype(), tactics.getLv());

        //消耗物品验证
        if (!rewardService.checkItem(player, tacticsBreakConfig.getBreakNeed())) {
            handler.sendErrorMsgToPlayer(GameError.PROP_NOT_ENOUGH);
            return;
        }
        int breakChips = tacticsBreakConfig.getBreakChips();
        GamePb6.TpTacticsRs.Builder builder = GamePb6.TpTacticsRs.newBuilder();
        if (breakChips > 0) {
            if (!checkTacticsSlice(player, tactics.getTacticsId(), breakChips)) {
                handler.sendErrorMsgToPlayer(GameError.PROP_NOT_ENOUGH);
                return;
            }
            builder.addAtom2(playerDataManager.subProp(player, AwardType.TACTICS_SLICE, tactics.getTacticsId(), breakChips, AwardFrom.UPGRADE_TACTICS));
        }

        for (List<Integer> it : tacticsBreakConfig.getBreakNeed()) {
            int type = it.get(0);
            int itemId = it.get(1);
            int count = it.get(2);
            builder.addAtom2(playerDataManager.subProp(player, type, itemId, count, AwardFrom.UPGRADE_TACTICS));
        }

        tactics.setState(1);
        //做升级
//        upgradeLevel(tactics, player);
        LogLordHelper.tacticsChange(AwardFrom.COMPOSE_TUPO, player, 3, tactics);
        builder.setTactics(PbHelper.createTactics(tactics));
        handler.sendMsgToPlayer(GamePb6.TpTacticsRs.ext, builder.build());
    }

    /**
     * 进阶
     *
     * @param rq
     * @param handler
     */
    public void advancedTacticsRq(GamePb6.AdvancedTacticsRq rq, ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());


    }

    /**
     * 设置战术阵型
     *
     * @param rq
     * @param handler
     */
    public void setTacticsFormRq(GamePb6.SetTacticsFormRq rq, ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());

        int index = rq.getIndex();


        if (index < 1 && index > 8) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }

        List<Integer> keyIdList = rq.getKeyIdList();

        if (keyIdList.size() > 6) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }

        for (Integer keyId : keyIdList) {
            if (keyId != 0) {
                Tactics tactics = player.tacticsInfo.getTacticsMap().get(keyId);
                if (tactics == null) {
                    handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
                    return;
                }
            }
        }

        player.tacticsInfo.getTacticsForm().put(index, new ArrayList<>(keyIdList));

        GamePb6.SetTacticsFormRs.Builder builder = GamePb6.SetTacticsFormRs.newBuilder();
        builder.setIndex(index);
        builder.addAllKeyId(keyIdList);
        handler.sendMsgToPlayer(GamePb6.SetTacticsFormRs.ext, builder.build());

    }


    /**
     * 合成战术
     *
     * @param rq
     * @param handler
     */
    public void composeTacticsRq(GamePb6.ComposeTacticsRq rq, ClientHandler handler) {

        int tacticsId = rq.getTacticsId();
        StaticTactics tacticsConfig = staticTacticsDataMgr.getTacticsConfig(tacticsId);

        if (tacticsConfig == null || tacticsConfig.getChipCount() <= 0) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }

        Player player = playerDataManager.getPlayer(handler.getRoleId());

        TacticsInfo tacticsInfo = player.tacticsInfo;

        //升级必须要有一个 不是万能碎片
        if (!tacticsInfo.getTacticsSliceMap().containsKey(tacticsId)) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }

        int count = tacticsInfo.getTacticsSliceMap().get(tacticsId);
        if (count <= 0) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }

        Map<Integer, Integer> consumeItemMap = new HashMap<>();

        //说明需要万能碎片补齐
        if (count < tacticsConfig.getChipCount()) {
            consumeItemMap.put(tacticsId, count);
            StaticTactics wanNengTacticsConfig = staticTacticsDataMgr.getWanNengTacticsConfig();
            consumeItemMap.put(wanNengTacticsConfig.getTacticsId(), tacticsConfig.getChipCount() - count);

        } else {
            consumeItemMap.put(tacticsId, tacticsConfig.getChipCount());
        }

        if (!checkTacticsSlice(player, consumeItemMap)) {
            handler.sendErrorMsgToPlayer(GameError.PROP_NOT_ENOUGH);
            return;
        }

        //删除材料
        removeTacticsSlice(player, consumeItemMap, AwardFrom.COMPOSE_TACTICS);

        Tactics tacticsList = addTactics(player, tacticsId, 0, AwardFrom.COMPOSE_TACTICS);


        GamePb6.ComposeTacticsRs.Builder builder = GamePb6.ComposeTacticsRs.newBuilder();
        builder.setTactics(PbHelper.createTactics(tacticsList));

        Set<Map.Entry<Integer, Integer>> entries = tacticsInfo.getTacticsSliceMap().entrySet();
        for (Map.Entry<Integer, Integer> e : entries) {
            builder.addTacticsSlice(PbHelper.createTwoIntPb(e.getKey(), e.getValue()));
        }
        handler.sendMsgToPlayer(GamePb6.ComposeTacticsRs.ext, builder.build());

    }


    /**
     * 绑定战术
     *
     * @param rq
     * @param handler
     */
    public void bindTacticsFormRq(GamePb6.BindTacticsFormRq rq, ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        TacticsInfo tacticsInfo = player.tacticsInfo;

        Tactics tactics = tacticsInfo.getTacticsMap().get(rq.getKeyId());

        if (tactics == null) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }
        tactics.setBind(tactics.getBind() == 1 ? 0 : 1);
        GamePb6.BindTacticsFormRs.Builder builder = GamePb6.BindTacticsFormRs.newBuilder();
        builder.setTactics(PbHelper.createTactics(tactics));
        handler.sendMsgToPlayer(GamePb6.BindTacticsFormRs.ext, builder.build());
    }


    /**
     * 添加一个战术
     *
     * @param player
     * @param id
     * @param count  添加数量
     * @param from
     */
    public Tactics addTactics(Player player, int id, int count, AwardFrom from) {
        TacticsInfo tacticsInfo = player.tacticsInfo;

        StaticTactics tacticsConfig = staticTacticsDataMgr.getTacticsConfig(id);
        int maxUpLevel = staticTacticsDataMgr.getMaxUpLevel(tacticsConfig.getQuality());
        if (count > maxUpLevel) {
            count = maxUpLevel;
        }

        //如果多个 说明需要循环加入, 战术是不能叠加的
        Tactics tactics = new Tactics();
        tactics.setKeyId(tacticsInfo.nextKeyid());
        tactics.setTacticsId(id);
        tactics.setLv(count);
        tactics.setExp(0);
        tactics.setUse(0);
        tactics.setState(0);
        tacticsInfo.getTacticsMap().put(tactics.getKeyId(), tactics);
        LogLordHelper.tacticsChange(from, player, 1, tactics);

        return tactics;
    }

    /**
     * 删除一个战术
     *
     * @param player
     * @param keyId
     * @param from
     */
    public void removeTactics(Player player, int keyId, AwardFrom from) {
        TacticsInfo tacticsInfo = player.tacticsInfo;
        if (!tacticsInfo.getTacticsMap().containsKey(keyId)) {
            LogUtil.error("removeTactics roleid=" + player.lord.getLordId() + " keyid=" + keyId);
        } else {
            Tactics tactics = tacticsInfo.getTacticsMap().remove(keyId);
            LogLordHelper.tacticsChange(from, player, 2, tactics);
        }
    }


    /**
     * 添加战术碎片
     *
     * @param player
     * @param id
     * @param count
     * @param from
     */
    public void addTacticsSlice(Player player, int id, int count, AwardFrom from) {

        //防止加入错误数据
        StaticTactics tacticsConfig = staticTacticsDataMgr.getTacticsConfig(id);
        if (tacticsConfig == null) {
            return;
        }

        TacticsInfo tacticsInfo = player.tacticsInfo;
        if (!tacticsInfo.getTacticsSliceMap().containsKey(id)) {
            tacticsInfo.getTacticsSliceMap().put(id, 0);
        }
        tacticsInfo.getTacticsSliceMap().put(id, tacticsInfo.getTacticsSliceMap().get(id) + count);
        LogLordHelper.tacticsItemChange(from, player, 1, AwardType.TACTICS_SLICE, id, count, tacticsInfo.getTacticsSliceMap().get(id));

    }

    /**
     * 删除战术碎片
     *
     * @param player
     * @param id
     * @param count
     * @param from
     */
    public int removeTacticsSlice(Player player, int id, int count, AwardFrom from) {
        TacticsInfo tacticsInfo = player.tacticsInfo;
        if (!tacticsInfo.getTacticsSliceMap().containsKey(id)) {
            LogUtil.error("removeTacticsSlice roleid=" + player.lord.getLordId() + " id=" + id + " count=" + count + " from=" + from.getCode());
            return 0;
        }
        int itemCount = tacticsInfo.getTacticsSliceMap().get(id);
        itemCount = itemCount - count;
        if (itemCount < 0) {
            itemCount = 0;
        }

        if (itemCount > 0) {
            tacticsInfo.getTacticsSliceMap().put(id, itemCount);
        } else {
            tacticsInfo.getTacticsSliceMap().remove(id);
        }

        LogLordHelper.tacticsItemChange(from, player, 2, AwardType.TACTICS_SLICE, id, -count, itemCount);
        return itemCount;
    }

    /**
     * 判断战术碎片是否足够
     *
     * @param player
     * @param item
     * @return
     */
    public void removeTacticsSlice(Player player, Map<Integer, Integer> item, AwardFrom from) {
        Set<Map.Entry<Integer, Integer>> entries = item.entrySet();
        for (Map.Entry<Integer, Integer> e : entries) {
            removeTacticsSlice(player, e.getKey(), e.getValue(), from);
        }
    }

    /**
     * 添加战术材料
     *
     * @param player
     * @param id
     * @param count
     * @param from
     */
    public void addTacticsItem(Player player, int id, int count, AwardFrom from) {

        TacticsInfo tacticsInfo = player.tacticsInfo;
        if (!tacticsInfo.getTacticsItemMap().containsKey(id)) {
            tacticsInfo.getTacticsItemMap().put(id, 0);
        }
        tacticsInfo.getTacticsItemMap().put(id, tacticsInfo.getTacticsItemMap().get(id) + count);
        LogLordHelper.tacticsItemChange(from, player, 1, AwardType.TACTICS_ITEM, id, count, tacticsInfo.getTacticsItemMap().get(id));

    }

    /**
     * 删除战术材料
     *
     * @param player
     * @param id
     * @param count
     * @param from
     */
    public int removeTacticsItem(Player player, int id, int count, AwardFrom from) {
        TacticsInfo tacticsInfo = player.tacticsInfo;
        if (!tacticsInfo.getTacticsItemMap().containsKey(id)) {
            LogUtil.error("removeTacticsItem roleid=" + player.lord.getLordId() + " id=" + id + " count=" + count + " from=" + from.getCode());
            return 0;
        }
        int itemCount = tacticsInfo.getTacticsItemMap().get(id);
        itemCount = itemCount - count;
        if (itemCount < 0) {
            itemCount = 0;
        }

        if (itemCount > 0) {
            tacticsInfo.getTacticsItemMap().put(id, itemCount);
        } else {
            tacticsInfo.getTacticsItemMap().remove(id);
        }

        LogLordHelper.tacticsItemChange(from, player, 2, AwardType.TACTICS_ITEM, id, -count, itemCount);

        return itemCount;
    }

    /**
     * 判断战术材料是否足够
     *
     * @param player
     * @param id
     * @param count
     * @return
     */
    public boolean checkTacticsItem(Player player, int id, int count) {
        TacticsInfo tacticsInfo = player.tacticsInfo;
        int itemCount = 0;
        if (tacticsInfo.getTacticsItemMap().containsKey(id)) {
            itemCount = tacticsInfo.getTacticsItemMap().get(id);
        }
        return itemCount >= count;
    }

    /**
     * 判断战术碎片是否足够
     *
     * @param player
     * @param id
     * @param count
     * @return
     */
    public boolean checkTacticsSlice(Player player, int id, int count) {
        TacticsInfo tacticsInfo = player.tacticsInfo;
        int itemCount = 0;
        if (tacticsInfo.getTacticsSliceMap().containsKey(id)) {
            itemCount = tacticsInfo.getTacticsSliceMap().get(id);
        }
        return itemCount >= count;
    }

    /**
     * 判断战术碎片是否足够
     *
     * @param player
     * @param item
     * @return
     */
    public boolean checkTacticsSlice(Player player, Map<Integer, Integer> item) {
        Set<Map.Entry<Integer, Integer>> entries = item.entrySet();
        for (Map.Entry<Integer, Integer> e : entries) {

            if (!checkTacticsSlice(player, e.getKey(), e.getValue())) {
                return false;
            }
        }
        return true;
    }

    /**
     * 判断战术是否可以
     * 同类型只能使用3个
     *
     * @param player
     * @param form
     */
    public boolean checkUseTactics(Player player, Form form) {

        if (form.getTactics() == null || form.getTactics().isEmpty()) {
            return true;
        }

        //如果都是 0 就直接返回
        boolean isZero = false;
        for (Integer keyId : form.getTactics()) {
            if (keyId != 0) {
                isZero = true;
                break;
            }
        }

        if (!isZero) {
            return true;
        }

        //有不存在的
        List<Tactics> playerTactics = getPlayerTactics(player, form.getTactics());
        if (playerTactics.isEmpty()) {
            return false;
        }


        Map<Integer, Integer> tempMap = new HashMap<>();
        //重复 或者已经使用
        for (Tactics tactics : playerTactics) {
            if (tempMap.containsKey(tactics.getKeyId())) {
                return false;
            }
            tempMap.put(tactics.getKeyId(), 1);
        }

        if (playerTactics.size() > 3) {
            Map<Integer, Integer> temp = new HashMap<>();
            for (Tactics tactics : playerTactics) {
                StaticTactics tacticsConfig = staticTacticsDataMgr.getTacticsConfig(tactics.getTacticsId());
                if (!temp.containsKey(tacticsConfig.getAttrtype())) {
                    temp.put(tacticsConfig.getAttrtype(), 0);
                }
                temp.put(tacticsConfig.getAttrtype(), temp.get(tacticsConfig.getAttrtype()) + 1);

            }

            for (Integer count : temp.values()) {
                if (count > 3) {
                    return false;
                }
            }

        }

        form.getTacticsList().clear();
        for (Tactics tactics : playerTactics) {
            form.getTacticsList().add(new TowInt(tactics.getTacticsId(), tactics.getLv()));
        }
        return true;
    }

    /**
     * 使用战术
     *
     * @param player
     * @param keyIds
     */
    public void useTactics(Player player, List<Integer> keyIds) {
//        if (keyIds == null || keyIds.isEmpty()) {
//            return;
//        }
//        List<Tactics> tacticsList = getPlayerTactics(player, keyIds);
//        if (tacticsList.isEmpty()) {
//            return;
//        }
//        for (Tactics tactics : tacticsList) {
//            tactics.setUse(1);
//        }
//        syncTacticsInfo(player, tacticsList);
    }

    /**
     * 取消使用战术
     *
     * @param player
     * @param keyIds
     */
    public void cancelUseTactics(Player player, List<Integer> keyIds) {
//        if (keyIds == null || keyIds.isEmpty()) {
//            return;
//        }
//
//        List<Tactics> tacticsList = getPlayerTactics(player, keyIds);
//
//        if (tacticsList.isEmpty()) {
//            return;
//        }
//
//        for (Tactics tactics : tacticsList) {
//            tactics.setUse(0);
//        }
//        syncTacticsInfo(player, tacticsList);
    }

    /**
     * 自动推送同步
     *
     * @param player
     * @param tacticsList
     */
    private void syncTacticsInfo(Player player, List<Tactics> tacticsList) {
        try {

            if (!player.isLogin) {
                return;
            }

            GamePb6.SynTacticsRq.Builder builder = GamePb6.SynTacticsRq.newBuilder();

            for (Tactics tactics : tacticsList) {
                builder.addTactics(PbHelper.createTactics(tactics));
            }

            BasePb.Base.Builder msg = PbHelper.createSynBase(GamePb6.SynTacticsRq.EXT_FIELD_NUMBER, GamePb6.SynTacticsRq.ext, builder.build());
            GameServer.getInstance().synMsgToPlayer(player.ctx, msg);

        } catch (Exception e) {
            LogUtil.error(e);
        }
    }


    /**
     * 获取玩家战术
     *
     * @param player
     * @param tacticsKeyIds
     * @return
     */
    public List<Tactics> getPlayerTactics(Player player, List<Integer> tacticsKeyIds) {


        List<Tactics> result = new ArrayList<>();

        if (player == null) {
            return result;
        }

        if (tacticsKeyIds.isEmpty()) {
            return result;
        }
        TacticsInfo tacticsInfo = player.tacticsInfo;
        for (Integer keyId : tacticsKeyIds) {
            if (keyId == 0) {
                continue;
            }
            Tactics tactics = tacticsInfo.getTacticsMap().get(keyId);
            if (tactics == null) {
                continue;
            }
            result.add(tactics);
        }
        return result;
    }

    /**
     * 战术基础属性
     *
     * @param tacticsList
     * @return
     */
    public Map<Integer, Integer> getBaseAttribute(List<Tactics> tacticsList) {
        Map<Integer, Integer> result = new HashMap<>();
        if (tacticsList.isEmpty()) {
            return result;
        }

        //基础属性 每个部队可装配6个战术 装配战术后，战术携带的属性，附加到当前部队上，战斗时生效
        for (Tactics t : tacticsList) {
            StaticTactics tacticsConfig = staticTacticsDataMgr.getTacticsConfig(t.getTacticsId());
            MapUtil.addMapValue(result, tacticsConfig.getAttrBase());
            MapUtil.multipleAttribute(result, t.getLv(), tacticsConfig.getAttrLv());

        }
        return result;

    }

    /**
     * 战术 全部装配单一效果战术属性
     *
     * @param tacticsList
     * @return
     */
    public Map<Integer, Integer> getTaozhaungAttribute(List<Tactics> tacticsList) {
        Map<Integer, Integer> result = new HashMap<>();
        if (tacticsList.isEmpty()) {
            return result;
        }
        //全部装配单一效果战术，可触发战术套效果 额外增加全兵种的属性
        int tacticstype = getTacticstype(tacticsList);
        StaticTacticsTacticsRestrict tacticsTacticsRestrictConfig = staticTacticsDataMgr.getTacticsTacticsRestrictConfig(tacticstype);
        if (tacticsTacticsRestrictConfig != null) {
            MapUtil.addMapValue(result, tacticsTacticsRestrictConfig.getAttrSuit());
        }
        return result;
    }


    /**
     * 根据玩家战术 获取战术类型  如果不全一样 就返回0
     *
     * @param tacticsList
     * @return
     */
    private int getTacticstype(List<Tactics> tacticsList) {

        if (tacticsList.size() != 6) {
            return 0;
        }

        int tacticstype = 0;

        for (Tactics t : tacticsList) {
            StaticTactics tacticsConfig = staticTacticsDataMgr.getTacticsConfig(t.getTacticsId());
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
     * 战术套属性 克制属性 如果不克制就没有这个属性
     *
     * @param attacker 攻击方
     * @param defencer 防御方
     */
    public void calTacticsRestrictAttribute(Fighter attacker, Fighter defencer) {


        try {
            //佩戴着不同的战术效果是没有额外加成的
            if (attacker.tactics.size() != 6 || defencer.tactics.size() != 6) {
                return;
            }


            //攻击方
            List<Tactics> attackerTactics = getPlayerTactics(attacker.player, attacker.tactics);
            int attackerTacticstype = getTacticstype(attackerTactics);

            if (attackerTacticstype == 0) {
                return;
            }


            //防守方
            List<Tactics> defencerTactics = getPlayerTactics(defencer.player, defencer.tactics);
            int defencerTacticsType = getTacticstype(defencerTactics);
            if (0 == defencerTacticsType) {
                return;
            }


            //攻击方克制了防守方 增加属性
            {
                StaticTacticsTacticsRestrict attackertConfig = staticTacticsDataMgr.getTacticsTacticsRestrictConfig(attackerTacticstype);
                //说明没有克制   克制类型不同 说明没有克制
                if (attackertConfig != null && defencerTacticsType == attackertConfig.getTacticsType2()) {

                    //说明克制了 克制时，装配属性额外提高x%
                    Map<Integer, Integer> attackerAttribute = new HashMap<>();
                    Map<Integer, Integer> baseAttribute = getBaseAttribute(attackerTactics);
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


            //防守方克制了进攻方增加属性
            {
                StaticTacticsTacticsRestrict defencerConfig = staticTacticsDataMgr.getTacticsTacticsRestrictConfig(defencerTacticsType);

                //说明没有克制
                if (defencerConfig != null && attackerTacticstype == defencerConfig.getTacticsType2()) {
                    //克制类型不同 说明没有克制

                    //说明克制了 克制时，装配属性额外提高x%
                    Map<Integer, Integer> defencerAttribute = new HashMap<>();

                    Map<Integer, Integer> attr = getBaseAttribute(defencerTactics);

                    MapUtil.multipleAttribute(attr, (float) (defencerConfig.getAttrUp() / 100.0f), defencerAttribute);

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


    /**
     * 兵种套属性
     *
     * @param tacticsList
     * @return
     */
    public Map<Integer, Integer> getTankTypeAttribute(List<Tactics> tacticsList, StaticTank staticTank) {

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
    public StaticTacticsTankSuit getTankTypeAttributeConfig(List<Tactics> tacticsList) {

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

        StaticTacticsTankSuit config = staticTacticsDataMgr.getStaticTacticsTankSuitConfig(quality, tacticsType, tankType);
        return config;
    }


    /**
     * 兵种套品质，品质向下兼容（如5个紫色，1个蓝色，则是蓝色兵种套效果）
     *
     * @param tacticsList
     * @return
     */
    private int getQuality(List<Tactics> tacticsList) {

        if (tacticsList.size() != 6) {
            return 0;
        }

        int quality = 0;
        for (Tactics t : tacticsList) {
            StaticTactics tacticsConfig = staticTacticsDataMgr.getTacticsConfig(t.getTacticsId());
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
    public int getTankType(List<Tactics> tacticsList) {

        if (tacticsList.size() != 6) {
            return 0;
        }

        int tankType = 0;

        for (Tactics t : tacticsList) {
            StaticTactics tacticsConfig = staticTacticsDataMgr.getTacticsConfig(t.getTacticsId());
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
     * 刷新玩家设置的阵型
     *
     * @param player
     * @param removeKeyIds
     */
    private void refreshForm(Player player, List<Integer> removeKeyIds) {

        try {
            if (removeKeyIds.isEmpty()) {
                return;
            }
            Map<Integer, Form> forms = player.forms;
            for (Integer f : new ArrayList<>(forms.keySet())) {
                Form form = forms.get(f);
                if (!form.getTactics().isEmpty()) {
                    for (Integer keyId : removeKeyIds) {
                        if (form.getTactics().contains(keyId)) {
                            int index = form.getTactics().indexOf(keyId);
                            form.getTactics().set(index, 0);
                            form.getTacticsList().clear();

                            List<Tactics> playerTactics = getPlayerTactics(player, form.getTactics());
                            for (Tactics t : playerTactics) {
                                form.getTacticsList().add(new TowInt(t.getTacticsId(), t.getLv()));
                            }
                        }
                    }

                }
            }
        } catch (Exception e) {
            LogUtil.error(e);
        }


        try {
            Map<Integer, List<Integer>> tacticsForm = player.tacticsInfo.getTacticsForm();
            for (Map.Entry<Integer, List<Integer>> e : tacticsForm.entrySet()) {
                List<Integer> value = e.getValue();
                for (Integer keyId : removeKeyIds) {
                    if (value.contains(keyId)) {
                        int indexOf = value.indexOf(keyId);
                        value.set(indexOf, 0);
                    }
                }
            }
        } catch (Exception e) {
            LogUtil.error(e);
        }


        try {
            List<Army> armys = player.armys;
            for (Army army : armys) {
                int target = army.getTarget();

                if (target != 0) {
                    {
                        Guard mineGuard = worldDataManager.getMineGuard(target);
                        if (mineGuard != null) {
                            Form form = mineGuard.getArmy().getForm();

                            if (form != null) {
                                for (Integer keyId : removeKeyIds) {
                                    if (form.getTactics().contains(keyId)) {
                                        int index = form.getTactics().indexOf(keyId);
                                        form.getTactics().set(index, 0);


                                        form.getTacticsList().clear();
                                        List<Tactics> playerTactics = getPlayerTactics(player, form.getTactics());
                                        for (Tactics t : playerTactics) {
                                            form.getTacticsList().add(new TowInt(t.getTacticsId(), t.getLv()));
                                        }
                                    }
                                }
                            }

                        }
                    }
                    {
                        Guard mineGuard1 = mineDataManager.getMineGuard(target);
                        if (mineGuard1 != null) {
                            Form form = mineGuard1.getArmy().getForm();
                            if (form != null) {
                                for (Integer keyId : removeKeyIds) {
                                    if (form.getTactics().contains(keyId)) {
                                        int index = form.getTactics().indexOf(keyId);
                                        form.getTactics().set(index, 0);

                                        form.getTacticsList().clear();
                                        List<Tactics> playerTactics = getPlayerTactics(player, form.getTactics());
                                        for (Tactics t : playerTactics) {
                                            form.getTacticsList().add(new TowInt(t.getTacticsId(), t.getLv()));
                                        }
                                    }
                                }
                            }

                        }

                    }

                }

            }
        } catch (Exception e) {
            LogUtil.error(e);
        }

    }


    /**
     * 实力榜计算出 最大战力的6个战术
     *
     * @param player
     * @param staticTank
     * @return
     */
    public List<Tactics> getTacticsMaxFight(Player player, final StaticTank staticTank) {

//        long timeMillis = System.currentTimeMillis();

        List<Tactics> result = new ArrayList<>();

        List<Tactics> values = new ArrayList<>(player.tacticsInfo.getTacticsMap().values());
        List<Tactics> tacticsValues = new ArrayList<>();

        for (Tactics t : values) {

            if (t.getLv() > 0) {
                tacticsValues.add(t);
            }

        }


        if (tacticsValues.isEmpty()) {
            return result;
        }


//        for (Tactics t : tacticsValues){
//            Map<Integer, Integer> attr2 = new HashMap<>();
//            StaticTactics tacticsConfig2 = staticTacticsDataMgr.getTacticsConfig(t.getTacticsId());
//            MapUtil.addMapValue(attr2, tacticsConfig2.getAttrBase());
//            MapUtil.multipleAttribute(attr2, t.getLv(), tacticsConfig2.getAttrLv());
//            if (!attr2.isEmpty()) {
//                AttrData attrData2 = new AttrData();
//                for (Map.Entry<Integer, Integer> e : attr2.entrySet()) {
//                    attrData2.addValue(e.getKey(), e.getValue());
//                }
//                int calcNewFight = (int) fightService.calcNewFight(attrData2);
//
//                LogUtil.info("战力  "+t.getKeyId() + "  = "+calcNewFight+"  tacticsId="+t.getTacticsId()+" name="+tacticsConfig2.getTacticsName());
//
//            }
//        }


        Collections.sort(tacticsValues, new Comparator<Tactics>() {
            @Override
            public int compare(Tactics o1, Tactics o2) {

                int fight1 = 0, fight2 = 0;

                Map<Integer, Integer> attr1 = new HashMap<>();
                StaticTactics tacticsConfig1 = staticTacticsDataMgr.getTacticsConfig(o1.getTacticsId());
                MapUtil.addMapValue(attr1, tacticsConfig1.getAttrBase());
                MapUtil.multipleAttribute(attr1, o1.getLv(), tacticsConfig1.getAttrLv());
                if (!attr1.isEmpty()) {
                    AttrData attrData1 = new AttrData();
                    for (Map.Entry<Integer, Integer> e : attr1.entrySet()) {
                        attrData1.addValue(e.getKey(), e.getValue());
                    }
                    fight1 = (int) fightService.calcNewFight(attrData1);
                }

                Map<Integer, Integer> attr2 = new HashMap<>();
                StaticTactics tacticsConfig2 = staticTacticsDataMgr.getTacticsConfig(o2.getTacticsId());
                MapUtil.addMapValue(attr2, tacticsConfig2.getAttrBase());
                MapUtil.multipleAttribute(attr2, o2.getLv(), tacticsConfig2.getAttrLv());
                if (!attr2.isEmpty()) {
                    AttrData attrData2 = new AttrData();
                    for (Map.Entry<Integer, Integer> e : attr2.entrySet()) {
                        attrData2.addValue(e.getKey(), e.getValue());
                    }
                    fight2 = (int) fightService.calcNewFight(attrData2);
                }


//                LogUtil.info(o1.getKeyId() + "  = "+fight1+" TacticsId="+tacticsConfig1.getTacticsId()+" name="+tacticsConfig1.getTacticsName());
//                LogUtil.info(o2.getKeyId() + "  = "+fight2+" TacticsId="+tacticsConfig2.getTacticsId()+" name="+tacticsConfig2.getTacticsName());

                if (fight1 > fight2) {
                    return -1;
                }

                if (fight1 < fight2) {
                    return 1;
                }

                return 0;

            }
        });

//        LogUtil.info(System.currentTimeMillis()-timeMillis);
        if (tacticsValues.size() > 6) {
            return tacticsValues.subList(0, 6);
        } else {
            return tacticsValues;
        }

    }
}
