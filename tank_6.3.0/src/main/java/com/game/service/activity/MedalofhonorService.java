package com.game.service.activity;

import com.game.constant.*;
import com.game.dataMgr.StaticActivityDataMgr;
import com.game.domain.ActivityBase;
import com.game.domain.Player;
import com.game.domain.UsualActivityData;
import com.game.domain.p.ActPlayerRank;
import com.game.domain.p.Activity;
import com.game.domain.p.Lord;
import com.game.domain.s.*;
import com.game.manager.ActivityDataManager;
import com.game.manager.PlayerDataManager;
import com.game.message.handler.ClientHandler;
import com.game.pb.CommonPb;
import com.game.pb.GamePb5;
import com.game.util.LogLordHelper;
import com.game.util.LogUtil;
import com.game.util.PbHelper;
import com.game.util.RandomHelper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

/**
 * @author zhangdh
 * @ClassName: ActMedalofhonorService
 * @Description: 荣誉勋章活动(大吉大利，晚上吃鸡)
 * status:
 * 0:今日刷新次数
 * statusMap
 * key:
 * 0:第一个坦克宝箱ID, 如果为负数表示此位置的鸡已经被吃了
 * 1:第二个坦克宝箱ID, 如果为负数表示此位置的鸡已经被吃了
 * 2:第三个坦克宝箱ID, 如果为负数表示此位置的鸡已经被吃了
 * 3-记录本次活动开启后系统是否有给玩家是刷新坦克宝箱
 * 4-玩家吃鸡的积分
 * 5-领取排名奖励标志位
 * @date 2017-10-28 17:50
 */
@Service
public class MedalofhonorService {

    @Autowired
    private PlayerDataManager playerDataManager;

    @Autowired
    private ActivityDataManager activityDataManager;

    @Autowired
    private StaticActivityDataMgr staticActivityDataMgr;


