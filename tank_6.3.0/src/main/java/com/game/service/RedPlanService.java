package com.game.service;

import com.alibaba.fastjson.JSON;
import com.game.constant.ActivityConst;
import com.game.constant.AwardFrom;
import com.game.constant.GameError;
import com.game.dataMgr.StaticActivityDataMgr;
import com.game.dataMgr.StaticRedPlanMgr;
import com.game.domain.ActivityBase;
import com.game.domain.Player;
import com.game.domain.p.Prop;
import com.game.domain.p.RedPlanInfo;
import com.game.domain.s.StaticRedPlanArea;
import com.game.domain.s.StaticRedPlanFuel;
import com.game.domain.s.StaticRedPlanPoint;
import com.game.domain.s.StaticRedPlanShop;
import com.game.manager.PlayerDataManager;
import com.game.message.handler.ClientHandler;
import com.game.pb.CommonPb;
import com.game.pb.GamePb6;
import com.game.util.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.*;

/**
 * @author GuiJie
 * @description 红色方案
 * @created 2018/03/20 11:26
 */
@Service
public class RedPlanService {

    @Autowired
    private StaticRedPlanMgr staticRedPlanMgr;
    @Autowired
    private PlayerDataManager playerDataManager;
    @Autowired
    private StaticActivityDataMgr staticActivityDataMgr;

    /**
     * 区域地图状态 1没开启 2开启 3未通过(单次已经走到了终点) 4全部通过
     */
    private static final int AREA_STATE_1 = 1;
    /**
     * 区域地图状态 1没开启 2开启 3未通过(单次已经走到了终点) 4全部通过
     */
    private static final int AREA_STATE_2 = 2;
    /**
     * 区域地图状态  1没开启 2开启 3未通过(单次已经走到了终点) 4全部通过
     */
    private static final int AREA_STATE_3 = 3;
    /**
     * 区域地图状态 1没开启 2开启 3未通过(单次已经走到了终点) 4全部通过
     */
    private static final int AREA_STATE_4 = 4;
    /**
     * 区域宝箱状态 0不可以 1可以领取  2已经领取
     */
    private static final int AREA_REWARD_0 = 0;
    /**
     * 区域宝箱状态 0不可以 1可以领取  2已经领取
     */
    private static final int AREA_REWARD_1 = 1;
    /**
     * 区域宝箱状态 0不可以 1可以领取  2已经领取
     */
    private static final int AREA_REWARD_2 = 2;

    /**
     * 代币id
     */
    private static final int ITEMID = 640;

