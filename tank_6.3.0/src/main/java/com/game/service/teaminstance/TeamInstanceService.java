package com.game.service.teaminstance;

import com.alibaba.fastjson.JSON;
import com.game.constant.AwardFrom;
import com.game.constant.AwardType;
import com.game.constant.GameError;
import com.game.dataMgr.StaticBountyDataMgr;
import com.game.domain.Player;
import com.game.domain.p.TeamInstanceInfo;
import com.game.domain.p.TeamTask;
import com.game.domain.s.StaticBountyConfig;
import com.game.domain.s.StaticBountyShop;
import com.game.domain.s.StaticBountyStage;
import com.game.domain.s.StaticBountyWanted;
import com.game.manager.DataRepairDM;
import com.game.manager.GlobalDataManager;
import com.game.manager.PlayerDataManager;
import com.game.message.handler.ClientHandler;
import com.game.pb.CommonPb;
import com.game.pb.GamePb6;
import com.game.pb.GamePb6.GetBountyShopBuyRs;
import com.game.pb.GamePb6.GetTaskRewardRq;
import com.game.pb.GamePb6.GetTaskRewardRs;
import com.game.pb.GamePb6.GetTaskRewardStatusRs;
import com.game.server.CrossMinContext;
import com.game.util.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.*;

/**
 * @author: LiFeng
 * @date:
 * @description:
 */
@Component
public class TeamInstanceService {

    @Autowired
    private PlayerDataManager playerDataManager;
    @Autowired
    private StaticBountyDataMgr staticBountyDataMgr;
    @Autowired
    private GlobalDataManager globalDataManager;
    @Autowired
    private DataRepairDM dataRepairDM;

    /**
     * 判断关卡是否开启
     *
     * @param stageId
     * @return
     */
    public boolean isOpen(int stageId) {
        StaticBountyStage config = staticBountyDataMgr.getBountyStageConfig(stageId);
        List<Integer> openTime = config.getOpenTime();

        Calendar calendar = Calendar.getInstance();
        int day_of_week = calendar.get(Calendar.DAY_OF_WEEK) - 1;

        if (day_of_week == 0) {
            day_of_week = 7;
        }
        return openTime.contains(day_of_week);
    }

    /**
     * 兑换物品
     *
     * @param rq
     * @param handler
     */
    public void exchange(GamePb6.TeamInstanceExchangeRq rq, ClientHandler handler) {

        Player player = playerDataManager.getPlayer(handler.getRoleId());
        TeamInstanceInfo teamInstanceInfo = player.getTeamInstanceInfo();


        int openServerweek = DateHelper.getServerOpenWeek();
        // 赏金兑换商店的商品是4星期一轮反复，所以对4求余
        int week = openServerweek % 4;
        if (week == 0) {
            week = 4;
        }


        int nowServerOpenWeek = DateHelper.getServerOpenWeek(teamInstanceInfo.getTime());
        if (teamInstanceInfo.getTime() != 0 && openServerweek != nowServerOpenWeek) {
            teamInstanceInfo.getCountInfo().clear();
        }


        // 避免跨周导致错误购买(买到已下架的物品)
        List<StaticBountyShop> shopList = getShopListByWeek(week);
        // 本周商品goodid列表
        List<Integer> goodIds = new ArrayList<>();
        for (StaticBountyShop staticBountyShop : shopList) {
            goodIds.add(staticBountyShop.getGoodId());
        }
        // 如果商品列表中不包含玩家要兑换的物品ID
        if (!goodIds.contains(rq.getGoodid())) {
            handler.sendErrorMsgToPlayer(GameError.BOUNTY_SHOP_NOGOOD);
            return;
        }

        // 兑换次数
        int count = 0;
        if (teamInstanceInfo.getCountInfo().containsKey(rq.getGoodid())) {
            count = teamInstanceInfo.getCountInfo().get(rq.getGoodid());
        }

        // 次数判断
        StaticBountyShop bountyShopConfig = staticBountyDataMgr.getBountyShopConfig(rq.getGoodid());
        if (count >= bountyShopConfig.getPersonNumber()) {
            handler.sendErrorMsgToPlayer(GameError.BOUNTY_SHOP_COUNT);
            return;
        }

        // 支持一次性兑换多个
        int times = 1;
        if (rq.hasCount()) {
            times = count;
        }

        // 物品验证
        int cost = bountyShopConfig.getCost() * times;
        if (player.getTeamInstanceInfo().getBounty() < cost) {
            handler.sendErrorMsgToPlayer(GameError.BOUNTY_NOT_ENOUGH);
            return;
        }

        // 扣除所消耗道具
        playerDataManager.subBounty(player, cost, AwardFrom.BOUNTY_SHOP_EXCHANGE);

        // 兑换成功，次数 + times
        teamInstanceInfo.getCountInfo().put(rq.getGoodid(), count + times);
        // 记录本次成功兑换时间
        teamInstanceInfo.setTime(System.currentTimeMillis());


        List<Integer> reward = bountyShopConfig.getReward();

        playerDataManager.addAward(player, reward.get(0), reward.get(1), reward.get(2), AwardFrom.BOUNTY_SHOP_EXCHANGE);

        GamePb6.TeamInstanceExchangeRs.Builder builder = GamePb6.TeamInstanceExchangeRs.newBuilder();
        builder.setItemCount(player.getTeamInstanceInfo().getBounty());
        CommonPb.Award awardPb = PbHelper.createAwardPb(reward.get(0), reward.get(1), reward.get(2));
        builder.addAward(awardPb);
        CommonPb.ShopBuy shopBuy = PbHelper.createShopBuy(rq.getGoodid(), times);
        builder.setBuyInfo(shopBuy);
        handler.sendMsgToPlayer(GamePb6.TeamInstanceExchangeRs.ext, builder.build());
    }

