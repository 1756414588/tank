package com.game.service;

import com.game.constant.*;
import com.game.dataMgr.StaticActivateNewMgr;
import com.game.dataMgr.StaticActivityDataMgr;
import com.game.dataMgr.StaticVipDataMgr;
import com.game.domain.ActivityBase;
import com.game.domain.Member;
import com.game.domain.Player;
import com.game.domain.p.*;
import com.game.domain.s.*;
import com.game.manager.ActivityDataManager;
import com.game.manager.GlobalDataManager;
import com.game.manager.PartyDataManager;
import com.game.manager.PlayerDataManager;
import com.game.message.handler.ClientHandler;
import com.game.pb.BasePb;
import com.game.pb.CommonPb;
import com.game.pb.GamePb6;
import com.game.pb.GamePb6.GetActLuckyPoolLogRs;
import com.game.server.GameServer;
import com.game.util.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.*;

/**
 * @author GuiJie
 * @description 活动 节日碎片 幸运奖池
 * @created 2018/04/17 10:24
 */
@Component
public class ActivityNewService {

    @Autowired
    private StaticActivateNewMgr dataConfig;
    @Autowired
    private PlayerDataManager playerDataManager;
    @Autowired
    private StaticActivityDataMgr staticActivityDataMgr;
    @Autowired
    private ActivityDataManager activityDataManager;
    @Autowired
    private GlobalDataManager globalDataManager;
    @Autowired
    private ChatService chatService;
    @Autowired
    private StaticVipDataMgr staticVipDataMgr;
    @Autowired
    private RewardService rewardService;
    @Autowired
    private PartyDataManager partyDataManager;

    public void buyBoxRq(GamePb6.BuyBoxRq rq, ClientHandler handler) {

        StaticBouns configBouns = dataConfig.getBouns(rq.getId());

        Player player = playerDataManager.getPlayer(handler.getRoleId());

        clearDayBoxInfo(player);

        Map<Integer, Integer> dayBoxinfo = player.dayBoxinfo;
        int count = 0;
        if (dayBoxinfo.containsKey(rq.getId())) {
            count = dayBoxinfo.get(rq.getId());
        }

        if (count >= configBouns.getCount()) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }

        if (player.lord.getGold() < configBouns.getPrice()) {
            handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
            return;
        }

        playerDataManager.subGold(player, configBouns.getPrice(), AwardFrom.BUY_DAY_BOX);
        count = count + 1;
        dayBoxinfo.put(rq.getId(), count);
        player.dayBoxTime = System.currentTimeMillis();

        GamePb6.BuyBoxRs.Builder builder = GamePb6.BuyBoxRs.newBuilder();

        for (List<Integer> it : configBouns.getContent()) {
            int type = it.get(0);
            int itemId = it.get(1);
            int itemCount = it.get(2);
            int keyId = playerDataManager.addAward(player, type, itemId, itemCount, AwardFrom.BUY_DAY_BOX);
            builder.addAward(PbHelper.createAwardPb(type, itemId, itemCount, keyId));
        }

        builder.setGold(player.lord.getGold());