    /**
     * 获取荣誉勋章活动内容
     *
     * @param req
     * @param handler
     */
    public void getActMedalofhonorInfoRq(GamePb5.GetActMedalofhonorInfoRq req, ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_MEDAL_OF_HONOR);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        //玩家活动数据
        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_MEDAL_OF_HONOR);
        //活动开启时免费给玩家刷新一批宝箱
        Map<Integer, Integer> statusMap = activity.getStatusMap();
        if (!statusMap.containsKey(ActConst.ActMedalofhonor.STATUS_MAP_DATA_INIT)) {
            List<StaticActMedalofhonor> list = staticActivityDataMgr.getActMedalofhonorListByType(ActConst.ActMedalofhonor.TYPE_0);
            if (list == null || list.isEmpty()) {
                handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
                return;
            }
            List<Integer> randomList = refresh(list);
            for (int i = 0; i < 3; i++) {
                statusMap.put(i, randomList.get(i));
            }
            activity.getStatusMap().put(ActConst.ActMedalofhonor.STATUS_MAP_DATA_INIT, 1);
        }

        Integer tar0Id = statusMap.get(0);
        Integer tar1Id = statusMap.get(1);
        Integer tar2Id = statusMap.get(2);
        int searchCount = activity.getStatusList().get(0).intValue();//今日刷新次数


        GamePb5.GetActMedalofhonorInfoRs.Builder builder = GamePb5.GetActMedalofhonorInfoRs.newBuilder();
        builder.setCount(searchCount);
        builder.addTargetId(tar0Id != null && tar0Id > 0 ? tar0Id : 0);
        builder.addTargetId(tar1Id != null && tar1Id > 0 ? tar1Id : 0);
        builder.addTargetId(tar2Id != null && tar2Id > 0 ? tar2Id : 0);
        Integer medalHonor = activity.getPropMap().get(ActPropIdConst.ID_MADELOFHONOR);
        builder.setMedalHonor(medalHonor == null ? 0 : medalHonor);
        handler.sendMsgToPlayer(GamePb5.GetActMedalofhonorInfoRs.ext, builder.build());
    }


    /**
     * 宝箱搜索
     *
     * @param req
     * @param handler
     */
    public void searchActMedalofhonorTargets(GamePb5.SearchActMedalofhonorTargetsRq req, ClientHandler handler) {
        int lockResult = req.getForceResult();//0:不锁定结果, 1：搜索结果为必定3橙
        int searchType = req.getSearchType();//0：普通搜索, 1：一键搜索
        if ((lockResult != 0 && lockResult != 1) || (searchType != 0 && searchType != 1)) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }

        //V6以上才能一键索敌
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (searchType == 1 && player.lord.getVip() < 6) {
            handler.sendErrorMsgToPlayer(GameError.VIP_NOT_ENOUGH);
            return;
        }

        //活动不存在
        Activity activity = player != null ? activityDataManager.getActivityInfo(player, ActivityConst.ACT_MEDAL_OF_HONOR) : null;
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_MEDAL_OF_HONOR);
        if (activityBase.getStep() != ActivityConst.OPEN_STEP) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_FINISYH);
            return;
        }

        //配置不存在
        StaticActMedalofhonorExplore explore = staticActivityDataMgr.getActMedalofhonorExplore();
        if (explore == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }

        //玩家记录
        List<Long> status = activity.getStatusList();
        Map<Integer, Integer> statusMap = activity.getStatusMap();

        //计算需要扣除的金币
        int baseCount = status.get(0).intValue();//当前刷新次数
        int searchCount = searchType == 0 ? 1 : 10;
        int goldCost = calcGoldCost(explore, baseCount, searchCount, lockResult);


        //扣除金币
        if (goldCost > 0) {
            if (player.lord.getGold() < goldCost) {
                handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
                return;
            }
            playerDataManager.subGold(player, goldCost, AwardFrom.ACT_MEDALOFHONOR_SEARCH);
        }

        List<StaticActMedalofhonor> list = staticActivityDataMgr.getActMedalofhonorListByType(searchType);
        if (list == null || list.isEmpty()) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }

        //必出3橙色
        if (lockResult == 1) {
            List<StaticActMedalofhonor> lockResultList = new ArrayList<>();
            for (StaticActMedalofhonor data : list) {
                if (data.getQuality() == 5) {
                    lockResultList.add(data);
                }
            }
            list = lockResultList;
        }

        //刷新
        List<Integer> randomList = refresh(list);
        for (int i = 0; i < 3; i++) {
            statusMap.put(i, randomList.get(i));
        }

        int scnt = baseCount + searchCount;

        status.set(0, (long) scnt);

        //索敌日志记录
        Lord lord = player.lord;
        StaticActivityPlan plan = activityBase.getPlan();
        LogUtil.info("宝箱搜索 "+String.format("keyId :%d, lordId :%d, nick :%s, lockResult :%d, searchType :%d, search count :%d, goldCost :%d, remain Gold :%d",
                plan.getKeyId(), lord.getLordId(), lord.getNick(), lockResult, searchType, scnt, goldCost, lord.getGold()));

        GamePb5.SearchActMedalofhonorTargetsRs.Builder builder = GamePb5.SearchActMedalofhonorTargetsRs.newBuilder();
        builder.addAllTargetId(randomList);
        builder.setGold(player.lord.getGold());
        handler.sendMsgToPlayer(GamePb5.SearchActMedalofhonorTargetsRs.ext, builder.build());
    }


    /**
     * 搜索敌人消耗的价格
     *
     * @param explore
     * @param baseCount   已经索敌的总次数
     * @param times       本次需要索敌次数
     * @param forceResult 本次索敌是否锁定结果
     * @return
     */
    private int calcGoldCost(StaticActMedalofhonorExplore explore, int baseCount, int times, int lockResult) {
        int cost = 0;
        int searchCount = baseCount;
        for (int i = 1; i <= times; i++) {
            searchCount++;
            //搜索价格
            if (searchCount > explore.getFreeCount()) {
                Map.Entry<Integer, Integer> priceEntry = explore.getPrice().ceilingEntry(searchCount - explore.getFreeCount());
                cost += priceEntry.getValue();
            }
        }
        //锁定结果消耗
        if (lockResult == 1) {
            cost += 100 * times;
        }
        return cost;
    }


    /**
     * 打开荣誉勋章宝箱
     *
     * @param req
     * @param handler
     */
    public void openActMedalofhonor(GamePb5.OpenActMedalofhonorRq req, ClientHandler handler) {
        //玩家点击的位置, [0,1,2]
        int pos = req.getPos();
        if (pos < 0 || pos > 2) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }

        Player player = playerDataManager.getPlayer(handler.getRoleId());
        Activity activity = player != null ? activityDataManager.getActivityInfo(player, ActivityConst.ACT_MEDAL_OF_HONOR) : null;
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_MEDAL_OF_HONOR);
        if (activityBase.getStep() != ActivityConst.OPEN_STEP) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_FINISYH);
            return;
        }


        Map<Integer, Integer> statusMap = activity.getStatusMap();
        //目标位置的道具ID
        Integer tarId = statusMap.get(pos);
        if (tarId == null || tarId < 0) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }
        StaticActMedalofhonor data = tarId > 0 ? staticActivityDataMgr.getActMedalofhonor(tarId) : null;
        if (data == null) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }

        int type = data.getType();


        GamePb5.OpenActMedalofhonorRs.Builder builder = GamePb5.OpenActMedalofhonorRs.newBuilder();
        //开宝箱
        if (type == ActConst.ActMedalofhonor.TYPE_0 || type == ActConst.ActMedalofhonor.TYPE_1) {
            //获得荣誉勋章数量
            int addCnt = data.getMedalawards();
            if (addCnt > 0) {
                playerDataManager.addAward(player, AwardType.ACTIVITY_PROP, ActPropIdConst.ID_MADELOFHONOR, addCnt, AwardFrom.ACT_MEDALOFHONOR_BOX);
                Integer propCount = activity.getPropMap().get(ActPropIdConst.ID_MADELOFHONOR);
                builder.setMedalHonor(propCount);
            }

            //可能掉落其它道具(鸡，全家桶)
            List<List<Integer>> especialAwards = data.getEspecialprobability();
            if (especialAwards != null && !data.getEspecialprobability().isEmpty()) {
                List<Integer> chickens = data.getEspecialprobability().get(0);
                int chickenId = chickens.get(0);//掉落ID
                if ((data.getQuality() == 5 && triggerChickenProtected(statusMap, pos))//触发必掉鸡的保护
                        || RandomHelper.isHitRangeIn10000(chickens.get(1))) {//掉鸡概率出发
                    builder.setChickenId(chickenId);
                    statusMap.put(pos, chickenId);
                } else {
                    //没有掉鸡
                    statusMap.put(pos, -data.getId());
                }
            } else {
                //没有掉鸡
                statusMap.put(pos, -data.getId());
            }
        } else if (type == ActConst.ActMedalofhonor.TYPE_2 || type == ActConst.ActMedalofhonor.TYPE_3) {
            //吃鸡，给予奖励
            List<List<Integer>> especialAwards = data.getEspecialprobability();
            if (especialAwards != null && !especialAwards.isEmpty()) {
                List<Integer> awardList = RandomHelper.getRandomByWeight(especialAwards);
                CommonPb.Award award = playerDataManager.addAwardBackPb(player, awardList, AwardFrom.ACT_MEDALOFHONOR_CHICKEN);
                builder.addAward(award);
//                List<CommonPb.Award> awards = playerDataManager.addAwardsBackPb(player, especialAwards, AwardFrom.ACT_MEDALOFHONOR_CHICKEN);
//                builder.addAllAward(awards);
            }

            //负数表示此鸡已经被吃过了
            statusMap.put(pos, -data.getId());
            Integer score = activity.getStatusMap().get(ActConst.ActMedalofhonor.STATUS_MAP_SCORE);
            int addScore = type == ActConst.ActMedalofhonor.TYPE_3 ? 10 : 1;//全家桶累计10分,普通鸡累计1分
            score = (score != null ? score : 0) + addScore;
            activity.getStatusMap().put(ActConst.ActMedalofhonor.STATUS_MAP_SCORE, score);
            if (score >= ActConst.ActMedalofhonor.RANK_SCORE_LESS) {//达到最低上榜积分
                UsualActivityData usualActivity = activityDataManager.getUsualActivity(ActivityConst.ACT_MEDAL_OF_HONOR);
                usualActivity.addPlayerRank(player.roleId, (long) score, ActivityConst.RANK_MEDAILOFHONOR, ActivityConst.DESC);
                ActPlayerRank actPlayerRank = usualActivity.getPlayerRank(ActivityConst.TYPE_DEFAULT, player.roleId);
                if (actPlayerRank != null) {
                    LogLordHelper.logRank(player, activityBase.getPlan().getAwardId(), score, addScore, actPlayerRank.getRank());
                }
            }
        }

        handler.sendMsgToPlayer(GamePb5.OpenActMedalofhonorRs.ext, builder.build());
    }

    /**
     * 如果刷新出来的3个宝箱都为橙色宝箱,但是前2此宝箱并未开出鸡,则最后一个宝箱必定开出鸡
     *
     * @param status
     * @return
     */
    private boolean triggerChickenProtected(Map<Integer, Integer> statusMap, int pos) {
        for (int i = 0; i < 3; i++) {
            int tarId = statusMap.get(i);
            if (tarId > 0) {//鸡或者宝箱
                if (i != pos) {
                    return false;//还有其他宝箱或者鸡
                }
            } else {
                StaticActMedalofhonor data = staticActivityDataMgr.getActMedalofhonor(Math.abs(tarId));
                if (data == null || data.getType() == ActConst.ActMedalofhonor.TYPE_2
                        || data.getType() == ActConst.ActMedalofhonor.TYPE_3
                        || data.getQuality() < 5) {
                    return false;//已经吃过鸡
                }
            }
        }
        return true;
    }


    /**
     * 荣誉勋章商店物品购买
     *
     * @param req
     * @param handler
     */
    public void buyItem(GamePb5.BuyActMedalofhonorItemRq req, ClientHandler handler) {
        int id = req.getId();
        int buyCount = req.getBuyCount();
        if (id < 1 || buyCount < 1) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }
        Map<Integer, StaticActMedalofhonorRule> shopMap = staticActivityDataMgr.getMedalofhonorRuleMap();
        StaticActMedalofhonorRule data = shopMap != null ? shopMap.get(id) : null;
        if (data == null || data.getAwards() == null || data.getAwards().isEmpty() || data.getCost() <= 0) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }

        //活动未开启
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_MEDAL_OF_HONOR);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        //荣誉勋章不足
        Map<Integer, Integer> props = activity.getPropMap();
        Integer madelHonorCount = props.get(ActPropIdConst.ID_MADELOFHONOR);
        int buyCost = data.getCost() * buyCount;
        if (buyCost > madelHonorCount) {
            handler.sendErrorMsgToPlayer(GameError.PROP_NOT_ENOUGH);
            return;
        }

        //扣除荣誉勋章
        playerDataManager.subProp(player, AwardType.ACTIVITY_PROP, ActPropIdConst.ID_MADELOFHONOR, buyCost, AwardFrom.ACT_MEDALOFHONOR_SHOP_BUY);

        //给予商店物品
        List<Integer> award = new ArrayList<>();
        award.addAll(data.getAwards());
        award.set(2, data.getAwards().get(2) * buyCount);
        CommonPb.Award pbAward = playerDataManager.addAwardBackPb(player, award, AwardFrom.ACT_MEDALOFHONOR_SHOP_BUY);
        GamePb5.BuyActMedalofhonorItemRs.Builder builder = GamePb5.BuyActMedalofhonorItemRs.newBuilder();
        builder.setMedalHonor(props.get(ActPropIdConst.ID_MADELOFHONOR));
        builder.setAward(pbAward);
        handler.sendMsgToPlayer(GamePb5.BuyActMedalofhonorItemRs.ext, builder.build());
    }


    /**
     * 获取荣誉勋章活动排行榜信息
     *
     * @param req
     * @param handler
     */
    public void getRankInfo(GamePb5.GetActMedalofhonorRankInfoRq req, ClientHandler handler) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_MEDAL_OF_HONOR);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        int step = activityBase.getStep();
        int activityKeyId = activityBase.getKeyId();
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }
        Lord lord = player.lord;
        if (lord == null) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }

        UsualActivityData activityData = activityDataManager.getUsualActivity(ActivityConst.ACT_MEDAL_OF_HONOR);
        if (activityData == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_MEDAL_OF_HONOR);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        // 我的积分
        Integer score = activity.getStatusMap().get(ActConst.ActMedalofhonor.STATUS_MAP_SCORE);
        GamePb5.GetActMedalofhonorRankInfoRs.Builder builder = GamePb5.GetActMedalofhonorRankInfoRs.newBuilder();
        LinkedList<ActPlayerRank> rankList = activityData.getPlayerRanks(ActivityConst.TYPE_DEFAULT);
        for (int i = 0; i < rankList.size() && i < ActivityConst.RANK_PAWN; i++) {
            ActPlayerRank e = rankList.get(i);
            long lordId = e.getLordId();
            Player rankPlayer = playerDataManager.getPlayer(lordId);
            if (rankPlayer != null && rankPlayer.lord != null) {
                builder.addActPlayerRank(PbHelper.createActPlayerRank(e, rankPlayer.lord.getNick()));
            }
        }
        builder.setStatus(0);
        builder.setScore(score != null ? score : 0);
        if (step == ActivityConst.OPEN_STEP) {
            builder.setOpen(false);
        } else if (step == ActivityConst.OPEN_AWARD) {
            builder.setOpen(true);
            Map<Integer, Integer> statusMap = activity.getStatusMap();
            if (statusMap.containsKey(ActConst.ActMedalofhonor.STATUS_MAP_RANK_REWARD)) {
                builder.setStatus(1);
            }
        }

        List<StaticActRank> staticActRankList = staticActivityDataMgr.getActRankList(activityKeyId, ActivityConst.TYPE_DEFAULT);
        if (staticActRankList != null) {
            for (StaticActRank e : staticActRankList) {
                builder.addRankAward(PbHelper.createRankAwardPb(e));
            }
        }
        handler.sendMsgToPlayer(GamePb5.GetActMedalofhonorRankInfoRs.ext, builder.build());
    }


    /**
     * 领取荣誉勋章排名活动奖励
     *
     * @param req
     * @param handler
     */
    public void getRankAward(GamePb5.GetActMedalofhonorRankAwardRq req, ClientHandler handler) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_MEDAL_OF_HONOR);
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (activityBase == null || player == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        int step = activityBase.getStep();
        if (step != ActivityConst.OPEN_AWARD) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_FINISH);
            return;
        }

        int keyId = activityBase.getKeyId();

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_MEDAL_OF_HONOR);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        //是否已经领取奖励标识
        if (activity.getStatusMap().containsKey(ActConst.ActMedalofhonor.STATUS_MAP_RANK_REWARD)) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_GOT);
            return;
        }

        UsualActivityData usualActivity = activityDataManager.getUsualActivity(ActivityConst.ACT_MEDAL_OF_HONOR);


        GamePb5.GetActMedalofhonorRankAwardRs.Builder builder = GamePb5.GetActMedalofhonorRankAwardRs.newBuilder();
        ActPlayerRank actRank = usualActivity.getPlayerRank(ActivityConst.TYPE_DEFAULT, player.roleId);
        int rank = actRank != null ? actRank.getRank() : 0;
        if (rank == 0) {
            handler.sendErrorMsgToPlayer(GameError.NOT_ON_RANK);
            return;
        }

        List<StaticActRank> listRank = staticActivityDataMgr.getActRankList(keyId, ActivityConst.TYPE_DEFAULT);
        if (listRank != null && listRank.size() > 0) {
            for (StaticActRank sActRank : listRank) {
                if (rank <= sActRank.getRankBegin() || rank <= sActRank.getRankEnd()) {
                    List<CommonPb.Award> awards = playerDataManager.addAwardsBackPb(player, sActRank.getAwardList(), AwardFrom.ACT_MEDALOFHONOR_RANK);
                    builder.addAllAward(awards);
                    activity.getStatusMap().put(ActConst.ActMedalofhonor.STATUS_MAP_RANK_REWARD, 1);
                    break;
                }
            }
        }

        handler.sendMsgToPlayer(GamePb5.GetActMedalofhonorRankAwardRs.ext, builder.build());
    }

    /**
     * 刷新一批荣誉勋章活动宝箱
     *
     * @param activity
     * @param type     宝箱类型
     * @param isInit   是否第一次开启此活动时初始化数据, {@link Activity.cleanStatusMap}
     * @return
     */
    private List<Integer> refresh(List<StaticActMedalofhonor> list) {
        List<Integer> weight = new ArrayList<>(list.size());
        for (StaticActMedalofhonor data : list) {
            weight.add(data.getProbability());
        }

        List<Integer> randomList = new ArrayList<>();
        for (int pos = 0; pos < 3; pos++) {
            int idx = RandomHelper.getRandomIndex(weight);
            randomList.add(list.get(idx).getId());
        }

        return randomList;
    }

}