    /**
     * 获取赏金商店界面，兑换次数信息
     *
     * @param handler
     */
    public void getShopInfo(ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        // 计算今天是开服第几周
        int openServerweek = DateHelper.getServerOpenWeek();
        // 赏金兑换商店的商品是4星期一轮反复，所以对4求余
        int week = openServerweek % 4;
        if (week == 0) {
            week = 4;
        }
        List<StaticBountyShop> shopList = getShopListByWeek(week);
        if (CheckNull.isEmpty(shopList)) {
            LogUtil.error("赏金商店的商品未配置, openWeek:" + week);
            return;
        }
        TeamInstanceInfo teamInstanceInfo = player.getTeamInstanceInfo();
        Map<Integer, Integer> countInfo = teamInstanceInfo.getCountInfo();
        // 判断当前时间是否与上次领取时间在同一周


        int nowServerOpenWeek = DateHelper.getServerOpenWeek(teamInstanceInfo.getTime());
        if (teamInstanceInfo.getTime() != 0 && openServerweek != nowServerOpenWeek) {
            // 不是，则清空上周的领取记录
            countInfo.clear();
            teamInstanceInfo.setTime(System.currentTimeMillis());
        }
        GetBountyShopBuyRs.Builder builder = GetBountyShopBuyRs.newBuilder();
        builder.setOpenWeek(week);
        builder.setItemCount(player.getTeamInstanceInfo().getBounty());
        for (StaticBountyShop staticBountyShop : shopList) {
            int tc = 0;
            if (countInfo.containsKey(staticBountyShop.getGoodId())) {
                tc = teamInstanceInfo.getCountInfo().get(staticBountyShop.getGoodId());
            }
            CommonPb.ShopBuy shopBuy = PbHelper.createShopBuy(staticBountyShop.getGoodId(), tc);
            builder.addShopInfo(shopBuy);
        }
        handler.sendMsgToPlayer(GetBountyShopBuyRs.ext, builder.build());
    }

    /**
     * 获取本周展示的物品信息
     *
     * @param week 当前是开服第几周
     */
    private List<StaticBountyShop> getShopListByWeek(int week) {
        List<StaticBountyShop> shopConfigList = new ArrayList<>();
        for (StaticBountyShop staticBountyShop : staticBountyDataMgr.getBountyShopConfigList()) {
            if (staticBountyShop.getOpenWeek() == week) {
                shopConfigList.add(staticBountyShop);
            }
        }
        return shopConfigList;
    }

