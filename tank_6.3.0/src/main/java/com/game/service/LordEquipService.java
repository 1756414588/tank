package com.game.service;

import com.alibaba.fastjson.JSON;
import com.game.actor.role.PlayerEventService;
import com.game.constant.*;
import com.game.dataMgr.*;
import com.game.domain.Player;
import com.game.domain.p.LeqScheme;
import com.game.domain.p.Prop;
import com.game.domain.p.lordequip.LordEquip;
import com.game.domain.p.lordequip.LordEquipBuilding;
import com.game.domain.p.lordequip.LordEquipInfo;
import com.game.domain.p.lordequip.LordEquipMatBuilding;
import com.game.domain.s.*;
import com.game.manager.PlayerDataManager;
import com.game.message.handler.ClientHandler;
import com.game.pb.CommonPb;
import com.game.pb.CommonPb.TwoInt;
import com.game.pb.GamePb5;
import com.game.pb.GamePb5.LordEquipChangeFreeTimeRq;
import com.game.pb.GamePb5.LordEquipChangeFreeTimeRs;
import com.game.pb.GamePb5.LordEquipChangeRq;
import com.game.pb.GamePb5.LordEquipChangeRs;
import com.game.pb.GamePb6.*;
import com.game.util.*;
import org.apache.commons.lang3.RandomUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.*;

/**
 * @author zhangdh
 * @ClassName: LordEquipService
 * @Description: 指挥官装备业务
 * @date 2017/4/20 16:42
 */
@Service
public class LordEquipService {

    @Autowired
    private PlayerDataManager playerDataManager;

    @Autowired
    private StaticEquipDataMgr staticEquipDataMgr;

    @Autowired
    private FormulaService productService;

    @Autowired
    private PlayerEventService playerEventService;

    @Autowired
    private StaticFormulaDataMgr staticFormulaDataMgr;

    @Autowired
    private StaticLordDataMgr staticLordDataMgr;

    @Autowired
    private StaticBuildingDataMgr staticBuildingDataMgr;

    @Autowired
    private StaticFunctionPlanDataMgr functionPlanDataMgr;

    @Autowired
    LoadService loadService;
    // ********************材料工坊*******************

    /**
     * 军备材料生产
     *
     * @param handler
     */
    public void productMaterial(GamePb5.ProductLordEquipMatRq req, ClientHandler handler) {
        if (!functionPlanDataMgr.isLordEquipOpen()) {
            handler.sendErrorMsgToPlayer(GameError.LORD_EQUIP_FUNCTION_CLOSE);
            return;// 功能未开放
        }

        Player player = playerDataManager.getPlayer(handler.getRoleId());
        int quality = req.getQuality();// 合成指定品质的材料
        int costId = req.getCostId();// 合成消耗的材料
        if (quality < 1 || costId < 1)
            return;
        StaticBuilding staticBuilding = staticBuildingDataMgr.getStaticBuilding(BuildingId.MATERIAL);
        if (staticBuilding == null || staticBuilding.getCanProduct() == 0)
            return;

        // 生产队列已经满了
        if (player.leqInfo.getLeq_mat_que().size() >= player.leqInfo.getBuyMatCount() + staticBuilding.getProDefault())
            return;

        // 消耗的材料不存在
        StaticLordEquipMaterial staticMaterial = staticEquipDataMgr.getLordEquipMaterial(costId);
        if (staticMaterial == null)
            return;
        Prop prop = player.leqInfo.getLeqMat().get(costId);
        if (prop == null || prop.getCount() == 0)
            return;

        // 合成公式不存在
        int fid = staticEquipDataMgr.getFormulaByQuality(quality);
        if (fid == 0)
            return;
        StaticFormula fla = staticFormulaDataMgr.getFormula(fid);
        if (fla == null || fla.getReward() == null || fla.getReward().isEmpty())
            return;

        // 玩家等级不满足条件
        if (player.lord.getLevel() < fla.getLevel())
            return;

        // 世界繁荣度等级不满足条件
        int prosLv = staticLordDataMgr.getStaticProsLv(player.lord.getPros()).getProsLv();
        if (prosLv < fla.getProsLv())
            return;

        // 消耗的道具
        List<List<Integer>> costList = fla.getMaterials();
        if (costList.size() < 1)
            return;
        // [0]-消耗的类型,[1]-消耗的材料品质,[2]-消耗的数量
        List<Integer> matCost = costList.get(0);
        if (staticMaterial.getQuality() != matCost.get(1) || prop.getCount() < matCost.get(2)) {
            return; // 材料品质不对或数量不足
        }

        List<List<Integer>> finalCost = new ArrayList<>();

        // 其它资源判断
        if (costList.size() > 1) {
            List<List<Integer>> otherCost = costList.subList(1, costList.size());
            for (List<Integer> list : otherCost) {
                if (!playerDataManager.checkPropIsEnougth(player, list.get(0), list.get(1), list.get(2))) {
                    return;
                }
            }
            // 设置需要扣除其他材料
            finalCost.addAll(otherCost);
        }

        // 设置需要扣除的图纸材料
        List<Integer> matCost0 = new ArrayList<>();
        matCost0.add(matCost.get(0));
        matCost0.add(costId);
        matCost0.add(matCost.get(2));
        finalCost.add(matCost0);

        List<CommonPb.Atom2> pbCost = new ArrayList<>();
        for (List<Integer> mat : finalCost) {
            pbCost.add(playerDataManager.subProp(player, mat.get(0), mat.get(1), mat.get(2), AwardFrom.LORD_EQUIP_MAT_PRO));
        }

        // 随机需要生产出来的材料
        List<Integer> reward = RandomHelper.getRandomByWeight(fla.getReward());
        if (reward.size() != 3)
            return;
        int now = TimeHelper.getCurrentSecond();
        LordEquipMatBuilding building = new LordEquipMatBuilding(reward.get(1), reward.get(2), fla.getPeriod() * LordEquipConst.PRECISION);
        long speed = calcMaterialProductSpeed(player);
        building.setSpeed(speed);
        building.setLastTime(now);
        building.setEndTime(now + (int) Math.ceil(building.getPeriod() / speed));
        player.leqInfo.getLeq_mat_que().add(building);
        Collections.sort(player.leqInfo.getLeq_mat_que());

        // 返回消息
        GamePb5.ProductLordEquipMatRs.Builder builder = GamePb5.ProductLordEquipMatRs.newBuilder();
        builder.addAllCost(pbCost);
        for (LordEquipMatBuilding lemb : player.leqInfo.getLeq_mat_que()) {// 适配客户端处理
            builder.addLemb(PbHelper.createLordEquipMatBuilding(lemb));
        }
        handler.sendMsgToPlayer(GamePb5.ProductLordEquipMatRs.ext, builder.build());
    }

    /**
     * 客户端每分钟向服务器请求材料队列生产进度
     *
     * @param handler
     */
    public void getLembQueueByMinute(ClientHandler handler) {
        if (!functionPlanDataMgr.isLordEquipOpen()) {
            handler.sendErrorMsgToPlayer(GameError.LORD_EQUIP_FUNCTION_CLOSE);
            return;// 功能未开放
        }

        Player player = playerDataManager.getPlayer(handler.getRoleId());

        if (player == null) {
            return;
        }

        List<LordEquipMatBuilding> queue = player.leqInfo.getLeq_mat_que();

        // 没有生产队列
        GamePb5.GetLembQueueRs.Builder builder = GamePb5.GetLembQueueRs.newBuilder();

        for (LordEquipMatBuilding building : queue) {
            builder.addLemb(PbHelper.createLordEquipMatBuilding(building));
        }

        handler.sendMsgToPlayer(GamePb5.GetLembQueueRs.ext, builder.build());
    }