        Set<Map.Entry<Integer, Integer>> entries = dayBoxinfo.entrySet();
        for (Map.Entry<Integer, Integer> e : entries) {
            builder.addInfo(PbHelper.createTwoIntPb(e.getKey(), e.getValue()));
        }
        handler.sendMsgToPlayer(GamePb6.BuyBoxRs.ext, builder.build());
    }

    public void getBoxInfo(ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());

        clearDayBoxInfo(player);

        Map<Integer, Integer> dayBoxinfo = player.dayBoxinfo;

        GamePb6.GetBoxInfoRs.Builder builder = GamePb6.GetBoxInfoRs.newBuilder();

        Set<Map.Entry<Integer, Integer>> entries = dayBoxinfo.entrySet();
        for (Map.Entry<Integer, Integer> e : entries) {
            builder.addInfo(PbHelper.createTwoIntPb(e.getKey(), e.getValue()));
        }
        handler.sendMsgToPlayer(GamePb6.GetBoxInfoRs.ext, builder.build());
    }

    private void clearDayBoxInfo(Player player) {

        if (!DateHelper.isToday(new Date(player.dayBoxTime))) {

            boolean tsToWeek = false;
            if (!DateHelper.tsToWeek("1|00:00", player.dayBoxTime)) {
                tsToWeek = true;
            }
            List<StaticBouns> bounsList = dataConfig.getBounsList();
            for (StaticBouns c : bounsList) {
                if (c.getType() == 2 && tsToWeek) {
                    player.dayBoxinfo.put(c.getId(), 0);
                }
                if (c.getType() == 1) {
                    player.dayBoxinfo.put(c.getId(), 0);
                }
            }

            player.dayBoxTime = System.currentTimeMillis();
        }

    }

    public StaticActTechsell getStaticActTechsell(int techId) {
        // 活动开启
        if (!isOpen(ActivityConst.ACT_TECHSELL)) {
            return null;
        }
        StaticActTechsell config = dataConfig.getTechsellConfig(getAwardId(ActivityConst.ACT_TECHSELL));

        if (config == null) {
            return null;
        }

        List<Integer> techId1 = config.getTechId();
        if (techId1.contains(techId)) {
            return config;
        }
        return null;
    }

    public StaticActBuildsell getStaticActBuildsell(int buildId) {
        // 活动开启
        if (!isOpen(ActivityConst.ACT_BUILDSELL)) {
            return null;
        }
        StaticActBuildsell config = dataConfig.getBuildsellConfig(getAwardId(ActivityConst.ACT_BUILDSELL));

        List<Integer> buildingId = config.getBuildingId();
        if (buildingId.contains(buildId)) {
            return config;
        }
        return null;
    }

    public void getActNewPayInfoRq(GamePb6.GetActNewPayInfoRq rq, ClientHandler handler) {

        // 活动开启
        if (!isOpen(ActivityConst.ACT_NEW_PAY)) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        Player player = playerDataManager.getPlayer(handler.getRoleId());

        String version = getActivateVersion(ActivityConst.ACT_NEW_PAY);
        if (!version.equals(player.newPayVersion)) {
            player.newPayVersion = version;
            player.newPayInfo.clear();
        }

        List<StaticPay> payList = staticVipDataMgr.getPayList();
        GamePb6.GetActNewPayInfoRs.Builder builder = GamePb6.GetActNewPayInfoRs.newBuilder();

        for (StaticPay s : payList) {
            if (player.newPayInfo.contains(s.getPayId())) {
                builder.addInfo(PbHelper.createTwoIntPb(s.getPayId(), 1));
            } else {
                builder.addInfo(PbHelper.createTwoIntPb(s.getPayId(), 0));
            }
        }

        handler.sendMsgToPlayer(GamePb6.GetActNewPayInfoRs.ext, builder.build());

    }

    public void newPayAct(Player player, StaticPay staticPay) {
        // 活动开启
        if (!isOpen(ActivityConst.ACT_NEW_PAY)) {
            return;
        }

        if (staticPay == null) {
            return;
        }

        String version = getActivateVersion(ActivityConst.ACT_NEW_PAY);
        if (!version.equals(player.newPayVersion)) {
            player.newPayVersion = version;
            player.newPayInfo.clear();
        }

        StaticActPay payConfig = dataConfig.getPayConfig(getAwardId(ActivityConst.ACT_NEW_PAY), staticPay.getPayId());

        int ratio = 0;
        boolean isFirstPay = player.newPayInfo.contains(staticPay.getPayId());
        if (!isFirstPay) {
            ratio = payConfig.getRatio1();
        } else {
            ratio = payConfig.getRatio2();
        }

        if (!player.newPayInfo.contains(staticPay.getPayId())) {
            player.newPayInfo.add(staticPay.getPayId());
        }

        int gold = (int) (staticPay.getTopup() * (ratio / 100.0f));

        List<CommonPb.Award> awards = new ArrayList<>();

        int type = 16;
        int itemId = 0;
        int count = gold;
        awards.add(PbHelper.createAwardPb(type, itemId, count));
        playerDataManager.sendAttachMail(AwardFrom.NEW_PAY_FRIST, player, awards, MailType.MOLD_ATTACK_NEW_APY,
                TimeHelper.getCurrentSecond(), gold + "");

        GamePb6.SyncActNewPayInfoRq.Builder builder = GamePb6.SyncActNewPayInfoRq.newBuilder();
        List<StaticPay> payList = staticVipDataMgr.getPayList();
        for (StaticPay s : payList) {
            if (player.newPayInfo.contains(s.getPayId())) {
                builder.addInfo(PbHelper.createTwoIntPb(s.getPayId(), 1));
            } else {
                builder.addInfo(PbHelper.createTwoIntPb(s.getPayId(), 0));
            }
        }
        BasePb.Base.Builder msg = PbHelper.createSynBase(GamePb6.SyncActNewPayInfoRq.EXT_FIELD_NUMBER, GamePb6.SyncActNewPayInfoRq.ext,
                builder.build());
        GameServer.getInstance().synMsgToPlayer(player.ctx, msg);
    }

    /**
     * 获取假日碎片信息
     *
     * @param rq
     * @param handler
     */
    public void getFestivalInfo(GamePb6.GetFestivalInfoRq rq, ClientHandler handler) {

        // 活动开启
        if (!isOpen(ActivityConst.ACT_FESTIVAL)) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        Player player = playerDataManager.getPlayer(handler.getRoleId());

        clearFestivalInfo(player);

        FestivalInfo festivalInfo = player.getFestivalInfo();

        GamePb6.GetFestivalInfoRs.Builder builder = GamePb6.GetFestivalInfoRs.newBuilder();

        builder.setLoginRewardState(festivalInfo.getLoginState());
        List<StaticActFestivalPiece> rewardConfig = dataConfig.getRewardConfig(getAwardId(ActivityConst.ACT_FESTIVAL));
        for (StaticActFestivalPiece c : rewardConfig) {

            if (festivalInfo.getCount().containsKey(c.getId())) {
                builder.addLimitCount(festivalInfo.getCount().get(c.getId()));
            } else {
                builder.addLimitCount(0);
            }
        }
        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_FESTIVAL);
        if (activity != null && activity.getPropMap() != null) {
            for (Integer id : activity.getPropMap().keySet()) {
                builder.addActProp(PbHelper.createAtom2Pb(AwardType.ACTIVITY_PROP, id, activity.getPropMap().get(id)));
            }
        }

        handler.sendMsgToPlayer(GamePb6.GetFestivalInfoRs.ext, builder.build());

    }

    /**
     * 假日碎片兑换
     *
     * @param rq
     * @param handler
     */
    public void getFestivalReward(GamePb6.GetFestivalRewardRq rq, ClientHandler handler) {
        // 活动开启
        if (!isOpen(ActivityConst.ACT_FESTIVAL)) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        if (rq.getCount() <= 0) {
            handler.sendErrorMsgToPlayer(GameError.RED_PLAN_COUNT);
            return;
        }

        Player player = playerDataManager.getPlayer(handler.getRoleId());
        FestivalInfo festivalInfo = player.getFestivalInfo();

        StaticActFestivalPiece rewardConfig = dataConfig.getRewardConfig(getAwardId(ActivityConst.ACT_FESTIVAL), rq.getId());

        if (rewardConfig == null) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }

        int count = 0;
        if (festivalInfo.getCount().containsKey(rq.getId())) {
            count = festivalInfo.getCount().get(rq.getId());
        }

        if (rewardConfig.getPersonNumber() != 0 && (count + rq.getCount()) > rewardConfig.getPersonNumber()) {
            handler.sendErrorMsgToPlayer(GameError.RED_PLAN_COUNT);
            return;
        }

        List<Integer> decr = rewardConfig.getCost();
        List<Integer> configSost = new ArrayList<>();
        configSost.add(decr.get(0));
        configSost.add(decr.get(1));
        configSost.add(decr.get(2) * rq.getCount());

        List<List<Integer>> cost = new ArrayList<>();
        cost.add(configSost);

        boolean isEnougth = checkItem(player, cost);
        if (!isEnougth) {
            handler.sendErrorMsgToPlayer(GameError.PROP_NOT_ENOUGH);
            return;
        }

        decrItem(player, AwardFrom.GET_FESTIVAL_REWARD, cost);

        festivalInfo.getCount().put(rq.getId(), count + rq.getCount());

        List<List<Integer>> configReward = rewardConfig.getReward();
        List<List<Integer>> reward = new ArrayList<>();

        for (List<Integer> tem : configReward) {
            List<Integer> item = new ArrayList<>();
            item.add(tem.get(0));
            item.add(tem.get(1));
            item.add(tem.get(2) * rq.getCount());
            reward.add(item);
        }

        addItem(player, AwardFrom.GET_FESTIVAL_REWARD, reward);
        GamePb6.GetFestivalRewardRs.Builder builder = GamePb6.GetFestivalRewardRs.newBuilder();
        builder.setGold(player.lord.getGold());

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_FESTIVAL);
        if (activity != null && activity.getPropMap() != null) {
            for (Integer id : activity.getPropMap().keySet()) {
                builder.addActProp(PbHelper.createAtom2Pb(AwardType.ACTIVITY_PROP, id, activity.getPropMap().get(id)));
            }
        }

        for (StaticActFestivalPiece c : dataConfig.getRewardConfig(getAwardId(ActivityConst.ACT_FESTIVAL))) {

            if (festivalInfo.getCount().containsKey(c.getId())) {
                builder.addLimitCount(festivalInfo.getCount().get(c.getId()));
            } else {
                builder.addLimitCount(0);
            }
        }

        for (List<Integer> r : reward) {
            CommonPb.Award awardPb = PbHelper.createAwardPb(r.get(0), r.get(1), r.get(2));
            builder.addAward(awardPb);
        }

        for (List<Integer> r : cost) {
            CommonPb.Award awardPb = PbHelper.createAwardPb(r.get(0), r.get(1), r.get(2));
            builder.addDecrAward(awardPb);
        }

        handler.sendMsgToPlayer(GamePb6.GetFestivalRewardRs.ext, builder.build());

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

    public void getFestivalLoginReward(ClientHandler handler) {
        // 活动开启
        if (!isOpen(ActivityConst.ACT_FESTIVAL)) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        Player player = playerDataManager.getPlayer(handler.getRoleId());
        FestivalInfo festivalInfo = player.getFestivalInfo();

        if (festivalInfo.getLoginState() == 1) {
            handler.sendErrorMsgToPlayer(GameError.RED_PLAN_REWARD);
            return;
        }

        festivalInfo.setLoginState(1);

        List<List<Integer>> loginReward = dataConfig.getLoginReward(getAwardId(ActivityConst.ACT_FESTIVAL));

        addItem(player, AwardFrom.GET_FESTIVAL_LOGIN_REWARD, loginReward);

        GamePb6.GetFestivalLoginRewardRs.Builder builder = GamePb6.GetFestivalLoginRewardRs.newBuilder();
        for (List<Integer> r : loginReward) {
            CommonPb.Award awardPb = PbHelper.createAwardPb(r.get(0), r.get(1), r.get(2));
            builder.addAward(awardPb);
        }

        builder.setLoginRewardState(festivalInfo.getLoginState());

        handler.sendMsgToPlayer(GamePb6.GetFestivalLoginRewardRs.ext, builder.build());

    }

    /**
     * 清空活动数据
     *
     * @param player
     */
    private void clearFestivalInfo(Player player) {

        FestivalInfo festivalInfo = player.getFestivalInfo();
        if (festivalInfo.getVersion() == null || !festivalInfo.getVersion().equals(getActivateVersion(ActivityConst.ACT_FESTIVAL))) {
            festivalInfo.setVersion(getActivateVersion(ActivityConst.ACT_FESTIVAL));
            festivalInfo.setLoginState(0);
            festivalInfo.setLoginTime((int) (System.currentTimeMillis() / 1000L));
            festivalInfo.getCount().clear();
        }

        if (!DateHelper.isToday(new Date(festivalInfo.getLoginTime() * 1000L))) {
            festivalInfo.setLoginState(0);
            festivalInfo.setLoginTime((int) (System.currentTimeMillis() / 1000L));
        }

    }

    /**
     * 获取活动版本号 更具活动开始时间 活动开始时间变了 版本号就变了
     *
     * @return
     */
    private String getActivateVersion(int activityType) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(activityType);
        if (activityBase == null) {
            return null;
        }
        return DateHelper.formatDateTime(activityBase.getBeginTime(), "yyyy-MM-dd");
    }

    /**
     * 活动是否开启
     * -
     *
     * @return
     */
    public boolean isOpen(int activityType) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(activityType);
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
    private int getAwardId(int activityType) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(activityType);
        if (activityBase == null) {
            return 0;
        }
        return activityBase.getPlan().getAwardId();
    }

    /**
     *
     *
     *
     * =================幸运奖池=================
     *
     *
     *
     *
     */

    /**
     * 幸运奖池获取信息
     *
     * @param handler
     */
    public void getLuckyInfo(ClientHandler handler) {
        // 活动开启
        if (!isOpen(ActivityConst.ACT_LUCKY)) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        Player player = playerDataManager.getPlayer(handler.getRoleId());
        clearLuckyInfo(player);

        GamePb6.GetActLuckyInfoRs.Builder builder = GamePb6.GetActLuckyInfoRs.newBuilder();
        builder.setLuckyCount(getLuckCount(player));

        LuckyGlobalInfo luckyGlobalInfo = globalDataManager.gameGlobal.getLuckyGlobalInfo();
        int poolGold = luckyGlobalInfo.getPoolGold();
        builder.setPoolgold(poolGold);

        builder.setRechargegold(player.getLuckyInfo().getRecharge());
        handler.sendMsgToPlayer(GamePb6.GetActLuckyInfoRs.ext, builder.build());

    }

    /**
     * 获取剩余次数
     *
     * @param player
     * @return
     */
    private int getLuckCount(Player player) {
        LuckyInfo luckyInfo = player.getLuckyInfo();
        int rechargeCount = getRechargeCount();

        if (rechargeCount == 0) {
            return 0;
        }

        int count = luckyInfo.getRecharge() / rechargeCount;
        int result = count - luckyInfo.getUseLuckyCount();
        return result > 0 ? result : 0;
    }

    /**
     * 幸运奖池单次抽取
     *
     * @param rq
     * @param handler
     */
    public void getActLuckyReward(GamePb6.GetActLuckyRewardRq rq, ClientHandler handler) {
        // 活动开启
        if (!isOpen(ActivityConst.ACT_LUCKY)) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        Player player = playerDataManager.getPlayer(handler.getRoleId());

        clearLuckyInfo(player);

        int luckCount = getLuckCount(player);
        if (rq.getCount() < 0 || luckCount < rq.getCount()) {
            handler.sendErrorMsgToPlayer(GameError.RED_PLAN_COUNT);
            return;
        }

        List<StaticActLukyDraw> luckyConfig = dataConfig.getLuckyConfig(getAwardId(ActivityConst.ACT_LUCKY));
        Map<StaticActLukyDraw, Float> con = new HashMap<>();
        for (StaticActLukyDraw c : luckyConfig) {
            con.put(c, (c.getWeight() * 1.0f));
        }

        List<List<Integer>> reward = new ArrayList<>();

        List<Integer> luckyId = new ArrayList<>();

        for (int a = 1; a <= rq.getCount(); a++) {

            StaticActLukyDraw randomKey = LotteryUtil.getRandomKey(con);

            if (randomKey.getType() == 1) {
                float reate = randomKey.getRewardGold() / 100F;

                if (reate > 1.0f) {
                    reate = 1.0f;
                }
                LuckyGlobalInfo luckyGlobalInfo = globalDataManager.gameGlobal.getLuckyGlobalInfo();
                int poolGold = luckyGlobalInfo.getPoolGold();
                int tempGold = (int) Math.ceil(poolGold * reate);
                luckyGlobalInfo.setPoolGold(poolGold - tempGold);

                List<Integer> gold = new ArrayList<>();
                gold.add(16);
                gold.add(0);
                gold.add(tempGold);

                reward.add(gold);

                // [["恭喜玩家",0],["",0],["在幸运奖池活动中，运气爆棚，抽中了",0],["",0],["奖池的奖励，获得",0],["",0],["金币",0],["我也要抽",1]]
                if (randomKey.getNotice() == 1) {
                    chatService.sendWorldChat(
                            chatService.createSysChat(SysChatId.ACT_LUCKY, player.lord.getNick(), randomKey.getGoodName(), tempGold + ""));
                    ActLuckyPoolLog log = new ActLuckyPoolLog();
                    log.setName(player.lord.getNick());
                    log.setGoodInfo(randomKey.getRewardGold() + "-" + tempGold);
                    log.setTime(TimeHelper.getCurrentSecond());
                    LinkedList<ActLuckyPoolLog> luckyLog = luckyGlobalInfo.getLuckyLog();
                    luckyLog.add(log);
                    if (luckyLog.size() > 20) {
                        luckyLog.removeFirst();
                    }
                }

                syncPoolGold(luckyGlobalInfo, player.roleId);
            } else {
                reward.add(new ArrayList<Integer>(randomKey.getReward()));
            }
            luckyId.add(randomKey.getLucyId());

            // LogUtil.info(JSON.toJSONString(randomKey));
            // LogUtil.info(JSON.toJSONString(reward));
        }

        LuckyInfo luckyInfo = player.getLuckyInfo();
        luckyInfo.setUseLuckyCount(luckyInfo.getUseLuckyCount() + rq.getCount());

        addItem(player, AwardFrom.GET_LUCKY_REWARD, reward);

        GamePb6.GetActLuckyRewardRs.Builder builder = GamePb6.GetActLuckyRewardRs.newBuilder();
        builder.setLuckyCount(getLuckCount(player));

        for (List<Integer> r : reward) {
            CommonPb.Award awardPb = PbHelper.createAwardPb(r.get(0), r.get(1), r.get(2));
            builder.addAward(awardPb);
        }
        for (Integer l : luckyId) {
            builder.addLuckyId(l);
        }

        LuckyGlobalInfo luckyGlobalInfo = globalDataManager.gameGlobal.getLuckyGlobalInfo();
        int poolGold = luckyGlobalInfo.getPoolGold();
        builder.setPoolgold(poolGold);
        handler.sendMsgToPlayer(GamePb6.GetActLuckyRewardRs.ext, builder.build());

    }

    /**
     * 幸运中大奖记录
     *
     * @param handler
     */
    public void getLuckyLog(ClientHandler handler) {
        GetActLuckyPoolLogRs.Builder builder = GetActLuckyPoolLogRs.newBuilder();
        LuckyGlobalInfo luckyGlobalInfo = globalDataManager.gameGlobal.getLuckyGlobalInfo();
        List<ActLuckyPoolLog> luckyLog = luckyGlobalInfo.getLuckyLog();
        for (int i = 0; i < luckyLog.size(); i++) {
            builder.addLuckLog(PbHelper.createActLuckyPoolLog(luckyLog.get(i)));
            if (i >= 20) {
                return;
            }
        }
        handler.sendMsgToPlayer(GetActLuckyPoolLogRs.ext, builder.build());
    }

    /**
     * 清空上次活动数据
     *
     * @param player
     */
    private void clearLuckyInfo(Player player) {

        String version = getActivateVersion(ActivityConst.ACT_LUCKY);

        LuckyInfo luckyInfo = player.getLuckyInfo();
        if (!version.equals(luckyInfo.getVersion())) {

            luckyInfo.setUseLuckyCount(0);
            luckyInfo.setVersion(version);
            luckyInfo.setRecharge(0);
        }
        LuckyGlobalInfo luckyGlobalInfo = globalDataManager.gameGlobal.getLuckyGlobalInfo();
        if (!version.equals(luckyGlobalInfo.getVersion())) {
            luckyGlobalInfo.setVersion(version);
            luckyGlobalInfo.setPoolGold(getPoolInitCount());
            luckyGlobalInfo.getLuckyLog().clear();
        }

    }

    /**
     * 奖金池初始化数量
     *
     * @return
     */
    private int getPoolInitCount() {
        StaticActConfig actConfig = dataConfig.getActConfig(ActivityConst.ACT_LUCKY, getAwardId(ActivityConst.ACT_LUCKY));

        if (actConfig == null) {
            return 0;
        }

        return actConfig.getData2().get(0);
    }

    /**
     * 获取单次充值
     *
     * @return
     */
    private int getRechargeCount() {
        StaticActConfig actConfig = dataConfig.getActConfig(ActivityConst.ACT_LUCKY, getAwardId(ActivityConst.ACT_LUCKY));

        if (actConfig == null) {
            return 0;
        }

        return actConfig.getData2().get(1);
    }

    public void recharge(Player player, int rechargeCount) {

        try {
            // 活动开启
            if (!isOpen(ActivityConst.ACT_LUCKY)) {
                return;
            }

            clearLuckyInfo(player);

            LuckyInfo luckyInfo = player.getLuckyInfo();
            luckyInfo.setRecharge(luckyInfo.getRecharge() + rechargeCount);

            LuckyGlobalInfo luckyGlobalInfo = globalDataManager.gameGlobal.getLuckyGlobalInfo();
            luckyGlobalInfo.setPoolGold(luckyGlobalInfo.getPoolGold() + rechargeCount);

            syncPoolGold(luckyGlobalInfo, 0);
        } catch (Exception e) {
            LogUtil.error(e);
        }
    }

    private void syncPoolGold(LuckyGlobalInfo luckyGlobalInfo, long roleId) {
        GamePb6.ActLuckyPoolGoldChangeRs.Builder builder = GamePb6.ActLuckyPoolGoldChangeRs.newBuilder();
        builder.setPoolgold(luckyGlobalInfo.getPoolGold());
        BasePb.Base.Builder msg = PbHelper.createSynBase(GamePb6.ActLuckyPoolGoldChangeRs.EXT_FIELD_NUMBER,
                GamePb6.ActLuckyPoolGoldChangeRs.ext, builder.build());

        Iterator<Player> iterator = playerDataManager.getPlayers().values().iterator();

        while (iterator.hasNext()) {
            Player p = iterator.next();
            try {

                if (roleId != 0) {
                    if (p.lord.getLordId() != roleId && p.isActive() && p.isLogin && p.ctx != null) {
                        GameServer.getInstance().synMsgToPlayer(p.ctx, msg);
                    }
                } else {
                    if (p.isActive() && p.isLogin && p.ctx != null) {
                        GameServer.getInstance().synMsgToPlayer(p.ctx, msg);
                    }
                }

            } catch (Exception e) {
                e.printStackTrace();
                LogUtil.error("奖金池改变通知出错", e);
            }

        }
    }

    /**
     * gm添加次数
     *
     * @param player
     * @param count
     */
    public void gmAddLuckyCount(Player player, int count) {
        recharge(player, count);
    }

    public void gmFestivalClear(Player player) {
        FestivalInfo festivalInfo = player.getFestivalInfo();
        festivalInfo.getCount().clear();
    }

    public void getActNew2PayInfoRq(GamePb6.GetActNew2PayInfoRq rq, ClientHandler handler) {

        // 活动开启
        if (!isOpen(ActivityConst.ACT_NEW_PAY_NEW)) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        Player player = playerDataManager.getPlayer(handler.getRoleId());

        String version = getActivateVersion(ActivityConst.ACT_NEW_PAY_NEW);
        if (!version.equals(player.new2PayVersion)) {
            player.new2PayVersion = version;
            player.new2PayInfo.clear();
        }

        List<StaticPay> payList = staticVipDataMgr.getPayList();
        GamePb6.GetActNew2PayInfoRs.Builder builder = GamePb6.GetActNew2PayInfoRs.newBuilder();

        for (StaticPay s : payList) {
            if (player.new2PayInfo.contains(s.getPayId())) {
                builder.addInfo(PbHelper.createTwoIntPb(s.getPayId(), 1));
            } else {
                builder.addInfo(PbHelper.createTwoIntPb(s.getPayId(), 0));
            }
        }

        handler.sendMsgToPlayer(GamePb6.GetActNew2PayInfoRs.ext, builder.build());

    }

    public void new2PayAct(Player player, StaticPay staticPay) {
        // 活动开启
        if (!isOpen(ActivityConst.ACT_NEW_PAY_NEW)) {
            return;
        }

        if (staticPay == null) {
            return;
        }

        String version = getActivateVersion(ActivityConst.ACT_NEW_PAY_NEW);
        if (!version.equals(player.new2PayVersion)) {
            player.new2PayVersion = version;
            player.new2PayInfo.clear();
        }

        StaticActPayNew payConfig = dataConfig.payNew2Config(getAwardId(ActivityConst.ACT_NEW_PAY_NEW), staticPay.getPayId());

        int ratio = 0;
        boolean isFirstPay = player.new2PayInfo.contains(staticPay.getPayId());
        if (!isFirstPay) {
            ratio = payConfig.getRatio1();
        } else {

            List<List<Integer>> ratio2 = payConfig.getRatio2();
            Map<Integer, Float> ratioMap = new HashMap<>();
            for (List<Integer> li : ratio2) {
                ratioMap.put(li.get(0), (float) (li.get(1)));
            }

            ratio = LotteryUtil.getRandomKey(ratioMap);

            LogUtil.common("newpay roleId=" + player.lord.getLordId() + " ratio=" + ratio);
        }

        if (!player.new2PayInfo.contains(staticPay.getPayId())) {
            player.new2PayInfo.add(staticPay.getPayId());
        }

        int gold = (int) (staticPay.getTopup() * (ratio / 100.0f));

        List<CommonPb.Award> awards = new ArrayList<>();

        int type = 16;
        int itemId = 0;
        int count = gold;
        awards.add(PbHelper.createAwardPb(type, itemId, count));
        playerDataManager.sendAttachMail(AwardFrom.NEW_PAY_FRIST_NEW, player, awards, MailType.MOLD_ATTACK_NEW_APY_NEW,
                TimeHelper.getCurrentSecond(), gold + "", staticPay.getTopup() + "", ratio + "");

        GamePb6.SyncActNew2PayInfoRq.Builder builder = GamePb6.SyncActNew2PayInfoRq.newBuilder();
        List<StaticPay> payList = staticVipDataMgr.getPayList();
        for (StaticPay s : payList) {
            if (player.new2PayInfo.contains(s.getPayId())) {
                builder.addInfo(PbHelper.createTwoIntPb(s.getPayId(), 1));
            } else {
                builder.addInfo(PbHelper.createTwoIntPb(s.getPayId(), 0));
            }
        }
        BasePb.Base.Builder msg = PbHelper.createSynBase(GamePb6.SyncActNew2PayInfoRq.EXT_FIELD_NUMBER, GamePb6.SyncActNew2PayInfoRq.ext,
                builder.build());
        GameServer.getInstance().synMsgToPlayer(player.ctx, msg);
    }


    //---------------工会活动


    /**
     * @param player
     * @param eventType 1 军团夺得第1名,2个人夺得第1名,3参与1次军团战,4活动期间累计军团战获得n军团贡献
     * @param count
     */
    public void refreshState(Player player, int eventType, int count) {

        // 活动开启
        if (!isOpen(ActivityConst.ACT_WAR_ACTIVITY)) {
            return;
        }

        String version = getActivateVersion(ActivityConst.ACT_WAR_ACTIVITY);

        if (!version.equals(player.warActivityInfo.getVersion())) {
            player.warActivityInfo.setVersion(version);
            player.warActivityInfo.getInfo().clear();
            player.warActivityInfo.getRewardState().clear();
        }

        List<StaticActivityPartyWar> warConfig = dataConfig.getActivityPartyWarConfig(getAwardId(ActivityConst.ACT_WAR_ACTIVITY), eventType);
        if (warConfig == null) {
            return;
        }
        for (StaticActivityPartyWar config : warConfig) {
            if (!player.warActivityInfo.getInfo().containsKey(config.getId())) {
                player.warActivityInfo.getInfo().put(config.getId(), 0);
            }

            int c = player.warActivityInfo.getInfo().get(config.getId()) + count;

            if (c >= config.getEventCondition()) {
                player.warActivityInfo.getInfo().put(config.getId(), config.getEventCondition());
            } else {
                player.warActivityInfo.getInfo().put(config.getId(), c);
            }
        }


        syncInfo(player);

    }

    public void refreshStateWar(int partyId) {

        // 活动开启
        if (!isOpen(ActivityConst.ACT_WAR_ACTIVITY)) {
            return;
        }

        List<Member> members = partyDataManager.getMemberList(partyId);
        for (Member mbr : members) {
            try {
                Player mbrp = playerDataManager.getPlayer(mbr.getLordId());
                if (mbrp != null) {
                    refreshState(mbrp, 1, 1);
                }
            } catch (Exception e) {
                LogUtil.error(e);
            }
        }
    }


    /**
     * 军团战活跃 获取信息
     *
     * @param rq
     * @param handler
     */

    public void getWarActivityInfoRq(GamePb6.GetWarActivityInfoRq rq, ClientHandler handler) {
        // 活动开启
        if (!isOpen(ActivityConst.ACT_WAR_ACTIVITY)) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        String version = getActivateVersion(ActivityConst.ACT_WAR_ACTIVITY);

        if (!version.equals(player.warActivityInfo.getVersion())) {
            player.warActivityInfo.setVersion(version);
            player.warActivityInfo.getInfo().clear();
            player.warActivityInfo.getRewardState().clear();
        }
        GamePb6.GetWarActivityInfoRs.Builder builder = GamePb6.GetWarActivityInfoRs.newBuilder();

        Map<Integer, Integer> info = player.warActivityInfo.getInfo();
        for (Map.Entry<Integer, Integer> e : info.entrySet()) {
            builder.addInfo(PbHelper.createTwoIntPb(e.getKey(), e.getValue()));
        }
        Map<Integer, Integer> rewardState = player.warActivityInfo.getRewardState();
        for (Map.Entry<Integer, Integer> e : rewardState.entrySet()) {
            builder.addRewardState(PbHelper.createTwoIntPb(e.getKey(), e.getValue()));
        }
        handler.sendMsgToPlayer(GamePb6.GetWarActivityInfoRs.ext, builder.build());

    }

    /**
     * 军团战活跃 领取奖励
     *
     * @param rq
     * @param handler
     */
    public void getWarActivityRewardRq(GamePb6.GetWarActivityRewardRq rq, ClientHandler handler) {
        // 活动开启
        if (!isOpen(ActivityConst.ACT_WAR_ACTIVITY)) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        String version = getActivateVersion(ActivityConst.ACT_WAR_ACTIVITY);
        if (!version.equals(player.warActivityInfo.getVersion())) {
            player.warActivityInfo.setVersion(version);
            player.warActivityInfo.getInfo().clear();
            player.warActivityInfo.getRewardState().clear();
        }

        StaticActivityPartyWar warConfig = dataConfig.getActivityPartyWarConfig(rq.getId());
        Integer integer = player.warActivityInfo.getInfo().get(rq.getId());

        if (integer.intValue() < warConfig.getEventCondition()) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }


        if (player.warActivityInfo.getRewardState().containsKey(rq.getId())) {
            Integer state = player.warActivityInfo.getRewardState().get(rq.getId());
            if (state == 1) {
                handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
                return;
            }

        }

        player.warActivityInfo.getRewardState().put(rq.getId(), 1);

        List<List<Integer>> award = warConfig.getAward();

        addItem(player, AwardFrom.ACT_WAR_ACTIVITY, award);
        GamePb6.GetWarActivityRewardRs.Builder builder = GamePb6.GetWarActivityRewardRs.newBuilder();

        Map<Integer, Integer> rewardState = player.warActivityInfo.getRewardState();
        for (Map.Entry<Integer, Integer> e : rewardState.entrySet()) {
            builder.addRewardState(PbHelper.createTwoIntPb(e.getKey(), e.getValue()));
        }

        for (List<Integer> r : award) {
            CommonPb.Award awardPb = PbHelper.createAwardPb(r.get(0), r.get(1), r.get(2));
            builder.addAward(awardPb);
        }
        handler.sendMsgToPlayer(GamePb6.GetWarActivityRewardRs.ext, builder.build());

    }

    public void gmWarActivity(Player player, int id, int count) {
        String version = getActivateVersion(ActivityConst.ACT_WAR_ACTIVITY);
        if (!version.equals(player.warActivityInfo.getVersion())) {
            player.warActivityInfo.setVersion(version);
            player.warActivityInfo.getInfo().clear();
            player.warActivityInfo.getRewardState().clear();
        }

        if (id != 0) {
            player.warActivityInfo.getInfo().put(dataConfig.getActivityPartyWarConfig(id).getId(), count);
            player.warActivityInfo.getRewardState().put(id, 0);
        } else {
            List<StaticActivityPartyWar> warConfigList = dataConfig.getActivityPartyWarConfig();
            for (StaticActivityPartyWar c : warConfigList) {

                if (getAwardId(ActivityConst.ACT_WAR_ACTIVITY) == c.getAwardId()) {

                    if (count > c.getEventCondition()) {
                        player.warActivityInfo.getInfo().put(c.getId(), c.getEventCondition());
                    } else {
                        player.warActivityInfo.getInfo().put(c.getId(), count);
                    }
                    player.warActivityInfo.getRewardState().put(c.getId(), 0);
                }

            }
        }
        syncInfo(player);

    }

    private void syncInfo(Player player) {
        try {

            if (player.isLogin) {
                GamePb6.SynWarActivityInfoRq.Builder builder = GamePb6.SynWarActivityInfoRq.newBuilder();

                Map<Integer, Integer> info = player.warActivityInfo.getInfo();
                for (Map.Entry<Integer, Integer> e : info.entrySet()) {
                    builder.addInfo(PbHelper.createTwoIntPb(e.getKey(), e.getValue()));
                }

                BasePb.Base.Builder msg = PbHelper.createSynBase(GamePb6.SynWarActivityInfoRq.EXT_FIELD_NUMBER, GamePb6.SynWarActivityInfoRq.ext, builder.build());
                GameServer.getInstance().synMsgToPlayer(player.ctx, msg);
            }

        } catch (Exception e) {
            LogUtil.error(e);
        }
    }

    /**
     * 获取极限探险重置次数
     * @return
     */
    public int getExtrEprCount() {
        // 活动开启
        if (!isOpen(ActivityConst.ACT_EXTREPR__ACTIVITY)) {
				return 0;
        }
        return 1;
    }
}