    /**
     * 通关
     *
     * @param player
     * @param builder
     * @param stageId
     */
    public void succFight(Player player, GamePb6.SyncTeamFightBossRq.Builder builder, int stageId, boolean isSucc) {

        TeamInstanceInfo teamInstanceInfo = player.getTeamInstanceInfo();

        int openServerweek = DateHelper.getServerOpenWeek();
        int nowServerOpenWeek = DateHelper.getServerOpenWeek(teamInstanceInfo.getTime());
        if (teamInstanceInfo.getTime() != 0 && openServerweek != nowServerOpenWeek) {
            teamInstanceInfo.getCountInfo().clear();
        }


        if (teamInstanceInfo.getTime() != 0 && !DateHelper.isToday(new Date(teamInstanceInfo.getTime()))) {

            teamInstanceInfo.getRewardInfo().clear();
            teamInstanceInfo.setTime(System.currentTimeMillis());
            teamInstanceInfo.setDayItemCount(0);
        }

        Map<Integer, Integer> rewardInfo = teamInstanceInfo.getRewardInfo();

        if (isSucc) {

            if (!rewardInfo.containsKey(stageId)) {
                rewardInfo.put(stageId, 0);
            }

            // 挑战次数+1
            int count = rewardInfo.get(stageId) + 1;
            rewardInfo.put(stageId, count);

            StaticBountyStage stageConfig = staticBountyDataMgr.getBountyStageConfig(stageId);
            List<List<Integer>> rewards = stageConfig.getReward();

            // 每次挑战成功后不受次数限制的奖励
            for (List<Integer> reward : rewards) {
                playerDataManager.addAward(player, reward.get(0), reward.get(1), reward.get(2), AwardFrom.BOUNTY_REWARD);
                CommonPb.Award awardPb = PbHelper.createAwardPb(reward.get(0), reward.get(1), reward.get(2));
                builder.addAward(awardPb);
            }


            // 一个零散配置
            StaticBountyConfig config = staticBountyDataMgr.getBountyConfig();
            float rate = 1;

            // 已经达到上限了就没有奖励可以领取
            if (teamInstanceInfo.getDayItemCount() < config.getCount1()) {
                // 如果已超过每日可挑战次数
                if (count > stageConfig.getCount()) {
                    rate = (config.getPercent() / 100f);
                }

                if (rate > 0) {

                    int award = (int) Math.ceil(stageConfig.getAward() * rate);

                    if (award > 0) {
                        teamInstanceInfo.setDayItemCount(teamInstanceInfo.getDayItemCount() + award);

                        playerDataManager.addAward(player, AwardType.BOUNTY, 0, award, AwardFrom.BOUNTY_REWARD);
                        CommonPb.Award awardPb = PbHelper.createAwardPb(AwardType.BOUNTY, 0, award);
                        builder.addAward(awardPb);
                    }

                }
            }

            teamInstanceInfo.setTime(System.currentTimeMillis());

            if (!rewardInfo.isEmpty()) {
                Set<Map.Entry<Integer, Integer>> entries = rewardInfo.entrySet();
                for (Map.Entry<Integer, Integer> e : entries) {
                    builder.addCount(PbHelper.createTwoIntPb(e.getKey(), e.getValue()));
                }
            }
            builder.setIsSuccess(1);

        } else {
            // 挑战次数
            if (!rewardInfo.isEmpty()) {
                Set<Map.Entry<Integer, Integer>> entries = rewardInfo.entrySet();
                for (Map.Entry<Integer, Integer> e : entries) {
                    builder.addCount(PbHelper.createTwoIntPb(e.getKey(), e.getValue()));
                }
            }
            teamInstanceInfo.setTime(System.currentTimeMillis());
            builder.setIsSuccess(0);
        }

        LogLordHelper.logTeamInstance(AwardFrom.BOUNTY_REWARD, player, stageId + "", isSucc ? 1 : 0);

    }