    /**
     * 购买一个军备材料生产坑位
     *
     * @param handler
     */
    public void buyLembQueue(ClientHandler handler) {
        if (!functionPlanDataMgr.isLordEquipOpen()) {
            handler.sendErrorMsgToPlayer(GameError.LORD_EQUIP_FUNCTION_CLOSE);
            return;// 功能未开放
        }

        StaticBuilding staticBuilding = staticBuildingDataMgr.getStaticBuilding(BuildingId.MATERIAL);
        if (staticBuilding == null || staticBuilding.getCanProduct() == 0)
            return;

        Player player = playerDataManager.getPlayer(handler.getRoleId());
        // 坑位已经买完
        int buyCount = player.leqInfo.getBuyMatCount();
        if (buyCount >= staticBuilding.getProBuyPrice().size())
            return;
        int buyPrice = staticBuilding.getProBuyPrice().get(buyCount);
        if (player.lord.getGold() < buyPrice)
            return;

        playerDataManager.subGold(player, buyPrice, AwardFrom.LORD_EQUIP_MAT_PRO_BUY);
        player.leqInfo.setBuyMatCount(buyCount + 1);

        // 返回消息
        GamePb5.BuyMaterialProRs.Builder builder = GamePb5.BuyMaterialProRs.newBuilder();
        builder.setBuyCount(player.leqInfo.getBuyMatCount());
        builder.setGold(player.lord.getGold());
        handler.sendMsgToPlayer(GamePb5.BuyMaterialProRs.ext, builder.build());
    }

    /**
     * 收取已经结束的材料
     *
     * @param req
     * @param handler
     */
    public void collectMaterial(GamePb5.CollectLeqMaterialRq req, ClientHandler handler) {
        if (!functionPlanDataMgr.isLordEquipOpen()) {
            handler.sendErrorMsgToPlayer(GameError.LORD_EQUIP_FUNCTION_CLOSE);
            return;// 功能未开放
        }

        int index = req.getQueueIdx();
        if (index < 1)
            return;
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        List<LordEquipMatBuilding> queue = player.leqInfo.getLeq_mat_que();
        if (index > queue.size())
            return;
        LordEquipMatBuilding matb = queue.get(index - 1);
        if (matb == null || matb.getComplete() < matb.getPeriod())
            return;
        queue.remove(index - 1);// 删除领取的材料生产信息
        playerDataManager.addAward(player, AwardType.LORD_EQUIP_METERIAL, matb.getStaticId(), matb.getCount(),
                AwardFrom.LORD_EQUIP_MAT_COLLECT);

        // 返回消息
        GamePb5.CollectLeqMaterialRs.Builder builder = GamePb5.CollectLeqMaterialRs.newBuilder();
        builder.setQueueIdx(req.getQueueIdx());
        builder.setAward(PbHelper.createAwardPb(AwardType.LORD_EQUIP_METERIAL, matb.getStaticId(), matb.getCount()));
        if (!queue.isEmpty()) {
            for (LordEquipMatBuilding building : queue) {
                builder.addLemb(PbHelper.createLordEquipMatBuilding(building));
            }
        }
        handler.sendMsgToPlayer(GamePb5.CollectLeqMaterialRs.ext, builder.build());
    }

    /**
     * 材料队列逻辑
     */
    public void materailQueueTimeLogic() {
        if (!functionPlanDataMgr.isLordEquipOpen()) {
            return;// 功能未开放
        }

        Iterator<Player> iterator = playerDataManager.getRecThreeMonOnlPlayer().values().iterator();
        int now = TimeHelper.getCurrentSecond();
        while (iterator.hasNext()) {
            Player player = iterator.next();

            /*if(player.is3MothLogin()){
                continue;
            }*/

            if (!player.leqInfo.getLeq_mat_que().isEmpty()) {
                for (LordEquipMatBuilding building : player.leqInfo.getLeq_mat_que()) {
                    // 已经生产结束
                    if (building.getComplete() >= building.getPeriod()) {
                        continue;
                    }
                    int subSec = now - building.getLastTime();
                    // 结算一分钟内产量
                    building.setComplete(Math.min(building.getComplete() + building.getSpeed() * subSec, building.getPeriod()));
                    long sub = building.getPeriod() - building.getComplete();
                    building.setEndTime(now + (int) Math.ceil(sub / building.getSpeed()));
                    building.setLastTime(now);
                }
                Collections.sort(player.leqInfo.getLeq_mat_que());
            }
        }
    }

    /**
     * 繁荣度或者繁荣等级变化时, 更新材料生产速度
     *
     * @param player
     */
    public void updateLembProductSpeed(Player player) {
        if (!functionPlanDataMgr.isLordEquipOpen())
            return;// 功能未开放

        if (!player.leqInfo.getLeq_mat_que().isEmpty()) {
            int now = TimeHelper.getCurrentSecond();
            long speed = calcMaterialProductSpeed(player);
            for (LordEquipMatBuilding building : player.leqInfo.getLeq_mat_que()) {
                building.setSpeed(speed);
                long sub = building.getPeriod() - building.getComplete();
                building.setEndTime(now + (int) Math.ceil(sub / speed));
            }
        }
    }

    /**
     * 生产因子发生变化时更新全服玩家生产速度
     */
    public void updateLembProductSpeed() {
        if (!functionPlanDataMgr.isLordEquipOpen())
            return;// 功能未开放

        Iterator<Player> iterator = playerDataManager.getPlayers().values().iterator();
        int now = TimeHelper.getCurrentSecond();
        while (iterator.hasNext()) {
            Player player = iterator.next();
            if (!player.leqInfo.getLeq_mat_que().isEmpty()) {
                long speed = calcMaterialProductSpeed(player);
                for (LordEquipMatBuilding building : player.leqInfo.getLeq_mat_que()) {
                    building.setSpeed(speed);
                    long sub = building.getPeriod() - building.getComplete();
                    building.setEndTime(now + (int) Math.ceil(sub / speed));
                }
            }
        }
    }

    /**
     * 材料生产速度: v=p(当前繁荣度)/系数1 + p(繁荣度上限)/系数2 + 1
     *
     * @param player
     * @return
     */
    private long calcMaterialProductSpeed(Player player) {
        int f1 = LordEquipConst.factor.get(0);
        int f2 = LordEquipConst.factor.get(1);
        return player.lord.getPros() * LordEquipConst.PRECISION / f1 + player.lord.getProsMax() * LordEquipConst.PRECISION / f2 + 10000;
    }

    // ****************************************