    /**
     * 活动是否开启
     *
     * @return
     */
    public boolean isOpen() {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_RED_PLAN);
        if (activityBase == null) {
            return false;
        }
        return true;
    }

    /**
     * 获取活动奖励id
     *
     * @return
     */
    private int getAwardId() {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_RED_PLAN);
        if (activityBase == null) {
            return 0;
        }
        return activityBase.getPlan().getAwardId();
    }

    /**
     * 定时每分钟增加科技粒子
     */
    public void redPlanFuelLogic() {
        //活动开启
        if (!isOpen()) {
            return;
        }
        Iterator<Player> iterator = playerDataManager.getRecThreeMonOnlPlayer().values().iterator();
        long time = System.currentTimeMillis();
        while (iterator.hasNext()) {
            Player player = iterator.next();
            /*if (player.is3MothLogin()) {
                continue;
            }*/
            try {
                fuelLogic(player, time);
            } catch (Exception e) {
                LogUtil.error(" 红色方案定时生产燃料, lordId:" + player.lord.getLordId(), e);
            }
        }
    }

    /**
     * 定时增加燃料
     *
     * @param player
     */
    private void fuelLogic(Player player, long time) {
        //满20不生产
        if (player.redPlanInfo.getFuel() >= staticRedPlanMgr.getRedPalnConfig().getRecoverLimit()) {
            return;
        }

        if (time > (player.redPlanInfo.getFuelTime() * 1000L)) {
            player.redPlanInfo.setFuel(player.redPlanInfo.getFuel() + 1);

            if (player.redPlanInfo.getFuel() >= staticRedPlanMgr.getRedPalnConfig().getRecoverLimit()) {
                player.redPlanInfo.setFuelTime(0);
            } else {
                player.redPlanInfo.setFuelTime(getFuelTime());
            }
        }
    }

    private int getItemCount(Player player) {
        Prop prop = player.props.get(ITEMID);

        if (prop == null) {
            return 0;
        }
        return prop.getCount();
    }

    /**
     * 获取信息
     *
     * @param handler
     */
    public void getRedPlanInfo(ClientHandler handler) {


        //活动开启
        if (!isOpen()) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }


        Player player = playerDataManager.getPlayer(handler.getRoleId());

        clearRedPlanInfo(player);

        RedPlanInfo info = player.redPlanInfo;

        GamePb6.GetRedPlanInfoRs.Builder builder = GamePb6.GetRedPlanInfoRs.newBuilder();

        builder.setFuel(info.getFuel());

        builder.setItemCount(getItemCount(player));
        builder.setFuelBuyCount(info.getFuelCount());


        //是否首次参加活动
        int isFirst = 0;
        if (info.getPointInfo().isEmpty()) {
            isFirst = 1;
        }

        //区域状态
        List<Integer> areaState = getAreaState(player);
        for (Integer state : areaState) {
            builder.addAreaInfo(state);

        }

        //奖励状态
        Map<Integer, Integer> shopInfo = info.getShopInfo();
        List<StaticRedPlanShop> redShopConfigList = staticRedPlanMgr.getRedShopConfigList(getAwardId());

        if (redShopConfigList != null) {
            for (StaticRedPlanShop c : redShopConfigList) {
                if (shopInfo.containsKey(c.getGoodId())) {
                    int count = shopInfo.get(c.getGoodId());
                    builder.addShopInfo(count);
                } else {
                    builder.addShopInfo(0);
                }

            }
        }

        builder.setNowAreaId(info.getNowAreaId());
        builder.setIsfirst(isFirst);

        if (info.getFuel() < staticRedPlanMgr.getRedPalnConfig().getRecoverLimit()) {
            builder.setFuelTime((int) (info.getFuelTime() - (System.currentTimeMillis() / 1000L)));
        } else {
            builder.setFuelTime(0);
        }
        handler.sendMsgToPlayer(GamePb6.GetRedPlanInfoRs.ext, builder.build());
    }


    /**
     * 移动格子
     *
     * @param rq
     * @param handler
     */
    public void move(GamePb6.MoveRedPlanRq rq, ClientHandler handler) {


        //活动开启
        if (!isOpen()) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }


        Player player = playerDataManager.getPlayer(handler.getRoleId());
        RedPlanInfo redPlanInfo = player.redPlanInfo;
        int areaId = rq.getAreaId();

        List<Integer> pointInfo = redPlanInfo.getPointInfo().get(rq.getAreaId());
        if (pointInfo == null || pointInfo.isEmpty()) {
            handler.sendErrorMsgToPlayer(GameError.RED_PLAN_NOT_OPEN);
            return;
        }

        int nowPointId = redPlanInfo.getNowPointId();
        //说明才开始这个区域
        if (nowPointId == 0) {
            nowPointId = staticRedPlanMgr.getStartPoint(getAwardId(), areaId);
        }

        //说明已经走完了
        if (nowPointId == staticRedPlanMgr.getStopPoint(getAwardId(), areaId)) {
            LogUtil.error("RedPlan move 1 " + player.lord.getNick() + "clientAreaId =" + areaId + " serverInfo=" + JSON.toJSONString(redPlanInfo));
            return;
        }

        if (redPlanInfo.getNowAreaId() != 0 && areaId != redPlanInfo.getNowAreaId()) {
            if (redPlanInfo.getNowAreaId() == 0) {
                StaticRedPlanArea firstAreaConfig = staticRedPlanMgr.getRedAreaConfigList(getAwardId()).get(0);
                if (firstAreaConfig.getAreaId() != areaId) {
                    LogUtil.error("RedPlan move 3 " + player.lord.getNick() + "clientAreaId =" + areaId + " serverInfo=" + JSON.toJSONString(redPlanInfo));
                    handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
                    return;
                }
            } else {
                //说明上一次的地图没有打完
                if (redPlanInfo.getNowPointId() != 0 && nowPointId != staticRedPlanMgr.getStopPoint(getAwardId(), redPlanInfo.getNowAreaId())) {
                    LogUtil.error("RedPlan move 2 " + player.lord.getNick() + "clientAreaId =" + areaId + " serverInfo=" + JSON.toJSONString(redPlanInfo));
                    handler.sendErrorMsgToPlayer(GameError.RED_PLAN_AREA);
                    return;
                }
            }

        }


        StaticRedPlanArea redAreaConfig = staticRedPlanMgr.getRedAreaConfig(getAwardId(), areaId);
        if (redPlanInfo.getFuel() < redAreaConfig.getCost()) {
            handler.sendErrorMsgToPlayer(GameError.RED_PLAN_FUEL);
            return;
        }


        if (redPlanInfo.getFuel() >= staticRedPlanMgr.getRedPalnConfig().getRecoverLimit() && (redPlanInfo.getFuel() - redAreaConfig.getCost()) < staticRedPlanMgr.getRedPalnConfig().getRecoverLimit()) {
            player.redPlanInfo.setFuelTime(getFuelTime());
        }

        redPlanInfo.setFuel(redPlanInfo.getFuel() - redAreaConfig.getCost());

        StaticRedPlanPoint config = staticRedPlanMgr.getRedPointConfig(getAwardId(), areaId, nowPointId);

        //随机出一个新的格子
        List<Integer> prePoint = config.getPrePoint();
        Map<Integer, Float> ratePointId = new HashMap<>();
        for (Integer pid : prePoint) {
            StaticRedPlanPoint redPointConfig = staticRedPlanMgr.getRedPointConfig(getAwardId(), areaId, pid);
            ratePointId.put(pid, Float.valueOf(redPointConfig.getPossibility()));
        }

        int newPointId = LotteryUtil.getRandomKey(ratePointId);
        StaticRedPlanPoint newConfig = staticRedPlanMgr.getRedPointConfig(getAwardId(), areaId, newPointId);


        //随机奖励
        Map<Integer, Float> rateTypeMap = new HashMap<>();

        List<List<Integer>> awardWeight = newConfig.getAwardWeight();
        for (List<Integer> r : awardWeight) {
            rateTypeMap.put(r.get(0), Float.valueOf(r.get(1)));
        }

        int awardType = LotteryUtil.getRandomKey(rateTypeMap);
        Map<Integer, List<List<Integer>>> awardConfigMap = new HashMap<>();
        for (List<Integer> r : newConfig.getAward()) {
            int type = r.get(3);
            if (!awardConfigMap.containsKey(type)) {
                awardConfigMap.put(type, new ArrayList<List<Integer>>());
            }
            awardConfigMap.get(type).add(r);
        }

        //添加奖励
        List<List<Integer>> award = awardConfigMap.get(awardType);
        addItem(player, AwardFrom.RED_PLAN_MOVE, award);


        //这个是挑战到那一关
        redPlanInfo.setNowPointId(newPointId);
        redPlanInfo.setNowAreaId(areaId);


        //这个是挑战历史线路
        if (!redPlanInfo.getLinePointInfo().containsKey(rq.getAreaId())) {
            redPlanInfo.getLinePointInfo().put(rq.getAreaId(), new ArrayList<Integer>());
        }

        int startPoint = staticRedPlanMgr.getStartPoint(getAwardId(), areaId);
        if (!redPlanInfo.getLinePointInfo().get(rq.getAreaId()).contains(startPoint)) {
            redPlanInfo.getLinePointInfo().get(rq.getAreaId()).add(startPoint);
        }

        if (!redPlanInfo.getLinePointInfo().get(rq.getAreaId()).contains(newPointId)) {
            redPlanInfo.getLinePointInfo().get(rq.getAreaId()).add(newPointId);
        }


        int isFirst = 0;
        //说明已经走完了
        if (newPointId == staticRedPlanMgr.getStopPoint(getAwardId(), areaId)) {
            redPlanInfo.getLinePointInfo().get(rq.getAreaId()).clear();
//            redPlanInfo.getLinePointInfo().get(rq.getAreaId()).add(staticRedPlanMgr.getStartPoint(getAwardId(), areaId));
            redPlanInfo.setNowPointId(0);
            redPlanInfo.setNowAreaId(0);
            if (!redPlanInfo.getPointInfo().get(areaId).contains(newPointId)) {
                isFirst = 1;
            }
        }

        int perfectState = getAreaState(redPlanInfo, rq.getAreaId());

        //通关记录
        if (!redPlanInfo.getPointInfo().get(areaId).contains(newPointId)) {
            redPlanInfo.getPointInfo().get(areaId).add(newPointId);
        }

        GamePb6.MoveRedPlanRs.Builder builder = GamePb6.MoveRedPlanRs.newBuilder();

        for (List<Integer> temp : award) {
            CommonPb.Award awardPb = PbHelper.createAwardPb(temp.get(0), temp.get(1), temp.get(2));
            builder.addAward(awardPb);
        }

        List<Integer> historyPointInfo = redPlanInfo.getPointInfo().get(rq.getAreaId());
        if (historyPointInfo != null && !historyPointInfo.isEmpty()) {
            for (Integer pid : historyPointInfo) {
                builder.addHistoryPoint(pid);
            }
        }

        builder.setRewardInfo(getRewardState(player, rq.getAreaId()));
        builder.setNextPointId(newPointId);
        builder.setAwardType(awardType);
        builder.setItemCount(getItemCount(player));
        builder.setFuel(redPlanInfo.getFuel());
        builder.setIsfirst(isFirst);

        int perfect = 0;
        if (perfectState == AREA_STATE_3 && getAreaState(redPlanInfo, rq.getAreaId()) == AREA_STATE_4) {
            perfect = 1;
        }
        builder.setPerfect(perfect);
        handler.sendMsgToPlayer(GamePb6.MoveRedPlanRs.ext, builder.build());

    }

    /**
     * 兑换物品
     *
     * @param rq
     * @param handler
     */
    public void exchange(GamePb6.RedPlanRewardRq rq, ClientHandler handler) {

        //活动开启
        if (!isOpen()) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        int paramCount = 1;
        if (rq.hasCount()) {
            paramCount = rq.getCount();
        }

        Player player = playerDataManager.getPlayer(handler.getRoleId());
        Map<Integer, Integer> shopInfo = player.redPlanInfo.getShopInfo();


        //兑换次数
        int count = 0;
        if (shopInfo.containsKey(rq.getGoodsid())) {
            count = shopInfo.get(rq.getGoodsid());
        }

        //次数判断
        StaticRedPlanShop redShopConfig = staticRedPlanMgr.getRedShopConfig(getAwardId(), rq.getGoodsid());
        if ((count + paramCount) > redShopConfig.getPersonNumber()) {
            handler.sendErrorMsgToPlayer(GameError.RED_PLAN_COUNT);
            return;
        }


        //物品验证
        List<Integer> cost = redShopConfig.getCost();
        boolean checkPropIsEnougth = playerDataManager.checkPropIsEnougth(player, cost.get(0), cost.get(1), cost.get(2) * paramCount);

        if (!checkPropIsEnougth) {
            handler.sendErrorMsgToPlayer(GameError.PROP_NOT_ENOUGH);
            return;
        }

        Prop prop = player.props.get(cost.get(1));
        playerDataManager.subProp(player, prop, cost.get(2) * paramCount, AwardFrom.RED_PLAN_EXCHANGE);

        shopInfo.put(rq.getGoodsid(), count + paramCount);
        List<Integer> reward = redShopConfig.getReward();

        playerDataManager.addAward(player, reward.get(0), reward.get(1), reward.get(2) * paramCount, AwardFrom.RED_PLAN_EXCHANGE);

        GamePb6.RedPlanRewardRs.Builder builder = GamePb6.RedPlanRewardRs.newBuilder();
        CommonPb.Award awardPb = PbHelper.createAwardPb(reward.get(0), reward.get(1), reward.get(2) * paramCount);
        builder.addAward(awardPb);

        //奖励状态
        List<StaticRedPlanShop> redShopConfigList = staticRedPlanMgr.getRedShopConfigList(getAwardId());
        for (StaticRedPlanShop c : redShopConfigList) {
            int tc = 0;
            if (shopInfo.containsKey(c.getGoodId())) {
                tc = shopInfo.get(c.getGoodId());
            }
            builder.addShopInfo(tc);
        }

        builder.setItemCount(getItemCount(player));
        handler.sendMsgToPlayer(GamePb6.RedPlanRewardRs.ext, builder.build());

    }


    /**
     * 发送物品
     *
     * @param player
     * @param from
     * @param cost
     */
    private void addItem(Player player, AwardFrom from, List<List<Integer>> cost) {
        if (cost == null || cost.isEmpty()) {
            return;
        }

        for (List<Integer> it : cost) {
            int itemId = it.get(1);
            int type = it.get(0);
            int count = it.get(2);
            playerDataManager.addAward(player, type, itemId, count, from);
        }

    }

    /**
     * 领取通关宝箱
     *
     * @param rq
     * @param handler
     */
    public void getRewardBox(GamePb6.GetRedPlanBoxRq rq, ClientHandler handler) {


        //活动开启
        if (!isOpen()) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        Player player = playerDataManager.getPlayer(handler.getRoleId());
        List<Integer> rewardInfo = player.redPlanInfo.getRewardInfo();

        //判断是否已经领取
        if (rewardInfo.contains(rq.getAreaId())) {
            handler.sendErrorMsgToPlayer(GameError.RED_PLAN_REWARD);
            return;
        }


        int rewardState = getRewardState(player, rq.getAreaId());
        //判断有没有全部通关
        if (rewardState != AREA_REWARD_1) {
            handler.sendErrorMsgToPlayer(GameError.RED_PLAN_AREA);
            return;
        }


        rewardInfo.add(rq.getAreaId());
        StaticRedPlanArea redAreaConfig = staticRedPlanMgr.getRedAreaConfig(getAwardId(), rq.getAreaId());
        List<List<Integer>> areaAward = redAreaConfig.getAreaAward();

        GamePb6.GetRedPlanBoxRs.Builder builder = GamePb6.GetRedPlanBoxRs.newBuilder();
        for (List<Integer> item : areaAward) {
            CommonPb.Award awardPb = PbHelper.createAwardPb(item.get(0), item.get(1), item.get(2));
            builder.addAward(awardPb);
        }
        addItem(player, AwardFrom.RED_PLAN_BOX, areaAward);
        builder.setRewardInfo(getRewardState(player, rq.getAreaId()));
        handler.sendMsgToPlayer(GamePb6.GetRedPlanBoxRs.ext, builder.build());

    }


    /**
     * 购买燃料
     *
     * @param rq
     * @param handler
     */
    public void buyFuel(GamePb6.RedPlanBuyFuelRq rq, ClientHandler handler) {

        //活动开启
        if (!isOpen()) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        Player player = playerDataManager.getPlayer(handler.getRoleId());
        RedPlanInfo redPlanInfo = player.redPlanInfo;

        clearRedPlanInfo(player);

        //如果大于100 就不能再购买
        if (redPlanInfo.getFuel() + staticRedPlanMgr.getRedPalnConfig().getBuyPoint() > staticRedPlanMgr.getRedPalnConfig().getBuyLimit()) {
            handler.sendErrorMsgToPlayer(GameError.RED_PLAN_MAX_FUEL);
            return;
        }

        //金币判断
        StaticRedPlanFuel fuelConfig = staticRedPlanMgr.getFuelConfig(redPlanInfo.getFuelCount() + 1);
        if (player.lord.getGold() < fuelConfig.getCost()) {
            handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
            return;
        }
        playerDataManager.subGold(player, fuelConfig.getCost(), AwardFrom.RED_PLAN_FUEL);
        redPlanInfo.setFuel(redPlanInfo.getFuel() + staticRedPlanMgr.getRedPalnConfig().getBuyPoint());

        if (redPlanInfo.getFuel() >= staticRedPlanMgr.getRedPalnConfig().getRecoverLimit()) {
            player.redPlanInfo.setFuelTime(0);
        }

        redPlanInfo.setFuelCount(redPlanInfo.getFuelCount() + 1);
        redPlanInfo.setBuyTime((int) (System.currentTimeMillis() / 1000));

        GamePb6.RedPlanBuyFuelRs.Builder builder = GamePb6.RedPlanBuyFuelRs.newBuilder();
        builder.setFuelBuyCount(redPlanInfo.getFuelCount());
        builder.setGold(player.lord.getGold());
        builder.setFuel(redPlanInfo.getFuel());
        handler.sendMsgToPlayer(GamePb6.RedPlanBuyFuelRs.ext, builder.build());
    }


    /**
     * 获取区域信息
     *
     * @param rq
     * @param handler
     */
    public void getAreaInfo(GamePb6.GetRedPlanAreaInfoRq rq, ClientHandler handler) {
        //活动开启
        if (!isOpen()) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        Player player = playerDataManager.getPlayer(handler.getRoleId());
        RedPlanInfo redPlanInfo = player.redPlanInfo;

        if (rq.getAreaId() == 0) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }

        StaticRedPlanArea redAreaConfig = staticRedPlanMgr.getRedAreaConfig(getAwardId(), rq.getAreaId());

        if (redAreaConfig == null) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }

        int isfirst = 0;

        if (rq.getAreaId() != redPlanInfo.getNowAreaId()) {


            StaticRedPlanArea beforeRedAreaConfig = staticRedPlanMgr.getBeforeRedAreaConfig(getAwardId(), rq.getAreaId());
            if (beforeRedAreaConfig != null) {
                //上一个未完成
                int lastAreaState = getAreaState(redPlanInfo, beforeRedAreaConfig.getAreaId());
                if (lastAreaState < AREA_STATE_3) {
                    handler.sendErrorMsgToPlayer(GameError.RED_PLAN_LAST_AREA);
                    return;
                }
            }

            List<Integer> pointInfo = redPlanInfo.getPointInfo().get(rq.getAreaId());
            if (pointInfo == null || pointInfo.isEmpty()) {
                int startPoint = staticRedPlanMgr.getStartPoint(getAwardId(), rq.getAreaId());
                //打开即代表开启 初始化数据
                redPlanInfo.getPointInfo().put(rq.getAreaId(), new ArrayList<Integer>());
                redPlanInfo.getPointInfo().get(rq.getAreaId()).add(startPoint);

                //单次挑战记录顺序
                redPlanInfo.getLinePointInfo().put(rq.getAreaId(), new ArrayList<Integer>());
                redPlanInfo.getLinePointInfo().get(rq.getAreaId()).add(startPoint);

                redPlanInfo.setNowAreaId(rq.getAreaId());
                redPlanInfo.setNowPointId(staticRedPlanMgr.getStartPoint(getAwardId(), rq.getAreaId()));
                isfirst = 1;
            }


        }


        GamePb6.GetRedPlanAreaInfoRs.Builder builder = GamePb6.GetRedPlanAreaInfoRs.newBuilder();

        if (redPlanInfo.getLinePointInfo().containsKey(rq.getAreaId())) {
            for (Integer pid : redPlanInfo.getLinePointInfo().get(rq.getAreaId())) {
                builder.addPointIds(pid);
            }
        }

        List<Integer> areaState = getAreaState(player);
        for (Integer state : areaState) {
            builder.addAreaInfo(state);

        }
        List<Integer> historyPointInfo = redPlanInfo.getPointInfo().get(rq.getAreaId());
        if (historyPointInfo != null && !historyPointInfo.isEmpty()) {
            for (Integer pid : historyPointInfo) {
                builder.addHistoryPoint(pid);
            }
        }

        builder.setIsfirst(isfirst);
        builder.setNowAreaId(redPlanInfo.getNowAreaId());
        builder.setRewardInfo(getRewardState(player, rq.getAreaId()));
        handler.sendMsgToPlayer(GamePb6.GetRedPlanAreaInfoRs.ext, builder.build());

    }


    /**
     * //1没开启 2开启 3未通过(单次已经走到了终点) 4全部通过
     *
     * @param player
     * @return
     */
    private List<Integer> getAreaState(Player player) {

        RedPlanInfo redPlanInfo = player.redPlanInfo;
        List<Integer> result = new ArrayList<>();
        List<StaticRedPlanArea> redAreaConfig = staticRedPlanMgr.getRedAreaConfigList(getAwardId());
        for (StaticRedPlanArea c : redAreaConfig) {
            result.add(getAreaState(redPlanInfo, c.getAreaId()));
        }

        return result;

    }

    /**
     * 区域状态
     *
     * @param redPlanInfo
     * @param areaId
     * @return
     */
    private int getAreaState(RedPlanInfo redPlanInfo, int areaId) {
        //历史记录
        Map<Integer, List<Integer>> pointInfo = redPlanInfo.getPointInfo();
        List<Integer> pointIds = pointInfo.get(areaId);

        //1没开启
        if (pointIds == null) {
            return AREA_STATE_1;
        } else {
            //说明开启了但是没有打完 2开启
            int stopPoint = staticRedPlanMgr.getStopPoint(getAwardId(), areaId);
            if (!pointIds.contains(stopPoint)) {
                return AREA_STATE_2;
            }

            //有没有打完的 3未通过(单次已经走到了终点)
            List<StaticRedPlanPoint> redPointConfig = staticRedPlanMgr.getRedPointConfig(getAwardId(), areaId);
            if (redPointConfig.size() != pointIds.size()) {
                return AREA_STATE_3;
            }
            //  4全部通过
            return AREA_STATE_4;
        }
    }


    /**
     * 获取奖励状态
     *
     * @param player
     * @param areaId
     * @return 0不可以 1可以领取  2已经领取
     */
    private int getRewardState(Player player, int areaId) {


        List<Integer> pointIds = player.redPlanInfo.getPointInfo().get(areaId);

        if (pointIds == null) {
            pointIds = new ArrayList<>();
        }

        //是否全部通过过
        boolean isReward = true;

        List<StaticRedPlanPoint> redPointConfig = staticRedPlanMgr.getRedPointConfig(getAwardId(), areaId);
        if (redPointConfig == null) {
            isReward = false;
        } else {
            for (StaticRedPlanPoint ss : redPointConfig) {
                if (!pointIds.contains(ss.getPid())) {
                    isReward = false;
                    break;
                }
            }
        }
        //奖励状态

        int rewardState = AREA_REWARD_0;
        if (isReward) {
            rewardState = AREA_REWARD_1;
        }
        List<Integer> rewardInfo = player.redPlanInfo.getRewardInfo();
        if (rewardInfo.contains(areaId)) {
            rewardState = AREA_REWARD_2;
        }
        return rewardState;
    }

    /**
     * 扫荡
     *
     * @param rq
     * @param handler
     */
    public void refRedPal(GamePb6.RefRedPlanAreaRq rq, ClientHandler handler) {
        //活动开启
        if (!isOpen()) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        Player player = playerDataManager.getPlayer(handler.getRoleId());
        RedPlanInfo redPlanInfo = player.redPlanInfo;

        //判断是否全部完成

        int areaState = getAreaState(player.redPlanInfo, rq.getAreaId());

        if (areaState != AREA_STATE_4) {
            handler.sendErrorMsgToPlayer(GameError.RED_PLAN_AREA);
            return;
        }

        StaticRedPlanArea redAreaConfig = staticRedPlanMgr.getRedAreaConfig(getAwardId(), rq.getAreaId());

        if (redPlanInfo.getFuel() < redAreaConfig.getRaidCost()) {
            handler.sendErrorMsgToPlayer(GameError.RED_PLAN_FUEL);
            return;
        }

        if (redPlanInfo.getFuel() >= staticRedPlanMgr.getRedPalnConfig().getRecoverLimit() && (redPlanInfo.getFuel() - redAreaConfig.getCost()) < staticRedPlanMgr.getRedPalnConfig().getRecoverLimit()) {
            player.redPlanInfo.setFuelTime(getFuelTime());
        }

        redPlanInfo.setFuel(redPlanInfo.getFuel() - redAreaConfig.getRaidCost());


        //随机奖励
        Map<Integer, Float> rateType = new HashMap<>();

        List<List<Integer>> awardWeight = redAreaConfig.getAwardWeight();
        for (List<Integer> r : awardWeight) {
            rateType.put(r.get(0), Float.valueOf(r.get(1)));
        }

        int awardType = LotteryUtil.getRandomKey(rateType);
        Map<Integer, List<List<Integer>>> awardConfig = new HashMap<>();
        for (List<Integer> r : redAreaConfig.getRaidAward()) {
            int type = r.get(3);
            if (!awardConfig.containsKey(type)) {
                awardConfig.put(type, new ArrayList<List<Integer>>());
            }
            awardConfig.get(type).add(r);
        }

        //添加奖励
        List<List<Integer>> award = awardConfig.get(awardType);

        addItem(player, AwardFrom.RED_PLAN_REF, award);

        GamePb6.RefRedPlanAreaRs.Builder builder = GamePb6.RefRedPlanAreaRs.newBuilder();

        for (List<Integer> temp : award) {
            CommonPb.Award awardPb = PbHelper.createAwardPb(temp.get(0), temp.get(1), temp.get(2));
            builder.addAward(awardPb);
        }
        builder.setFuel(redPlanInfo.getFuel());
        builder.setAwardType(awardType);
        builder.setItemCount(getItemCount(player));
        handler.sendMsgToPlayer(GamePb6.RefRedPlanAreaRs.ext, builder.build());

    }


    /**
     * gm指令添加燃料
     *
     * @param player
     * @param count
     */
    public void gmSetFuel(Player player, int count) {

        RedPlanInfo redPlanInfo = player.redPlanInfo;
        redPlanInfo.setFuel(redPlanInfo.getFuel() + count);

        if (player.redPlanInfo.getFuel() >= staticRedPlanMgr.getRedPalnConfig().getRecoverLimit()) {
            player.redPlanInfo.setFuelTime(0);
        } else {
            player.redPlanInfo.setFuelTime(getFuelTime());
        }
    }

    /**
     * gm清空数据
     *
     * @param player
     * @param count
     */
    public void gmClear(Player player, int count) {
        player.redPlanInfo.clear(getFuelTime());
    }

    /**
     * 清空购买次数
     *
     * @param player
     */
    private void clearRedPlanInfo(Player player) {
        RedPlanInfo redPlanInfo = player.redPlanInfo;

        //活动编号变了 清空之前的数据
        String version = getActivateVersin();
        int fuelTime = getFuelTime();

        if (version != null && !version.equals(redPlanInfo.getVersion())) {
            redPlanInfo.reset(version, staticRedPlanMgr.getRedPalnConfig().getRecoverLimit(), fuelTime);
        }

        int f = (int) (redPlanInfo.getFuelTime() - (System.currentTimeMillis() / 1000L));
        if (f < 0) {
            redPlanInfo.setFuelTime(fuelTime);
        }
    }


    /**
     * 获取活动版本号 更具活动开始时间 活动开始时间变了 版本号就变了
     *
     * @return
     */
    private String getActivateVersin() {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_RED_PLAN);
        if (activityBase == null) {
            return null;
        }
        return DateHelper.formatDateTime(activityBase.getBeginTime(), "yyyy-MM-dd");
    }


    /**
     * 获取下次燃料回复时间s
     *
     * @return
     */
    private int getFuelTime() {
        return (int) ((System.currentTimeMillis() + (TimeHelper.SECOND_MS * staticRedPlanMgr.getRedPalnConfig().getRecoverSpan())) / 1000L);
    }
}