    /**
     * 更新任务数据
     *
     * @param player
     * @param taskType
     */
    public void changeTask(Player player, int taskType, long v) {


        List<StaticBountyWanted> configList = staticBountyDataMgr.getBountyWantedConfigList(taskType);

        if (configList == null) {
            LogUtil.error("通缉令的任务信息未配置, taskType:" + taskType);
            return;
        }

        for (StaticBountyWanted c : configList) {

            if (c.getTarget() == 2) {
                TeamTask teamTaskInfo = globalDataManager.gameGlobal.getTeamTask();
                if (teamTaskInfo.getTaskInfo().containsKey(c.getId())) {

                    if (teamTaskInfo.getTaskInfo().get(c.getId()) < c.getCond()) {
                        teamTaskInfo.getTaskInfo().put(c.getId(), teamTaskInfo.getTaskInfo().get(c.getId()) + v);
                    }

                }
            } else {

                TeamInstanceInfo teamInstanceInfo = player.getTeamInstanceInfo();
                Map<Integer, Integer> taskInfo = teamInstanceInfo.getTaskInfo();

                if (taskInfo.containsKey(c.getId())) {
                    if (taskInfo.get(c.getId()) >= c.getCond()) {
                        continue;
                    }
                    taskInfo.put(c.getId(), (int) (taskInfo.get(c.getId()) + v));
                }

            }

        }
    }

    /**
     * 获取通缉令奖励
     *
     * @param req
     */
    public void getTaskReward(ClientHandler handler, GetTaskRewardRq req) {
        int taskId = req.getTaskId();
        Player player = playerDataManager.getPlayer(handler.getRoleId());

        if (player.lord.getLevel() < getStaticBountyConfig().getLv()) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }

        TeamInstanceInfo teamInstanceInfo = player.getTeamInstanceInfo();
        Map<Integer, Integer> taskInfo = teamInstanceInfo.getTaskInfo();
        Map<Integer, Integer> rewardStateInfo = teamInstanceInfo.getTaskRewardState();

        // 判断奖励是否可领取
        if (rewardStateInfo.containsKey(taskId)) {
            LogUtil.error("error team task 1" + JSON.toJSONString(rewardStateInfo));
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }

        StaticBountyWanted config = staticBountyDataMgr.getBountyWantedConfig(taskId);


        if (config.getTarget() == 1) {
            // 若未做过该任务 或 任务次数不足
            if (!taskInfo.containsKey(taskId) || config.getCond() > taskInfo.get(taskId)) {
                LogUtil.error("error team task 3 " + JSON.toJSONString(taskInfo));
                LogUtil.error("error team task 3 " + config.getCond() + " taskInfo.get(taskId)=" + taskInfo.get(taskId));
                handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
                return;
            }

        } else {
            TeamTask teamTaskInfo = globalDataManager.gameGlobal.getTeamTask();

            if (!teamTaskInfo.getTaskInfo().containsKey(taskId) || config.getCond() > teamTaskInfo.getTaskInfo().get(taskId)) {
                LogUtil.error("error team task 2 " + JSON.toJSONString(teamTaskInfo));
                LogUtil.error("error team task 2 taskId=" + taskId + " cond=" + config.getCond() + " val=" + teamTaskInfo.getTaskInfo().get(taskId));
                handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
                return;
            }

        }


        GetTaskRewardRs.Builder builder = GetTaskRewardRs.newBuilder();