    /**
     * 获取指挥官装备信息
     *
     * @param handler
     */
    public void getLordEquips(ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        GamePb5.GetLordEquipInfoRs.Builder builder = GamePb5.GetLordEquipInfoRs.newBuilder();
        // 身上的军备列表
        if (!player.leqInfo.getPutonLordEquips().isEmpty()) {
            for (Map.Entry<Integer, LordEquip> entry : player.leqInfo.getPutonLordEquips().entrySet()) {
                builder.addPuton(PbHelper.createLordEquip(entry.getValue()));
            }
        }
        // 仓库中的军备列表
        if (!player.leqInfo.getStoreLordEquips().isEmpty()) {
            for (Map.Entry<Integer, LordEquip> entry : player.leqInfo.getStoreLordEquips().entrySet()) {
                builder.addStore(PbHelper.createLordEquip(entry.getValue()));
            }
        }

        // 材料列表
        if (!player.leqInfo.getLeqMat().isEmpty()) {
            for (Map.Entry<Integer, Prop> entry : player.leqInfo.getLeqMat().entrySet()) {
                builder.addProp(PbHelper.createPropPb(entry.getValue()));
            }
        }

        // 军备生产队列
        if (!player.leqInfo.getLeq_que().isEmpty()) {
            builder.setLeqb(PbHelper.createLordEquipBuilding(player.leqInfo.getLeq_que().get(0)));
        }

        // 材料生产队列
        if (!player.leqInfo.getLeq_mat_que().isEmpty()) {
            for (LordEquipMatBuilding leqb : player.leqInfo.getLeq_mat_que()) {
                builder.addMatQueue(PbHelper.createLordEquipMatBuilding(leqb));
            }
        }

        int nowSec = TimeHelper.getCurrentSecond();
        checkAndReset(player, nowSec);
        builder.setEmployTechId(player.leqInfo.getEmployTechId());
        builder.setEmployEndTime(player.leqInfo.getEmployEndTime());
        builder.setUnlockTechMax(player.leqInfo.getUnlock_tech_max());
        builder.setFree(player.leqInfo.isFree());
        builder.setBuyCount(player.leqInfo.getBuyMatCount());
        handler.sendMsgToPlayer(GamePb5.GetLordEquipInfoRs.ext, builder.build());
    }

    /**
     * 穿戴指挥官装备
     *
     * @param req
     * @param handler
     */
    public void putonEquip(GamePb5.PutonLordEquipRq req, ClientHandler handler) {
        if (!functionPlanDataMgr.isLordEquipOpen()) {
            handler.sendErrorMsgToPlayer(GameError.LORD_EQUIP_FUNCTION_CLOSE);
            return;// 功能未开放
        }

        Player player = playerDataManager.getPlayer(handler.getRoleId());
        int keyId = req.getKeyId();
        LordEquip eq = player.leqInfo.getStoreLordEquips().get(keyId);
        if (eq == null)
            return;
        StaticLordEquip staticEquip = staticEquipDataMgr.getStaticLordEquip(eq.getEquipId());
        // 道具不存在
        if (staticEquip == null) {
            handler.sendErrorMsgToPlayer(GameError.LORD_EQUIP_ALEADY_PUTON);
            return;
        }
        // 穿戴等级不够
        if (player.lord.getLevel() < staticEquip.getLevel()) {
            handler.sendErrorMsgToPlayer(GameError.LV_NOT_ENOUGH);
            return;
        }

        int toPos = staticEquip.getPos();

        GamePb5.PutonLordEquipRs.Builder builder = GamePb5.PutonLordEquipRs.newBuilder();

        // 目标位置已经有装备则替换，先脱下该装备
        if (player.leqInfo.getPutonLordEquips().containsKey(staticEquip.getPos())) {
            LordEquip putonEquip = player.leqInfo.getPutonLordEquips().remove(toPos);
            putonEquip.setPos(0);
            player.leqInfo.getStoreLordEquips().put(putonEquip.getKeyId(), putonEquip);
            builder.addLe(PbHelper.createLordEquip(putonEquip));
        }

        player.leqInfo.getStoreLordEquips().remove(keyId);// 从仓库中移除装备
        eq.setPos(toPos);
        player.leqInfo.getPutonLordEquips().put(toPos, eq);// 穿上装备

        // 消息返回
        builder.addLe(PbHelper.createLordEquip(eq));
        handler.sendMsgToPlayer(GamePb5.PutonLordEquipRs.ext, builder.build());

        // 重新计算玩家最强实力
        playerEventService.calcStrongestFormAndFight(player);
    }