        playerDataManager.addAward(player, AwardType.BOUNTY, 0, config.getAwardList(), AwardFrom.BOUNTY_REWARD);
        CommonPb.Award awardPb = PbHelper.createAwardPb(AwardType.BOUNTY, 0, config.getAwardList());
        builder.addAward(awardPb);
        // 领取之后，将状态置为已领取
        rewardStateInfo.put(taskId, 1);
        handler.sendMsgToPlayer(GetTaskRewardRs.ext, builder.build());
    }

    /**
     * 获取所有任务进度，以及奖励的领取状态
     *
     * @param handler
     */
    public void getTaskStatus(ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());

        if (player.lord.getLevel() < getStaticBountyConfig().getLv()) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }


        TeamInstanceInfo teamInstanceInfo = player.getTeamInstanceInfo();
        Map<Integer, Integer> rewardStateInfo = teamInstanceInfo.getTaskRewardState();

        GetTaskRewardStatusRs.Builder builder = GetTaskRewardStatusRs.newBuilder();

        Map<Integer, Integer> taskInfo = teamInstanceInfo.getTaskInfo();
        for (Map.Entry<Integer, Integer> e : taskInfo.entrySet()) {
            CommonPb.TeamTask.Builder teamTask = CommonPb.TeamTask.newBuilder();
            teamTask.setTaskId(e.getKey());
            teamTask.setSchedule(e.getValue());
            teamTask.setStatus(rewardStateInfo.containsKey(e.getKey()) ? 1 : 0);
            builder.addTaskInfo(teamTask.build());
        }

        TeamTask teamTaskInfo = globalDataManager.gameGlobal.getTeamTask();
        Map<Integer, Long> taskInfo1 = teamTaskInfo.getTaskInfo();
        for (Map.Entry<Integer, Long> e : taskInfo1.entrySet()) {
            CommonPb.TeamTask.Builder teamTask = CommonPb.TeamTask.newBuilder();
            teamTask.setTaskId(e.getKey());
            teamTask.setSchedule(e.getValue());
            teamTask.setStatus(rewardStateInfo.containsKey(e.getKey()) ? 1 : 0);
            builder.addTaskInfo(teamTask.build());
        }

        handler.sendMsgToPlayer(GetTaskRewardStatusRs.ext, builder.build());
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
     * 获取挑战记录
     *
     * @param handler
     */
    public void getFightBossInfo(ClientHandler handler) {

        Player player = playerDataManager.getPlayer(handler.getRoleId());
        TeamInstanceInfo teamInstanceInfo = player.getTeamInstanceInfo();
        Map<Integer, Integer> rewardInfo = teamInstanceInfo.getRewardInfo();

        GamePb6.GetTeamFightBossInfoRs.Builder builder = GamePb6.GetTeamFightBossInfoRs.newBuilder();

        if (teamInstanceInfo.getTime() != 0 && !DateHelper.isToday(new Date(teamInstanceInfo.getTime()))) {
            int openServerweek = DateHelper.getServerOpenWeek();
            int nowServerOpenWeek = DateHelper.getServerOpenWeek(teamInstanceInfo.getTime());
            if (teamInstanceInfo.getTime() != 0 && openServerweek != nowServerOpenWeek) {
                teamInstanceInfo.getCountInfo().clear();
            }
            teamInstanceInfo.getRewardInfo().clear();
            teamInstanceInfo.setTime(System.currentTimeMillis());
            teamInstanceInfo.setDayItemCount(0);
        }
        builder.setDayItemCount(teamInstanceInfo.getDayItemCount());


        if (!rewardInfo.isEmpty()) {
            Set<Map.Entry<Integer, Integer>> entries = rewardInfo.entrySet();
            for (Map.Entry<Integer, Integer> e : entries) {
                builder.addCount(PbHelper.createTwoIntPb(e.getKey(), e.getValue()));
            }
        }
        handler.sendMsgToPlayer(GamePb6.GetTeamFightBossInfoRs.ext, builder.build());

    }

    public void logicRefreshTask() {
        try {
            TeamTask teamTaskInfo = globalDataManager.gameGlobal.getTeamTask();
            List<StaticBountyWanted> bountyWantedConfigList = staticBountyDataMgr.getBountyWantedConfigList();
            for (StaticBountyWanted c : bountyWantedConfigList) {
                if (isOpenTask(c.getOpenDay()) && isOpenTime(c.getOpenTime())) {
                    if (c.getTarget() == 2) {
                        if (!teamTaskInfo.getTaskInfo().containsKey(c.getId())) {
                            teamTaskInfo.getTaskInfo().put(c.getId(), 0L);
                        }
                    } else {
                        //个人任务 只遍历三个月上线
                        Iterator<Player> iterator = playerDataManager.getRecThreeMonOnlPlayer().values().iterator();
                        while (iterator.hasNext()) {
                            Player player = iterator.next();
                            try {
                                Map<Integer, Integer> taskInfo = player.getTeamInstanceInfo().getTaskInfo();
                                if (!taskInfo.containsKey(c.getId())) {
                                    taskInfo.put(c.getId(), 0);
                                }
                            } catch (Exception e) {
                                LogUtil.error(" 组队任务刷新, lordId:" + player.lord.getLordId(), e);
                            }
                        }
                    }
                } else {
                    if (c.getTarget() == 2) {
                        if (teamTaskInfo.getTaskInfo().containsKey(c.getId())) {
                            //如果完成了邮件发送
                            teamTaskInfo.getTaskInfo().remove(c.getId());
                            Iterator<Player> iterator = playerDataManager.getRecThreeMonOnlPlayer().values().iterator();
                            while (iterator.hasNext()) {
                                Player player = iterator.next();
                                player.getTeamInstanceInfo().getTaskRewardState().remove(c.getId());
                            }
                        }
                    } else {
                        //个人任务 只遍历三个月上线的玩家
                        Iterator<Player> iterator = playerDataManager.getRecThreeMonOnlPlayer().values().iterator();
                        while (iterator.hasNext()) {
                            Player player = iterator.next();
                            try {
                                /*if (player.is3MothLogin()) {
                                    continue;
                                }*/
                                Map<Integer, Integer> taskInfo = player.getTeamInstanceInfo().getTaskInfo();
                                if (taskInfo.isEmpty()) {
                                    continue;
                                }
                                if (taskInfo.containsKey(c.getId())) {
                                    //如果完成了邮件发送
                                    taskInfo.remove(c.getId());
                                    player.getTeamInstanceInfo().getTaskRewardState().remove(c.getId());
                                }
                            } catch (Exception e) {
                                LogUtil.error(" 组队任务刷新, lordId:" + player.lord.getLordId(), e);
                            }
                        }
                    }
                }
            }
        } catch (Exception e) {
            LogUtil.error(" 组队任务刷新 1", e);
        }
    }


    /**
     * 判断任务是否开启
     *
     * @return
     */
    public boolean isOpenTask(List<Integer> openDay) {
        Calendar calendar = Calendar.getInstance();
        int day_of_week = calendar.get(Calendar.DAY_OF_WEEK) - 1;

        if (day_of_week == 0) {
            day_of_week = 7;
        }
        return openDay.contains(day_of_week);
    }

    //判断是否是周六日
    public boolean isCrossOpen() {
        Calendar calendar = Calendar.getInstance();
        int day_of_week = calendar.get(Calendar.DAY_OF_WEEK);
        if ((day_of_week == 7 || day_of_week == 1) && CrossMinContext.isCrossMinSocket()) {
            return true;
        }
        return false;
    }


    private boolean isOpenTime(String time) {
        Calendar calendar = Calendar.getInstance();

        List<Long[]> open = getOpenTime(time);

        for (Long[] l : open) {
            if (calendar.getTimeInMillis() > l[0] && calendar.getTimeInMillis() < l[1]) {
                return true;
            }
        }

        return false;
    }


    private List<Long[]> getOpenTime(String time) {

        List<Long[]> result = new ArrayList<>();

        time = time.substring(1, time.length() - 1);
        String[] strings = time.split(",");
        for (String tStr : strings) {

            Long[] r = new Long[2];

            String[] split = tStr.split("-");
            String str = split[0];
            String[] split1 = str.split(":");
            Calendar calendar = Calendar.getInstance();
            calendar.set(Calendar.HOUR_OF_DAY, Integer.valueOf(split1[0]));
            calendar.set(Calendar.MINUTE, Integer.valueOf(split1[1]));
            calendar.set(Calendar.SECOND, 0);
            r[0] = calendar.getTimeInMillis();

            String str1 = split[1];
            String[] split2 = str1.split(":");
            Calendar calendar2 = Calendar.getInstance();
            calendar2.set(Calendar.HOUR_OF_DAY, Integer.valueOf(split2[0]));
            calendar2.set(Calendar.MINUTE, Integer.valueOf(split2[1]));
            calendar2.set(Calendar.SECOND, 0);
            r[1] = calendar2.getTimeInMillis();

            result.add(r);

        }

        return result;

    }


    private StaticBountyConfig getStaticBountyConfig() {

        return staticBountyDataMgr.getBountyConfig();
    }

}