    /**
     * 脱下装备
     *
     * @param req
     * @param handler
     */
    public void takeOffEquip(GamePb5.TakeOffEquipRq req, ClientHandler handler) {
        if (!functionPlanDataMgr.isLordEquipOpen()) {
            handler.sendErrorMsgToPlayer(GameError.LORD_EQUIP_FUNCTION_CLOSE);
            return;// 功能未开放
        }

        Player player = playerDataManager.getPlayer(handler.getRoleId());
        LordEquip eq = player.leqInfo.getPutonLordEquips().get(req.getPos());
        if (eq == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_LORD_EQUIP);
            return;
        }
        StaticLordEquip staticEquip = staticEquipDataMgr.getStaticLordEquip(eq.getEquipId());
        if (staticEquip == null || eq.getPos() != staticEquip.getPos()) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }
        player.leqInfo.getPutonLordEquips().remove(req.getPos());
        eq.setPos(0);
        player.leqInfo.getStoreLordEquips().put(eq.getKeyId(), eq);

        // 消息返回
        GamePb5.TakeOffEquipRs.Builder builder = GamePb5.TakeOffEquipRs.newBuilder();
        builder.setLe(PbHelper.createLordEquip(eq));
        handler.sendMsgToPlayer(GamePb5.TakeOffEquipRs.ext, builder.build());

        // 重新计算玩家最强实力
        playerEventService.calcStrongestFormAndFight(player);
    }

    /**
     * 制造装备
     *
     * @param handler
     */
    public void productEquip(GamePb5.ProductEquipRq rq, ClientHandler handler) {
        if (!functionPlanDataMgr.isLordEquipOpen())
            return;// 功能未开放

        Player player = playerDataManager.getPlayer(handler.getRoleId());
        int eid = rq.getEquipId();// 需要生产的装备ID
        if (eid < 1)
            return;
        // 静态数据检查
        StaticLordEquip staticEquip = staticEquipDataMgr.getStaticLordEquip(eid);
        if (staticEquip == null || staticEquip.getFormula() < 1)
            return;
        StaticFormula fla = staticFormulaDataMgr.getFormula(staticEquip.getFormula());
        if (fla == null || fla.getReward() == null || fla.getReward().size() != 1)
            return;
        if (player.leqInfo.getLeq_que().size() >= LordEquipConst.LEQ_MAX_BUILD_SIZE)
            return;
        List<CommonPb.Atom2> pbCost = new ArrayList<>();

        if (!productService.product(player, fla, pbCost, AwardFrom.FORMULA_PRODUCT_PROP)) {
            return; // 合成失败
        }
        List<Integer> product = fla.getReward().get(0);
        int now = TimeHelper.getCurrentSecond();
        player.leqInfo.getLeq_que().add(new LordEquipBuilding(product.get(1), fla.getPeriod(), now + fla.getPeriod()));

        GamePb5.ProductEquipRs.Builder builder = GamePb5.ProductEquipRs.newBuilder();
        builder.setLeqb(PbHelper.createLordEquipBuilding(player.leqInfo.getLeq_que().get(0)));
        builder.addAllCost(pbCost);
        handler.sendMsgToPlayer(GamePb5.ProductEquipRs.ext, builder.build());
    }

    /**
     * 收取生产结束的军备
     *
     * @param handler
     */
    public void collectLordEquipBuiding(ClientHandler handler) {
        if (!functionPlanDataMgr.isLordEquipOpen())
            return;// 功能未开放

        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player.leqInfo.getLeq_que().size() != 1)
            return;
        LordEquipBuilding leqb = player.leqInfo.getLeq_que().get(0);
        int now = TimeHelper.getCurrentSecond();
        if (leqb.getEndTime() > now)
            return;
        player.leqInfo.getLeq_que().remove(0);
        int keyId = playerDataManager.addAward(player, AwardType.LORD_EQUIP, leqb.getStaticId(), 1, AwardFrom.LORD_EQUIP_PRODUCT_FINISH);
        LordEquip leq = player.leqInfo.getStoreLordEquips().get(keyId);
        GamePb5.CollectLordEquipRs.Builder builder = GamePb5.CollectLordEquipRs.newBuilder();
        builder.setLordEquip(PbHelper.createLordEquip(leq));
        handler.sendMsgToPlayer(GamePb5.CollectLordEquipRs.ext, builder.build());
    }

    /**
     * 军备分解
     *
     * @param rq
     * @param handler
     */
    public void resloveLordEquip(GamePb5.ResloveLordEquipRq rq, ClientHandler handler) {
        if (!functionPlanDataMgr.isLordEquipOpen())
            return;// 功能未开放

        int keyId = rq.getKeyId();// 根据ID列表分解
        List<Integer> quaList = rq.getQualityList();// 或者根据品质列表分解
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        GamePb5.ResloveLordEquipRs.Builder builder = GamePb5.ResloveLordEquipRs.newBuilder();
        Set<Integer> remove = new HashSet<>();
        if (keyId > 0) {
            LordEquip leq = player.leqInfo.getStoreLordEquips().get(keyId);
            if (leq == null || leq.getPos() != 0) {
                LogUtil.error(String.format("lord id :%d, not found lord equip in store key id :%d", player.lord.getLordId(), keyId));
                return;
            }

            if (leq.isLock()) {
                handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
                return;
            }

            remove.add(keyId);
            resloveLordEquip(player, leq, builder);
        } else if (quaList != null && !quaList.isEmpty()) {
            for (Integer qua : quaList) {
                for (Map.Entry<Integer, LordEquip> entry : player.leqInfo.getStoreLordEquips().entrySet()) {
                    LordEquip leq = entry.getValue();

                    if (leq.isLock()) {
                        continue;
                    }

                    StaticLordEquip staticEquip = staticEquipDataMgr.getStaticLordEquip(leq.getEquipId());
                    if (staticEquip == null || staticEquip.getQuality() != qua)
                        continue;
                    remove.add(leq.getKeyId());
                    resloveLordEquip(player, leq, builder);
                }
            }
        } else {
            return;
        }
        for (Integer rid : remove) {
            player.leqInfo.getStoreLordEquips().remove(rid);
        }
        if (builder.getAwardCount() > 10) {
            builder = adapt(builder);
        }
        handler.sendMsgToPlayer(GamePb5.ResloveLordEquipRs.ext, builder.build());
    }

    /**
     * 使用铁匠加速
     *
     * @param req
     * @param handler
     */
    public void useTechnical(GamePb5.UseTechnicalRq req, ClientHandler handler) {
        if (!functionPlanDataMgr.isLordEquipOpen())
            return;// 功能未开放

        Player player = playerDataManager.getPlayer(handler.getRoleId());
        int now = TimeHelper.getCurrentSecond();

        // 没有雇佣铁匠或者铁匠已到期
        if (player.leqInfo.getEmployTechId() < LordEquipConst.UNLOCK_TECHNICAL_DEFAULT || now > player.leqInfo.getEmployEndTime())
            return;
        if (player.leqInfo.getLeq_que().size() != 1)
            return;
        LordEquipBuilding building = player.leqInfo.getLeq_que().get(0);

        // 已经使用铁匠加速过
        if (building.getTechId() > 0 && building.getTechId() >= player.leqInfo.getEmployTechId())
            return;
        // 铁匠不存在
        StaticTechnical staticTech = staticEquipDataMgr.getTechnical(player.leqInfo.getEmployTechId());
        if (staticTech == null)
            return;

        int reduceTime = staticTech.getTimeDown();
        // 技工更换
        StaticTechnical beforeStaticTech = null;
        if (building.getTechId() > 0) {
            beforeStaticTech = staticEquipDataMgr.getTechnical(building.getTechId());
            if (beforeStaticTech != null) {
                reduceTime -= beforeStaticTech.getTimeDown();
                reduceTime = Math.max(0, reduceTime);
            }
        }
        building.setEndTime(building.getEndTime() - reduceTime);
        building.setTechId(player.leqInfo.getEmployTechId());
        GamePb5.UseTechnicalRs.Builder builder = GamePb5.UseTechnicalRs.newBuilder();
        builder.setTechId(building.getTechId());
        builder.setEndTime((int) building.getEndTime());
        handler.sendMsgToPlayer(GamePb5.UseTechnicalRs.ext, builder.build());
    }

    /**
     * 雇佣铁匠
     *
     * @param req
     * @param handler
     */
    public void employTechnicalRq(GamePb5.EmployTechnicalRq req, ClientHandler handler) {
        if (!functionPlanDataMgr.isLordEquipOpen())
            return;// 功能未开放

        int techId = req.getTechId();
        if (techId < LordEquipConst.UNLOCK_TECHNICAL_DEFAULT)
            return;
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        // 铁匠未解锁或者不能雇佣低品质铁匠
        if (techId != player.leqInfo.getUnlock_tech_max())
            return;

        // 铁匠不存在
        StaticTechnical staticTech = staticEquipDataMgr.getTechnical(techId);
        if (staticTech == null)
            return;

        // 刚解锁的铁匠可以免费雇佣一次
        if (!player.leqInfo.isFree() && player.lord.getGold() < staticTech.getCost()) {
            return;
        }
        if (!player.leqInfo.isFree()) {
            if (player.lord.getGold() < staticTech.getCost()) {
                handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
                return;
            }
            playerDataManager.subGold(player, staticTech.getCost(), AwardFrom.LORD_EQUIP_TECH_EMPLOY);
        }
        int now = TimeHelper.getCurrentSecond();
        player.leqInfo.setEmployTechId(techId);
        player.leqInfo.setEmployEndTime(Math.max(now, player.leqInfo.getEmployEndTime()) + staticTech.getWorkTime());
        player.leqInfo.setFree(false);
        GamePb5.EmployTechnicalRs.Builder builder = GamePb5.EmployTechnicalRs.newBuilder();
        builder.setTechId(techId);
        builder.setEmployEndTime(player.leqInfo.getEmployEndTime());
        builder.setGold(player.lord.getGold());
        handler.sendMsgToPlayer(GamePb5.EmployTechnicalRs.ext, builder.build());
    }

    /**
     * 使用金币加速
     *
     * @param handler
     */
    public void speedByGold(ClientHandler handler) {
        if (!functionPlanDataMgr.isLordEquipOpen())
            return;// 功能未开放

        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player.leqInfo.getLeq_que().size() != LordEquipConst.LEQ_MAX_BUILD_SIZE)
            return;
        LordEquipBuilding building = player.leqInfo.getLeq_que().get(0);
        int now = TimeHelper.getCurrentSecond();
        if (now >= building.getEndTime())
            return;// 不需要加速
        StaticLordEquip staticEquip = staticEquipDataMgr.getStaticLordEquip(building.getStaticId());
        if (staticEquip == null || staticEquip.getFormula() == 0)
            return;
        StaticFormula fla = staticFormulaDataMgr.getFormula(staticEquip.getFormula());
        if (fla == null || fla.getCdPrice() == 0)
            return;
        long subSec = building.getEndTime() - now;
        int cost = (int) (Math.ceil(subSec / 60.0) * Math.max(1, fla.getCdPrice()));
        if (player.lord.getGold() < cost)
            return;
        playerDataManager.subGold(player, cost, AwardFrom.LORD_EQUIP_GOLD_SPEED);
        building.setEndTime(now);
        GamePb5.LordEquipSpeedByGoldRs.Builder build = GamePb5.LordEquipSpeedByGoldRs.newBuilder();
        build.setGold(player.lord.getGold());
        handler.sendMsgToPlayer(GamePb5.LordEquipSpeedByGoldRs.ext, build.build());
    }

    /**
     * 发给客户端的奖励信息太长需要规整一下把ID相同的奖励整合成一个奖励
     *
     * @param builder
     * @return
     */
    private GamePb5.ResloveLordEquipRs.Builder adapt(GamePb5.ResloveLordEquipRs.Builder builder) {
        Map<Integer, Integer> tyMap = new HashMap<>();// KEY:id,VALUE:type
        Map<Integer, Long> ctMap = new HashMap<>();// KEY:id,VALUE:count
        GamePb5.ResloveLordEquipRs.Builder builder0 = GamePb5.ResloveLordEquipRs.newBuilder();
        for (CommonPb.Award award : builder.getAwardList()) {
            if (award.getKeyId() > 0) {// 具有唯一ID的奖励不变化
                builder0.addAward(award);
            } else {
                tyMap.put(award.getId(), award.getType());
                Long count = ctMap.get(award.getId());
                ctMap.put(award.getId(), (count == null ? 0 : count) + award.getCount());
            }
        }
        if (!ctMap.isEmpty()) {
            for (Map.Entry<Integer, Long> entry : ctMap.entrySet()) {
                int type = tyMap.get(entry.getKey());
                builder0.addAward(PbHelper.createAwardPb(type, entry.getKey(), entry.getValue()));
            }
        }
        return builder0;
    }

    /**
     * 分解单个军备
     *
     * @param player
     * @param leq
     * @param builder
     */
    private void resloveLordEquip(Player player, LordEquip leq, GamePb5.ResloveLordEquipRs.Builder builder) {
        StaticLordEquip staticEquip = staticEquipDataMgr.getStaticLordEquip(leq.getEquipId());
        if (staticEquip == null || staticEquip.getFormula() == 0)
            return;

        StaticFormula fla = staticFormulaDataMgr.getFormula(staticEquip.getFormula());
        if (fla == null)
            return;

        // 分解获得固定物品
        List<List<Integer>> rewards = new ArrayList<>();
        if (fla.getRslFix() != null && !fla.getRslFix().isEmpty()) {
            rewards.addAll(fla.getRslFix());
        }
        // 分解获得随机物品
        if (fla.getRslRadom() != null && !fla.getRslRadom().isEmpty()) {
            List<List<Integer>> randomList = new ArrayList<>();
            List<Integer> weightList = new ArrayList<>();
            for (List<Integer> list : fla.getRslRadom()) {
                if (list.size() == 4) {
                    randomList.add(list.subList(0, 3));
                    weightList.add(list.get(3));
                }
            }
            rewards.add(randomList.get(RandomHelper.getRandomIndex(weightList)));
        }
        builder.addAllAward(playerDataManager.addAwardsBackPb(player, rewards, AwardFrom.LORD_EQUIP_RESLOVE));
    }

    /**
     * 判断雇佣的技工到期了没
     *
     * @param player
     * @param now    void
     */
    private void checkAndReset(Player player, int now) {
        // 雇佣到期
        if (player.leqInfo.getEmployEndTime() > 0 && now > player.leqInfo.getEmployEndTime()) {
            player.leqInfo.setEmployTechId(0);
            player.leqInfo.setEmployEndTime(0);
        }
    }

    /**
     * 根据当前繁荣度等级解锁相应的技工
     *
     * @param player
     * @param prosLv
     */
    public void checkAndUnlockLordEquipTechnical(Player player, int prosLv) {
        StaticTechnical staticTechnical = staticEquipDataMgr.getOpenMaxTechnical(prosLv);
        if (staticTechnical != null && player.leqInfo.getUnlock_tech_max() < staticTechnical.getId()) {
            player.leqInfo.setUnlock_tech_max(staticTechnical.getId());
            player.leqInfo.setFree(true);
            StcHelper.syncUnlockTechMax(player);
        }
    }

    /**
     * 军备锁定
     *
     * @param rq
     * @param handler
     */
    public void lockLordEquip(GamePb5.LockLordEquipRq rq, ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        LordEquipInfo leqInfo = player.leqInfo;
        Map<Integer, LordEquip> leqMap;
        if (rq.getPuton() == 1) {
            leqMap = leqInfo.getPutonLordEquips();
        } else {
            leqMap = leqInfo.getStoreLordEquips();
        }
        int keyId = rq.getKeyId();
        LordEquip le = null;
        for (LordEquip temp : leqMap.values()) {
            if (temp.getKeyId() == keyId) {
                le = temp;
                break;
            }
        }
        if (le == null) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }

        le.setLock(!le.isLock());

        GamePb5.LockLordEquipRs.Builder build = GamePb5.LockLordEquipRs.newBuilder();
        build.setLordEquip(PbHelper.createLordEquip(le));
        handler.sendMsgToPlayer(GamePb5.LockLordEquipRs.ext, build.build());

    }

    /**
     * 军备洗炼
     *
     * @param req
     * @param productLordEquipChangeHandler
     */
    public void productLordEquipChange(LordEquipChangeRq req, ClientHandler handler) {

        // 如果没有开启洗练功能则返回
        if (!functionPlanDataMgr.isLordEquipChangeOpen())
            return;

        Player player = playerDataManager.getPlayer(handler.getRoleId());
        LordEquipChangeRs.Builder build = LordEquipChangeRs.newBuilder();
        LordEquipInfo leqInfo = player.leqInfo;
        Map<Integer, LordEquip> leqMap;
        if (req.getPuton() == 1) {
            leqMap = leqInfo.getPutonLordEquips();
        } else {
            leqMap = leqInfo.getStoreLordEquips();
        }
        int keyId = req.getKeyId();
        LordEquip le = null;
        for (LordEquip temp : leqMap.values()) {
            if (temp.getKeyId() == keyId) {
                le = temp;
                break;
            }
        }

        if (le == null || le.isLock()) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }

        // 刷新一下，计算剩余次数和恢复时间
        leqInfo.refreshFreeChangeTime();

        GameError error = lordEquipChange(req.getType(), handler.getRoleId(), le);

        if (error != GameError.OK) {
            handler.sendErrorMsgToPlayer(error);
        } else {
            build.setNum(leqInfo.getFreeChangeNum());
            build.setGold(player.lord.getGold());
            build.setLe(PbHelper.createLordEquip(le));

            handler.sendMsgToPlayer(LordEquipChangeRs.ext, build.build());

            // 打印日志
            AwardFrom from = null;
            switch (req.getType()) {
                case 1:
                    from = AwardFrom.LORD_EQUIP_CHANGE_FREE;
                    break;
                case 2:
                    from = AwardFrom.LORD_EQUIP_CHANGE_GOLD;
                    break;
                case 3:
                    from = AwardFrom.LORD_EQUIP_CHANGE_SUPER;
                    break;
            }
            LogLordHelper.logLordEquipChange(player, from, le);
            // 洗练成功，重新计算玩家最强实力
            playerEventService.calcStrongestFormAndFight(player);
        }
    }

    /**
     * 军备洗练入口，根据type分配具体逻辑
     *
     * @param type   1 普通洗练 2 至尊洗练 3 神秘洗练
     * @param lordId
     * @param leq
     */
    public GameError lordEquipChange(int type, long lordId, LordEquip le) {
        switch (type) {
            case 1:// 普通洗练
                return lordEquipFreeChange(lordId, le);
            case 2:// 至尊洗练
                return lordEquipGoldChange(lordId, le);
            case 3:// 神秘洗练
                return lordEquipSuperChange(lordId, le);
            default:// 参数错误
                return GameError.INVALID_PARAM;
        }
    }

    /**
     * 军备洗练普通洗练和至尊洗练共同逻辑
     *
     * @param changeId 1 普通洗练 2 至尊洗练
     * @param lordId
     * @param le
     * @return
     */
    public GameError change(int changeId, long lordId, LordEquip le) {
        StaticLordEquip staticLordEquip = staticEquipDataMgr.getStaticLordEquip(le.getEquipId());
        // 军备技能格子是否为空，如为空则随机出技能
        List<List<Integer>> skillList = le.getLordEquipSkillList();

        if (le.getLordEquipSaveType() == 1) {
            skillList = le.getLordEquipSkillSecondList();
        }
        int skillSize = skillList.size();

        List<List<Integer>> typePropList = staticEquipDataMgr.getLordEquipChange(changeId).getTypeProp();

        if (skillSize == 0) {
            for (int i = 0; i < staticLordEquip.getNormalBox(); i++) {
                skillList.add(null);
                // 根据技能类型查找对应技能
                // 先随机出一个技能类型
                // 权重算法随机出技能类型
                List<Integer> resultList = RandomHelper.getRandomByWeight(typePropList, 1);
                int type = resultList.get(0);
                StaticLordEquipSkill lordEquipSkill = staticEquipDataMgr.getLordEquipSkillMap(type, 1);
                List<Integer> twoInt = new ArrayList<Integer>(2);
                twoInt.add(lordEquipSkill.getId());
                twoInt.add(lordEquipSkill.getLevel());
                skillList.set(i, twoInt);
            }
            return GameError.OK;
        }

        StaticLordEquipChange sLordEquipChange = staticEquipDataMgr.getLordEquipChange(changeId);

        // 根据品质取系数
        List<List<Integer>> list = loadService.getListListIntSystemValue(42, null);
        int coefficient = list.get(staticLordEquip.getQuality() - 1).get(1);

        float standard = (float) ((sLordEquipChange.getUpProp() * coefficient) / 10000.0);

        for (int i = 0; i < skillList.size(); i++) {

            // 先随机出一个技能类型
            // 权重算法随机出技能类型
            List<Integer> resultList = RandomHelper.getRandomByWeight(typePropList, 1);
            int type = resultList.get(0);

            // 洗练等级（随机数小于配置随机数则等级提升，否则等级不变）
            // 概率 = 概率值 * 品质系数
            int iRandom = RandomUtils.nextInt(0, 10000);
            int lv = skillList.get(i).get(1);
            if (iRandom < standard) {
                // 如果没有满级则升级下一等级，否则等级不变
                if (lv < staticLordEquip.getMaxSkillLevel()) {
                    lv++;
                }
            }

            // 根据技能类型查找对应技能
            StaticLordEquipSkill lordEquipSkill = staticEquipDataMgr.getLordEquipSkillMap(type, lv);
            List<Integer> twoInt = new ArrayList<>(2);
            twoInt.add(lordEquipSkill.getId());
            twoInt.add(lordEquipSkill.getLevel());
            skillList.set(i, twoInt);
        }
        return GameError.OK;
    }

    /**
     * 神秘洗练逻辑
     *
     * @param lordId
     * @param leq
     * @return
     */
    private GameError lordEquipSuperChange(long lordId, LordEquip le) {
        Player player = playerDataManager.getPlayer(lordId);
        StaticLordEquip staticLordEquip = staticEquipDataMgr.getStaticLordEquip(le.getEquipId());
        // 如果配置为能洗练则可洗练
        if (!staticLordEquip.canSuperChange()) {
            return GameError.LORD_EQUIP_SKILL_CANNOT_CHANGE;
        }

        List<List<Integer>> skillList = le.getLordEquipSkillList();
        if (le.getLordEquipSaveType() == 1) {
            skillList = le.getLordEquipSkillSecondList();
        }

        // 如果normalbox格子的某个技能未升级到最大等级，则不能洗练
        for (int i = 0; i < staticLordEquip.getNormalBox(); i++) {
            List<Integer> skill = skillList.get(i);
            if (skill.get(1) < staticLordEquip.getMaxSkillLevel()) {
                return GameError.LORD_EQUIP_SKILL_NO_FULL_LEVEL;
            }
        }


        int cost = staticEquipDataMgr.getLordEquipChange(3).getCost();

        // 金币少于需要金币数，则不能洗练
        if (player.lord.getGold() < cost) {
            return GameError.LORD_EQUIP_SKILL_NO_GLOD;
        }

        // 扣除金币数
        playerDataManager.subGold(player, cost, AwardFrom.LORD_EQUIP_CHANGE_SUPER);

        List<List<Integer>> typePropList = staticEquipDataMgr.getLordEquipChange(3).getTypeProp();
        // 随机出某类型技能
        List<Integer> resultList = RandomHelper.getRandomByWeight(typePropList, 1);
        int type = resultList.get(0);
        // 根据技能类型查找对应技能
        int maxSkillLv = staticLordEquip.getMaxSkillLevel();
        StaticLordEquipSkill lordEquipSkill = staticEquipDataMgr.getLordEquipSkillMap(type, maxSkillLv);
        List<Integer> twoInt = new ArrayList<Integer>(2);
        twoInt.add(lordEquipSkill.getId());
        twoInt.add(lordEquipSkill.getLevel());
        // 如果第一次神秘洗练(格子数等于默认格子数)，增加一格
        if (skillList.size() == staticLordEquip.getNormalBox()) {
            skillList.add(null);
        }
        // 所有格子设置为同一个技能
        for (int i = 0; i < skillList.size(); i++) {
            skillList.set(i, twoInt);
        }
        return GameError.OK;
    }

    /**
     * 至尊洗练逻辑
     *
     * @param lordId
     * @param leq
     * @return
     */
    private GameError lordEquipGoldChange(long lordId, LordEquip le) {
        Player player = playerDataManager.getPlayer(lordId);
        int cost = staticEquipDataMgr.getLordEquipChange(2).getCost();

        // 金币少于需要金币数，则不能洗练
        if (player.lord.getGold() < cost) {
            return GameError.LORD_EQUIP_SKILL_NO_GLOD;
        }

        // 扣除金币数
        playerDataManager.subGold(player, cost, AwardFrom.LORD_EQUIP_CHANGE_GOLD);

        return change(2, lordId, le);
    }

    /**
     * 普通洗练逻辑
     *
     * @param lordId
     * @param le
     * @return
     */
    private GameError lordEquipFreeChange(long lordId, LordEquip le) {
        Player player = playerDataManager.getPlayer(lordId);
        LordEquipInfo leqInfo = player.leqInfo;

        // 确认免费次数是否大于0，如果没有免费次数则洗练失败
        if (leqInfo.getFreeChangeNum() <= 0) {
            return GameError.LORD_EQUIP_SKILL_NO_NUM;
        }

        // 扣除一次免费使用次数
        leqInfo.useFreeNum();

        return change(1, lordId, le);
    }

    /**
     * 获取免费洗练次数和恢复时间
     *
     * @param req
     * @param productLordEquipChangFreeTimeeHandler
     */
    public void getLordEquipChangFreeTime(LordEquipChangeFreeTimeRq req, ClientHandler handler) {
        // 如果没有开启洗练功能则返回
        if (!functionPlanDataMgr.isLordEquipChangeOpen())
            return;

        LordEquipInfo leq = playerDataManager.getPlayer(handler.getRoleId()).leqInfo;
        // 刷新一下，计算剩余次数和恢复时间
        leq.refreshFreeChangeTime();
        LordEquipChangeFreeTimeRs.Builder build = GamePb5.LordEquipChangeFreeTimeRs.newBuilder();
        build.setNum(leq.getFreeChangeNum());
        build.setRemainingTime(leq.getRemainingTimeSec());
        handler.sendMsgToPlayer(LordEquipChangeFreeTimeRs.ext, build.build());
    }

    /**
     * 返回最大免费洗练次数
     */
    public int getKeepNum() {
        return staticEquipDataMgr.getLordEquipChangeMap().get(1).getKeepNumber();
    }

    /**
     * 返回洗练恢复时间
     */
    public int getCD() {
        return staticEquipDataMgr.getLordEquipChangeMap().get(1).getCd();
    }

    /**
     * 返回洗练需要金币数
     *
     * @param
     */
    public int getCost(int changeId) {
        return staticEquipDataMgr.getLordEquipChangeMap().get(changeId).getCost();
    }

    /**
     * 设置军备保存方案
     */
    public void setLeqScheme(SetLeqSchemeRq req, ClientHandler handler) {
        if (!functionPlanDataMgr.isLordEquipOpen()) {
            return;// 功能未开放
        }

        CommonPb.LeqScheme leqScheme = req.getLeqScheme();
        if (leqScheme == null || !leqScheme.hasType() || !leqScheme.hasName()) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }

        int type = leqScheme.getType();
        // 暂时只有两套方案，先简单写死了
        if (type > 2 || type < 1) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }

        Player player = playerDataManager.getPlayer(handler.getRoleId());
        LeqScheme leq = player.leqScheme.get(type);
        if (leq == null) {
            leq = new LeqScheme();
        }

        Map<Integer, Integer> leqmap = new HashMap<>();
        List<TwoInt> leqList = leqScheme.getLeqList();
        List<Integer> pos = new ArrayList<>();
        for (TwoInt twoInt : leqList) {
            // 0表示该方案此部位没有设置军备
            if (twoInt.getV2() == 0) {
                leqmap.put(twoInt.getV1(), twoInt.getV2());
                continue;
            }
            // 不允许同一个部位的军备出现重复
            if (pos.contains(twoInt.getV1())) {
                handler.sendErrorMsgToPlayer(GameError.LORD_EQUIP_SCHEME_SAME_POS);
                return;
            }
            pos.add(twoInt.getV1());
            // 设置军备方案时，是以身上穿戴的军备来设置
            LordEquip eq = player.leqInfo.getPutonLordEquips().get(twoInt.getV1());
            if (eq == null || eq.getKeyId() != twoInt.getV2()) {
                handler.sendErrorMsgToPlayer(GameError.NO_LORD_EQUIP);
                return;
            }
            StaticLordEquip staticEquip = staticEquipDataMgr.getStaticLordEquip(eq.getEquipId());
            if (staticEquip == null) {
                handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
                return;
            }
            if (player.lord.getLevel() < staticEquip.getLevel()) {
                handler.sendErrorMsgToPlayer(GameError.LV_NOT_ENOUGH);
                return;
            }
            if (twoInt.getV1() != staticEquip.getPos()) {
                handler.sendErrorMsgToPlayer(GameError.LORD_EQUIP_SCHEME_POS_MISSMATCH);
                return;
            }

            leqmap.put(twoInt.getV1(), twoInt.getV2());
        }

        // 覆盖原方案
        leq.setType(type);
        leq.setLeq(leqmap);
        leq.setSchemeName(leqScheme.getName());
        player.leqScheme.put(type, leq);

        SetLeqSchemeRs.Builder builder = SetLeqSchemeRs.newBuilder();
        builder.setLeqScheme(leq.toPb());
        handler.sendMsgToPlayer(SetLeqSchemeRs.ext, builder.build());
    }

    /**
     * 一键穿戴军备方案中的所有军备
     */
    public void putonLeqScheme(ClientHandler handler, PutonLeqSchemeRq req) {
        if (!functionPlanDataMgr.isLordEquipOpen()) {
            return;// 功能未开放
        }
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        int type = req.getType();
        LeqScheme scheme = player.leqScheme.get(type);
        if (scheme == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_SUCH_LORD_EQUIP_SCHEME);
            return;
        }
        Map<Integer, Integer> leq = scheme.getLeq();
        Map<Integer, LordEquip> putonLordEquips = new HashMap<>((player.leqInfo.getPutonLordEquips()));
        PutonLeqSchemeRs.Builder builder = PutonLeqSchemeRs.newBuilder();
        // 方案中被删除的军备的部位集合
        List<Integer> posList = new ArrayList<>();
        try {
            outer:
            for (Map.Entry<Integer, Integer> entry : leq.entrySet()) {
                if (entry.getValue() != 0) {
                    LordEquip eq = player.leqInfo.getLordEquipByKeyid(entry.getValue());
                    if (eq == null) {
                        posList.add(entry.getKey());
                        continue outer;
                    }
                    StaticLordEquip staticEquip = staticEquipDataMgr.getStaticLordEquip(eq.getEquipId());
                    // 道具不存在
                    if (staticEquip == null) {
                        handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
                        return;
                    }
                    // 穿戴等级不够
                    if (player.lord.getLevel() < staticEquip.getLevel()) {
                        handler.sendErrorMsgToPlayer(GameError.LV_NOT_ENOUGH);
                        return;
                    }
                    // 方案信息不符合要求
                    if (staticEquip.getPos() != entry.getKey()) {
                        handler.sendErrorMsgToPlayer(GameError.LORD_EQUIP_SCHEME_POS_MISSMATCH);
                        return;
                    }
                }
                // 先检查方案中的军备是否已穿戴
                for (LordEquip lordEquip : putonLordEquips.values()) {
                    // 目标位置已经有装备
                    if (lordEquip.getPos() == entry.getKey()) {
                        // 如果是同一件装备
                        if (lordEquip.getKeyId() == entry.getValue()) {
                            builder.addLeq(PbHelper.createLordEquip(lordEquip));
                            continue outer;
                        } else {
                            // 脱下装备
                            player.leqInfo.getPutonLordEquips().remove(entry.getKey());
                            lordEquip.setPos(0);
                            builder.addLeq(PbHelper.createLordEquip(lordEquip));
                            player.leqInfo.getStoreLordEquips().put(lordEquip.getKeyId(), lordEquip);
                        }
                    }
                }

                // 并穿戴另一件
                if (entry.getValue() != 0) {
                    // 从仓库中移除该装备
                    LordEquip remove = player.leqInfo.getStoreLordEquips().remove(entry.getValue());
                    if (remove == null) {
                        posList.add(entry.getKey());
                        continue outer;
                    }
                    remove.setPos(entry.getKey());
                    player.leqInfo.getPutonLordEquips().put(entry.getKey(), remove);// 穿上装备
                    builder.addLeq(PbHelper.createLordEquip(remove));
                }
            }
        } catch (Exception e) {
            LogUtil.error("穿戴军备方案错误 | nick : " + player.lord.getNick() + " | 方案 : " + leq, e);
        }
        builder.addAllResolve(posList);
        handler.sendMsgToPlayer(PutonLeqSchemeRs.ext, builder.build());
    }

    /**
     * 获取玩家所有军备方案
     *
     * @param handler
     */
    public void getAllLeqScheme(ClientHandler handler) {
        if (!functionPlanDataMgr.isLordEquipOpen()) {
            return;// 功能未开放
        }
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        Map<Integer, LeqScheme> leqScheme = player.leqScheme;
        GetAllLeqSchemeRs.Builder builder = GetAllLeqSchemeRs.newBuilder();
        for (LeqScheme scheme : leqScheme.values()) {
            builder.addLeqScheme(PbHelper.createSimpleLeqScheme(scheme.getType(), scheme.getSchemeName()));
        }
        handler.sendMsgToPlayer(GetAllLeqSchemeRs.ext, builder.build());
    }


    /**
     * 设置军备使用的是第几套
     *
     * @param rq
     * @param handler
     */
    public void setLordEquipUseTypeRq(GamePb5.SetLordEquipUseTypeRq rq, ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (rq.getType() != 0 && rq.getType() != 1) {
            return;
        }

        GamePb5.SetLordEquipUseTypeRs.Builder builder = GamePb5.SetLordEquipUseTypeRs.newBuilder();
        int operationType = rq.getOperationType();
        LordEquipInfo leqInfo = player.leqInfo;
        //单个
        if (operationType == 1) {

            Map<Integer, LordEquip> leqMap;
            if (rq.getPuton() == 1) {
                leqMap = leqInfo.getPutonLordEquips();
            } else {
                leqMap = leqInfo.getStoreLordEquips();
            }

            int keyId = rq.getKeyId();
            LordEquip le = null;
            for (LordEquip temp : leqMap.values()) {
                if (temp.getKeyId() == keyId) {
                    le = temp;
                    break;
                }
            }


            if (rq.getType() == 1) {
                if (!le.getLordEquipSkillSecondList().isEmpty()) {
                    le.setLordEquipSaveType(rq.getType());
                }
            } else {
                le.setLordEquipSaveType(rq.getType());
            }

            builder.addLe(PbHelper.createLordEquip(le));
        } else {
            Map<Integer, LordEquip> leqMap = leqInfo.getPutonLordEquips();
            for (LordEquip temp : leqMap.values()) {
                if (rq.getType() == 1) {
                    if (!temp.getLordEquipSkillSecondList().isEmpty()) {
                        temp.setLordEquipSaveType(rq.getType());
                    }
                } else {
                    temp.setLordEquipSaveType(rq.getType());
                }
                builder.addLe(PbHelper.createLordEquip(temp));
            }

        }
        handler.sendMsgToPlayer(GamePb5.SetLordEquipUseTypeRs.ext, builder.build());
    }

    /**
     * 第二套军备继承
     *
     * @param rq
     * @param handler
     */
    public void lordEquipInheritRq(GamePb5.LordEquipInheritRq rq, ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());

        LordEquipInfo leqInfo = player.leqInfo;
        Map<Integer, LordEquip> leqMap;
        if (rq.getPuton() == 1) {
            leqMap = leqInfo.getPutonLordEquips();
        } else {
            leqMap = leqInfo.getStoreLordEquips();
        }
        int keyId = rq.getKeyId();
        LordEquip le = null;
        for (LordEquip temp : leqMap.values()) {
            if (temp.getKeyId() == keyId) {
                le = temp;
                break;
            }
        }

        // 刷新一下，计算剩余次数和恢复时间
        leqInfo.refreshFreeChangeTime();


        //金币判断 和 军备满级判断

        List<List<Integer>> lordEquipSkillList = le.getLordEquipSkillList();

        StaticLordEquip staticLordEquip = staticEquipDataMgr.getStaticLordEquip(le.getEquipId());
        //等级没有满级
        for (List<Integer> l : lordEquipSkillList) {
            if (staticLordEquip.getMaxSkillLevel() != l.get(1)) {
                handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
                return;
            }
        }


        int consumekeyId = rq.getConsumekeyId();

        if( consumekeyId == le.getKeyId()){
            return;
        }

        Map<Integer, LordEquip> storeLordEquips = leqInfo.getStoreLordEquips();

        LordEquip consumeLordEquip = null;
        for (LordEquip temp : storeLordEquips.values()) {
            if (temp.getKeyId() == consumekeyId) {
                consumeLordEquip = temp;
                break;
            }
        }

        if (consumeLordEquip == null) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }

        if( consumeLordEquip.getEquipId() != le.getEquipId()-1){
            return;
        }

        List<List<Integer>> lordEquipSkillList1 = consumeLordEquip.getLordEquipSkillList();
        StaticLordEquip staticLordEquip2 = staticEquipDataMgr.getStaticLordEquip(consumeLordEquip.getEquipId());
        //等级没有满级
        for (List<Integer> l : lordEquipSkillList1) {
            if (staticLordEquip2.getMaxSkillLevel() != l.get(1)) {
                handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
                return;
            }
        }


        List<List<Integer>> lordEquipSkillSecondList = le.getLordEquipSkillSecondList();

        if (!lordEquipSkillSecondList.isEmpty()) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }

        int cost = 500;
        // 金币少于需要金币数，则不能洗练
        if (player.lord.getGold() < cost) {
            handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
            return;
        }

        //删除军备
        storeLordEquips.remove(consumekeyId);

        LogUtil.error("lordEquipInheritRq roleId="+player.lord.getLordId()+" "+ JSON.toJSONString(consumeLordEquip));


        // 扣除金币数
        playerDataManager.subGold(player, cost, AwardFrom.LORD_LORDEQUIPINHERITRQ);


        for (List<Integer> list : lordEquipSkillList) {
            lordEquipSkillSecondList.add(new ArrayList<Integer>(list));
        }

        GamePb5.LordEquipInheritRs.Builder builder = GamePb5.LordEquipInheritRs.newBuilder();
        builder.setGold(player.lord.getGold());
        builder.setLe(PbHelper.createLordEquip(le));
        handler.sendMsgToPlayer(GamePb5.LordEquipInheritRs.ext, builder.build());

    }
}
