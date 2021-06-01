package com.game.service;

import com.game.actor.role.PlayerEventService;
import com.game.constant.*;
import com.game.dataMgr.*;
import com.game.domain.*;
import com.game.domain.p.*;
import com.game.domain.s.*;
import com.game.manager.ActivityDataManager;
import com.game.manager.PartyDataManager;
import com.game.manager.PlayerDataManager;
import com.game.message.handler.ClientHandler;
import com.game.message.handler.cs.GetQueAwardStatusHandler;
import com.game.pb.CommonPb;
import com.game.pb.CommonPb.ActCumulativePayInfo;
import com.game.pb.CommonPb.Award;
import com.game.pb.CommonPb.PirateData;
import com.game.pb.CommonPb.TwoInt;
import com.game.pb.GamePb2.*;
import com.game.pb.GamePb3.*;
import com.game.pb.GamePb4.*;
import com.game.pb.GamePb5.*;
import com.game.pb.GamePb6.*;
import com.game.util.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.*;
import java.util.Map.Entry;

/**
 * @author ChenKui
 * @version 创建时间：2015-10-29 下午5:16:57
 * @declare 活动中心
 */
@Service
public class ActionCenterService {

    @Autowired
    private PlayerDataManager playerDataManager;

    @Autowired
    private PartyDataManager partyDataManager;

    @Autowired
    private ActivityDataManager activityDataManager;

    @Autowired
    private StaticActivityDataMgr staticActivityDataMgr;

    @Autowired
    private StaticTankDataMgr staticTankDataMgr;

    @Autowired
    private StaticPropDataMgr staticPropDataMgr;

    @Autowired
    private StaticAwardsDataMgr staticAwardsDataMgr;

    @Autowired
    private StaticPartDataMgr staticPartDataMgr;

    @Autowired
    private ChatService chatService;

    @Autowired
    private PropService propService;

    @Autowired
    private PlayerEventService playerEventService;

    @Autowired
    private StaticTankConvertDataMgr tankConvertDataMgr;

    /**
     * 限时活动列表面板
     *
     * @param handler void
     */
    public void getActionCenterRq(ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }
        int platFlag = 1;// 默认为安卓玩家
        int platNo = player.account.getPlatNo();
        if (platNo == 94 || platNo == 95 || platNo > 500) {// IOS玩家
            platFlag = 2;
        }

        Date now = new Date();
        List<ActivityBase> list = staticActivityDataMgr.getActivityList();
        GetActionCenterRs.Builder builder = GetActionCenterRs.newBuilder();
        for (ActivityBase e : list) {
            if (e.getActivityId() < 100 || e.getActivityId() >= 1000) {
                continue;
            }
            int plat = e.getPlan().getPlat();
            if (plat == 1 && platFlag == 2) {// 如果是安卓平台,IOS玩家不可见
                continue;
            } else if (plat == 2 && platFlag == 1) {// 如果是IOS平台,安卓玩家不可见
                continue;
            }
            Date beginTime = e.getBeginTime();
            Date endTime = e.getEndTime();
            Date display = e.getDisplayTime();

            int open = e.getBaseOpen();
            if (open == ActivityConst.OPEN_CLOSE) {// 活动未开启
                continue;
            }

            if (display == null) {
                if (now.after(beginTime) && now.before(endTime)) {
                    builder.addActivity(PbHelper.createActivityPb(e, true, 0));
                }
            } else {
                if (now.after(beginTime)) {
                    if (now.before(endTime)) {
                        builder.addActivity(PbHelper.createActivityPb(e, false, 0));
                    } else if (now.after(endTime) && now.before(display)) {
                        builder.addActivity(PbHelper.createActivityPb(e, true, 0));
                    }
                }
            }
        }
        handler.sendMsgToPlayer(GetActionCenterRs.ext, builder.build());
    }

    /**
     * 排行榜奖励列表
     *
     * @param req
     * @param handler
     */
    public void getRankAwardListRq(GetRankAwardListRq req, ClientHandler handler) {
        int activityId = req.getActivityId();
        int rankType = req.getRankType();
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(activityId);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
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

        UsualActivityData activityData = activityDataManager.getUsualActivity(activityId);
        if (activityData == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        Activity activity = activityDataManager.getActivityInfo(player, activityId);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        List<StaticActRank> srankList = staticActivityDataMgr.getActRankList(activityKeyId, rankType);
        if (srankList == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_FINISH);
            return;
        }

        GetRankAwardListRs.Builder builder = GetRankAwardListRs.newBuilder();
        for (StaticActRank staticActRank : srankList) {
            builder.addRankAward(PbHelper.createRankAwardPb(staticActRank));
        }
        int step = activityBase.getStep();
        if (step == ActivityConst.OPEN_AWARD) {// 可领奖
            builder.setOpen(true);
        } else {// 不可领奖
            builder.setOpen(false);
        }
        handler.sendMsgToPlayer(GetRankAwardListRs.ext, builder.build());
    }

    /**
     * 获取排名奖励
     *
     * @param handler
     */
    public void getRankAwardRq(GetRankAwardRq req, ClientHandler handler) {
        int activityId = req.getActivityId();
        int rankType = req.getRankType();
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(activityId);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        int activityKeyId = activityBase.getKeyId();
        // 常规领取
        int step = activityBase.getStep();// end-display之间才可领取排名奖励
        if (step != 1) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
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

        UsualActivityData activityData = activityDataManager.getUsualActivity(activityId);
        if (activityData == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        Activity activity = activityDataManager.getActivityInfo(player, activityId);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        ActPlayerRank playerRank = activityData.getPlayerRank(rankType, lord.getLordId());
        if (playerRank == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_FINISH);
            return;
        }

        int rank = playerRank.getRank();
        StaticActRank staticActRank = staticActivityDataMgr.getActRank(activityKeyId, rankType, rank);
        if (staticActRank == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_FINISH);
            return;
        }

        Integer status = activity.getStatusMap().get(rankType);
        if (status != null && status != 0) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_GOT);
            return;
        }

        // 记录领奖状态
        activity.getStatusMap().put(rankType, 1);

        int serverId = player.account.getServerId();

        GetRankAwardRs.Builder builder = GetRankAwardRs.newBuilder();
        List<List<Integer>> awardList = staticActRank.getAwardList();
        for (List<Integer> e : awardList) {
            if (e.size() != 3) {
                continue;
            }
            int type = e.get(0);
            int id = e.get(1);
            int count = e.get(2);
            if (type == AwardType.EQUIP || type == AwardType.PART) {
                for (int c = 0; c < count; c++) {
                    int itemkey = playerDataManager.addAward(player, type, id, 1, AwardFrom.ACT_RANK_AWARD);
                    builder.addAward(PbHelper.createAwardPb(type, id, 1, itemkey));
                }
            } else {
                int keyId = playerDataManager.addAward(player, type, id, count, AwardFrom.ACT_RANK_AWARD);
                builder.addAward(PbHelper.createAwardPb(type, id, count, keyId));
            }
            LogHelper.logActivity(player.lord, activityId, 0, type, id, count, serverId);
        }
        handler.sendMsgToPlayer(GetRankAwardRs.ext, builder.build());
    }

    /**
     * 获取军团排名奖励
     *
     * @param handler
     */
    public void getPartyRankAwardRq(GetPartyRankAwardRq req, ClientHandler handler) {
        int activityId = req.getActivityId();
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(activityId);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        int activityKeyId = activityBase.getKeyId();
        // 常规领取
        int step = activityBase.getStep();// end-display之间才可领取排名奖励
        if (step != 1) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
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

        PartyData partyData = partyDataManager.getPartyByLordId(handler.getRoleId());
        if (partyData == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
            return;
        }

        UsualActivityData activityData = activityDataManager.getUsualActivity(activityId);
        if (activityData == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        Activity activity = activityDataManager.getActivityInfo(player, activityId);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        ActPartyRank actPartyRank = activityData.getPartyRank(partyData.getPartyId());
        if (actPartyRank == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_FINISH);
            return;
        }

        int rank = actPartyRank.getRank();
        StaticActRank staticActRank = staticActivityDataMgr.getActRank(activityKeyId, 0, rank);
        if (staticActRank == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_FINISH);
            return;
        }

        Integer status = activity.getStatusMap().get(0);
        if (status != null && status != 0) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_GOT);
            return;
        }

        Member member = partyDataManager.getMemberById(handler.getRoleId());
        Date endTime = activityBase.getEndTime();
        int enterTime = member.getEnterTime();
        if (enterTime != 0) {
            Date enterDate = TimeHelper.getDate(enterTime);
            if (enterDate != null && enterDate.after(endTime)) {
                handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_FINISH);
                return;
            }
        }

        // 记录领奖状态
        activity.getStatusMap().put(0, 1);
        int serverId = player.account.getServerId();
        GetPartyRankAwardRs.Builder builder = GetPartyRankAwardRs.newBuilder();
        List<List<Integer>> awardList = staticActRank.getAwardList();
        for (List<Integer> e : awardList) {
            if (e.size() != 3) {
                continue;
            }
            int type = e.get(0);
            int id = e.get(1);
            int count = e.get(2);
            if (type == AwardType.EQUIP || type == AwardType.PART) {
                for (int c = 0; c < count; c++) {
                    int itemkey = playerDataManager.addAward(player, type, id, 1, AwardFrom.ACT_RANK_AWARD);
                    builder.addAward(PbHelper.createAwardPb(type, id, 1, itemkey));
                }
            } else {
                int keyId = playerDataManager.addAward(player, type, id, count, AwardFrom.ACT_RANK_AWARD);
                builder.addAward(PbHelper.createAwardPb(type, id, count, keyId));
            }
            LogHelper.logActivity(player.lord, activityId, 0, type, id, count, serverId);
        }
        handler.sendMsgToPlayer(GetPartyRankAwardRs.ext, builder.build());
    }

    /**
     * Function机甲洪流
     *
     * @param handler
     */
    public void getActMechaRq(ClientHandler handler) {
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
        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_MECHA);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_MECHA);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        int activityKeyId = activityBase.getKeyId();
        GetActMechaRs.Builder builder = GetActMechaRs.newBuilder();
        StaticActMecha single = staticActivityDataMgr.getMechaById(activityKeyId, 1);
        StaticActMecha ten = staticActivityDataMgr.getMechaById(activityKeyId, 10);
        if (single == null || ten == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
        }
        int free = 0;
        if (lord.getFreeMecha() != TimeHelper.getCurrentDay()) {
            free = 1;
        }
        List<Long> statusList = activity.getStatusList();
        int part1 = (int) statusList.get(0).longValue();
        int part2 = (int) statusList.get(1).longValue();
        int crit = (int) statusList.get(2).longValue();
        crit = crit == 0 ? 1 : crit;
        builder.setMechaSingle(PbHelper.createMechaPb(single, free, crit, part1));
        builder.setMechaTen(PbHelper.createMechaPb(ten, 0, crit, part2));
        handler.sendMsgToPlayer(GetActMechaRs.ext, builder.build());
    }

    /**
     * Function机甲洪流之抽取
     *
     * @param req
     * @param handler
     */
    public void doActMechaRq(DoActMechaRq req, ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }
        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_MECHA);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        int mechaId = req.getMechaId();
        Lord lord = player.lord;
        if (lord == null) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }
        StaticActMecha actMecha = staticActivityDataMgr.getMechaById(mechaId);
        int cost = actMecha.getCost();
        if (actMecha.getCount() == 1 && lord.getFreeMecha() != TimeHelper.getCurrentDay()) {
            cost = 0;
            lord.setFreeMecha(TimeHelper.getCurrentDay());
        }
        if (cost > player.lord.getGold()) {
            handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
            return;
        }
        if (cost > 0) {
            playerDataManager.subGold(player, cost, AwardFrom.ASSEMBLE_MECHA);
        }
        int serverId = player.account.getServerId();
        List<Long> statusList = activity.getStatusList();
        int part1 = 0;
        int part2 = 0;
        long crit = (int) statusList.get(2).longValue();
        crit = crit == 0 ? 1 : crit;
        DoActMechaRs.Builder builder = DoActMechaRs.newBuilder();
        for (int i = 0; i < actMecha.getCount(); i++) {
            part1 += getNum(actMecha.getTank1PartList()) * crit;
            part2 += getNum(actMecha.getTank2PartList()) * crit;
            crit = getNum(actMecha.getCritList());
        }
        statusList.set(0, statusList.get(0) + part1);
        statusList.set(1, statusList.get(1) + part2);
        statusList.set(2, crit);
        activity.setStatusList(statusList);
        builder.setTwoInt(PbHelper.createTwoIntPb((int) statusList.get(0).longValue(), (int) statusList.get(1).longValue()));
        builder.setCrit((int) crit);
        handler.sendMsgToPlayer(DoActMechaRs.ext, builder.build());
        LogHelper.logActivity(player.lord, ActivityConst.ACT_MECHA, cost, 0, 1, part1, serverId);
        LogHelper.logActivity(player.lord, ActivityConst.ACT_MECHA, cost, 0, 2, part2, serverId);
    }

    /**
     * 里面那个list的下标为1的 数字是权重 下标0是值 根据权重随机得出值
     *
     * @param list
     * @return int
     */
    private int getNum(List<List<Integer>> list) {
        int random = RandomHelper.randomInSize(100);
        int total = 0;
        for (List<Integer> e : list) {
            total += e.get(1);
            if (random < total) {
                return e.get(0);
            }
        }
        return 4;
    }

    /**
     * Function机甲洪流之组装
     *
     * @param req
     * @param handler
     */
    public void assembleMechaRq(AssembleMechaRq req, ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_MECHA);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        int mechaId = req.getMechaId();

        StaticActMecha staticActMecha = staticActivityDataMgr.getMechaById(mechaId);
        if (staticActMecha == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }

        StaticTank staticTank = staticTankDataMgr.getStaticTank(staticActMecha.getTank());
        if (staticTank == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }
        int index = 0;
        if (staticActMecha.getCount() == 10) {
            index = 1;
        }
        List<Long> statusList = activity.getStatusList();
        int part = (int) statusList.get(index).longValue();
        int count = part / 20;
        long reless = part % 20;
        if (count <= 0) {
            handler.sendErrorMsgToPlayer(GameError.PART_NOT_ENOUGH);
            return;
        }

        statusList.set(index, reless);

        int keyId = playerDataManager.addAward(player, AwardType.TANK, staticActMecha.getTank(), count, AwardFrom.ASSEMBLE_MECHA);

        AssembleMechaRs.Builder builder = AssembleMechaRs.newBuilder();
        builder.addAward(PbHelper.createAwardPb(AwardType.TANK, staticActMecha.getTank(), count, keyId));
        handler.sendMsgToPlayer(AssembleMechaRs.ext, builder.build());

        chatService.sendWorldChat(
                chatService.createSysChat(SysChatId.ASSEMBER_TANK, player.lord.getNick(), String.valueOf(staticActMecha.getTank())));
    }

    /**
     * Function建军节-返利环节
     *
     * @param handler
     */
    public void getActAmyRebate(GetActAmyRebateRq req, ClientHandler handler) {
        int activityId = req.getActivityId();
        if (activityId != ActivityConst.ACT_AMY_ID && activityId != ActivityConst.ACT_AMY_ID2) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(activityId);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
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

        Activity activity = activityDataManager.getActivityInfo(player, activityId);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        List<Long> statusList = activity.getStatusList();
        Map<Integer, Integer> countMap = new HashMap<Integer, Integer>();
        for (Long e : statusList) {
            int rebateId = (int) e.longValue();
            if (rebateId == 0) {
                continue;
            }
            StaticActRebate staticRebate = staticActivityDataMgr.getRebateById(rebateId);
            if (staticRebate == null) {
                continue;
            }
            Integer count = countMap.get(rebateId);
            if (count == null) {
                count = 0;
            }
            count++;
            countMap.put(rebateId, count);
        }

        GetActAmyRebateRs.Builder builder = GetActAmyRebateRs.newBuilder();
        Iterator<Entry<Integer, Integer>> it = countMap.entrySet().iterator();
        while (it.hasNext()) {
            Entry<Integer, Integer> next = it.next();
            int rebateId = next.getKey();
            int count = next.getValue();
            builder.addAmyRebate(PbHelper.createAmyRebatePb(rebateId, count));
        }
        handler.sendMsgToPlayer(GetActAmyRebateRs.ext, builder.build());
    }

    /**
     * Function欢庆返利
     *
     * @param req
     * @param handler
     */
    public void doActAmyRebateRq(DoActAmyRebateRq req, ClientHandler handler) {
        int activityId = req.getActivityId();
        if (activityId != ActivityConst.ACT_AMY_ID && activityId != ActivityConst.ACT_AMY_ID2) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(activityId);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }
        Activity activity = activityDataManager.getActivityInfo(player, activityId);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        Lord lord = player.lord;
        if (lord == null) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }
        int rebateId = req.getRebateId();
        StaticActRebate actRebate = staticActivityDataMgr.getRebateById(rebateId);
        if (actRebate == null) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }

        List<Long> statusList = activity.getStatusList();
        if (statusList.size() < 1) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }
        boolean flag = false;
        Iterator<Long> it = statusList.iterator();
        while (it.hasNext()) {
            int id = (int) it.next().longValue();
            if (rebateId == id) {
                it.remove();
                flag = true;
                break;
            }
        }

        if (!flag) {// 玩家身上不包含该奖励
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }

        int money = actRebate.getMoney();
        int rebate = actRebate.getRandomRebate();

        DoActAmyRebateRs.Builder builder = DoActAmyRebateRs.newBuilder();
        int addGold = money * rebate / 10;
        if (addGold > 0) {
            playerDataManager.addGold(player, addGold, AwardFrom.AMY_REBATE);
            builder.addAward(PbHelper.createAwardPb(AwardType.GOLD, 0, addGold));
        }
        builder.setGold(lord.getGold());

        handler.sendMsgToPlayer(DoActAmyRebateRs.ext, builder.build());
    }

    /**
     * Function建军节-全服欢庆
     *
     * @param handler
     */
    public void getActAmyfestivityRq(GetActAmyfestivityRq req, ClientHandler handler) {
        int activityId = req.getActivityId();
        if (activityId != ActivityConst.ACT_AMY_ID && activityId != ActivityConst.ACT_AMY_ID2) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(activityId);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
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

        UsualActivityData activityData = activityDataManager.getUsualActivity(activityId);
        if (activityData == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        Activity activity = activityDataManager.getActivityInfo(player, activityId);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        Map<Integer, Integer> statusMap = activity.getStatusMap();
        GetActAmyfestivityRs.Builder builder = GetActAmyfestivityRs.newBuilder();
        List<StaticActAward> condList = staticActivityDataMgr.getActAwardById(activityId);
        for (StaticActAward e : condList) {
            int keyId = e.getKeyId();
            Integer status = statusMap.get(keyId);
            if (status == null) {
                status = 0;
            }
            builder.addActivityCond(PbHelper.createActivityCondPb(e, status));
        }
        builder.setState(activityData.getGoal());
        handler.sendMsgToPlayer(GetActAmyfestivityRs.ext, builder.build());
    }

    /**
     * Function建军节-全服欢庆
     *
     * @param handler
     */
    public void doActAmyfestivityRq(DoActAmyfestivityRq req, ClientHandler handler) {
        int activityId = req.getActivityId();
        if (activityId != ActivityConst.ACT_AMY_ID && activityId != ActivityConst.ACT_AMY_ID2) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(activityId);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
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

        int keyId = req.getKeyId();
        StaticActAward actAward = staticActivityDataMgr.getActAward(keyId);
        if (actAward == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }

        UsualActivityData activityData = activityDataManager.getUsualActivity(activityId);
        if (activityData == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        Activity activity = activityDataManager.getActivityInfo(player, activityId);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        // 欢庆值不足,则不可领奖
        if (activityData.getGoal() < actAward.getCond()) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_FINISH);
            return;
        }

        Map<Integer, Integer> statusMap = activity.getStatusMap();
        Integer awardStatus = statusMap.get(keyId);
        if (awardStatus != null && awardStatus == 1) {
            handler.sendErrorMsgToPlayer(GameError.AWARD_HAD_GOT);
            return;
        }
        activity.getStatusMap().put(keyId, 1);

        DoActAmyfestivityRs.Builder builder = DoActAmyfestivityRs.newBuilder();
        List<List<Integer>> awardList = actAward.getAwardList();
        for (List<Integer> e : awardList) {
            if (e.size() != 3) {
                continue;
            }
            int type = e.get(0);
            int itemId = e.get(1);
            int count = e.get(2);
            if (type == AwardType.EQUIP || type == AwardType.PART) {
                for (int i = 0; i < count; i++) {
                    int itemkey = playerDataManager.addAward(player, type, itemId, 1, AwardFrom.ACTIVITY_AWARD);
                    builder.addAward(PbHelper.createAwardPb(type, itemId, 1, itemkey));
                }
            } else {
                int itemkey = playerDataManager.addAward(player, type, itemId, count, AwardFrom.ACTIVITY_AWARD);
                builder.addAward(PbHelper.createAwardPb(type, itemId, count, itemkey));
            }
        }

        handler.sendMsgToPlayer(DoActAmyfestivityRs.ext, builder.build());
    }

    /**
     * 极限单兵-主页面
     *
     * @param handler
     */
    public void getActFortuneRq(ClientHandler handler) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_PAWN_ID);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null || player.lord == null) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_PAWN_ID);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        GetActFortuneRs.Builder builder = GetActFortuneRs.newBuilder();
        int day = TimeHelper.getCurrentDay();
        if (player.lord.getPawn() != day) {
            builder.setFree(1);
        } else {
            builder.setFree(0);
        }
        int activityKeyId = activityBase.getKeyId();

        long score = activity.getStatusList().get(0);
        List<StaticActFortune> condList = staticActivityDataMgr.getActFortuneList(activityKeyId);
        for (StaticActFortune e : condList) {
            builder.addFortune(PbHelper.createFortunePb(e));
            builder.setDisplayList(e.getDisplayList());
        }
        builder.setScore((int) score);// 我的积分
        handler.sendMsgToPlayer(GetActFortuneRs.ext, builder.build());
    }

    /**
     * 极限单兵-排行榜{前十名,其他均为未入榜}
     *
     * @param handler
     */
    public void getActFortuneRankRq(ClientHandler handler) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_PAWN_ID);
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

        UsualActivityData activityData = activityDataManager.getUsualActivity(ActivityConst.ACT_PAWN_ID);
        if (activityData == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_PAWN_ID);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        // 我的积分
        long score = activity.getStatusList().get(0);

        GetActFortuneRankRs.Builder builder = GetActFortuneRankRs.newBuilder();
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
        builder.setScore((int) score);
        if (step == ActivityConst.OPEN_STEP) {
            builder.setOpen(false);
        } else if (step == ActivityConst.OPEN_AWARD) {
            builder.setOpen(true);
            Map<Integer, Integer> statusMap = activity.getStatusMap();
            if (statusMap.containsKey(ActivityConst.TYPE_DEFAULT)) {
                builder.setStatus(1);
            }
        }

        List<StaticActRank> staticActRankList = staticActivityDataMgr.getActRankList(activityKeyId, ActivityConst.TYPE_DEFAULT);
        if (staticActRankList != null) {
            for (StaticActRank e : staticActRankList) {
                builder.addRankAward(PbHelper.createRankAwardPb(e));
            }
        }
        handler.sendMsgToPlayer(GetActFortuneRankRs.ext, builder.build());
    }

    /**
     * 极限单兵-抽取
     *
     * @param req
     * @param handler
     */
    public void doActFortuneRq(DoActFortuneRq req, ClientHandler handler) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_PAWN_ID);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        int step = activityBase.getStep();
        if (step != 0) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
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

        UsualActivityData activityData = activityDataManager.getUsualActivity(ActivityConst.ACT_PAWN_ID);
        if (activityData == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_PAWN_ID);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        int fortuneId = req.getFortuneId();
        StaticActFortune staticActFortune = staticActivityDataMgr.getActFortune(fortuneId);
        if (staticActFortune == null) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }

        int day = TimeHelper.getCurrentDay();
        if (lord.getPawn() != day && staticActFortune.getCount() == 1) {// 单抽免费次数
            lord.setPawn(day);
        } else {
            int price = staticActFortune.getPrice();
            if (lord.getGold() < price) {
                handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
                return;
            }
            playerDataManager.subGold(player, price, AwardFrom.PAWN);
        }

        long score = activity.getStatusList().get(0);
        score = score + staticActFortune.getPoint();
        activity.getStatusList().set(0, score);

        // 优化：转盘新增每日目标
        DialDailyGoalInfo fortuneInfo = player.getFortuneDialDayInfo();
        if (fortuneInfo.getLastDay() == day) {
            fortuneInfo.setCount(fortuneInfo.getCount() + staticActFortune.getCount());
        } else {
            fortuneInfo.setLastDay(day);
            fortuneInfo.setCount(staticActFortune.getCount());
            fortuneInfo.getRewardStatus().clear();
        }

        List<StaticActAward> awards = staticActivityDataMgr.getActAwardById(activityBase.getKeyId());
        if (awards == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }
        // 更新每日目标奖励状态
        Map<Integer, Integer> status = fortuneInfo.getRewardStatus();
        for (StaticActAward award : awards) {
            if (fortuneInfo.getCount() >= award.getCond()
                    && (!status.containsKey(award.getKeyId()) || status.get(award.getKeyId()) == -1)) {
                status.put(award.getKeyId(), 0);
            }
        }

        // 计算排名
        if (score >= 500 && lord.getLevel() >= 10) {// 积分超过500才可进入排行
            activityData.addPlayerRank(lord.getLordId(), score, ActivityConst.RANK_PAWN, ActivityConst.DESC);
        }

        DoActFortuneRs.Builder builder = DoActFortuneRs.newBuilder();

        // 发放奖励
        int repeat = staticActFortune.getCount();
        for (int i = 0; i < repeat; i++) {
            List<Integer> list = staticActivityDataMgr.randomAwardList(staticActFortune.getAwardList());
            if (list == null || list.size() < 3) {
                continue;
            }
            int type = list.get(0);
            int id = list.get(1);
            int count = list.get(2);
            int keyId = playerDataManager.addAward(player, type, id, count, AwardFrom.PAWN);
            builder.addAward(PbHelper.createAwardPb(type, id, count, keyId));

            if (type == AwardType.CHIP) {
                StaticPart staticPart = staticPartDataMgr.getStaticPart(id);
                if (staticPart != null && staticPart.getQuality() >= 3) {
                    chatService.sendWorldChat(chatService.createSysChat(SysChatId.LUCK_ROUND, player.lord.getNick(), String.valueOf(id)));
                }
            }
        }

        builder.setScore((int) score);// 我的积分
        handler.sendMsgToPlayer(DoActFortuneRs.ext, builder.build());
    }

    /**
     * 极限单兵-抽取 获取每日目标界面信息
     *
     * @param handler
     */
    public void getActFortuneDayInfo(ClientHandler handler) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_PAWN_ID);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null || player.lord == null) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }
        List<StaticActAward> list = staticActivityDataMgr.getActAwardById(activityBase.getKeyId());
        if (list == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }
        DialDailyGoalInfo fortuneInfo = player.getFortuneDialDayInfo();
        Map<Integer, Integer> status = fortuneInfo.getRewardStatus();
        // 清除前一天的奖励信息
        int day = TimeHelper.getCurrentDay();
        if (fortuneInfo.getLastDay() != day) {
            status.clear();
            fortuneInfo.setCount(0);
        }
        for (StaticActAward award : list) {
            if (!status.containsKey(award.getKeyId())) {
                // -1 默认奖励不可领取状态
                status.put(award.getKeyId(), -1);
            }
        }
        GetActFortuneDayInfoRs.Builder builder = GetActFortuneDayInfoRs.newBuilder();
        builder.setCount(fortuneInfo.getCount());
        for (StaticActAward award : list) {
            builder.addRewardStatus(PbHelper.createTwoIntPb(award.getKeyId(), status.get(award.getKeyId())));
        }
        handler.sendMsgToPlayer(GetActFortuneDayInfoRs.ext, builder.build());
    }

    /**
     * 极限单兵 领取每日目标奖励
     *
     * @param handler, rq
     */
    public void getActFortuneDayAward(ClientHandler handler, GetFortuneDayAwardRq rq) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_PAWN_ID);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null || player.lord == null) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }
        int awardId = rq.getAwardId();
        StaticActAward award = staticActivityDataMgr.getActAward(awardId);
        DialDailyGoalInfo fortuneInfo = player.getFortuneDialDayInfo();
        Map<Integer, Integer> status = fortuneInfo.getRewardStatus();
        int day = TimeHelper.getCurrentDay();
        if (fortuneInfo.getLastDay() != day) {
            handler.sendErrorMsgToPlayer(GameError.ACT_NOT_REFRESH_DATA);
            return;
        }
        if (status.get(award.getKeyId()) == null || status.get(award.getKeyId()) != 0) {
            handler.sendErrorMsgToPlayer(GameError.ACT_AWARD_COND_LIMIT);
            return;
        }
        GetFortuneDayAwardRs.Builder builder = GetFortuneDayAwardRs.newBuilder();
        List<List<Integer>> awardList = award.getAwardList();
        builder.addAllAward(playerDataManager.addAwardsBackPb(player, awardList, AwardFrom.FORTUNE_DAYILGOAL_AWARD));
        // 将奖励状态置为已领取
        status.put(award.getKeyId(), 1);
        handler.sendMsgToPlayer(GetFortuneDayAwardRs.ext, builder.build());
    }

    /**
     * 勤劳致富-主页面
     *
     * @param handler
     */
    public void getActBeeRq(GetActBeeRq req, ClientHandler handler) {
        int activityid = req.getActivityId();
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(activityid);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
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
        UsualActivityData usualActivityData = activityDataManager.getUsualActivity(activityid);
        if (usualActivityData == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        Activity activity = activityDataManager.getActivityInfo(player, activityid);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        GetActBeeRs.Builder builder = GetActBeeRs.newBuilder();
        List<StaticActAward> condList = staticActivityDataMgr.getActAwardById(activityKeyId);
        List<CommonPb.ActivityCond> stoneList = new ArrayList<>();
        List<CommonPb.ActivityCond> ironList = new ArrayList<>();
        List<CommonPb.ActivityCond> oilList = new ArrayList<>();
        List<CommonPb.ActivityCond> copperList = new ArrayList<>();
        List<CommonPb.ActivityCond> siliconList = new ArrayList<>();
        for (StaticActAward e : condList) {
            int keyId = e.getKeyId();
            Integer status = activity.getStatusMap().get(keyId);
            if (status == null) {
                status = 0;
            }
            int sortId = e.getSortId();
            if (sortId == 0) {// 铁
                ironList.add(PbHelper.createActivityCondPb(e, status));
            } else if (sortId == 1) {// 石油
                oilList.add(PbHelper.createActivityCondPb(e, status));
            } else if (sortId == 2) {// 铜
                copperList.add(PbHelper.createActivityCondPb(e, status));
            } else if (sortId == 3) {// 钛
                siliconList.add(PbHelper.createActivityCondPb(e, status));
            } else if (sortId == 4) {// 水晶
                stoneList.add(PbHelper.createActivityCondPb(e, status));
            }
        }
        List<Long> status = activity.getStatusList();
        long collect = status.get(0);
        int state = collect > Integer.MAX_VALUE ? Integer.MAX_VALUE : (int) collect;
        builder.setIron(PbHelper.createCondStatePb(state, ironList));

        collect = status.get(1);
        state = collect > Integer.MAX_VALUE ? Integer.MAX_VALUE : (int) collect;
        builder.setOil(PbHelper.createCondStatePb(state, oilList));

        collect = status.get(2);
        state = collect > Integer.MAX_VALUE ? Integer.MAX_VALUE : (int) collect;
        builder.setCopper(PbHelper.createCondStatePb(state, copperList));

        collect = status.get(3);
        state = collect > Integer.MAX_VALUE ? Integer.MAX_VALUE : (int) collect;
        builder.setSilicon(PbHelper.createCondStatePb(state, siliconList));

        collect = status.get(4);
        state = collect > Integer.MAX_VALUE ? Integer.MAX_VALUE : (int) collect;
        builder.setStone(PbHelper.createCondStatePb(state, stoneList));

        handler.sendMsgToPlayer(GetActBeeRs.ext, builder.build());
    }

    /**
     * 勤劳致富-排行榜{每榜的前十名,其他均为未入榜}
     *
     * @param handler
     */
    public void getActBeeRankRq(GetActBeeRankRq req, ClientHandler handler) {
        int activityid = req.getActivityId();
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(activityid);
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

        UsualActivityData activityData = activityDataManager.getUsualActivity(activityid);
        if (activityData == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        Activity activity = activityDataManager.getActivityInfo(player, activityid);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        List<StaticActRank> srankList = staticActivityDataMgr.getActRankList(activityKeyId, ActivityConst.TYPE_DEFAULT);
        if (srankList == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }

        Map<Integer, Integer> statusMap = activity.getStatusMap();
        GetActBeeRankRs.Builder builder = GetActBeeRankRs.newBuilder();
        for (int index = 0; index < 5; index++) {

            long collect = activity.getStatusList().get(index);// 我的采集量

            LinkedList<ActPlayerRank> rankList = activityData.getPlayerRanks(index);// 排行榜
            List<CommonPb.ActPlayerRank> playerRanks = new ArrayList<CommonPb.ActPlayerRank>();

            for (int i = 0; i < rankList.size() && i < ActivityConst.RANK_BEE; i++) {// 榜单前十名
                ActPlayerRank e = rankList.get(i);
                long lordId = e.getLordId();
                Player rankPlayer = playerDataManager.getPlayer(lordId);
                if (rankPlayer == null || rankPlayer.lord == null) {
                    continue;
                }

                playerRanks.add(PbHelper.createActPlayerRank(e, rankPlayer.lord.getNick()));

            }
            if (statusMap.containsKey(index)) {// 奖励已领取
                builder.addBeeRank(PbHelper.createBeeRankPb(index + 1, collect, 1, playerRanks));
            } else {
                builder.addBeeRank(PbHelper.createBeeRankPb(index + 1, collect, 0, playerRanks));
            }
        }

        for (StaticActRank e : srankList) {
            builder.addRankAward(PbHelper.createRankAwardPb(e));
        }

        if (step == ActivityConst.OPEN_CLOSE || step == ActivityConst.OPEN_STEP) {
            builder.setOpen(false);
        } else if (step == ActivityConst.OPEN_AWARD) {
            builder.setOpen(true);
        }
        handler.sendMsgToPlayer(GetActBeeRankRs.ext, builder.build());
    }

    /**
     * 哈洛克宝藏
     *
     * @param handler
     */
    public void getActProfotoRq(ClientHandler handler) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_PROFOTO_ID);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
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
        StaticActProfoto staticActProfoto = staticActivityDataMgr.getActProfoto(activityKeyId);
        if (staticActProfoto == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }
        GetActProfotoRs.Builder builder = GetActProfotoRs.newBuilder();

        int preciousId = staticActProfoto.getPrecious();
        Prop precious = player.props.get(preciousId);
        if (precious == null) {
            builder.setProfoto(PbHelper.createProfotoPb(preciousId, 0));
        } else {
            builder.setProfoto(PbHelper.createProfotoPb(preciousId, precious.getCount()));
        }

        int trustId = staticActProfoto.getTrust();
        Prop trust = player.props.get(trustId);
        if (trust == null) {
            builder.setTrust(PbHelper.createProfotoPb(trustId, 0));
        } else {
            builder.setTrust(PbHelper.createProfotoPb(trustId, trust.getCount()));
        }

        int part1Id = staticActProfoto.getPart1();
        Prop part1 = player.props.get(part1Id);
        if (part1 == null) {
            builder.addParts(PbHelper.createProfotoPb(part1Id, 0));
        } else {
            builder.addParts(PbHelper.createProfotoPb(part1Id, part1.getCount()));
        }

        int part2Id = staticActProfoto.getPart2();
        Prop part2 = player.props.get(part2Id);
        if (part2 == null) {
            builder.addParts(PbHelper.createProfotoPb(part2Id, 0));
        } else {
            builder.addParts(PbHelper.createProfotoPb(part2Id, part2.getCount()));
        }

        int part3Id = staticActProfoto.getPart3();
        Prop part3 = player.props.get(part3Id);
        if (part3 == null) {
            builder.addParts(PbHelper.createProfotoPb(part3Id, 0));
        } else {
            builder.addParts(PbHelper.createProfotoPb(part3Id, part3.getCount()));
        }

        int part4Id = staticActProfoto.getPart4();
        Prop part4 = player.props.get(part4Id);
        if (part4 == null) {
            builder.addParts(PbHelper.createProfotoPb(part4Id, 0));
        } else {
            builder.addParts(PbHelper.createProfotoPb(part4Id, part4.getCount()));
        }

        handler.sendMsgToPlayer(GetActProfotoRs.ext, builder.build());
    }

    /**
     * 合成宝藏
     *
     * @param handler
     */
    public void doActProfotoRq(ClientHandler handler) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_PROFOTO_ID);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
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
        StaticActProfoto staticActProfoto = staticActivityDataMgr.getActProfoto(activityKeyId);
        if (staticActProfoto == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }

        int part1Id = staticActProfoto.getPart1();
        int part2Id = staticActProfoto.getPart2();
        int part3Id = staticActProfoto.getPart3();
        int part4Id = staticActProfoto.getPart4();
        Prop part1 = player.props.get(part1Id);
        Prop part2 = player.props.get(part2Id);
        Prop part3 = player.props.get(part3Id);
        Prop part4 = player.props.get(part4Id);
        if (part1 == null || part1.getCount() < 1 || part2 == null || part2.getCount() < 1 || part3 == null || part3.getCount() < 1
                || part4 == null || part4.getCount() < 1) {
            handler.sendErrorMsgToPlayer(GameError.PROP_NOT_ENOUGH);
            return;
        }

        DoActProfotoRs.Builder builder = DoActProfotoRs.newBuilder();

        int preciousId = staticActProfoto.getPrecious();

        playerDataManager.subProp(player, part1, 1, AwardFrom.ACT_PROFOTO);
        playerDataManager.subProp(player, part2, 1, AwardFrom.ACT_PROFOTO);
        playerDataManager.subProp(player, part3, 1, AwardFrom.ACT_PROFOTO);
        playerDataManager.subProp(player, part4, 1, AwardFrom.ACT_PROFOTO);
        int keyId = playerDataManager.addAward(player, AwardType.PROP, preciousId, 1, AwardFrom.ACTIVITY_AWARD);
        builder.addAward(PbHelper.createAwardPb(AwardType.PROP, preciousId, 1, keyId));
        builder.addParts(PbHelper.createProfotoPb(part1.getPropId(), part1.getCount()));
        builder.addParts(PbHelper.createProfotoPb(part2.getPropId(), part2.getCount()));
        builder.addParts(PbHelper.createProfotoPb(part3.getPropId(), part3.getCount()));
        builder.addParts(PbHelper.createProfotoPb(part4.getPropId(), part4.getCount()));
        handler.sendMsgToPlayer(DoActProfotoRs.ext, builder.build());
    }

    /**
     * 开启宝藏
     *
     * @param handler
     */
    public void unfoldProfotoRq(ClientHandler handler) {
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
        StaticActProfoto staticActProfoto = staticActivityDataMgr.getActProfoto(105);
        if (staticActProfoto == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }

        UnfoldProfotoRs.Builder builder = UnfoldProfotoRs.newBuilder();
        int preciousId = staticActProfoto.getPrecious();
        Prop precious = player.props.get(preciousId);
        if (precious == null || precious.getCount() <= 0) {
            handler.sendErrorMsgToPlayer(GameError.PROP_NOT_ENOUGH);
            return;
        }

        StaticProp staticProp = staticPropDataMgr.getStaticProp(preciousId);
        List<List<Integer>> effectValue = staticProp.getEffectValue();
        if (effectValue == null || effectValue.isEmpty()) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }
        List<Integer> one = effectValue.get(0);
        if (one.size() != 1) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }

        int trustId = staticActProfoto.getTrust();
        int trustCount = 0;
        Prop trust = player.props.get(trustId);
        if (trust == null || trust.getCount() <= 0) {
            if (lord.getGold() < 50) {
                handler.sendErrorMsgToPlayer(GameError.PROP_NOT_ENOUGH);
                return;
            }
            playerDataManager.subGold(player, 50, AwardFrom.ACT_PROFOTO);
        } else {
            playerDataManager.subProp(player, trust, 1, AwardFrom.ACT_PROFOTO);
            trustCount = trust.getCount();
        }
        playerDataManager.subProp(player, precious, 1, AwardFrom.ACT_PROFOTO);

        List<List<Integer>> awards = staticAwardsDataMgr.getAwards(one.get(0));

        builder.addAllAward(playerDataManager.addAwardsBackPb(player, awards, AwardFrom.USE_PROP));
        builder.setProfoto(PbHelper.createProfotoPb(precious.getPropId(), precious.getCount()));
        builder.setTrust(PbHelper.createProfotoPb(trustId, trustCount));
        handler.sendMsgToPlayer(UnfoldProfotoRs.ext, builder.build());

        if (awards != null && !awards.isEmpty()) {
            List<Integer> award = awards.get(0);
            chatService.sendWorldChat(chatService.createSysChat(SysChatId.HALOKE_TREASURE, player.lord.getNick(),
                    String.valueOf(award.get(0)), String.valueOf(award.get(1))));
        }

    }

    /**
     * 配件转盘-主页面
     *
     * @param handler
     */
    public void getActPartDialRq(ClientHandler handler) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_PART_DIAL_ID);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
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

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_PART_DIAL_ID);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        GetActPartDialRs.Builder builder = GetActPartDialRs.newBuilder();
        int monthAndDay = TimeHelper.getMonthAndDay(new Date());
        int partDial = lord.getPartDial();
        if (partDial / 100 != monthAndDay / 100) {
            partDial = monthAndDay;
        }

        int useCount = partDial % 100;
        int free = 0;
        if (lord.getVip() > 0) {
            free = 2 - useCount < 0 ? 0 : 2 - useCount;
        } else {
            free = 1 - useCount < 0 ? 0 : 1 - useCount;
        }
        builder.setFree(free);// 剩余次数

        long score = activity.getStatusList().get(0);
        List<StaticActFortune> condList = staticActivityDataMgr.getActFortuneList(ActivityConst.ACT_PART_DIAL_ID);
        for (StaticActFortune e : condList) {
            builder.addFortune(PbHelper.createFortunePb(e));
            builder.setDisplayList(e.getDisplayList());
        }
        builder.setScore((int) score);// 我的积分
        handler.sendMsgToPlayer(GetActPartDialRs.ext, builder.build());
    }

    /**
     * 配件转盘-排行榜{前十名,其他均为未入榜}
     *
     * @param handler
     */
    public void getActPartDialRankRq(ClientHandler handler) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_PART_DIAL_ID);
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

        UsualActivityData activityData = activityDataManager.getUsualActivity(ActivityConst.ACT_PART_DIAL_ID);
        if (activityData == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_PART_DIAL_ID);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        // 我的积分
        long score = activity.getStatusList().get(0);

        GetActPartDialRankRs.Builder builder = GetActPartDialRankRs.newBuilder();
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
        builder.setScore((int) score);
        if (step == ActivityConst.OPEN_STEP) {
            builder.setOpen(false);
        } else if (step == ActivityConst.OPEN_AWARD) {
            builder.setOpen(true);
            Map<Integer, Integer> statusMap = activity.getStatusMap();
            if (statusMap.containsKey(ActivityConst.TYPE_DEFAULT)) {
                builder.setStatus(1);
            }
        }

        List<StaticActRank> staticActRankList = staticActivityDataMgr.getActRankList(activityKeyId, ActivityConst.TYPE_DEFAULT);
        if (staticActRankList != null) {
            for (StaticActRank e : staticActRankList) {
                builder.addRankAward(PbHelper.createRankAwardPb(e));
            }
        }
        handler.sendMsgToPlayer(GetActPartDialRankRs.ext, builder.build());
    }

    /**
     * 配件转轴-抽取
     *
     * @param req
     * @param handler
     */
    public void doActPartDialRq(DoActPartDialRq req, ClientHandler handler) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_PART_DIAL_ID);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        int step = activityBase.getStep();
        if (step != 0) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
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

        UsualActivityData activityData = activityDataManager.getUsualActivity(ActivityConst.ACT_PART_DIAL_ID);
        if (activityData == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_PART_DIAL_ID);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        int fortuneId = req.getFortuneId();
        StaticActFortune staticActFortune = staticActivityDataMgr.getActFortune(fortuneId);
        if (staticActFortune == null) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }

        int monthAndDay = TimeHelper.getMonthAndDay(new Date());
        int partDial = lord.getPartDial();
        if (partDial / 100 != monthAndDay / 100) {
            partDial = monthAndDay;
        }
        int useCount = partDial % 100;
        int free = 0;
        if (lord.getVip() > 0) {
            free = 2 - useCount < 0 ? 0 : 2 - useCount;
        } else {
            free = 1 - useCount < 0 ? 0 : 1 - useCount;
        }

        if (free > 0 && staticActFortune.getCount() == 1) {// 单抽免费次数
            lord.setPartDial(partDial + 1);
        } else {
            int price = staticActFortune.getPrice();
            if (lord.getGold() < price) {
                handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
                return;
            }
            playerDataManager.subGold(player, price, AwardFrom.PART_DIAL);
        }

        DoActPartDialRs.Builder builder = DoActPartDialRs.newBuilder();

        // 发放奖励
        int scoreAdd = 0;
        int repeat = staticActFortune.getCount();
        for (int i = 0; i < repeat; i++) {
            List<Integer> list = staticActivityDataMgr.randomAwardList(staticActFortune.getAwardList());
            if (list == null || list.size() < 5) {
                continue;
            }
            int type = list.get(0);
            int id = list.get(1);
            int count = list.get(2);
            int keyId = playerDataManager.addAward(player, type, id, count, AwardFrom.PART_DIAL);
            scoreAdd += list.get(4);// 增加积分
            builder.addAward(PbHelper.createAwardPb(type, id, count, keyId));
        }

        long score = activity.getStatusList().get(0);
        score += scoreAdd;
        activity.getStatusList().set(0, score);
        // 计算排名
        if (score >= 250) {// 积分超过500才可进入排行
            activityData.addPlayerRank(lord.getLordId(), score, ActivityConst.RANK_PART_DIAL, ActivityConst.DESC);
        }

        builder.setScore((int) score);// 我的积分
        handler.sendMsgToPlayer(DoActPartDialRs.ext, builder.build());
    }

    /**
     * 坦克拉霸-主页面
     *
     * @param handler
     */
    public void getActTankRaffleRq(ClientHandler handler) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_TANK_RAFFLE_ID);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
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

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_TANK_RAFFLE_ID);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        StaticActRaffle staticActRaffle = staticActivityDataMgr.getActRaffle(activityKeyId);
        if (staticActRaffle == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }
        GetActTankRaffleRs.Builder builder = GetActTankRaffleRs.newBuilder();
        int tankRaffle = lord.getTankRaffle();
        int monthAndDay = TimeHelper.getMonthAndDay(new Date());
        if (tankRaffle != monthAndDay) {
            builder.setFree(1);
        } else {
            builder.setFree(0);
        }
        handler.sendMsgToPlayer(GetActTankRaffleRs.ext, builder.build());
    }

    /**
     * 坦克拉霸
     *
     * @param req
     * @param handler
     */
    public void doActTankRaffleRq(DoActTankRaffleRq req, ClientHandler handler) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_TANK_RAFFLE_ID);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
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

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_TANK_RAFFLE_ID);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        StaticActRaffle staticActRaffle = staticActivityDataMgr.getActRaffle(activityKeyId);
        if (staticActRaffle == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }
        int type = req.getType();
        int price = 0;
        int add = 1;
        if (type == 1) {
            int tankRaffle = lord.getTankRaffle();
            int monthAndDay = TimeHelper.getMonthAndDay(new Date());
            if (tankRaffle != monthAndDay) {// 免费一次抽取
                lord.setTankRaffle(monthAndDay);
            } else {
                price = staticActRaffle.getPrice();
            }
        } else {
            price = staticActRaffle.getTenPrice();
            add = 10;
        }
        if (lord.getGold() < price) {
            handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
            return;
        }

        if (price > 0) {
            playerDataManager.subGold(player, price, AwardFrom.ACTIVITY_DAY_BUY);
        }
        int serverId = player.account.getServerId();
        DoActTankRaffleRs.Builder builder = DoActTankRaffleRs.newBuilder();
        int color[] = staticActivityDataMgr.getColor(staticActRaffle);
        int count = staticActRaffle.getCount() * add;
        int tankId = staticActRaffle.getTankList().get(color[0] - 1);

        int keyId = playerDataManager.addAward(player, AwardType.TANK, tankId, count, AwardFrom.ACTIVITY_DAY_BUY);

        CommonPb.Award a = PbHelper.createAwardPb(AwardType.TANK, tankId, count, keyId);
        builder.addAward(a);

        LogHelper.logActivity(lord, ActivityConst.ACT_TANK_RAFFLE_ID, price, AwardType.TANK, tankId, count, serverId);

        for (int i = 0; i < 3; i++) {
            builder.addColor(color[i + 1]);
        }
        handler.sendMsgToPlayer(DoActTankRaffleRs.ext, builder.build());

        // 加入活动获取奖励发送消息
        propService.sendJoinActivityMsg(ActivityConst.ACT_TANK_RAFFLE_ID, player, Collections.singletonList(a));

    }

    /**
     * 坦克拉霸-主页面·新
     *
     * @param handler
     */
    public void getActNewRaffleRq(ClientHandler handler) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_NEW_RAFFLE_ID);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
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

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_NEW_RAFFLE_ID);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        StaticActRaffle staticActRaffle = staticActivityDataMgr.getActRaffle(activityKeyId);
        if (staticActRaffle == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }
        int lordTime = lord.getLockTime();
        int currentDay = TimeHelper.getCurrentDay();
        if (lordTime != currentDay) {
            lord.setLockTankId(0);
            lord.setLockTime(currentDay);
        }

        GetActNewRaffleRs.Builder builder = GetActNewRaffleRs.newBuilder();
        int tankRaffle = lord.getTankRaffle();
        int monthAndDay = TimeHelper.getMonthAndDay(new Date());
        if (tankRaffle != monthAndDay) {
            builder.setFree(1);
        } else {
            builder.setFree(0);
        }
        List<Integer> tankList = staticActRaffle.getTankList();
        for (Integer e : tankList) {
            builder.addTankId(e);
        }

        int lockId = lord.getLockTankId();
        if (tankList.indexOf(lockId) < 0) {
            lockId = 0;
            lord.setLockTankId(0);
        }

        builder.setLockId(lord.getLockTankId());
        handler.sendMsgToPlayer(GetActNewRaffleRs.ext, builder.build());
    }

    /**
     * 坦克拉霸·新
     *
     * @param req
     * @param handler
     */
    public void doActNewRaffleRq(DoActNewRaffleRq req, ClientHandler handler) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_NEW_RAFFLE_ID);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
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

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_NEW_RAFFLE_ID);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        StaticActRaffle staticActRaffle = staticActivityDataMgr.getActRaffle(activityKeyId);
        if (staticActRaffle == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }
        int type = req.getType();
        int price = 0;
        int add = 1;
        if (type == 1) {
            int tankRaffle = lord.getTankRaffle();
            int monthAndDay = TimeHelper.getMonthAndDay(new Date());
            if (tankRaffle != monthAndDay) {// 免费一次抽取
                lord.setTankRaffle(monthAndDay);
            } else {
                if (lord.getLockTankId() != 0) {
                    price = staticActRaffle.getLockPrice();
                } else {
                    price = staticActRaffle.getPrice();
                }
            }
        } else {
            if (lord.getLockTankId() != 0) {
                price = staticActRaffle.getLockTenPrice();
            } else {
                price = staticActRaffle.getTenPrice();

            }
            add = 10;
        }
        if (lord.getGold() < price) {
            handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
            return;
        }

        if (price > 0) {
            playerDataManager.subGold(player, price, AwardFrom.ACTIVITY_DAY_BUY);
        }

        int lordTime = lord.getLockTime();
        int currentDay = TimeHelper.getCurrentDay();
        if (lordTime != currentDay) {
            lord.setLockTankId(0);
            lord.setLockTime(currentDay);
        }

        DoActNewRaffleRs.Builder builder = DoActNewRaffleRs.newBuilder();
        int color[] = staticActivityDataMgr.getColor(staticActRaffle);
        int count = staticActRaffle.getCount() * add;
        int tankId = staticActRaffle.getTankList().get(color[0] - 1);
        if (price != 0 && lord.getLockTankId() != 0) {
            tankId = lord.getLockTankId();
        }
        int keyId = playerDataManager.addAward(player, AwardType.TANK, tankId, count, AwardFrom.ACTIVITY_DAY_BUY);
        builder.addAward(PbHelper.createAwardPb(AwardType.TANK, tankId, count, keyId));
        builder.setGold(lord.getGold());

        for (int i = 0; i < 3; i++) {
            builder.addColor(color[i + 1]);
        }
        handler.sendMsgToPlayer(DoActNewRaffleRs.ext, builder.build());
    }

    /**
     * 坦克拉霸锁定·新
     *
     * @param req
     * @param handler
     */
    public void lockNewRaffleRq(LockNewRaffleRq req, ClientHandler handler) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_NEW_RAFFLE_ID);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
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

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_NEW_RAFFLE_ID);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        StaticActRaffle staticActRaffle = staticActivityDataMgr.getActRaffle(activityKeyId);
        if (staticActRaffle == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }
        int tankId = req.getTankId();
        if (tankId != 0) {
            List<Integer> tankList = staticActRaffle.getTankList();
            if (tankList.indexOf(tankId) < 0) {
                handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
                return;
            }
        }
        lord.setLockTankId(tankId);
        lord.setLockTime(TimeHelper.getCurrentDay());
        LockNewRaffleRs.Builder builder = LockNewRaffleRs.newBuilder();
        builder.setResult(true);

        handler.sendMsgToPlayer(LockNewRaffleRs.ext, builder.build());
    }

    /**
     * 疯狂歼灭-主页面
     *
     * @param handler
     */
    public void getActDestroyRq(ClientHandler handler) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_TANK_DESTORY_ID);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
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
        UsualActivityData usualActivityData = activityDataManager.getUsualActivity(ActivityConst.ACT_TANK_DESTORY_ID);
        if (usualActivityData == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_TANK_DESTORY_ID);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        int nowDay = TimeHelper.getCurrentDay();

        List<Long> statusList = activity.getStatusList();
        GetActDestroyRs.Builder builder = GetActDestroyRs.newBuilder();
        List<StaticActAward> condList = staticActivityDataMgr.getActAwardById(activityKeyId);
        for (StaticActAward e : condList) {
            int keyId = e.getKeyId();
            Integer status = activity.getStatusMap().get(keyId);
            if (status == null) {
                status = 0;
            }
            int sortId = e.getSortId();
            int state = (int) statusList.get(sortId).longValue();

            if (activity.getEndTime() != nowDay && !e.getParam().trim().equals("0")) {// 清理歼灭数据{坦克,战车,火炮,火箭}
                status = 0;
                state = 0;
            }
            builder.addDestoryTank(PbHelper.createCondStatePb(state, e, status));
        }
        handler.sendMsgToPlayer(GetActDestroyRs.ext, builder.build());
    }

    /**
     * 疯狂歼灭-排行榜{前十名,其他均为未入榜}
     *
     * @param handler
     */
    public void getActDestroyRankRq(ClientHandler handler) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_TANK_DESTORY_ID);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        int activityKeyId = activityBase.getKeyId();
        int step = activityBase.getStep();
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

        UsualActivityData activityData = activityDataManager.getUsualActivity(ActivityConst.ACT_TANK_DESTORY_ID);
        if (activityData == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_TANK_DESTORY_ID);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        List<StaticActRank> srankList = staticActivityDataMgr.getActRankList(activityKeyId, ActivityConst.TYPE_DEFAULT);
        if (srankList == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }
        // 我的积分
        long score = activity.getStatusList().get(5);

        GetActDestroyRankRs.Builder builder = GetActDestroyRankRs.newBuilder();
        LinkedList<ActPlayerRank> rankList = activityData.getPlayerRanks(ActivityConst.TYPE_DEFAULT);

        // 去重
        if (!CheckNull.isEmpty(rankList)) {
            Set<Long> lordIdSet = new HashSet<Long>();

            Iterator<ActPlayerRank> its = rankList.iterator();
            while (its.hasNext()) {
                ActPlayerRank rk = its.next();
                if (lordIdSet.contains(rk.getLordId())) {
                    its.remove();
                    continue;
                }
                lordIdSet.add(rk.getLordId());
            }
            lordIdSet.clear();

            // for (int i = 0; i < rankList.size(); i++) {
            // rank = rankList.get(i);
            // if (lordIdSet.contains(rank.getLordId())) {
            // rankList.remove(i);
            // i--;
            // continue;
            // }
            // lordIdSet.add(rank.getLordId());
            // }
        }

        for (int i = 0; i < rankList.size() && i < ActivityConst.RANK_TANK_DESTORY; i++) {
            ActPlayerRank e = rankList.get(i);
            long lordId = e.getLordId();
            Player rankPlayer = playerDataManager.getPlayer(lordId);
            if (rankPlayer != null && rankPlayer.lord != null) {
                builder.addActPlayerRank(PbHelper.createActPlayerRank(e, rankPlayer.lord.getNick()));
            }
        }
        builder.setStatus(0);
        builder.setScore((int) score);
        if (step == ActivityConst.OPEN_STEP) {
            builder.setOpen(false);
        } else if (step == ActivityConst.OPEN_AWARD) {
            builder.setOpen(true);
            Map<Integer, Integer> statusMap = activity.getStatusMap();
            if (statusMap.containsKey(ActivityConst.TYPE_DEFAULT)) {
                builder.setStatus(1);
            }
        }

        List<StaticActRank> staticActRankList = staticActivityDataMgr.getActRankList(activityKeyId, ActivityConst.TYPE_DEFAULT);
        if (staticActRankList != null) {
            for (StaticActRank e : staticActRankList) {
                builder.addRankAward(PbHelper.createRankAwardPb(e));
            }
        }
        handler.sendMsgToPlayer(GetActDestroyRankRs.ext, builder.build());
    }

    /**
     * 技术革新主页面
     *
     * @param handler
     */
    public void getActTechRq(ClientHandler handler) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_TECH_ID);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        GetActTechRs.Builder builder = GetActTechRs.newBuilder();
        Iterator<StaticActTech> it = staticActivityDataMgr.getActTechMap().values().iterator();
        while (it.hasNext()) {
            StaticActTech next = it.next();
            builder.addTech(PbHelper.createTechPb(next));
        }
        handler.sendMsgToPlayer(GetActTechRs.ext, builder.build());
    }

    /**
     * 技术革新
     *
     * @param req
     * @param handler
     */
    public void doActTechRq(DoActTechRq req, ClientHandler handler) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_TECH_ID);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
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
        int techId = req.getTechId();
        StaticActTech staticActTech = staticActivityDataMgr.getActTech(techId);
        if (staticActTech == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }
        int costPropId = staticActTech.getPropId();
        int costCount = staticActTech.getCount();

        Prop prop = player.props.get(costPropId);
        if (prop == null || prop.getCount() < costCount) {
            handler.sendErrorMsgToPlayer(GameError.PROP_NOT_ENOUGH);
            return;
        }

        List<Integer> award = staticActivityDataMgr.getActTechAward(staticActTech);
        if (award == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }
        int serverId = player.account.getServerId();
        playerDataManager.subProp(player, prop, costCount, AwardFrom.ACTIVITY_TECH);
        // prop.setCount(prop.getCount() - costCount);
        DoActTechRs.Builder builder = DoActTechRs.newBuilder();
        int type = award.get(0);
        int itemId = award.get(1);
        int count = award.get(2);
        int keyId = playerDataManager.addAward(player, type, itemId, count, AwardFrom.ACTIVITY_TECH);
        builder.addAward(PbHelper.createAwardPb(type, itemId, count, keyId));

        LogHelper.logActivity(player.lord, ActivityConst.ACT_TECH_ID, 0, type, itemId, count, serverId);

        handler.sendMsgToPlayer(DoActTechRs.ext, builder.build());
    }

    /**
     * 武将招募-主页面
     *
     * @param handler
     */
    public void getActGeneralRq(GetActGeneralRq req, ClientHandler handler) {
        int actId = ActivityConst.ACT_GENERAL_ID;
        if (req.hasActId()) {
            actId = req.getActId();
        }
        if (actId != ActivityConst.ACT_GENERAL_ID && actId != ActivityConst.ACT_GOD_GENERAL_ID) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(actId);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
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

        Activity activity = activityDataManager.getActivityInfo(player, actId);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        int activityKeyId = activityBase.getKeyId();

        GetActGeneralRs.Builder builder = GetActGeneralRs.newBuilder();

        long score = activity.getStatusList().get(0);
        long times = activity.getStatusList().get(1);
        List<StaticActGeneral> condList = staticActivityDataMgr.getActGeneralList(activityKeyId);
        for (StaticActGeneral e : condList) {
            builder.addGeneral(PbHelper.createGeneralPb(e));
            builder.setLuck(e.getRepeat());
        }
        builder.setScore((int) score);// 我的积分
        builder.setCount((int) times);// 次数
        handler.sendMsgToPlayer(GetActGeneralRs.ext, builder.build());
    }

    /**
     * 武将招募-抽取
     *
     * @param req
     * @param handler
     */
    public void doActGeneralRq(DoActGeneralRq req, ClientHandler handler) {
        int actId = ActivityConst.ACT_GENERAL_ID;
        if (req.hasActId()) {
            actId = req.getActId();
        }
        if (actId != ActivityConst.ACT_GENERAL_ID && actId != ActivityConst.ACT_GOD_GENERAL_ID) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }

        ActivityBase activityBase = staticActivityDataMgr.getActivityById(actId);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
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

        int step = activityBase.getStep();
        if (step != ActivityConst.OPEN_STEP) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        UsualActivityData activityData = activityDataManager.getUsualActivity(actId);
        if (activityData == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        Activity activity = activityDataManager.getActivityInfo(player, actId);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        int generalId = req.getGeneralId();
        StaticActGeneral staticActGeneral = staticActivityDataMgr.getActGeneral(generalId);
        if (staticActGeneral == null) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }

        if (staticActGeneral.getActivityId() != actId) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }

        int price = staticActGeneral.getPrice();
        if (lord.getGold() < price) {
            handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
            return;
        }

        AwardFrom from = null;
        if (actId == ActivityConst.ACT_GENERAL_ID) {
            from = AwardFrom.ACTIVITY_GENERAL;
        } else {
            from = AwardFrom.ACTIVITY_GOD_GENERAL;
        }

        playerDataManager.subGold(player, price, from);

        List<Long> statusList = activity.getStatusList();

        long score = statusList.get(0);
        long times = statusList.get(1);

        int hotHero1 = (int) (times / staticActGeneral.getRepeat());

        score = score + staticActGeneral.getPoint();
        times = times + staticActGeneral.getCount();

        statusList.set(0, score);
        statusList.set(1, times);

        int hotHero2 = (int) (times / staticActGeneral.getRepeat());

        // 计算排名
        if (score >= 800) {// 积分超过800才可进入排行
            activityData.addPlayerRank(lord.getLordId(), score, ActivityConst.RANK_GENERAL, ActivityConst.DESC);
        }
        int serverId = player.account.getServerId();
        DoActGeneralRs.Builder builder = DoActGeneralRs.newBuilder();

        // 发放奖励
        int repeat = staticActGeneral.getCount();

        LogHelper.logActivity(lord, actId, price, 0, 0, 0, serverId);

        List<CommonPb.Award> awards = new ArrayList<CommonPb.Award>();
        CommonPb.Award a;
        if (hotHero1 != hotHero2) {// 出热门武将
            repeat -= 1;
            int keyId = playerDataManager.addAward(player, AwardType.HERO, staticActGeneral.getHeroId(), 1, from);
            a = PbHelper.createAwardPb(AwardType.HERO, staticActGeneral.getHeroId(), 1, keyId);
            awards.add(a);
            builder.addAward(a);
            LogHelper.logActivity(lord, actId, 0, AwardType.HERO, staticActGeneral.getHeroId(), 1, serverId);

            times = 0;
            statusList.set(1, times);
        }

        for (int i = 0; i < repeat; i++) {
            List<Integer> list = staticActivityDataMgr.randomAwardList(staticActGeneral.getAwardList());
            if (list == null || list.size() < 3) {
                continue;
            }
            int type = list.get(0);
            int id = list.get(1);
            int count = list.get(2);
            // 名将招募活动优化：招募将领通过概率获得安兴后，次数需要重置，重新开始计算次数，界面的幸运值会立即清空，重新开始累积幸运值
            if (hotHero1 == hotHero2 && id == staticActGeneral.getHeroId()) {
                if (times < staticActGeneral.getLeastTime()) {
                    repeat++;
                    continue;
                }
                times = 0;
                statusList.set(1, times);
            }
            int keyId = playerDataManager.addAward(player, type, id, count, from);
            a = PbHelper.createAwardPb(type, id, count, keyId);
            awards.add(a);
            builder.addAward(a);
            LogHelper.logActivity(lord, actId, 0, type, id, count, serverId);
        }

        builder.setScore((int) score);// 我的积分
        builder.setCount((int) times);// 次数
        handler.sendMsgToPlayer(DoActGeneralRs.ext, builder.build());

        // 发送加入活动消息
        propService.sendJoinActivityMsg(actId, player, awards);

        // 更新玩家最强实力
        playerEventService.calcStrongestFormAndFight(player);
    }

    /**
     * 招募武将-排行榜{前十名,其他均为未入榜}
     *
     * @param handler
     */
    public void getActGeneralRankRq(GetActGeneralRankRq req, ClientHandler handler) {
        int actId = ActivityConst.ACT_GENERAL_ID;
        if (req.hasActId()) {
            actId = req.getActId();
        }
        if (actId != ActivityConst.ACT_GENERAL_ID && actId != ActivityConst.ACT_GOD_GENERAL_ID) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }

        ActivityBase activityBase = staticActivityDataMgr.getActivityById(actId);
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

        UsualActivityData activityData = activityDataManager.getUsualActivity(actId);
        if (activityData == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        Activity activity = activityDataManager.getActivityInfo(player, actId);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        // 我的积分
        long score = activity.getStatusList().get(0);

        GetActGeneralRankRs.Builder builder = GetActGeneralRankRs.newBuilder();
        LinkedList<ActPlayerRank> rankList = activityData.getPlayerRanks(ActivityConst.TYPE_DEFAULT);
        for (int i = 0; i < rankList.size() && i < ActivityConst.RANK_GENERAL; i++) {
            ActPlayerRank e = rankList.get(i);
            long lordId = e.getLordId();
            Player rankPlayer = playerDataManager.getPlayer(lordId);
            if (rankPlayer != null && rankPlayer.lord != null) {
                builder.addActPlayerRank(PbHelper.createActPlayerRank(e, rankPlayer.lord.getNick()));
            }
        }
        builder.setStatus(0);
        builder.setScore((int) score);
        if (step == ActivityConst.OPEN_STEP) {
            builder.setOpen(false);
        } else if (step == ActivityConst.OPEN_AWARD) {
            builder.setOpen(true);
            Map<Integer, Integer> statusMap = activity.getStatusMap();
            if (statusMap.containsKey(ActivityConst.TYPE_DEFAULT)) {
                builder.setStatus(1);
            }
        }

        List<StaticActRank> staticActRankList = staticActivityDataMgr.getActRankList(activityKeyId, ActivityConst.TYPE_DEFAULT);
        if (staticActRankList != null) {
            for (StaticActRank e : staticActRankList) {
                builder.addRankAward(PbHelper.createRankAwardPb(e));
            }
        }
        handler.sendMsgToPlayer(GetActGeneralRankRs.ext, builder.build());
    }

    /**
     * 每日充值-主页面
     *
     * @param handler
     */
    public void getActEDayPayRq(ClientHandler handler) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_EDAY_PAY_ID);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
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

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_EDAY_PAY_ID);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        int dayiy = activityBase.getDayiy();
        dayiy = dayiy % 4 == 0 ? 4 : dayiy % 4;

        long status = activity.getStatusList().get(0);
        StaticActEverydayPay staticEverydayPay = staticActivityDataMgr.getActEverydayPay(dayiy);
        if (staticEverydayPay == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }
        GetActEDayPayRs.Builder builder = GetActEDayPayRs.newBuilder();
        builder.setState((int) status);
        builder.setGoldBoxId(staticEverydayPay.getBox1());
        builder.setPropBoxId(staticEverydayPay.getBox2());
        handler.sendMsgToPlayer(GetActEDayPayRs.ext, builder.build());
    }

    /**
     * 每日充值-领奖
     *
     * @param handler
     */
    public void doActEDayPayRq(ClientHandler handler) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_EDAY_PAY_ID);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
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

        UsualActivityData activityData = activityDataManager.getUsualActivity(ActivityConst.ACT_EDAY_PAY_ID);
        if (activityData == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_EDAY_PAY_ID);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        long status = activity.getStatusList().get(0);
        if (status == 0) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_FINISH);
            return;
        }
        if (status == 2) {
            handler.sendErrorMsgToPlayer(GameError.AWARD_HAD_GOT);
            return;
        }

        int dayiy = activityBase.getDayiy();
        dayiy = dayiy % 4 == 0 ? 4 : dayiy % 4;

        StaticActEverydayPay staticEverydayPay = staticActivityDataMgr.getActEverydayPay(dayiy);
        if (staticEverydayPay == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }
        activity.getStatusList().set(0, (long) 2);// 领取奖励

        DoActEDayPayRs.Builder builder = DoActEDayPayRs.newBuilder();

        // 开启两个箱子
        StaticProp goldBox = staticPropDataMgr.getStaticProp(staticEverydayPay.getBox1());
        if (goldBox != null && goldBox.getEffectValue().size() > 0) {// 金币箱子
            int awardId = goldBox.getEffectValue().get(0).get(0);
            List<List<Integer>> awardList = staticAwardsDataMgr.getAwards(awardId);
            for (List<Integer> e : awardList) {
                if (e.size() < 3) {
                    continue;
                }
                int type = e.get(0);
                int id = e.get(1);
                int count = e.get(2);
                playerDataManager.addAward(player, type, id, count, AwardFrom.EVERY_DAY_PAY);
                builder.addAward(PbHelper.createAwardPb(type, id, count));
            }
        }
        String params = activityData.getParams();

        // 箱子特殊道具
        boolean flag = false;
        StaticProp propBox = staticPropDataMgr.getStaticProp(staticEverydayPay.getBox2());
        if (propBox != null && propBox.getEffectValue().size() > 0) {
            int awardId = propBox.getEffectValue().get(0).get(0);
            List<List<Integer>> awardList = staticAwardsDataMgr.getAwards(awardId);
            for (List<Integer> e : awardList) {
                if (e.size() < 3) {
                    continue;
                }
                int type = e.get(0);
                int id = e.get(1);
                int count = e.get(2);

                flag = staticActivityDataMgr.isSpecial(staticEverydayPay, type, id);
                if (flag) {
                    flag = false;
                    String pp = new StringBuffer().append(type).append("_").append(id).toString();
                    if (params != null && !params.equals("")) {
                        int index = params.indexOf(pp);
                        if (index > -1) {// 该特殊道具被已被抽取
                            flag = true;
                        } else {// 未抽取到,则记录的特殊道具
                            pp = new StringBuffer().append(params).append(",").append(pp).toString();
                        }
                    }

                    if (!flag) {// 添加奖励
                        int keyId = playerDataManager.addAward(player, type, id, count, AwardFrom.EVERY_DAY_PAY);
                        builder.addAward(PbHelper.createAwardPb(type, id, count, keyId));
                        activityData.setParams(pp);
                    }

                    flag = false;
                } else {
                    int keyId = playerDataManager.addAward(player, type, id, count, AwardFrom.EVERY_DAY_PAY);
                    builder.addAward(PbHelper.createAwardPb(type, id, count, keyId));

                }
            }
        }

        // 出了特殊道具,并且已被抽取掉
        if (flag) {// 补一个道具
            StaticProp fixBox = staticPropDataMgr.getStaticProp(staticEverydayPay.getBox3());
            if (fixBox != null && fixBox.getEffectValue().size() > 0) {
                int awardId = fixBox.getEffectValue().get(0).get(0);
                List<List<Integer>> awardList = staticAwardsDataMgr.getAwards(awardId);
                for (List<Integer> e : awardList) {
                    if (e.size() < 3) {
                        continue;
                    }
                    int type = e.get(0);
                    int id = e.get(1);
                    int count = e.get(2);
                    int keyId = playerDataManager.addAward(player, type, id, count, AwardFrom.EVERY_DAY_PAY);
                    builder.addAward(PbHelper.createAwardPb(type, id, count, keyId));
                }
            }
        }
        handler.sendMsgToPlayer(DoActEDayPayRs.ext, builder.build());
    }

    /**
     * 消费转盘-主页面
     *
     * @param handler
     */
    public void getActConsumeDialRq(ClientHandler handler) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_CONSUME_DIAL_ID);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
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

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_CONSUME_DIAL_ID);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        GetActConsumeDialRs.Builder builder = GetActConsumeDialRs.newBuilder();
        int monthAndDay = TimeHelper.getMonthAndDay(new Date());
        int consumeDial = lord.getConsumeDial();
        if (consumeDial / 100 != monthAndDay / 100) {
            consumeDial = monthAndDay;
        }

        int useCount = consumeDial % 100;
        int free = 0;
        if (lord.getVip() > 0) {
            free = 2 - useCount < 0 ? 0 : 2 - useCount;
        } else {
            free = 1 - useCount < 0 ? 0 : 1 - useCount;
        }

        builder.setFree(free);// 剩余次数
        long consume = activity.getStatusList().get(0);
        builder.setCount((int) (consume / 199));

        long score = activity.getStatusList().get(1);
        List<StaticActFortune> condList = staticActivityDataMgr.getActFortuneList(ActivityConst.ACT_CONSUME_DIAL_ID);
        for (StaticActFortune e : condList) {
            builder.addFortune(PbHelper.createFortunePb(e));
            builder.setDisplayList(e.getDisplayList());
        }
        builder.setScore((int) score);// 我的积分
        handler.sendMsgToPlayer(GetActConsumeDialRs.ext, builder.build());
    }

    /**
     * 消费转盘-排行榜{前三十名,其他均为未入榜}
     *
     * @param handler
     */
    public void getActConsumeDialRankRq(ClientHandler handler) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_CONSUME_DIAL_ID);
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

        UsualActivityData activityData = activityDataManager.getUsualActivity(ActivityConst.ACT_CONSUME_DIAL_ID);
        if (activityData == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_CONSUME_DIAL_ID);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        // 我的积分
        long score = activity.getStatusList().get(1);

        GetActConsumeDialRankRs.Builder builder = GetActConsumeDialRankRs.newBuilder();
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
        builder.setScore((int) score);
        if (step == ActivityConst.OPEN_STEP) {
            builder.setOpen(false);
        } else if (step == ActivityConst.OPEN_AWARD) {
            builder.setOpen(true);
            Map<Integer, Integer> statusMap = activity.getStatusMap();
            if (statusMap.containsKey(ActivityConst.TYPE_DEFAULT)) {
                builder.setStatus(1);
            }
        }

        List<StaticActRank> staticActRankList = staticActivityDataMgr.getActRankList(activityKeyId, ActivityConst.TYPE_DEFAULT);
        if (staticActRankList != null) {
            for (StaticActRank e : staticActRankList) {
                builder.addRankAward(PbHelper.createRankAwardPb(e));
            }
        }
        handler.sendMsgToPlayer(GetActConsumeDialRankRs.ext, builder.build());
    }

    /**
     * 消费转轴-抽取
     *
     * @param req
     * @param handler
     */
    public void doActConsumeDialRq(DoActConsumeDialRq req, ClientHandler handler) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_CONSUME_DIAL_ID);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        int step = activityBase.getStep();
        if (step != 0) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
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

        UsualActivityData activityData = activityDataManager.getUsualActivity(ActivityConst.ACT_CONSUME_DIAL_ID);
        if (activityData == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_CONSUME_DIAL_ID);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        int fortuneId = req.getFortuneId();
        StaticActFortune staticActFortune = staticActivityDataMgr.getActFortune(fortuneId);
        if (staticActFortune == null) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }

        int monthAndDay = TimeHelper.getMonthAndDay(new Date());
        int consumeDial = lord.getConsumeDial();
        if (consumeDial / 100 != monthAndDay / 100) {
            consumeDial = monthAndDay;
        }
        int useCount = consumeDial % 100;
        int free = 0;
        if (lord.getVip() > 0) {
            free = 2 - useCount < 0 ? 0 : 2 - useCount;
        } else {
            free = 1 - useCount < 0 ? 0 : 1 - useCount;
        }

        if (free > 0 && staticActFortune.getCount() == 1) {// 单抽免费次数
            lord.setConsumeDial(consumeDial + 1);
        } else {
            long consume = activity.getStatusList().get(0);
            if (staticActFortune.getPrice() > consume) {
                handler.sendErrorMsgToPlayer(GameError.SCORE_NOT_ENOUGH);
                return;
            }
            activity.getStatusList().set(0, consume - staticActFortune.getPrice());
        }

        DoActConsumeDialRs.Builder builder = DoActConsumeDialRs.newBuilder();

        // 发放奖励
        int scoreAdd = 0;
        int repeat = staticActFortune.getCount();
        for (int i = 0; i < repeat; i++) {
            List<Integer> list = staticActivityDataMgr.randomAwardList(staticActFortune.getAwardList());
            if (list == null || list.size() < 5) {
                continue;
            }
            int type = list.get(0);
            int id = list.get(1);
            int count = list.get(2);
            int keyId = playerDataManager.addAward(player, type, id, count, AwardFrom.CONSUME_DIAL);
            scoreAdd += list.get(4);// 增加积分
            builder.addAward(PbHelper.createAwardPb(type, id, count, keyId));
        }

        long score = activity.getStatusList().get(1);
        score += scoreAdd;
        activity.getStatusList().set(1, score);
        // 计算排名
        if (score >= 30) {// 积分超过500才可进入排行
            activityData.addPlayerRank(lord.getLordId(), score, ActivityConst.RANK_CONSUME_DIAL, ActivityConst.DESC);
        }

        builder.setScore((int) score);// 我的积分
        handler.sendMsgToPlayer(DoActConsumeDialRs.ext, builder.build());
    }

    /**
     * 度假胜地
     *
     * @param handler
     */
    public void getActVacationlandRq(ClientHandler handler) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_VACATIONLAND_ID);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
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

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_VACATIONLAND_ID);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        GetActVacationlandRs.Builder builder = GetActVacationlandRs.newBuilder();

        List<Long> statusList = activity.getStatusList();
        int topup = (int) statusList.get(0).longValue();
        int villageId = (int) statusList.get(1).longValue();
        int buyDate = (int) statusList.get(2).longValue();// 购买时间
        if (villageId != 0 && buyDate != 0) {// 是否已购买
            int onday = TimeHelper.subDay(TimeHelper.getCurrentDay(), buyDate) + 3;
            long state = statusList.get(onday);
            if (state == 0) {
                statusList.set(onday, 1L);
            }
        }

        builder.setTopup(topup);
        builder.setVillageId(villageId);

        List<StaticActVacationland> vlist = staticActivityDataMgr.getVillageList();
        for (StaticActVacationland e : vlist) {
            builder.addVillage(PbHelper.createVillagePb(e));
        }

        Map<Integer, Integer> statusMap = activity.getStatusMap();
        Map<Integer, StaticActVacationland> landMap = staticActivityDataMgr.getActVacationlandMap();
        Iterator<StaticActVacationland> it = landMap.values().iterator();
        while (it.hasNext()) {
            StaticActVacationland next = it.next();
            int landId = next.getLandId();
            int theday = next.getOnday();
            int state = (int) statusList.get(theday + 2).longValue();
            if (statusMap.containsKey(landId)) {
                builder.addVillageAward(PbHelper.createVillageAwardPb(next, villageId, state, 1));
            } else {
                builder.addVillageAward(PbHelper.createVillageAwardPb(next, villageId, state, 0));
            }
        }
        handler.sendMsgToPlayer(GetActVacationlandRs.ext, builder.build());
    }

    /**
     * 度假胜地
     *
     * @param handler
     */
    public void buyActVacationlandRq(BuyActVacationlandRq req, ClientHandler handler) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_VACATIONLAND_ID);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
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

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_VACATIONLAND_ID);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        List<Long> statusList = activity.getStatusList();
        int topup = (int) statusList.get(0).longValue();
        int villageId = (int) statusList.get(1).longValue();
        // int onday = (int) statusList.get(2).longValue();
        if (villageId != 0) {
            handler.sendErrorMsgToPlayer(GameError.BUY_ONLY_ONCE);
            return;
        }
        int buyId = req.getVillageId();
        StaticActVacationland buyLand = null;
        List<StaticActVacationland> vlist = staticActivityDataMgr.getVillageList();
        for (StaticActVacationland e : vlist) {
            if (e.getVillageId() == buyId) {
                buyLand = e;
                break;
            }
        }
        if (buyLand == null) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }
        if (topup < buyLand.getTopup()) {
            handler.sendErrorMsgToPlayer(GameError.TOPUP_NOT_ENOUGH);
            return;
        }

        // 给特效
        StaticProp staticProp = staticPropDataMgr.getStaticProp(buyId);
        List<List<Integer>> effectValue = staticProp.getEffectValue();
        if (effectValue == null || effectValue.isEmpty()) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }

        if (!playerDataManager.subGold(player, buyLand.getPrice(), AwardFrom.VACATION)) {
            handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
            return;
        }

        for (List<Integer> one : effectValue) {
            if (one.size() != 2 && one.get(1) <= 0) {
                continue;
            }
            playerDataManager.addEffect(player, one.get(0), one.get(1));
        }

        int currentDay = TimeHelper.getCurrentDay();
        statusList.set(1, (long) buyId);
        statusList.set(2, (long) currentDay);
        statusList.set(3, 1L);// 第一天已登陆

        BuyActVacationlandRs.Builder builder = BuyActVacationlandRs.newBuilder();
        handler.sendMsgToPlayer(BuyActVacationlandRs.ext, builder.build());
    }

    /**
     * 度假胜地-领奖
     *
     * @param handler
     */
    public void doActVacationlandRq(DoActVacationlandRq req, ClientHandler handler) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_VACATIONLAND_ID);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
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

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_VACATIONLAND_ID);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        List<Long> statusList = activity.getStatusList();
        // int topup = (int) statusList.get(0).longValue();//充值
        int villageId = (int) statusList.get(1).longValue();// 村庄ID
        int buyDate = (int) statusList.get(2).longValue();// 购买日期
        if (villageId == 0 || buyDate == 0) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_FINISH);
            return;
        }
        int landId = req.getLandId();
        StaticActVacationland village = staticActivityDataMgr.getVillage(landId);
        if (village == null) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }

        long state = statusList.get(2 + village.getOnday());
        if (state == 0) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_FINISH);
            return;
        }

        if (activity.getStatusMap().containsKey(landId)) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_GOT);
            return;
        }
        activity.getStatusMap().put(landId, 1);

        DoActVacationlandRs.Builder builder = DoActVacationlandRs.newBuilder();
        List<List<Integer>> awardList = village.getAwardList();
        for (List<Integer> e : awardList) {
            if (e.size() < 3) {
                continue;
            }
            int type = e.get(0);
            int id = e.get(1);
            int count = e.get(2);
            if (type == AwardType.EQUIP) {
                for (int i = 0; i < count; i++) {
                    int keyId = playerDataManager.addAward(player, type, id, 1, AwardFrom.VACATION);
                    builder.addAward(PbHelper.createAwardPb(type, id, 1, keyId));
                }
            } else {
                int keyId = playerDataManager.addAward(player, type, id, count, AwardFrom.VACATION);
                builder.addAward(PbHelper.createAwardPb(type, id, count, keyId));
            }

        }
        handler.sendMsgToPlayer(DoActVacationlandRs.ext, builder.build());
    }

    /**
     * 获取配件兑换配方列表
     *
     * @param handler
     */
    public void getActPartCashRq(ClientHandler handler) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_PART_EXCHANGE_ID);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
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

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_PART_EXCHANGE_ID);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        GetActPartCashRs.Builder builder = GetActPartCashRs.newBuilder();
        List<StaticActExchange> exchangeList = staticActivityDataMgr.getActExchange(activityBase.getKeyId());
        if (exchangeList == null || exchangeList.size() == 0) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }
        int today = TimeHelper.getCurrentDay();
        for (StaticActExchange e : exchangeList) {
            int exchangeId = e.getExchangeId();
            Cash cash = player.cashs.get(exchangeId);
            if (cash == null || cash.getRefreshDate() != today) {
                cash = activityDataManager.freshCash(player, cash, e, true);
                cash.setRefreshDate(today);
                player.cashs.put(exchangeId, cash);
            }
            builder.addCash(PbHelper.createCashPb(cash));
        }
        handler.sendMsgToPlayer(GetActPartCashRs.ext, builder.build());
    }

    /**
     * 配件配方兑换
     *
     * @param handler
     */
    public void doPartCashRq(DoPartCashRq req, ClientHandler handler) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_PART_EXCHANGE_ID);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
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

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_PART_EXCHANGE_ID);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        int cashId = req.getCashId();
        StaticActExchange actExchange = staticActivityDataMgr.getActExchange(activityBase.getKeyId(), cashId);
        if (actExchange == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        int today = TimeHelper.getCurrentDay();
        Cash cash = player.cashs.get(cashId);
        if (cash == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        if (cash.getRefreshDate() != today) {
            cash = activityDataManager.freshCash(player, cash, actExchange, true);
            cash.setRefreshDate(today);
            player.cashs.put(actExchange.getExchangeId(), cash);
        }

        if (cash.getState() <= 0) {
            handler.sendErrorMsgToPlayer(GameError.COUNT_NOT_ENOUGH);
            return;
        }

        // 判定材料是否足够
        List<Part> partList = new ArrayList<Part>();
        for (List<Integer> e : cash.getList()) {
            int type = e.get(0);// 类型
            int id = e.get(1);// ID
            int count = e.get(2);// 数量
            if (type == AwardType.PROP) {//
                Prop prop = player.props.get(id);
                if (prop == null || prop.getCount() < count) {
                    handler.sendErrorMsgToPlayer(GameError.PROP_NOT_ENOUGH);
                    return;
                }
            } else if (type == AwardType.GOLD) {
                if (lord.getGold() < count) {
                    handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
                    return;
                }
            } else if (type == AwardType.PART) {
                Part part = playerDataManager.getMinLvPartById(player, id);
                if (part == null) {
                    handler.sendErrorMsgToPlayer(GameError.NO_PART);
                    return;
                }
                partList.add(part);
            } else if (type == AwardType.CHIP) {
                Chip chip = player.chips.get(id);
                if (chip == null || chip.getCount() < count) {
                    handler.sendErrorMsgToPlayer(GameError.CHIP_NOT_ENOUGH);
                    return;
                }
            } else if (type == AwardType.PART_MATERIAL) {
                if (id == 1 && lord.getFitting() < count) {
                    handler.sendErrorMsgToPlayer(GameError.FIGHT_NOT_ENOUGH);
                    return;
                } else if (id == 2 && lord.getMetal() < count) {
                    handler.sendErrorMsgToPlayer(GameError.METAL_NOT_ENOUGH);
                    return;
                } else if (id == 3 && lord.getPlan() < count) {
                    handler.sendErrorMsgToPlayer(GameError.DRAW_NOT_ENOUGH);
                    return;
                } else if (id == 4 && lord.getMineral() < count) {
                    handler.sendErrorMsgToPlayer(GameError.METAL_NOT_ENOUGH);
                    return;
                } else if (id == 5 && lord.getTool() < count) {
                    handler.sendErrorMsgToPlayer(GameError.METAL_NOT_ENOUGH);
                    return;
                } else if (id == 6 && lord.getDraw() < count) {
                    handler.sendErrorMsgToPlayer(GameError.DRAW_NOT_ENOUGH);
                    return;
                } else if (id == 7 && lord.getTankDrive() < count) {
                    handler.sendErrorMsgToPlayer(GameError.DRAW_NOT_ENOUGH);
                    return;
                } else if (id == 8 && lord.getChariotDrive() < count) {
                    handler.sendErrorMsgToPlayer(GameError.DRAW_NOT_ENOUGH);
                    return;
                } else if (id == 9 && lord.getArtilleryDrive() < count) {
                    handler.sendErrorMsgToPlayer(GameError.DRAW_NOT_ENOUGH);
                    return;
                } else if (id == 10 && lord.getRocketDrive() < count) {
                    handler.sendErrorMsgToPlayer(GameError.DRAW_NOT_ENOUGH);
                    return;
                } else if (!playerDataManager.checkPartMaterialIsEnougth(player, id, count)) {
                    handler.sendErrorMsgToPlayer(GameError.METAL_NOT_ENOUGH);
                    return;
                }
            } else {
                handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
                return;
            }
        }

        DoPartCashRs.Builder builder = DoPartCashRs.newBuilder();
        for (List<Integer> e : cash.getList()) {
            int type = e.get(0);
            int id = e.get(1);
            int count = e.get(2);
            if (type == AwardType.PROP) {
                Prop prop = player.props.get(id);
                playerDataManager.subProp(player, prop, count, AwardFrom.EXCHANGE_PART);
                builder.addCostList(PbHelper.createAwardPb(type, id, count, 0));
            } else if (type == AwardType.GOLD) {
                playerDataManager.subGold(player, count, AwardFrom.EXCHANGE_PART);
                builder.addCostList(PbHelper.createAwardPb(type, id, count, 0));
            } else if (type == AwardType.PART) {
                continue;
            } else if (type == AwardType.CHIP) {
                Chip chip = player.chips.get(id);
                if (chip != null) {
                    playerDataManager.subChip(player, chip, count, AwardFrom.EXCHANGE_PART);
                }
                builder.addCostList(PbHelper.createAwardPb(type, id, count, 0));
            } else if (type == AwardType.PART_MATERIAL) {
                playerDataManager.addPartMaterial(player, id, -count, AwardFrom.EXCHANGE_PART);
                builder.addCostList(PbHelper.createAwardPb(type, id, count, 0));
            }
        }

        for (Part part : partList) {
            player.parts.get(0).remove(part.getKeyId());
            LogLordHelper.part(AwardFrom.EXCHANGE_PART, player.account, lord, part);
            builder.addCostList(PbHelper.createAwardPb(AwardType.PART, part.getPartId(), 1, part.getKeyId()));
        }

        int type = cash.getAwardList().get(0);
        int id = cash.getAwardList().get(1);
        int count = cash.getAwardList().get(2);
        int awardKeyId = playerDataManager.addAward(player, type, id, count, AwardFrom.EXCHANGE_PART);

        cash.setState(cash.getState() - 1);

        builder.setAward(PbHelper.createAwardPb(type, id, count, awardKeyId));
        handler.sendMsgToPlayer(DoPartCashRs.ext, builder.build());
    }

    /**
     * 刷新配件兑换配方
     *
     * @param handler
     */
    public void refshPartCashRq(RefshPartCashRq req, ClientHandler handler) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_PART_EXCHANGE_ID);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
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

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_PART_EXCHANGE_ID);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        int cashId = req.getCashId();
        StaticActExchange actExchange = staticActivityDataMgr.getActExchange(activityBase.getKeyId(), cashId);
        if (actExchange == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }
        int today = TimeHelper.getCurrentDay();
        Cash cash = player.cashs.get(cashId);
        if (cash == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }

        if (cash.getRefreshDate() != today) {
            cash = activityDataManager.freshCash(player, cash, actExchange, true);
            cash.setRefreshDate(today);
            player.cashs.put(cashId, cash);
        } else if (cash.getFree() > 0) {
            cash = activityDataManager.freshCash(player, cash, actExchange, false);
            cash.setFree(cash.getFree() - 1);
        } else {
            int price = actExchange.getPrice();
            if (!playerDataManager.subGold(player, price, AwardFrom.EXCHANGE_PART)) {
                handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
                return;
            }
            cash = activityDataManager.freshCash(player, cash, actExchange, false);
        }

        RefshPartCashRs.Builder builder = RefshPartCashRs.newBuilder();
        builder.setCash(PbHelper.createCashPb(cash));
        handler.sendMsgToPlayer(RefshPartCashRs.ext, builder.build());
    }

    /**
     * 获取装备兑换配方列表
     *
     * @param handler
     */
    public void getActEquipCashRq(ClientHandler handler) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_EQUIP_EXCHANGE_ID);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
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

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_EQUIP_EXCHANGE_ID);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        GetActEquipCashRs.Builder builder = GetActEquipCashRs.newBuilder();
        List<StaticActExchange> exchangeList = staticActivityDataMgr.getActExchange(activityBase.getKeyId());
        if (exchangeList == null || exchangeList.size() == 0) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }
        int today = TimeHelper.getCurrentDay();
        for (StaticActExchange e : exchangeList) {
            int exchangeId = e.getExchangeId();
            Cash cash = player.cashs.get(exchangeId);
            if (cash == null || cash.getRefreshDate() != today) {
                cash = activityDataManager.freshCash(player, cash, e, true);
                cash.setRefreshDate(today);
                player.cashs.put(exchangeId, cash);
            }
            builder.addCash(PbHelper.createCashPb(cash));
        }
        handler.sendMsgToPlayer(GetActEquipCashRs.ext, builder.build());
    }

    /**
     * 装备配方兑换
     *
     * @param handler
     */
    public void doEquipCashRq(DoEquipCashRq req, ClientHandler handler) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_EQUIP_EXCHANGE_ID);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
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

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_EQUIP_EXCHANGE_ID);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        int cashId = req.getCashId();
        StaticActExchange actExchange = staticActivityDataMgr.getActExchange(activityBase.getKeyId(), cashId);
        if (actExchange == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        int today = TimeHelper.getCurrentDay();
        Cash cash = player.cashs.get(cashId);
        if (cash == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        if (cash.getRefreshDate() != today) {
            cash = activityDataManager.freshCash(player, cash, actExchange, true);
            cash.setRefreshDate(today);
        }

        if (cash.getState() <= 0) {
            handler.sendErrorMsgToPlayer(GameError.COUNT_NOT_ENOUGH);
            return;
        }

        List<Equip> equipList = new ArrayList<Equip>();
        for (List<Integer> e : cash.getList()) {
            int type = e.get(0);// 类型
            int id = e.get(1);// ID
            int count = e.get(2);// 数量
            if (type == AwardType.PROP) {//
                Prop prop = player.props.get(id);
                if (prop == null || prop.getCount() < count) {
                    handler.sendErrorMsgToPlayer(GameError.PROP_NOT_ENOUGH);
                    return;
                }
            } else if (type == AwardType.GOLD) {
                if (lord.getGold() < count) {
                    handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
                    return;
                }
            } else if (type == AwardType.EQUIP) {
                List<Equip> costList = playerDataManager.getMinLvEquipById(player, id);
                if (costList.size() < count) {
                    handler.sendErrorMsgToPlayer(GameError.NO_EQUIP);
                    return;
                }
                Collections.sort(costList, new CompareEquipLv());
                for (int i = 0; i < count; i++) {
                    equipList.add(costList.get(i));
                }
            } else {
                handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
                return;
            }
        }

        DoEquipCashRs.Builder builder = DoEquipCashRs.newBuilder();
        for (List<Integer> e : cash.getList()) {
            int type = e.get(0);
            int id = e.get(1);
            int count = e.get(2);
            if (type == AwardType.PROP) {
                Prop prop = player.props.get(id);
                playerDataManager.subProp(player, prop, count, AwardFrom.EXCHANGE_EQUIP);
                builder.addCostList(PbHelper.createAwardPb(type, id, count, 0));
            } else if (type == AwardType.GOLD) {
                playerDataManager.subGold(player, count, AwardFrom.EXCHANGE_EQUIP);
                builder.addCostList(PbHelper.createAwardPb(type, id, count, 0));
            } else if (type == AwardType.EQUIP) {
                continue;
            }
        }

        for (Equip equip : equipList) {
            player.equips.get(0).remove(equip.getKeyId());
            LogLordHelper.equip(AwardFrom.EXCHANGE_EQUIP, player.account, lord, equip.getKeyId(), equip.getEquipId(), equip.getLv(), 0);
            builder.addCostList(PbHelper.createAwardPb(AwardType.EQUIP, equip.getEquipId(), 1, equip.getKeyId()));
        }

        int type = cash.getAwardList().get(0);
        int id = cash.getAwardList().get(1);
        int count = cash.getAwardList().get(2);

        cash.setState(cash.getState() - 1);

        int awardKeyId = playerDataManager.addAward(player, type, id, count, AwardFrom.EXCHANGE_EQUIP);

        builder.setAward(PbHelper.createAwardPb(type, id, count, awardKeyId));
        handler.sendMsgToPlayer(DoEquipCashRs.ext, builder.build());
    }

    /**
     * 刷新装备兑换配方
     *
     * @param handler
     */
    public void refshEquipCashRq(RefshEquipCashRq req, ClientHandler handler) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_EQUIP_EXCHANGE_ID);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
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

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_EQUIP_EXCHANGE_ID);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        int cashId = req.getCashId();
        StaticActExchange actExchange = staticActivityDataMgr.getActExchange(activityBase.getKeyId(), cashId);
        if (actExchange == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }
        int today = TimeHelper.getCurrentDay();
        Cash cash = player.cashs.get(cashId);
        if (cash == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }

        if (cash.getRefreshDate() != today) {
            cash = activityDataManager.freshCash(player, cash, actExchange, true);
            cash.setRefreshDate(today);
        } else if (cash.getRefreshDate() == today && cash.getFree() > 0) {
            cash = activityDataManager.freshCash(player, cash, actExchange, false);
            cash.setFree(cash.getFree() - 1);
        } else {
            int price = actExchange.getPrice();
            if (player.lord.getGold() < price) {
                handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
                return;
            }
            if (!playerDataManager.subGold(player, price, AwardFrom.EXCHANGE_EQUIP)) {
                handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
                return;
            }
            cash = activityDataManager.freshCash(player, cash, actExchange, false);
        }

        RefshEquipCashRs.Builder builder = RefshEquipCashRs.newBuilder();
        builder.setCash(PbHelper.createCashPb(cash));
        handler.sendMsgToPlayer(RefshEquipCashRs.ext, builder.build());
    }

    /**
     * 分解配件兑换-主页面
     *
     * @param handler
     */
    public void getActPartResolveRq(ClientHandler handler) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_PART_RESOLVE_ID);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
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

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_PART_RESOLVE_ID);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        int activityKeyId = activityBase.getKeyId();
        List<Long> statusList = activity.getStatusList();
        long score = statusList.get(0);

        GetActPartResolveRs.Builder builder = GetActPartResolveRs.newBuilder();
        List<StaticActPartResolve> condList = staticActivityDataMgr.getActPartResolveList(activityKeyId);
        for (StaticActPartResolve e : condList) {
            builder.addPartResolve(PbHelper.createPartResolvePb(e));
        }
        builder.setState((int) score);
        handler.sendMsgToPlayer(GetActPartResolveRs.ext, builder.build());
    }

    /**
     * 分解配件兑换
     *
     * @param req
     * @param handler
     */
    public void doActPartResolveRq(DoActPartResolveRq req, ClientHandler handler) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_PART_RESOLVE_ID);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
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

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_PART_RESOLVE_ID);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        int resolveId = req.getResolveId();
        int activityKeyId = activityBase.getKeyId();
        List<Long> statusList = activity.getStatusList();
        long score = statusList.get(0);
        StaticActPartResolve staticActPartResolve = staticActivityDataMgr.getActPartResolve(activityKeyId, resolveId);
        if (staticActPartResolve.getSlug() > score) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_FINISH);
            return;
        }
        DoActPartResolveRs.Builder builder = DoActPartResolveRs.newBuilder();
        statusList.set(0, score - staticActPartResolve.getSlug());
        for (int i = 0; i < staticActPartResolve.getAwardList().size(); i++) {
            List<Integer> elist = staticActPartResolve.getAwardList().get(0);
            if (elist.size() < 3) {
                continue;
            }
            int type = elist.get(0);
            int id = elist.get(1);
            int count = elist.get(2);
            int keyId = playerDataManager.addAward(player, type, id, count, AwardFrom.PART_RESOLVE);
            builder.addAward(PbHelper.createAwardPb(type, id, count, keyId));
        }

        handler.sendMsgToPlayer(DoActPartResolveRs.ext, builder.build());
    }

    /**
     * 下注赢金币-主页面
     *
     * @param handler
     */
    public void getActGambleRq(ClientHandler handler) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_GAMBLE_ID);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
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

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_GAMBLE_ID);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        int activityKeyId = activityBase.getKeyId();
        List<StaticActGamble> gambleList = staticActivityDataMgr.getActGambleList(activityKeyId);
        if (gambleList == null || gambleList.size() == 0) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }

        List<Long> statusList = activity.getStatusList();
        long topup = statusList.get(0);// 累计充值
        long price = statusList.get(1);// 已抽到哪一档

        GetActGambleRs.Builder builder = GetActGambleRs.newBuilder();
        builder.setTopup((int) topup);
        builder.setPrice((int) price);

        int count = 0;
        for (StaticActGamble e : gambleList) {
            if (e.getTopup() <= topup && e.getPrice() > price) {
                count++;
            }
            builder.addTopupGamble(PbHelper.createTopupGamblePb(e));
        }
        builder.setCount(count);
        handler.sendMsgToPlayer(GetActGambleRs.ext, builder.build());
    }

    /**
     * 下注赢金币
     *
     * @param req
     * @param handler
     */
    public void doActGambleRq(DoActGambleRq req, ClientHandler handler) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_GAMBLE_ID);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
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

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_GAMBLE_ID);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        int activityKeyId = activityBase.getKeyId();

        List<Long> statusList = activity.getStatusList();
        long topup = statusList.get(0);// 累计充值
        long price = statusList.get(1);// 已抽到哪一档

        StaticActGamble actGamble = staticActivityDataMgr.getActGamble(activityKeyId, (int) topup, (int) price);
        if (actGamble == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_FINISH);
            return;
        }
        if (!playerDataManager.subGold(player, actGamble.getPrice(), AwardFrom.TOPUP_GAMBLE)) {
            handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
            return;
        }

        statusList.set(1, (long) actGamble.getPrice());

        List<List<Integer>> awardList = actGamble.getAwardList();
        int[] seed = new int[]{0, 0, 0};
        for (List<Integer> e : awardList) {
            seed[0] += e.get(3);
        }
        seed[0] = RandomHelper.randomInSize(seed[0]);
        for (List<Integer> e : awardList) {
            seed[1] += e.get(3);
            if (seed[0] <= seed[1]) {
                seed[2] = e.get(2);
                break;
            }
        }
        playerDataManager.addGold(player, seed[2], AwardFrom.TOPUP_GAMBLE_ADD);
        DoActGambleRs.Builder builder = DoActGambleRs.newBuilder();
        builder.setGold(seed[2]);
        handler.sendMsgToPlayer(DoActGambleRs.ext, builder.build());
    }

    /**
     * 充值转盘-主页面
     *
     * @param handler
     */
    public void getActPayTurntableRq(ClientHandler handler) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_PAY_TURNTABLE_ID);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
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

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_PAY_TURNTABLE_ID);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        int activityKeyId = activityBase.getKeyId();
        List<StaticActGamble> gambleList = staticActivityDataMgr.getActGambleList(activityKeyId);
        if (gambleList == null || gambleList.size() == 0) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }

        for (StaticActGamble e : gambleList) {

            List<Long> statusList = activity.getStatusList();
            long topup = statusList.get(0);// 累计充值
            long count = statusList.get(1);// 已抽次数
            int count1 = (int) (topup / e.getTopup() - count);

            GetActPayTurntableRs.Builder builder = GetActPayTurntableRs.newBuilder();
            builder.setTopup((int) topup);
            builder.setCount(count1);
            builder.setPaycount(e.getTopup());

            builder.setTopupGamble(PbHelper.createTopupGamblePb(e));
            handler.sendMsgToPlayer(GetActPayTurntableRs.ext, builder.build());
            break;
        }

    }

    /**
     * 充值转盘
     *
     * @param req
     * @param handler
     */
    public void doActPayTurntableRq(DoActPayTurntableRq req, ClientHandler handler) {
        int lottyCount = 1;

        if (req.hasCount()) {
            lottyCount = req.getCount();
        }

        if (lottyCount < 1) {
            return;
        }

        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_PAY_TURNTABLE_ID);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
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

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_PAY_TURNTABLE_ID);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        int activityKeyId = activityBase.getKeyId();
        List<StaticActGamble> gambleList = staticActivityDataMgr.getActGambleList(activityKeyId);
        if (gambleList == null || gambleList.size() == 0) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_FINISH);
            return;
        }
        StaticActGamble actGamble = gambleList.get(0);
        List<Long> statusList = activity.getStatusList();
        long topup = statusList.get(0);// 累计充值
        long count = statusList.get(1);// 已抽次数
        int count1 = (int) (topup / actGamble.getTopup() - (count + lottyCount));
        if (count1 < 0) {
            handler.sendErrorMsgToPlayer(GameError.COUNT_NOT_ENOUGH);
            return;
        }

        DoActPayTurntableRs.Builder builder = DoActPayTurntableRs.newBuilder();
        List<List<Integer>> awardList = actGamble.getAwardList();

        for (int c = 1; c <= lottyCount; c++) {
            int[] seed = new int[]{0, 0, 0};
            for (List<Integer> e : awardList) {
                seed[0] += e.get(3);
            }
            seed[0] = RandomHelper.randomInSize(seed[0]);
            for (List<Integer> e : awardList) {
                seed[1] += e.get(3);
                if (seed[0] <= seed[1]) {
                    int type = e.get(0);
                    int id = e.get(1);
                    int itemCount = e.get(2);
                    int keyId = playerDataManager.addAward(player, type, id, itemCount, AwardFrom.PAY_TURN_TABLE);
                    builder.addAward(PbHelper.createAwardPb(type, id, itemCount, keyId));
                    break;
                }
            }
        }

        statusList.set(1, count + lottyCount);
        handler.sendMsgToPlayer(DoActPayTurntableRs.ext, builder.build());
    }

    /**
     * 新春狂欢-主页面
     *
     * @param handler
     */
    public void getActCarnivalRq(ClientHandler handler) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_SPRING_ID);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
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

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_SPRING_ID);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        int activityKeyId = activityBase.getKeyId();

        List<StaticActAward> condList = staticActivityDataMgr.getActAwardById(activityKeyId);
        if (condList == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }
        GetActCarnivalRs.Builder builder = GetActCarnivalRs.newBuilder();
        // 头像
        List<Long> statusList = activity.getStatusList();

        for (StaticActAward e : condList) {
            int sortId = e.getSortId();
            int state = (int) statusList.get(sortId).longValue();
            int keyId = e.getKeyId();
            if (sortId == 0) {
                if (activity.getStatusMap().containsKey(keyId)) {// 已领取奖励
                    builder.setPortrait(PbHelper.createCondStatePb(state, e, 1));
                } else {
                    builder.setPortrait(PbHelper.createCondStatePb(state, e, 0));
                }
            } else if (sortId == 1) {// 首次充值
                int currentDay = TimeHelper.getCurrentDay();
                if (state != currentDay) {
                    builder.setPayFrist(PbHelper.createCondStatePb(0, e, 0));
                } else {
                    if (activity.getStatusMap().containsKey(keyId)) {
                        builder.setPayFrist(PbHelper.createCondStatePb(1, e, 1));
                    } else {
                        builder.setPayFrist(PbHelper.createCondStatePb(1, e, 0));
                    }
                }
            } else if (sortId == 3) {
                builder.setPortrait(PbHelper.createCondStatePb(state, e, 0));
            }
        }

        handler.sendMsgToPlayer(GetActCarnivalRs.ext, builder.build());
    }

    /**
     * 新春狂欢-主页面
     *
     * @param handler
     */
    public void getActPray(ClientHandler handler) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_SPRING_ID);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
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

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_SPRING_ID);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        int activityKeyId = activityBase.getKeyId();

        List<StaticActAward> condList = staticActivityDataMgr.getActAwardById(activityKeyId);
        if (condList == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }
        GetActPrayRs.Builder builder = GetActPrayRs.newBuilder();
        // 头像
        // List<Long> statusList = activity.getStatusList();
        //
        // for (StaticActAward e : condList) {
        // int sortId = e.getSortId();
        // int state = (int) statusList.get(sortId).longValue();
        // int keyId = e.getKeyId();
        // if (sortId == 0) {
        // if (activity.getStatusMap().containsKey(keyId)) {// 已领取奖励
        // builder.setPortrait(PbHelper.createCondStatePb(state, e, 1));
        // } else {
        // builder.setPortrait(PbHelper.createCondStatePb(state, e, 0));
        // }
        // } else if (sortId == 1) {// 首次充值
        // int currentDay = TimeHelper.getCurrentDay();
        // if (state != currentDay) {
        // builder.setPayFrist(PbHelper.createCondStatePb(0, e, 0));
        // } else {
        // if (activity.getStatusMap().containsKey(keyId)) {
        // builder.setPayFrist(PbHelper.createCondStatePb(1, e, 1));
        // } else {
        // builder.setPayFrist(PbHelper.createCondStatePb(1, e, 0));
        // }
        // }
        // } else if (sortId == 3) {
        // builder.setPortrait(PbHelper.createCondStatePb(state, e, 0));
        // }
        // }

        handler.sendMsgToPlayer(GetActPrayRs.ext, builder.build());
    }

    /**
     * 火力全开-军团捐献排名
     *
     * @param handler
     */
    public void getActPartyDonateRankRq(ClientHandler handler) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_FIRE_SHEET);
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

        UsualActivityData activityData = activityDataManager.getUsualActivity(ActivityConst.ACT_FIRE_SHEET);
        if (activityData == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_FIRE_SHEET);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        PartyData partyData = partyDataManager.getPartyByLordId(handler.getRoleId());
        ActPartyRank partyRank = null;
        int rank = 0;
        int partyId = 0;

        GetActPartyDonateRankRs.Builder builder = GetActPartyDonateRankRs.newBuilder();

        LinkedList<ActPartyRank> rankList = activityData.getPartyRanks();

        for (int i = 0; i < rankList.size() && i < ActivityConst.RANK_FIRE_SHEET; i++) {
            ActPartyRank e = rankList.get(i);
            int epartyId = e.getPartyId();
            if (epartyId == partyId) {
                rank = i + 1;
            }

            PartyData entity = partyDataManager.getParty(epartyId);
            if (entity == null) {
                continue;
            }
            String partyName = entity.getPartyName();
            long fight = entity.getFight();

            builder.addActPartyRank(PbHelper.createPartyRankPb(e, i + 1, partyName, fight));
        }

        if (partyData != null) {
            partyId = partyData.getPartyId();
            Long score = activityData.getPartyScore(partyId);
            if (score == null) {
                score = 0L;
            }
            partyRank = new ActPartyRank(partyId, 0, score);
            builder.setParty(PbHelper.createPartyRankPb(partyRank, rank, partyData.getPartyName(), partyData.getFight()));
        }

        builder.setStatus(0);
        if (step == ActivityConst.OPEN_STEP) {
            builder.setOpen(false);
        } else if (step == ActivityConst.OPEN_AWARD) {
            builder.setOpen(true);
            Map<Integer, Integer> statusMap = activity.getStatusMap();
            if (statusMap.containsKey(ActivityConst.TYPE_DEFAULT)) {
                builder.setStatus(1);
            }
        }

        List<StaticActRank> staticActRankList = staticActivityDataMgr.getActRankList(activityKeyId, ActivityConst.TYPE_DEFAULT);
        if (staticActRankList != null) {
            for (StaticActRank e : staticActRankList) {
                builder.addRankAward(PbHelper.createRankAwardPb(e));
            }
        }
        handler.sendMsgToPlayer(GetActPartyDonateRankRs.ext, builder.build());
    }

    /**
     * 获取坦克嘉年华活动数据
     *
     * @param handler
     */
    public void getTankCarnival(ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null || null == player.lord) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }

        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_TANK_CARNIVAL);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        int totday = TimeHelper.getCurrentDay();
        Activity activity = player.activitys.get(ActivityConst.ACT_TANK_CARNIVAL);
        if (activity == null) {
            activity = new Activity();
            activity.setStatusMap(new HashMap<Integer, Integer>());
            activity.setActivityId(ActivityConst.ACT_TANK_CARNIVAL);
            activity.setOpen(1);// 用open参数记录玩家当天剩余的免费次数
            player.activitys.put(ActivityConst.ACT_TANK_CARNIVAL, activity);
        } else {
            if (activity.getEndTime() != totday) {// 隔天后清空记录
                activity.setEndTime(totday);// 用endTime参数记录玩家最后拉取坦克嘉年华奖励的日期
                activity.setOpen(1);// 用open参数记录玩家当天剩余的免费次数
            }
        }

        GetTankCarnivalRs.Builder builder = GetTankCarnivalRs.newBuilder();
        builder.setFreeNum(activity.getOpen());
        handler.sendMsgToPlayer(GetTankCarnivalRs.ext, builder.build());
    }

    static final int[] CARNIVAL_COST = {40, 288};

    /**
     * 随机出的九宫格结果对应gridList的顺序如下 <br/>
     * 0 3 6 <br/>
     * 1 4 7 <br/>
     * 2 5 8 <br/>
     * 所以八条线上从左到右的index分别是 1线:1,4,7; 2线:2,5,8; 3线:0,3,6; 4线:3,4,5; 5线:0,1,2; 6线:6,7,8; 7线:0,4,8; 8线:2,4,6 <br/>
     * lineIndexArr = new int[9][1];其中0位为填位，没有值，其他的代表8条线从左到右数，该位置在gridList中的index
     */
    static final int[][] lineIndexArr = {{}, {1, 4, 7}, {2, 5, 8}, {0, 3, 6}, {3, 4, 5}, {0, 1, 2}, {6, 7, 8}, {0, 4, 8},
            {2, 4, 6}};

    /**
     * 坦克嘉年华活动拉取奖励
     *
     * @param req
     * @param handler
     */
    public void tankCarnivalReward(TankCarnivalRewardRq req, ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null || null == player.lord) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }

        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_TANK_CARNIVAL);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        int totday = TimeHelper.getCurrentDay();
        Activity activity = player.activitys.get(ActivityConst.ACT_TANK_CARNIVAL);
        if (activity == null) {
            activity = new Activity();
            activity.setStatusMap(new HashMap<Integer, Integer>());
            activity.setActivityId(ActivityConst.ACT_TANK_CARNIVAL);
            activity.setOpen(1);// 用open参数记录玩家当天剩余的免费次数
            player.activitys.put(ActivityConst.ACT_TANK_CARNIVAL, activity);
        } else {
            if (activity.getEndTime() != totday) {// 隔天后清空记录
                activity.setEndTime(totday);// 用endTime参数记录玩家最后拉取坦克嘉年华奖励的日期
                activity.setOpen(1);// 用open参数记录玩家当天剩余的免费次数
            }
        }

        int cost = 0;
        boolean allLine = false;
        TankCarnivalRewardRs.Builder builder = TankCarnivalRewardRs.newBuilder();
        builder.setAllLine(req.getAllLine());
        if (activity.getOpen() <= 0) {// 免费次数已用完，需要选择是否全开模式
            allLine = req.getAllLine() == 1;// 是否选择全开模式，1 是，0 否
            if (allLine) {
                cost = CARNIVAL_COST[1];
            } else {
                cost = CARNIVAL_COST[0];
            }

            // 检查金币是否足够
            if (player.lord.getGold() < cost) {
                handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
                return;
            }

            // 扣除金币
            playerDataManager.subGold(player, cost, AwardFrom.BUY_TANK_CARNIVAL);
        } else {
            // 扣除一次免费次数
            activity.setOpen(activity.getOpen() - 1);
        }
        activity.setEndTime(totday);// 记录时间

        // 随机出结果
        int randomIndex = 0;
        StaticActEquate sae;
        List<StaticActEquate> list;
        List<StaticActEquate> gridList = new ArrayList<>();
        for (int i = 1; i <= 3; i++) {
            // 按权重随机出一个
            list = staticActivityDataMgr.getActEquateList(i);
            randomIndex = randomIndex(list);

            sae = list.get(randomIndex);
            gridList.add(sae);
            gridList.add(list.get((randomIndex + 1) % list.size()));// 列表循环，防止越界
            gridList.add(list.get((randomIndex + 2) % list.size()));

            builder.addEquateId(sae.getEquateId());// 记录每列随机出来的equateId
        }

        // 根据结果计算奖励
        int index;
        CommonPb.Award award;
        List<Integer> rewardList;
        List<CommonPb.Award> awardList;
        Map<Integer, Integer> map = new HashMap<>();
        for (int line = 1; line <= 8; line++) {// 分别计算8条线对应的奖励，并发送和发给客户端
            if (!allLine && line > 1) {
                break;
            }

            awardList = new ArrayList<>();
            map.clear();

            for (int pos = 0; pos < 3; pos++) {
                index = lineIndexArr[line][pos];
                sae = gridList.get(index);
                addNum(sae.getKind(), map);// 记录这个配置项在这条线中出现的次数
            }

            for (Entry<Integer, Integer> entry : map.entrySet()) {
                sae = staticActivityDataMgr.getActEquateByKind(entry.getKey());
                rewardList = sae.getRewardList(entry.getValue());// 根据物品出现的次数，获取对应的奖励
                if (!CheckNull.isEmpty(rewardList)) {// 发送奖励
                    award = playerDataManager.addAwardBackPb(player, rewardList, AwardFrom.TANK_CARNIVAL_REWARD);
                    if (null != award) {
                        awardList.add(award);
                    }
                }
            }
            // 加入活动获取奖励，增加世界消息推送
            propService.sendJoinActivityMsg(ActivityConst.ACT_TANK_CARNIVAL, player, awardList);

            builder.addRewards(PbHelper.createTankCrnivalRewardPb(line, awardList));// 返回客户端每条线的奖励信息
        }

        handler.sendMsgToPlayer(TankCarnivalRewardRs.ext, builder.build());
    }

    /**
     * 根据Priority权重 随机得到StaticActEquate 返回list的索引
     *
     * @param list
     * @return int
     */
    private int randomIndex(List<StaticActEquate> list) {
        int temp = 0;
        int random = 0;
        int totalProb = 0;
        for (StaticActEquate equate : list) {
            totalProb += equate.getPriority();
        }
        random = RandomHelper.randomInSize(totalProb);
        for (int index = 0; index < list.size(); index++) {
            temp += list.get(index).getPriority();
            if (temp >= random) {
                return index;
            }
        }
        return 0;
    }

    /**
     * 将map中指定key的值数字增加1
     *
     * @param kind
     * @param map  void
     */
    private void addNum(int kind, Map<Integer, Integer> map) {
        Integer num = map.get(kind);
        if (null == num) {
            map.put(kind, 1);
        } else {
            map.put(kind, num + 1);
        }
    }

    /**
     * 获取能量赠送活动数据
     *
     * @param handler
     */
    public void getPowerGiveData(ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null || null == player.lord) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }

        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_POWER_GIVE);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        Activity activity = player.activitys.get(ActivityConst.ACT_POWER_GIVE);
        if (activity == null) {
            activity = new Activity();
            activity.setStatusMap(new HashMap<Integer, Integer>());
            activity.setActivityId(ActivityConst.ACT_POWER_GIVE);
            player.activitys.put(ActivityConst.ACT_POWER_GIVE, activity);
        }
        if (null == activity.getStatusList()) {
            activity.setStatusList(new ArrayList<Long>());
        }

        int weekDay = TimeHelper.getCNDayOfWeek();
        List<StaticActivityTime> list = staticActivityDataMgr.getActivityTimeById(ActivityConst.ACT_POWER_GIVE);
        if (CheckNull.isEmpty(list) || !list.get(0).getOpenWeekDay().contains(weekDay)) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        int totday = TimeHelper.getCurrentDay();
        if (activity.getEndTime() != totday) {// 隔天后清空记录
            activity.setEndTime(totday);// 用endTime参数记录玩家最后领取能晶补给活动奖励的日期
            activity.getStatusList().clear();
            for (int i = 0; i < list.size(); i++) {
                activity.getStatusList().add(1L);// 能量补给活动状态，1 未领取，2 已领取
            }
        }

        GetPowerGiveDataRs.Builder builder = GetPowerGiveDataRs.newBuilder();
        for (Long state : activity.getStatusList()) {
            builder.addState(state.intValue());
        }

        handler.sendMsgToPlayer(GetPowerGiveDataRs.ext, builder.build());
    }

    /**
     * 领取能量赠送活动能晶
     *
     * @param handler
     */
    public void getFreePower(ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null || null == player.lord) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }

        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_POWER_GIVE);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        Activity activity = player.activitys.get(ActivityConst.ACT_POWER_GIVE);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        StaticActivityTime sat = activityDataManager.getCurActivityTime(ActivityConst.ACT_POWER_GIVE);
        if (null == sat) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        int state = activity.getStatusList().get(sat.getTime() - 1).intValue();
        if (state == 2) {
            handler.sendErrorMsgToPlayer(GameError.ACT_POWER_ALREADY_GET);
            return;
        }

        if (player.lord.getPower() > 95) {
            handler.sendErrorMsgToPlayer(GameError.ACT_POWER_FULL);
            return;
        }

        // 更新活动状态，1 未领取，2 已领取
        activity.setEndTime(TimeHelper.getCurrentDay());// 记录时间
        activity.getStatusList().set(sat.getTime() - 1, 2L);

        // 发送奖励
        List<CommonPb.Award> awards = playerDataManager.addAwardsBackPb(player, sat.getAwardList(), AwardFrom.ACT_POWER_GIVE_REWARD);
        GetFreePowerRs.Builder builder = GetFreePowerRs.newBuilder();
        builder.addAllReward(awards);
        handler.sendMsgToPlayer(GetFreePowerRs.ext, builder.build());

        LogLordHelper.logActivity(staticActivityDataMgr, player, ActivityConst.ACT_POWER_GIVE, AwardFrom.ACT_POWER_GIVE_REWARD,
                sat.getAwardList(), 0);
    }

    /**
     * 请求集字活动信息
     *
     * @param handler
     */
    public void getCollectCharacter(ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null || null == player.lord) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_COLLECT_CHARACTER);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        GetCollectCharacterRs.Builder builder = GetCollectCharacterRs.newBuilder();
        Map<Integer, Integer> statusMap = activity.getStatusMap(); // 已兑换数量集合
        for (StaticCharacterChange change : staticActivityDataMgr.getCharacterChangeMap().values()) {
            if (change.getItemNum() < 0) { // -1 为无限制
                continue;
            }
            if (statusMap.containsKey(change.getId())) { // 该物品兑换过 减去兑换的数量
                builder.addChangeNum(PbHelper.createTwoIntPb(change.getId(), change.getItemNum() - statusMap.get(change.getId())));
            } else {
                builder.addChangeNum(PbHelper.createTwoIntPb(change.getId(), change.getItemNum()));
            }
        }
        for (Integer id : activity.getPropMap().keySet()) {
            builder.addActProp(PbHelper.createAtom2Pb(AwardType.ACTIVITY_PROP, id, activity.getPropMap().get(id)));
        }
        handler.sendMsgToPlayer(GetCollectCharacterRs.ext, builder.build());
    }

    /**
     * 集字兑换
     *
     * @param req
     * @param handler
     */
    public void collectCharacterChange(CollectCharacterChangeRq req, ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null || null == player.lord) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }

        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_COLLECT_CHARACTER);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        Activity activity = player.activitys.get(ActivityConst.ACT_COLLECT_CHARACTER);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        int id = req.getId();
        StaticCharacterChange staticChange = staticActivityDataMgr.getCharacterChangeMap().get(id);
        if (staticChange == null) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }
        Map<Integer, Integer> statusMap = activity.getStatusMap();
        if (statusMap.containsKey(id) && statusMap.get(id) >= staticChange.getItemNum() && staticChange.getItemNum() >= 0) { // 该物品已经超出兑换数量
            handler.sendErrorMsgToPlayer(GameError.COUNT_NOT_ENOUGH);
            return;
        }
        for (List<Integer> list : staticChange.getMore()) {
            if (!playerDataManager.checkPropIsEnougth(player, list.get(0), list.get(1), list.get(2))) {
                handler.sendErrorMsgToPlayer(GameError.PROP_NOT_ENOUGH);
                return;
            }
        }
        CollectCharacterChangeRs.Builder builder = CollectCharacterChangeRs.newBuilder();
        for (List<Integer> list : staticChange.getMore()) { // 减去兑换需要的活动道具
            playerDataManager.subProp(player, list.get(0), list.get(1), list.get(2), AwardFrom.COLLECT_CHARACTER_CHANGE);
        }
        for (List<Integer> list : staticChange.getAwardId()) { // 添加兑换奖励
            playerDataManager.addAward(player, list.get(0), list.get(1), list.get(2), AwardFrom.COLLECT_CHARACTER_CHANGE);
        }
        builder.addAllAward(PbHelper.createAwardsPb(staticChange.getAwardId()));
        Integer num = statusMap.get(id);
        if (num == null) {
            statusMap.put(id, 1);
        } else {
            statusMap.put(id, num + 1);
        }
        for (StaticCharacterChange change : staticActivityDataMgr.getCharacterChangeMap().values()) {
            if (change.getItemNum() < 0) { // -1 为无限制
                continue;
            }
            if (statusMap.containsKey(change.getId())) { // 该物品兑换过 减去兑换的数量
                builder.addChangeNum(PbHelper.createTwoIntPb(change.getId(), change.getItemNum() - statusMap.get(change.getId())));
            } else {
                builder.addChangeNum(PbHelper.createTwoIntPb(change.getId(), change.getItemNum()));
            }
        }
        for (Integer propId : activity.getPropMap().keySet()) {
            builder.addActProp(PbHelper.createAtom2Pb(AwardType.ACTIVITY_PROP, propId, activity.getPropMap().get(propId)));
        }
        handler.sendMsgToPlayer(CollectCharacterChangeRs.ext, builder.build());
    }

    /**
     * 集字合成
     *
     * @param req
     * @param handler
     */
    public void collectCharacterCombine(CollectCharacterCombineRq req, ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null || null == player.lord) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }

        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_COLLECT_CHARACTER);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        Activity activity = player.activitys.get(ActivityConst.ACT_COLLECT_CHARACTER);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        int id = req.getId();
        StaticActivityProp prop = staticActivityDataMgr.getActivityPropById(id);
        if (prop == null) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }
        Map<Integer, Integer> map = activity.getPropMap();
        if (map == null) {
            handler.sendErrorMsgToPlayer(GameError.PROP_NOT_ENOUGH);
            return;
        }
        Map<Integer, Integer> needNum = new HashMap<>();
        for (Integer propId : prop.getKind()) {
            if (needNum.get(propId) == null) {
                needNum.put(propId, 1);
            } else {
                needNum.put(propId, needNum.get(propId) + 1);
            }
        }
        for (Integer propId : needNum.keySet()) { // 判断合成需要的道具
            if (!playerDataManager.checkPropIsEnougth(player, AwardType.ACTIVITY_PROP, propId, needNum.get(propId))) {
                handler.sendErrorMsgToPlayer(GameError.PROP_NOT_ENOUGH);
                return;
            }
        }
        for (Integer propId : needNum.keySet()) {
            playerDataManager.subActivityProp(player, propId, needNum.get(propId), AwardFrom.COLLECT_CHARACTER_COMBINE);
        }
        playerDataManager.addActivityProp(player, id, 1, AwardFrom.COLLECT_CHARACTER_COMBINE);

        CollectCharacterCombineRs.Builder builder = CollectCharacterCombineRs.newBuilder();
        for (Integer propId : activity.getPropMap().keySet()) {
            builder.addActProp(PbHelper.createAtom2Pb(AwardType.ACTIVITY_PROP, propId, activity.getPropMap().get(propId)));
        }
        handler.sendMsgToPlayer(CollectCharacterCombineRs.ext, builder.build());
    }

    /**
     * 请求m1a2活动
     */
    public void getActM1a2(GetActM1a2Rq getActM1a2Rq, ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null || null == player.lord) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_M1A2_ID);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        Integer useDay = activity.getStatusMap().get(1);// 使用免费次数日期天
        Integer curDay = TimeHelper.getCurrentDay();
        boolean hasFree = !curDay.equals(useDay);

        GetActM1a2Rs.Builder builder = GetActM1a2Rs.newBuilder();
        builder.setHasFree(hasFree);
        handler.sendMsgToPlayer(GetActM1a2Rs.ext, builder.build());
    }

    /**
     * 探索m1a2活动
     */
    public void doActM1a2(DoActM1a2Rq doActM1a2Rq, ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null || null == player.lord) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_M1A2_ID);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        int id = doActM1a2Rq.getId();// 普通1 高级2
        boolean isSingle = doActM1a2Rq.getSingle();
        int times = isSingle ? 1 : 10;
        StaticActivityM1a2 staticActivityM1a2 = staticActivityDataMgr.getActivityM1a2(id);
        if (staticActivityM1a2 == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }

        Integer useDay = activity.getStatusMap().get(1);// 使用免费次数日期天
        Integer curDay = TimeHelper.getCurrentDay();
        boolean hasFree = !curDay.equals(useDay);
        if (id == 1 && isSingle && hasFree) {// 只有普通 且是单抽 才有免费次数
            activity.getStatusMap().put(1, curDay);
            hasFree = false;
        } else {
            int cost = 0;
            if (isSingle) {
                cost = staticActivityM1a2.getPriceOne();
            } else {
                cost = staticActivityM1a2.getPriceTen();
            }

            if (player.lord.getGold() < cost) {
                handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
                return;
            }
            playerDataManager.subGold(player, cost, AwardFrom.DO_ACT_M1A2);
        }

        DoActM1a2Rs.Builder builder = DoActM1a2Rs.newBuilder();
        builder.setGold(player.lord.getGold());
        builder.setHasFree(hasFree);
        builder.addAllAward(activityDataManager.getM1a2Awards(player, staticActivityM1a2, times, AwardFrom.DO_ACT_M1A2));
        handler.sendMsgToPlayer(DoActM1a2Rs.ext, builder.build());
    }

    /**
     * m1a2坦克改造
     */
    public void m1a2RefitTank(M1a2RefitTankRq refitTankRq, ClientHandler handler) {
        int tankId = refitTankRq.getTankId();
        int count = refitTankRq.getCount();

        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null || null == player.lord) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_M1A2_ID);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        if (count <= 0 || count > 100) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }

        StaticTank staticTank = staticTankDataMgr.getStaticTank(tankId);
        if (staticTank == null) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }

        StaticActivityM1a2 staticActivityM1a2 = staticActivityDataMgr.getActivityM1a2(1);
        if (staticActivityM1a2 == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }

        // 只有这种坦克可以使用此方法改造
        if (staticActivityM1a2.getTankId() != tankId) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }

        int refitId = staticTank.getRefitId();
        StaticTank refitTank = staticTankDataMgr.getStaticTank(refitId);
        if (refitTank == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }

        Tank tank = player.tanks.get(tankId);
        if (tank == null || tank.getCount() < count) {
            handler.sendErrorMsgToPlayer(GameError.TANK_COUNT);
            return;
        }

        Resource resource = player.resource;
        int ironCost = (refitTank.getIron() - staticTank.getIron()) * count;
        int oilCost = (refitTank.getOil() - staticTank.getOil()) * count;
        int copperCost = (refitTank.getCopper() - staticTank.getCopper()) * count;
        int siliconCost = (refitTank.getSilicon() - staticTank.getSilicon()) * count;

        if (resource.getIron() < ironCost || resource.getOil() < oilCost || resource.getCopper() < copperCost
                || resource.getSilicon() < siliconCost) {
            handler.sendErrorMsgToPlayer(GameError.RESOURCE_NOT_ENOUGH);
            return;
        }

        // 坦克核心道具
        int drawingId = refitTank.getDrawing();
        int drawingCount = count;

        Prop drawingProp = null;
        if (drawingId > 0 && drawingCount > 0) {
            drawingProp = player.props.get(drawingId);
            if (drawingProp == null || drawingProp.getCount() < drawingCount) {
                handler.sendErrorMsgToPlayer(GameError.PROP_NOT_ENOUGH);
                return;
            }
        }

        M1a2RefitTankRs.Builder builder = M1a2RefitTankRs.newBuilder();

        // 减资源
        if (ironCost > 0) {
            playerDataManager.modifyIron(player, -ironCost, AwardFrom.M1A2_REFIT_TANK);
            builder.addAtom2(PbHelper.createAtom2Pb(AwardType.RESOURCE, 1, resource.getIron()));
        }

        if (oilCost > 0) {
            playerDataManager.modifyOil(player, -oilCost, AwardFrom.M1A2_REFIT_TANK);
            builder.addAtom2(PbHelper.createAtom2Pb(AwardType.RESOURCE, 2, resource.getOil()));
        }

        if (copperCost > 0) {
            playerDataManager.modifyCopper(player, -copperCost, AwardFrom.M1A2_REFIT_TANK);
            builder.addAtom2(PbHelper.createAtom2Pb(AwardType.RESOURCE, 3, resource.getCopper()));
        }

        if (siliconCost > 0) {
            playerDataManager.modifySilicon(player, -siliconCost, AwardFrom.M1A2_REFIT_TANK);
            builder.addAtom2(PbHelper.createAtom2Pb(AwardType.RESOURCE, 4, resource.getSilicon()));
        }

        if (drawingId > 0) {
            builder.addAtom2(playerDataManager.subProp(player, AwardType.PROP, drawingId, drawingCount, AwardFrom.M1A2_REFIT_TANK));
        }

        // 减坦克
        builder.addAtom2(playerDataManager.subProp(player, AwardType.TANK, tankId, count, AwardFrom.M1A2_REFIT_TANK));

        // 增加坦克
        Tank t = playerDataManager.addTank(player, refitId, count, AwardFrom.M1A2_REFIT_TANK);
        builder.addAtom2(PbHelper.createAtom2Pb(AwardType.TANK, refitId, t.getCount()));

        handler.sendMsgToPlayer(M1a2RefitTankRs.ext, builder.build());
    }

    /**
     * 请求鲜花祝福活动信息
     *
     * @param handler
     */
    public void getFlower(ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null || null == player.lord) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_FLOWER);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        int totday = TimeHelper.getCurrentDay();
        if (activity.getEndTime() != totday) {// 隔天后清空记录
            activity.setEndTime(totday);
        }

        GetFlowerRs.Builder builder = GetFlowerRs.newBuilder();
        Map<Integer, Integer> statusMap = activity.getStatusMap(); // 已祝福数量集合
        for (StaticActivityFlower flower : staticActivityDataMgr.getActivityFlowerMap().values()) {
            if (flower.getItemNum() < 0) { // -1 为无限制
                continue;
            }
            if (statusMap.containsKey(flower.getId())) { // 该物品兑换过 减去兑换的数量
                builder.addChangeNum(PbHelper.createTwoIntPb(flower.getId(), flower.getItemNum() - statusMap.get(flower.getId())));
            } else {
                builder.addChangeNum(PbHelper.createTwoIntPb(flower.getId(), flower.getItemNum()));
            }
        }
        for (Integer id : activity.getPropMap().keySet()) {
            builder.setActProp(PbHelper.createAtom2Pb(AwardType.ACTIVITY_PROP, id, activity.getPropMap().get(id)));
        }
        handler.sendMsgToPlayer(GetFlowerRs.ext, builder.build());
    }

    /**
     * 鲜花祝福
     *
     * @param req
     * @param handler
     */
    public void wishFlower(WishFlowerRq req, ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null || null == player.lord) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }

        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_FLOWER);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        Activity activity = player.activitys.get(ActivityConst.ACT_FLOWER);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        int id = req.getId();
        StaticActivityFlower flower = staticActivityDataMgr.getActivityFlowerMap().get(id);
        if (flower == null) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }
        Map<Integer, Integer> statusMap = activity.getStatusMap();
        if (statusMap.containsKey(id) && statusMap.get(id) >= flower.getItemNum() && flower.getItemNum() >= 0) { // 该物品已经超出兑换数量
            handler.sendErrorMsgToPlayer(GameError.COUNT_NOT_ENOUGH);
            return;
        }
        for (List<Integer> list : flower.getMore()) {
            if (!playerDataManager.checkPropIsEnougth(player, list.get(0), list.get(1), list.get(2))) {
                handler.sendErrorMsgToPlayer(GameError.PROP_NOT_ENOUGH);
                return;
            }
        }
        List<Integer> award = new ArrayList<>();
        int random = 0;
        for (List<Integer> list : flower.getAwards()) {
            random += list.get(3);
        }
        random = RandomHelper.randomInSize(random);
        int total = 0;
        for (List<Integer> list : flower.getAwards()) {
            if (list.size() < 4) {
                continue;
            }
            total += list.get(3);
            if (random <= total) {
                award = list;
                break;
            }
        }
        for (List<Integer> list : flower.getMore()) { // 减去兑换需要的活动道具
            playerDataManager.subProp(player, list.get(0), list.get(1), list.get(2), AwardFrom.WISH_FLOWER);
        }
        // 添加兑换奖励
        int keyId = playerDataManager.addAward(player, award.get(0), award.get(1), award.get(2), AwardFrom.WISH_FLOWER);
        Integer num = statusMap.get(id);
        if (num == null) {
            statusMap.put(id, 1);
        } else {
            statusMap.put(id, num + 1);
        }
        WishFlowerRs.Builder builder = WishFlowerRs.newBuilder();
        CommonPb.Award awardPb = PbHelper.createAwardPb(award.get(0), award.get(1), award.get(2), keyId);
        builder.addAward(awardPb);
        for (StaticActivityFlower flowers : staticActivityDataMgr.getActivityFlowerMap().values()) {
            if (flowers.getItemNum() < 0) { // -1 为无限制
                continue;
            }
            if (statusMap.containsKey(flowers.getId())) { // 该物品兑换过 减去兑换的数量
                builder.addChangeNum(PbHelper.createTwoIntPb(flowers.getId(), flowers.getItemNum() - statusMap.get(flowers.getId())));
            } else {
                builder.addChangeNum(PbHelper.createTwoIntPb(flowers.getId(), flowers.getItemNum()));
            }
        }
        for (Integer propId : activity.getPropMap().keySet()) {
            builder.setActProp(PbHelper.createAtom2Pb(AwardType.ACTIVITY_PROP, propId, activity.getPropMap().get(propId)));
        }
        handler.sendMsgToPlayer(WishFlowerRs.ext, builder.build());

        // 发送加入活动消息
        List<CommonPb.Award> awardPbList = new ArrayList<>();
        awardPbList.add(awardPb);
        propService.sendJoinActivityMsg(ActivityConst.ACT_FLOWER, player, awardPbList);
    }

    /**
     * 请求返利我做主活动
     *
     * @param handler
     */
    public void getPayRebate(ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null || null == player.lord) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_PAY_REBATE);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        int totday = TimeHelper.getCurrentDay();
        if (activity.getEndTime() != totday) {// 隔天后清空记录
            activity.setEndTime(totday);
        }

        GetPayRebateRs.Builder builder = GetPayRebateRs.newBuilder();
        builder.setPayRebate(PbHelper.createPayRebatePb(activity.getStatusList(), ActivityConst.COUNT_FOR_PAY_REBATE));
        handler.sendMsgToPlayer(GetPayRebateRs.ext, builder.build());
    }

    /**
     * 开始转盘
     *
     * @param handler
     */
    public void doPayRebate(ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null || null == player.lord) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }

        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_PAY_REBATE);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        Activity activity = player.activitys.get(ActivityConst.ACT_PAY_REBATE);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        int useCount = activity.getStatusList().get(3).intValue();
        if (ActivityConst.COUNT_FOR_PAY_REBATE - useCount <= 0) { // 次数不足
            handler.sendErrorMsgToPlayer(GameError.COUNT_NOT_ENOUGH);
            return;
        }
        StaticActPayRebate rate = staticActivityDataMgr.randomPayRebateRate(1);
        StaticActPayRebate money = staticActivityDataMgr.randomPayRebateRate(2);

        activity.getStatusList().set(0, (long) money.getValue());
        activity.getStatusList().set(1, (long) rate.getValue());
        activity.getStatusList().set(2, 0L); // 充值清除
        activity.getStatusList().set(3, (long) (useCount + 1)); // 扣除次数

        DoPayRebateRs.Builder builder = DoPayRebateRs.newBuilder();
        builder.setPayRebate(PbHelper.createPayRebatePb(activity.getStatusList(), ActivityConst.COUNT_FOR_PAY_REBATE));
        handler.sendMsgToPlayer(DoPayRebateRs.ext, builder.build());

        // 记录日志：转动次数，转动返利比例，转动返利金额
        LogLordHelper.payRebate(player, activityBase.getPlan().getAwardId(), useCount + 1, rate.getValue(), money.getValue());
    }

    /**
     * 请求海贼宝藏抽奖界面
     *
     * @param handler
     */
    public void getActPirateLottery(ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null || null == player.lord) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }

        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_PIRATE);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        int awardId = activityBase.getKeyId();

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_PIRATE);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        int totday = TimeHelper.getCurrentDay();
        if (activity.getEndTime() != totday) {// 隔天后清空记录
            activity.setEndTime(totday);
        }
        GetPirateLotteryRs.Builder builder = GetPirateLotteryRs.newBuilder();
        PirateData.Builder data = PirateData.newBuilder();
        Integer count = activity.getSaveMap().get(0);
        if (count == null) { // 新一轮
            data.setCount(ActivityConst.COUNT_FOR_PIRATE);
            data.setOneLottery(ActivityConst.PRICE_FOR_PIRATE_ONE);
            data.setAllLottery(0);
            data.setIsReset(false);
        } else { // 进行中
            data.setIsReset(true);
            if (count == ActivityConst.COUNT_FOR_PIRATE) { // 已经抽完
                data.setCount(0);
                data.setOneLottery(0);
                data.setAllLottery(0);
            } else { // 还未抽完
                data.setCount(ActivityConst.COUNT_FOR_PIRATE - count);
                data.setOneLottery(ActivityConst.PRICE_FOR_PIRATE_ONE);
                if (count == 1) { // 刚抽完一次
                    data.setAllLottery(ActivityConst.PRICE_FOR_PIRATE_MORE);
                } else {
                    data.setAllLottery(0);
                }
            }
            for (StaticActPirate pirate : staticActivityDataMgr.getActPirateMap(awardId).values()) {
                int grid = pirate.getId();
                boolean has = activity.getSaveMap().get(-grid) == 1; // 负的记录的是抽中状态 1.已抽中 0.没抽中
                List<Integer> award = pirate.getAward().get(activity.getSaveMap().get(grid)); // 正的记录的是随出奖励下标
                data.addGrids(PbHelper.createPirateGridPb(grid, has, award));
            }
        }
        builder.setAwardId(awardId);
        builder.setData(data);
        handler.sendMsgToPlayer(GetPirateLotteryRs.ext, builder.build());
    }

    /**
     * 请求海贼宝藏抽奖
     *
     * @param req
     * @param handler
     */
    public void doActPirateLottery(DoPirateLotteryRq req, ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null || null == player.lord) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_PIRATE);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_PIRATE);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        int awardId = activityBase.getKeyId();

        if (activityBase.getStep() == ActivityConst.OPEN_AWARD) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        UsualActivityData activityData = activityDataManager.getUsualActivity(ActivityConst.ACT_PIRATE);
        if (activityData == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        int type = req.getType();
        if (type != 1 && type != 2) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }
        Map<Integer, Integer> saveMap = activity.getSaveMap();
        Integer count = saveMap.get(0);
        if (count != null && count >= ActivityConst.COUNT_FOR_PIRATE) {
            handler.sendErrorMsgToPlayer(GameError.COUNT_NOT_ENOUGH);
            return;
        }
        Integer score = saveMap.get(10);

        // 新增积分
        int increase;

        DoPirateLotteryRs.Builder builder = DoPirateLotteryRs.newBuilder();
        PirateData.Builder data = PirateData.newBuilder();

        List<CommonPb.Award> awardPbList = new ArrayList<>();
        if (type == 1) { // 单抽
            if (player.lord.getGold() < ActivityConst.PRICE_FOR_PIRATE_ONE) {
                handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
                return;
            }
            if (score == null) {
                score = 0;
                saveMap.put(10, score);
            }
            if (count == null) { // 新一轮 第一次抽
                saveMap = staticActivityDataMgr.randomActPirate(awardId);
                saveMap.put(0, 0);
            }
            playerDataManager.subGold(player, ActivityConst.PRICE_FOR_PIRATE_ONE, AwardFrom.ACT_PIRATE_LOTTERY); // 消耗金币
            saveMap.put(0, saveMap.get(0) + 1); // 消耗次数
            int gridId = staticActivityDataMgr.randomActPirate(saveMap, awardId); // 随机出抽到的格子id
            int index = saveMap.get(gridId); // 找出之前随出的奖励下标
            saveMap.put(-gridId, 1); // 状态致为已抽取
            List<Integer> award = staticActivityDataMgr.getActPirateMap(awardId).get(gridId).getAward().get(index);
            int keyId = playerDataManager.addAward(player, award.get(0), award.get(1), award.get(2), AwardFrom.ACT_PIRATE_LOTTERY);
            awardPbList.add(PbHelper.createAwardPb(award.get(0), award.get(1), award.get(2), keyId));
            if (saveMap.get(0) == 1) { // 第一次
                data.setOneLottery(ActivityConst.PRICE_FOR_PIRATE_ONE);
                data.setAllLottery(ActivityConst.PRICE_FOR_PIRATE_MORE);
            } else if (saveMap.get(0) == ActivityConst.COUNT_FOR_PIRATE) { // 没次数了
                data.setOneLottery(0);
                data.setAllLottery(0);
            } else {
                data.setOneLottery(ActivityConst.PRICE_FOR_PIRATE_ONE);
                data.setAllLottery(0);
            }
            score += ActivityConst.SCORE_FOR_PIRATE_ONE;

            // 单抽新增积分
            increase = ActivityConst.SCORE_FOR_PIRATE_ONE;
        } else { // 全抽
            if (player.lord.getGold() < ActivityConst.PRICE_FOR_PIRATE_MORE) {
                handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
                return;
            }
            if (saveMap.size() == 0) { // 没抽过无法全抽
                handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
                return;
            }
            if (saveMap.get(0) != 1) { // 只有第二次才能全抽
                handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
                return;
            }
            playerDataManager.subGold(player, ActivityConst.PRICE_FOR_PIRATE_MORE, AwardFrom.ACT_PIRATE_LOTTERY); // 消耗金币
            Iterator<Integer> it = saveMap.keySet().iterator();
            int hasGrid = 0;
            for (Integer key : saveMap.keySet()) {
                if (key < 0 && saveMap.get(key) == 1) {
                    hasGrid = -key; // 找出已经抽中的格子
                    break;
                }
            }
            while (it.hasNext()) {
                Integer key = it.next();
                if (key == 0) {
                    saveMap.put(key, ActivityConst.COUNT_FOR_PIRATE); // 全抽消耗全部次数
                } else if (key < 0) {
                    saveMap.put(key, 1); // 全抽 状态全部至为已抽取
                } else { // 发放全部奖励
                    if (key != 10 && key != hasGrid) { // 10为积分 其他的为奖励 还要出去已经抽中的那一次
                        int index = saveMap.get(key);
                        List<Integer> award = staticActivityDataMgr.getActPirateMap(awardId).get(key).getAward().get(index);
                        int keyId = playerDataManager.addAward(player, award.get(0), award.get(1), award.get(2),
                                AwardFrom.ACT_PIRATE_LOTTERY);
                        awardPbList.add(PbHelper.createAwardPb(award.get(0), award.get(1), award.get(2), keyId));
                    }
                }
            }
            data.setOneLottery(0);
            data.setAllLottery(0);
            score += ActivityConst.SCORE_FOR_PIRATE_MORE;

            // 多抽新增积分
            increase = ActivityConst.SCORE_FOR_PIRATE_MORE;
        }
        data.setIsReset(true);
        data.setCount(ActivityConst.COUNT_FOR_PIRATE - saveMap.get(0));
        for (StaticActPirate pirate : staticActivityDataMgr.getActPirateMap(awardId).values()) {
            int grid = pirate.getId();
            boolean has = saveMap.get(-grid) == 1; // 负的记录的是抽中状态 1.已抽中 0.没抽中
            List<Integer> award = pirate.getAward().get(saveMap.get(grid)); // 正的记录的是随出奖励下标
            data.addGrids(PbHelper.createPirateGridPb(grid, has, award));
        }
        saveMap.put(10, score);
        activity.setSaveMap(saveMap);

        if (score >= ActivityConst.SCORE_FOR_PIRATE_RANK) { // 大于500积分入榜
            activityData.addPlayerRank(player.lord.getLordId(), (long) score, ActivityConst.RANK_PAWN, ActivityConst.DESC);
        }

        builder.setData(data);
        builder.setGold(player.lord.getGold());
        builder.addAllAwards(awardPbList);
        handler.sendMsgToPlayer(DoPirateLotteryRs.ext, builder.build());

        // 发送加入活动消息
        propService.sendJoinActivityMsg(ActivityConst.ACT_PIRATE, player, awardPbList);

        // 计算玩家在排名榜上的名次
        LinkedList<ActPlayerRank> rankList = activityData.getPlayerRanks(ActivityConst.DESC);
        int rank = 0;
        for (int i = 0; i < rankList.size(); i++) {
            if (rankList.get(i).getLordId() == player.lord.getLordId()) {
                rank = i + 1;
                break;
            }
        }
        // 记录玩家排行榜日志
        LogLordHelper.logRank(player, activityBase.getPlan().getAwardId(), score, increase, rank);
    }

    /**
     * 请求重置海贼宝藏抽奖
     *
     * @param handler
     */
    public void resetActPirateLottery(ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null || null == player.lord) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_PIRATE);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_PIRATE);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        if (activityBase.getStep() == ActivityConst.OPEN_AWARD) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        Map<Integer, Integer> saveMap = activity.getSaveMap();
        if (saveMap.size() == 0) { // 并没有开始抽
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }
        Integer score = saveMap.get(10);
        saveMap.clear();
        saveMap.put(10, score); // 保留积分
        ResetPirateLotteryRs.Builder builder = ResetPirateLotteryRs.newBuilder();
        PirateData.Builder data = PirateData.newBuilder();
        data.setCount(ActivityConst.COUNT_FOR_PIRATE);
        data.setOneLottery(ActivityConst.PRICE_FOR_PIRATE_ONE);
        data.setAllLottery(0);
        data.setIsReset(false);
        builder.setData(data);
        handler.sendMsgToPlayer(ResetPirateLotteryRs.ext, builder.build());
    }

    /**
     * 请求海贼宝藏兑换界面
     *
     * @param handler
     */
    public void getActPirateChange(ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null || null == player.lord) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_PIRATE);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_PIRATE);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        int awardId = activityBase.getKeyId();

        GetPirateChangeRs.Builder builder = GetPirateChangeRs.newBuilder();
        Map<Integer, Integer> statusMap = activity.getStatusMap(); // 已兑换数量集合
        for (StaticActivityChange change : staticActivityDataMgr.getActivityChangeMap(awardId).values()) {
            if (change.getItemNum() < 0) { // -1 为无限制
                continue;
            }
            if (statusMap.containsKey(change.getId())) { // 该物品兑换过 减去兑换的数量
                builder.addChangeNum(PbHelper.createTwoIntPb(change.getId(), change.getItemNum() - statusMap.get(change.getId())));
            } else {
                builder.addChangeNum(PbHelper.createTwoIntPb(change.getId(), change.getItemNum()));
            }
        }
        for (Integer id : activity.getPropMap().keySet()) {
            builder.setActProp(PbHelper.createAtom2Pb(AwardType.ACTIVITY_PROP, id, activity.getPropMap().get(id)));
        }
        builder.setAwardId(awardId);
        handler.sendMsgToPlayer(GetPirateChangeRs.ext, builder.build());
    }

    /**
     * 请求海贼宝藏兑换
     *
     * @param req
     * @param handler
     */
    public void doActPirateChange(DoPirateChangeRq req, ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null || null == player.lord) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }

        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_PIRATE);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        Activity activity = player.activitys.get(ActivityConst.ACT_PIRATE);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        if (activityBase.getStep() == ActivityConst.OPEN_AWARD) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        int id = req.getId();
        StaticActivityChange staticChange = staticActivityDataMgr.getActivityChangeMap(activityBase.getKeyId()).get(id);
        if (staticChange == null) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }
        Map<Integer, Integer> statusMap = activity.getStatusMap();
        if (statusMap.containsKey(id) && statusMap.get(id) >= staticChange.getItemNum() && staticChange.getItemNum() >= 0) { // 该物品已经超出兑换数量
            handler.sendErrorMsgToPlayer(GameError.COUNT_NOT_ENOUGH);
            return;
        }
        for (List<Integer> list : staticChange.getMore()) {
            if (!playerDataManager.checkPropIsEnougth(player, list.get(0), list.get(1), list.get(2))) {
                handler.sendErrorMsgToPlayer(GameError.PROP_NOT_ENOUGH);
                return;
            }
        }
        for (List<Integer> need : staticChange.getMore()) { // 减去兑换需要的活动道具
            playerDataManager.subProp(player, need.get(0), need.get(1), need.get(2), AwardFrom.ACT_PIRATE_CHANGE);
        }
        Integer num = statusMap.get(id);
        if (num == null) {
            statusMap.put(id, 1);
        } else {
            statusMap.put(id, num + 1);
        }
        DoPirateChangeRs.Builder builder = DoPirateChangeRs.newBuilder();
        // 添加兑换奖励
        for (List<Integer> award : staticChange.getAward()) { // 发放活动奖励
            int keyId = playerDataManager.addAward(player, award.get(0), award.get(1), award.get(2), AwardFrom.ACT_PIRATE_CHANGE);
            CommonPb.Award awardPb = PbHelper.createAwardPb(award.get(0), award.get(1), award.get(2), keyId);
            builder.addAward(awardPb);
        }
        for (StaticActivityChange change : staticActivityDataMgr.getActivityChangeMap(ActivityConst.ACT_PIRATE).values()) {
            if (change.getItemNum() < 0) { // -1 为无限制
                continue;
            }
            if (statusMap.containsKey(change.getId())) { // 该物品兑换过 减去兑换的数量
                builder.addChangeNum(PbHelper.createTwoIntPb(change.getId(), change.getItemNum() - statusMap.get(change.getId())));
            } else {
                builder.addChangeNum(PbHelper.createTwoIntPb(change.getId(), change.getItemNum()));
            }
        }
        for (Integer propId : activity.getPropMap().keySet()) {
            builder.setActProp(PbHelper.createAtom2Pb(AwardType.ACTIVITY_PROP, propId, activity.getPropMap().get(propId)));
        }
        handler.sendMsgToPlayer(DoPirateChangeRs.ext, builder.build());
    }

    /**
     * 请求海贼宝藏积分排行榜
     *
     * @param handler
     */
    public void getActPirateRank(ClientHandler handler) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_PIRATE);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        int activityKeyId = activityBase.getKeyId();
        int step = activityBase.getStep();
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

        UsualActivityData activityData = activityDataManager.getUsualActivity(ActivityConst.ACT_PIRATE);
        if (activityData == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_PIRATE);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        List<StaticActRank> srankList = staticActivityDataMgr.getActRankList(activityKeyId, ActivityConst.TYPE_DEFAULT);
        if (srankList == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }
        // 我的积分
        Integer score = activity.getSaveMap().get(10);
        if (score == null) {
            score = 0;
        }

        GetActPirateRankRs.Builder builder = GetActPirateRankRs.newBuilder();
        LinkedList<ActPlayerRank> rankList = activityData.getPlayerRanks(ActivityConst.TYPE_DEFAULT);

        // 去重
        if (!CheckNull.isEmpty(rankList)) {
            Set<Long> lordIdSet = new HashSet<Long>();

            Iterator<ActPlayerRank> its = rankList.iterator();
            while (its.hasNext()) {
                ActPlayerRank rk = its.next();
                if (lordIdSet.contains(rk.getLordId())) {
                    its.remove();
                    continue;
                }
                lordIdSet.add(rk.getLordId());
            }
            lordIdSet.clear();
        }

        for (int i = 0; i < rankList.size() && i < ActivityConst.RANK_PAWN; i++) {
            ActPlayerRank e = rankList.get(i);
            long lordId = e.getLordId();
            Player rankPlayer = playerDataManager.getPlayer(lordId);
            if (rankPlayer != null && rankPlayer.lord != null) {
                builder.addActPlayerRank(PbHelper.createActPlayerRank(e, rankPlayer.lord.getNick()));
            }
        }
        builder.setStatus(0);
        builder.setScore((int) score);
        if (step == ActivityConst.OPEN_STEP) {
            builder.setOpen(false);
        } else if (step == ActivityConst.OPEN_AWARD) {
            builder.setOpen(true);
            Map<Integer, Integer> statusMap = activity.getStatusMap();
            if (statusMap.containsKey(ActivityConst.TYPE_DEFAULT)) {
                builder.setStatus(1);
            }
        }

        List<StaticActRank> staticActRankList = staticActivityDataMgr.getActRankList(activityKeyId, ActivityConst.TYPE_DEFAULT);
        if (staticActRankList != null) {
            for (StaticActRank e : staticActRankList) {
                builder.addRankAward(PbHelper.createRankAwardPb(e));
            }
        }
        handler.sendMsgToPlayer(GetActPirateRankRs.ext, builder.build());
    }

    /**
     * 能晶转盘-主页面
     *
     * @param handler
     */
    public void getActEnergyStoneDialRq(ClientHandler handler) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_ENERGYSTONE_DIAL_ID);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
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

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_ENERGYSTONE_DIAL_ID);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        GetActEnergyStoneDialRs.Builder builder = GetActEnergyStoneDialRs.newBuilder();
        int monthAndDay = TimeHelper.getMonthAndDay(new Date());
        int energyStoneDial = lord.getEnergyStoneDial();
        if (energyStoneDial / 100 != monthAndDay / 100) {
            energyStoneDial = monthAndDay;
        }

        int useCount = energyStoneDial % 100;
        int free = 0;
        // if (lord.getVip() > 0) {
        // free = 2 - useCount < 0 ? 0 : 2 - useCount;
        // } else {
        free = 1 - useCount < 0 ? 0 : 1 - useCount;
        // }
        builder.setFree(free);// 剩余次数

        long score = activity.getStatusList().get(0);
        List<StaticActFortune> condList = staticActivityDataMgr.getActFortuneList(ActivityConst.ACT_ENERGYSTONE_DIAL_ID);
        for (StaticActFortune e : condList) {
            builder.addFortune(PbHelper.createFortunePb(e));
            builder.setDisplayList(e.getDisplayList());
        }
        builder.setScore((int) score);// 我的积分
        handler.sendMsgToPlayer(GetActEnergyStoneDialRs.ext, builder.build());
    }

    /**
     * 能晶转盘-排行榜{前十名,其他均为未入榜}
     *
     * @param handler
     */
    public void getActEnergyStoneDialRankRq(ClientHandler handler) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_ENERGYSTONE_DIAL_ID);
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

        UsualActivityData activityData = activityDataManager.getUsualActivity(ActivityConst.ACT_ENERGYSTONE_DIAL_ID);
        if (activityData == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_ENERGYSTONE_DIAL_ID);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        // 我的积分
        long score = activity.getStatusList().get(0);

        GetActEnergyStoneDialRankRs.Builder builder = GetActEnergyStoneDialRankRs.newBuilder();
        LinkedList<ActPlayerRank> rankList = activityData.getPlayerRanks(ActivityConst.TYPE_DEFAULT);
        for (int i = 0; i < rankList.size() && i < ActivityConst.RANK_ENERGYSTONE_DESTORY; i++) {
            ActPlayerRank e = rankList.get(i);
            long lordId = e.getLordId();
            Player rankPlayer = playerDataManager.getPlayer(lordId);
            if (rankPlayer != null && rankPlayer.lord != null) {
                builder.addActPlayerRank(PbHelper.createActPlayerRank(e, rankPlayer.lord.getNick()));
            }
        }
        builder.setStatus(0);
        builder.setScore((int) score);
        if (step == ActivityConst.OPEN_STEP) {
            builder.setOpen(false);
        } else if (step == ActivityConst.OPEN_AWARD) {
            builder.setOpen(true);
            Map<Integer, Integer> statusMap = activity.getStatusMap();
            if (statusMap.containsKey(ActivityConst.TYPE_DEFAULT)) {
                builder.setStatus(1);
            }
        }

        List<StaticActRank> staticActRankList = staticActivityDataMgr.getActRankList(activityKeyId, ActivityConst.TYPE_DEFAULT);
        if (staticActRankList != null) {
            for (StaticActRank e : staticActRankList) {
                builder.addRankAward(PbHelper.createRankAwardPb(e));
            }
        }
        handler.sendMsgToPlayer(GetActEnergyStoneDialRankRs.ext, builder.build());
    }

    /**
     * 能晶转盘-抽取
     *
     * @param req
     * @param handler
     */
    public void doActEnergyStoneDialRq(DoActEnergyStoneDialRq req, ClientHandler handler) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_ENERGYSTONE_DIAL_ID);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        int step = activityBase.getStep();
        if (step != 0) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
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

        UsualActivityData activityData = activityDataManager.getUsualActivity(ActivityConst.ACT_ENERGYSTONE_DIAL_ID);
        if (activityData == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_ENERGYSTONE_DIAL_ID);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        int fortuneId = req.getFortuneId();
        StaticActFortune staticActFortune = staticActivityDataMgr.getActFortune(fortuneId);
        if (staticActFortune == null) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }

        int monthAndDay = TimeHelper.getMonthAndDay(new Date());
        int energyStoneDial = lord.getEnergyStoneDial();
        if (energyStoneDial / 100 != monthAndDay / 100) {
            energyStoneDial = monthAndDay;
        }
        int useCount = energyStoneDial % 100;
        int free = 0;
        // if (lord.getVip() > 0) {
        // free = 2 - useCount < 0 ? 0 : 2 - useCount;
        // } else {
        free = 1 - useCount < 0 ? 0 : 1 - useCount;
        // }

        if (free > 0 && staticActFortune.getCount() == 1) {// 单抽免费次数
            lord.setEnergyStoneDial(energyStoneDial + 1);
        } else {
            int price = staticActFortune.getPrice();
            if (lord.getGold() < price) {
                handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
                return;
            }
            playerDataManager.subGold(player, price, AwardFrom.ENERGYSTONE_DIAL);
        }

        DoActEnergyStoneDialRs.Builder builder = DoActEnergyStoneDialRs.newBuilder();

        // 发放奖励
        int scoreAdd = 0;
        int repeat = staticActFortune.getCount();
        for (int i = 0; i < repeat; i++) {
            List<Integer> list = staticActivityDataMgr.randomAwardList(staticActFortune.getAwardList());
            if (list == null || list.size() < 5) {
                continue;
            }
            int type = list.get(0);
            int id = list.get(1);
            int count = list.get(2);
            int keyId = playerDataManager.addAward(player, type, id, count, AwardFrom.ENERGYSTONE_DIAL);
            scoreAdd += list.get(4);// 增加积分
            builder.addAward(PbHelper.createAwardPb(type, id, count, keyId));
        }

        long score = activity.getStatusList().get(0);
        score += scoreAdd;
        activity.getStatusList().set(0, score);

        // 优化：转盘新增每日目标
        int day = TimeHelper.getCurrentDay();
        DialDailyGoalInfo energyDialDayInfo = player.getEnergyDialDayInfo();
        if (energyDialDayInfo.getLastDay() == day) {
            energyDialDayInfo.setCount(energyDialDayInfo.getCount() + staticActFortune.getCount());
        } else {
            energyDialDayInfo.setLastDay(day);
            energyDialDayInfo.setCount(staticActFortune.getCount());
            energyDialDayInfo.getRewardStatus().clear();
        }

        List<StaticActAward> awards = staticActivityDataMgr.getActAwardById(activityBase.getKeyId());
        if (awards == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }
        // 更新每日目标奖励状态
        Map<Integer, Integer> status = energyDialDayInfo.getRewardStatus();
        for (StaticActAward award : awards) {
            if (energyDialDayInfo.getCount() >= award.getCond()
                    && (!status.containsKey(award.getKeyId()) || status.get(award.getKeyId()) == -1)) {
                status.put(award.getKeyId(), 0);
            }
        }

        // 计算排名
        if (score >= 600) {// 积分超过600才可进入排行
            activityData.addPlayerRank(lord.getLordId(), score, ActivityConst.RANK_ENERGYSTONE_DESTORY, ActivityConst.DESC);
        }

        builder.setScore((int) score);// 我的积分
        handler.sendMsgToPlayer(DoActEnergyStoneDialRs.ext, builder.build());
    }

    /**
     * 能晶转盘 获取每日目标界面信息
     *
     * @param handler
     */
    public void getEnergyDialDayInfo(ClientHandler handler) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_ENERGYSTONE_DIAL_ID);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null || player.lord == null) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }
        List<StaticActAward> list = staticActivityDataMgr.getActAwardById(activityBase.getKeyId());
        DialDailyGoalInfo enengyInfo = player.getEnergyDialDayInfo();
        Map<Integer, Integer> status = enengyInfo.getRewardStatus();
        // 清除前一天的奖励信息
        int day = TimeHelper.getCurrentDay();
        if (enengyInfo.getLastDay() != day) {
            enengyInfo.setCount(0);
            status.clear();
        }
        for (StaticActAward award : list) {
            if (!status.containsKey(award.getKeyId())) {
                // -1 默认奖励不可领取状态
                status.put(award.getKeyId(), -1);
            }
        }
        GetEnergyDialDayInfoRs.Builder builder = GetEnergyDialDayInfoRs.newBuilder();
        builder.setCount(enengyInfo.getCount());
        for (StaticActAward award : list) {
            builder.addRewardStatus(PbHelper.createTwoIntPb(award.getKeyId(), status.get(award.getKeyId())));
        }
        handler.sendMsgToPlayer(GetEnergyDialDayInfoRs.ext, builder.build());
    }

    /**
     * 能晶转盘 领取每日目标奖励
     *
     * @param handler,rq
     */
    public void getEnergyDialDayAward(ClientHandler handler, GetEnergyDialDayAwardRq rq) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_ENERGYSTONE_DIAL_ID);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null || player.lord == null) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }
        int awardId = rq.getAwardId();
        StaticActAward award = staticActivityDataMgr.getActAward(awardId);
        DialDailyGoalInfo enengyInfo = player.getEnergyDialDayInfo();
        Map<Integer, Integer> status = enengyInfo.getRewardStatus();
        int day = TimeHelper.getCurrentDay();
        if (enengyInfo.getLastDay() != day) {
            handler.sendErrorMsgToPlayer(GameError.ACT_NOT_REFRESH_DATA);
            return;
        }
        if (status.get(award.getKeyId()) == null || status.get(award.getKeyId()) != 0) {
            handler.sendErrorMsgToPlayer(GameError.ACT_AWARD_COND_LIMIT);
            return;
        }
        GetEnergyDialDayAwardRs.Builder builder = GetEnergyDialDayAwardRs.newBuilder();
        List<List<Integer>> awardList = award.getAwardList();
        builder.addAllAward(playerDataManager.addAwardsBackPb(player, awardList, AwardFrom.ENERGRDIAL_DAYILGOAL_AWARD));
        // 将奖励状态置为已领取
        status.put(award.getKeyId(), 1);
        handler.sendMsgToPlayer(GetEnergyDialDayAwardRs.ext, builder.build());
    }

    /**
     * 获取boss界面数据
     */
    public void getActBoss(int type, ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }

        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_BOSS);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        UsualActivityData activityData = activityDataManager.getUsualActivity(ActivityConst.ACT_BOSS);
        if (activityData == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_BOSS);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        Integer cdTime = activity.getStatusMap().get(ActBossConst.MAP_KEY_CD);
        if (cdTime == null) {
            cdTime = 0;
        }

        Long addBagNum = activity.getStatusList().get(ActBossConst.RANK_BAG);
        Long callTimes = activity.getStatusList().get(ActBossConst.RANK_CALL);

        StaticActBoss staticActBoss = staticActivityDataMgr.getActBoss();
        ActBoss actBoss = activityData.getActBoss();

        String callLordName = "";
        Player callPlayer = playerDataManager.getPlayer(actBoss.getLordId());
        if (callPlayer != null) {
            callLordName = callPlayer.lord.getNick();
        }

        int bossState = -1; // boss状态 -1不能召唤 0可以召唤 1已召唤
        int step = activityBase.getStep();
        if (step == ActivityConst.OPEN_STEP) {
            if (actBoss.getState() == 1) {
                bossState = 1;
            } else {
                if (TimeHelper.isActBossTime(staticActBoss.getBeginTime())) {
                    bossState = 0;
                }
            }
        }

        GetActBossRs.Builder builder = GetActBossRs.newBuilder();
        builder.setBossState(bossState);
        builder.setBossEndTime(actBoss.getEndTime());
        builder.setBossBagNum(actBoss.getBossBagNum());
        builder.setBossCallTimes(actBoss.getCallTimes());
        builder.setCallLordName(callLordName);
        builder.setBossName(actBoss.getBossName());
        builder.setBossIcon(actBoss.getBossIcon());

        if (type == 1) {
            builder.setCallTimes(callTimes.intValue());
            builder.setAttackCd(cdTime);
            for (Integer id : activity.getPropMap().keySet()) {
                builder.addActProp(PbHelper.createAtom2Pb(AwardType.ACTIVITY_PROP, id, activity.getPropMap().get(id)));
            }
            builder.setBagNum(addBagNum.intValue());
        }

        handler.sendMsgToPlayer(GetActBossRs.ext, builder.build());
    }

    /**
     * 召唤boss
     */
    public void callActBoss(ClientHandler handler) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_BOSS);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        int step = activityBase.getStep();
        if (step != ActivityConst.OPEN_STEP) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }

        UsualActivityData activityData = activityDataManager.getUsualActivity(ActivityConst.ACT_BOSS);
        if (activityData == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        StaticActBoss staticActBoss = staticActivityDataMgr.getActBoss();
        ActBoss actBoss = activityData.getActBoss();

        if (player.lord.getLevel() < staticActBoss.getLevel()) {
            handler.sendErrorMsgToPlayer(GameError.LV_NOT_ENOUGH);
            return;
        }

        if (!TimeHelper.isActBossTime(staticActBoss.getBeginTime())) {
            handler.sendErrorMsgToPlayer(GameError.ACT_BOSS_NO_IN_TIME);// 不在指定期间不能召唤
            return;
        }

        if (actBoss.getState() == 1) {
            handler.sendErrorMsgToPlayer(GameError.ACT_BOSS_ALRADY_CALLED);// 已经召唤
            return;
        }

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_BOSS);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        List<Integer> callCost = staticActBoss.getCallCost();

        if (!playerDataManager.checkPropIsEnougth(player, callCost.get(0), callCost.get(1), callCost.get(2))) {
            if (callCost.get(0) == AwardType.GOLD) {
                handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
            } else {
                handler.sendErrorMsgToPlayer(GameError.PROP_NOT_ENOUGH);
            }
            return;
        }

        Long callTimes = activity.getStatusList().get(ActBossConst.RANK_CALL);
        callTimes++;
        activity.getStatusList().set(ActBossConst.RANK_CALL, callTimes);

        actBossBorn(actBoss, staticActBoss, player.lord.getLordId());

        if (callTimes >= staticActBoss.getCallRank()) { // 大于积分入榜
            activityData.addPlayerRank(player.lord.getLordId(), ActBossConst.RANK_CALL, callTimes, ActivityConst.RANK_ACT_BOSS,
                    ActivityConst.DESC);
        }

        CommonPb.Atom2 atom = playerDataManager.subProp(player, callCost.get(0), callCost.get(1), callCost.get(2), AwardFrom.CALL_ACT_BOSS);

        // 召唤奖励
        List<CommonPb.Award> awards = new ArrayList<CommonPb.Award>();
        for (List<Integer> item : staticActBoss.getCallAward()) {
            awards.add(PbHelper.createAwardPb(item.get(0), item.get(1), item.get(2)));
        }
        playerDataManager.sendAttachMail(AwardFrom.CALL_ACT_BOSS, player, awards, MailType.MOLD_ACT_BOSS_CALL,
                TimeHelper.getCurrentSecond());

        String callLordName = player.lord.getNick();
        chatService.sendHornChat(chatService.createSysChat(SysChatId.ACT_BOSS_CALL, callLordName, callLordName + actBoss.getBossName()), 1);

        CallActBossRs.Builder builder = CallActBossRs.newBuilder();
        builder.setCallTimes(callTimes.intValue());
        builder.setAtom(atom);
        handler.sendMsgToPlayer(CallActBossRs.ext, builder.build());
    }

    /**
     * 挑战boss
     */
    public void attackActBoss(int useId, boolean useGold, ClientHandler handler) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_BOSS);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        int step = activityBase.getStep();
        if (step != ActivityConst.OPEN_STEP) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }

        UsualActivityData activityData = activityDataManager.getUsualActivity(ActivityConst.ACT_BOSS);
        if (activityData == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        StaticActBoss staticActBoss = staticActivityDataMgr.getActBoss();
        ActBoss actBoss = activityData.getActBoss();

        if (player.lord.getLevel() < staticActBoss.getLevel()) {
            handler.sendErrorMsgToPlayer(GameError.LV_NOT_ENOUGH);
            return;
        }

        if (actBoss.getState() == 0) {
            handler.sendErrorMsgToPlayer(GameError.ACT_BOSS_NO_CALL);// 未召唤
            return;
        }

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_BOSS);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        int attackAddBagNum = staticActBoss.getAttack();

        List<List<Integer>> costItem = new ArrayList<>();
        List<List<Integer>> addAward = new ArrayList<>();
        if (useId == 1) {
            List<Integer> item = new ArrayList<>();
            if (useGold) {
                StaticActivityProp sap = staticActivityDataMgr.getActivityPropById(staticActBoss.getAttackCost().get(1));
                item.add(AwardType.GOLD);
                item.add(0);
                item.add(sap.getPrice());
            } else {
                item.addAll(staticActBoss.getAttackCost());
            }
            costItem.add(item);
            addAward.addAll(staticActBoss.getAttackAward());
        } else {
            List<Integer> item = new ArrayList<>();
            if (useGold) {
                StaticActivityProp sap = staticActivityDataMgr.getActivityPropById(staticActBoss.getAttackExCost().get(1));
                item.add(AwardType.GOLD);
                item.add(0);
                item.add(sap.getPrice());
            } else {
                item.addAll(staticActBoss.getAttackExCost());
            }
            costItem.add(item);
            addAward.addAll(staticActBoss.getAttackExAward());
            attackAddBagNum = staticActBoss.getAttackEx();
        }

        for (List<Integer> item : costItem) {
            if (!playerDataManager.checkPropIsEnougth(player, item.get(0), item.get(1), item.get(2))) {
                if (item.get(0) == AwardType.GOLD) {
                    handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
                } else {
                    handler.sendErrorMsgToPlayer(GameError.PROP_NOT_ENOUGH);
                }
                return;
            }
        }

        int curTime = TimeHelper.getCurrentSecond();
        Integer cdTime = activity.getStatusMap().get(ActBossConst.MAP_KEY_CD);
        if (cdTime == null) {
            cdTime = 0;
        }
        int costCdTime = (cdTime - curTime);
        if (costCdTime > 0) {
            handler.sendErrorMsgToPlayer(GameError.ACT_BOSS_CD_ENOUGH);
            return;
        }

        int bossBagNum = actBoss.getBossBagNum();
        if (bossBagNum < attackAddBagNum) {
            attackAddBagNum = bossBagNum;
        }
        bossBagNum -= attackAddBagNum;
        actBoss.setBossBagNum(bossBagNum);
        if (bossBagNum <= 0) {
            actBossDie(actBoss, staticActBoss, false);

            String callLordName = "";
            Player callPlayer = playerDataManager.getPlayer(actBoss.getLordId());
            if (callPlayer != null) {
                callLordName = callPlayer.lord.getNick();
            }
            // 击杀奖励
            List<CommonPb.Award> awards = new ArrayList<CommonPb.Award>();
            for (List<Integer> item : staticActBoss.getKillAward()) {
                awards.add(PbHelper.createAwardPb(item.get(0), item.get(1), item.get(2)));
            }
            playerDataManager.sendAttachMail(AwardFrom.ATTACK_ACT_BOSS, player, awards, MailType.MOLD_ACT_BOSS_KILL,
                    TimeHelper.getCurrentSecond(), callLordName + actBoss.getBossName());

            chatService.sendHornChat(chatService.createSysChat(SysChatId.ACT_BOSS_KILL, callLordName + actBoss.getBossName()), 1);
            chatService.sendHornChat(
                    chatService.createSysChat(SysChatId.ACT_BOSS_KILL_LAST, player.lord.getNick(), callLordName + actBoss.getBossName()),
                    1);
        }

        actBoss.getJoinLordIds().add(player.lord.getLordId());

        Long addBagNum = activity.getStatusList().get(ActBossConst.RANK_BAG);
        addBagNum += attackAddBagNum;
        activity.getStatusList().set(ActBossConst.RANK_BAG, addBagNum);

        activity.getStatusMap().put(ActBossConst.MAP_KEY_CD, curTime + staticActBoss.getAttackCD());

        if (addBagNum >= staticActBoss.getAttackRank()) { // 大于积分入榜
            activityData.addPlayerRank(player.lord.getLordId(), ActBossConst.RANK_BAG, addBagNum, ActivityConst.RANK_ACT_BOSS,
                    ActivityConst.DESC);
        }

        int bossState = -1; // boss状态 -1不能召唤 0可以召唤 1已召唤
        if (step == ActivityConst.OPEN_STEP) {
            if (actBoss.getState() == 1) {
                bossState = 1;
            } else {
                if (TimeHelper.isActBossTime(staticActBoss.getBeginTime())) {
                    bossState = 0;
                }
            }
        }

        AttackActBossRs.Builder builder = AttackActBossRs.newBuilder();
        builder.setAttackCd(activity.getStatusMap().get(ActBossConst.MAP_KEY_CD));
        for (List<Integer> item : addAward) {
            CommonPb.Award award = playerDataManager.addAwardBackPb(player, item, AwardFrom.ATTACK_ACT_BOSS);
            builder.addAward(award);
        }
        for (List<Integer> item : costItem) {
            CommonPb.Atom2 atom = playerDataManager.subProp(player, item.get(0), item.get(1), item.get(2), AwardFrom.ATTACK_ACT_BOSS);
            builder.addAtom(atom);
        }
        builder.setBossState(bossState);
        builder.setBossBagNum(bossBagNum);
        builder.setBagNum(addBagNum.intValue());
        handler.sendMsgToPlayer(AttackActBossRs.ext, builder.build());
    }

    /**
     * 购买CD
     */
    public void buyActBossCd(ClientHandler handler) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_BOSS);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        int step = activityBase.getStep();
        if (step != ActivityConst.OPEN_STEP) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        Player player = playerDataManager.getPlayer(handler.getRoleId());

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_BOSS);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        StaticActBoss staticActBoss = staticActivityDataMgr.getActBoss();

        int curTime = TimeHelper.getCurrentSecond();
        Integer cdTime = activity.getStatusMap().get(ActBossConst.MAP_KEY_CD);
        if (cdTime == null) {
            cdTime = 0;
        }
        int costCdTime = (cdTime - curTime);

        if (cdTime > curTime) {
            int sub = staticActBoss.getCdClear() * (int) Math.ceil(costCdTime / 60.0);
            Lord lord = player.lord;
            if (lord.getGold() < sub) {
                handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
                return;
            }
            cdTime = curTime - 1000;
            playerDataManager.subGold(player, sub, AwardFrom.BUY_ACT_BOSS_CD_TIME);
            activity.getStatusMap().put(ActBossConst.MAP_KEY_CD, cdTime);
        }

        BuyActBossCdRs.Builder builder = BuyActBossCdRs.newBuilder();
        builder.setCdTime(cdTime);
        builder.setGold(player.lord.getGold());
        handler.sendMsgToPlayer(BuyActBossCdRs.ext, builder.build());
    }

    /**
     * 福袋排行、召唤排行
     */
    public void getActBossRankRq(int rankType, ClientHandler handler) {
        if (rankType != ActBossConst.RANK_BAG && rankType != ActBossConst.RANK_CALL) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_BOSS);
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

        UsualActivityData activityData = activityDataManager.getUsualActivity(ActivityConst.ACT_BOSS);
        if (activityData == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_BOSS);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        // 我的积分
        long score = activity.getStatusList().get(rankType);

        GetActBossRankRs.Builder builder = GetActBossRankRs.newBuilder();
        LinkedList<ActPlayerRank> rankList = activityData.getPlayerRanks(rankType);
        for (int i = 0; i < rankList.size() && i < ActivityConst.RANK_ACT_BOSS; i++) {
            ActPlayerRank e = rankList.get(i);
            long lordId = e.getLordId();
            Player rankPlayer = playerDataManager.getPlayer(lordId);
            if (rankPlayer != null && rankPlayer.lord != null) {
                builder.addActPlayerRank(PbHelper.createActPlayerRank(e, rankPlayer.lord.getNick()));
            }
        }
        builder.setStatus(0);
        builder.setScore((int) score);
        if (step == ActivityConst.OPEN_STEP) {
            builder.setOpen(false);
        } else if (step == ActivityConst.OPEN_AWARD) {
            builder.setOpen(true);
            Map<Integer, Integer> statusMap = activity.getStatusMap();
            if (statusMap.containsKey(rankType)) {
                builder.setStatus(1);
            }
        }

        List<StaticActRank> staticActRankList = staticActivityDataMgr.getActRankList(activityKeyId, rankType);
        if (staticActRankList != null) {
            for (StaticActRank e : staticActRankList) {
                builder.addRankAward(PbHelper.createRankAwardPb(e));
            }
        }
        handler.sendMsgToPlayer(GetActBossRankRs.ext, builder.build());
    }

    /**
     * boss诞生
     *
     * @param actBoss
     * @param staticActBoss
     * @param lordId        void
     */
    private void actBossBorn(ActBoss actBoss, StaticActBoss staticActBoss, long lordId) {
        int now = TimeHelper.getCurrentSecond();
        int endTime = now + staticActBoss.getBattleTime();

        actBoss.setState(1);
        actBoss.setEndTime(endTime);
        actBoss.setBossBagNum(staticActBoss.getBagNumber());
        actBoss.setCallTimes(actBoss.getCallTimes() + 1);
        actBoss.setLordId(lordId);
        actBoss.getJoinLordIds().clear();

        // 名字随机
        int seeds[] = {0, 0};
        for (Integer weight : staticActBoss.getNameweights()) {
            seeds[0] += weight;
        }
        seeds[0] = RandomHelper.randomInSize(seeds[0]);
        int i = 0;
        for (Integer weight : staticActBoss.getNameweights()) {
            seeds[1] += weight;
            if (seeds[0] <= seeds[1]) {
                actBoss.setBossName(staticActBoss.getNameRandom().get(i));
                break;
            }
            i++;
        }
        // 随机外形
        seeds[0] = 0;
        seeds[1] = 0;
        for (List<Integer> pic : staticActBoss.getPictureRandom()) {
            seeds[0] += pic.get(0);
        }
        seeds[0] = RandomHelper.randomInSize(seeds[0]);
        for (List<Integer> pic : staticActBoss.getPictureRandom()) {
            seeds[1] += pic.get(0);
            if (seeds[0] <= seeds[1]) {
                actBoss.setBossIcon(pic.get(1));
                break;
            }
        }
    }

    /**
     * boss死亡
     *
     * @param actBoss
     * @param staticActBoss
     * @param isRun         void
     */
    private void actBossDie(ActBoss actBoss, StaticActBoss staticActBoss, boolean isRun) {
        actBoss.setState(0);

        if (!isRun) {
            String callLordName = "";
            Player callPlayer = playerDataManager.getPlayer(actBoss.getLordId());
            if (callPlayer != null) {
                callLordName = callPlayer.lord.getNick();
            }

            for (Long lordId : actBoss.getJoinLordIds()) {
                Player player = playerDataManager.getPlayer(lordId);
                if (player == null) {
                    continue;
                }
                // 参与奖励
                List<CommonPb.Award> awards = new ArrayList<CommonPb.Award>();
                for (List<Integer> item : staticActBoss.getJoinAward()) {
                    awards.add(PbHelper.createAwardPb(item.get(0), item.get(1), item.get(2)));
                }
                playerDataManager.sendAttachMail(AwardFrom.ATTACK_ACT_BOSS, player, awards, MailType.MOLD_ACT_BOSS_JOIN,
                        TimeHelper.getCurrentSecond(), callLordName + actBoss.getBossName());
            }
        }
    }

    /**
     * 打boss结束时的逻辑 由定时器调用 void
     */
    public void actBossLogic() {
        // boss剩余倒计时
        UsualActivityData activityData = activityDataManager.getUsualActivity(ActivityConst.ACT_BOSS);
        if (activityData == null) {
            return;
        }

        ActBoss actBoss = activityData.getActBoss();

        if (actBoss.getState() != 1) {
            return;
        }

        int now = TimeHelper.getCurrentSecond();
        if (actBoss.getEndTime() > now) {
            return;
        }

        String callLordName = "";
        Player callPlayer = playerDataManager.getPlayer(actBoss.getLordId());
        if (callPlayer != null) {
            callLordName = callPlayer.lord.getNick();
        }

        StaticActBoss staticActBoss = staticActivityDataMgr.getActBoss();
        actBossDie(actBoss, staticActBoss, true);
        chatService.sendHornChat(chatService.createSysChat(SysChatId.ACT_BOSS_RUN, callLordName + actBoss.getBossName()), 1);
    }

    /**
     * 获取新年狂欢祈福活动信息
     *
     * @param handler
     */
    public void getActHilarityPray(ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null || null == player.lord) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }
        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_HILARITY_PRAY_ID);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        Map<Integer, StaticActHilarityPray> map = staticActivityDataMgr.getActHilarityPrayMap();
        List<Long> statusList = activity.getStatusList();
        // 充值每日充值
        int nowDay = TimeHelper.getCurrentDay();
        if (activity.getEndTime() != nowDay) {
            statusList.set(0, 0L);
            activity.setEndTime(nowDay);
        }
        GetActHilarityPrayRs.Builder builder = GetActHilarityPrayRs.newBuilder();
        for (StaticActHilarityPray act : map.values()) {
            builder.addKeyId(act.getId());
            if (act.getType() == 1) { // 连续充值领挂件
                int count = 0;
                for (int i = 1; i < statusList.size(); i++) {
                    if (statusList.get(i) == 1L) {
                        count++;
                    }
                }
                builder.addValue(count);
                if (activity.getStatusMap().size() > 0) { // 已经领过
                    builder.addStatus(-1);
                } else {
                    if (count >= act.getValue()) {
                        builder.addStatus(1);
                    } else {
                        builder.addStatus(0);
                    }
                }
            } else if (act.getType() == 2) { // 每日首充领奖
                builder.addStatus(statusList.get(0).intValue());
                builder.addValue(0);
            } else if (act.getType() == 3) { // 充值额度兑换领奖
                Integer value = activity.getSaveMap().get(0);
                if (value == null) {
                    builder.addValue(0);
                    builder.addStatus(0);
                } else {
                    builder.addValue(value);
                    if (value >= ActivityConst.SCORE_FOR_HILARITY_PRAY) {
                        builder.addStatus(1);
                    } else {
                        builder.addStatus(0);
                    }
                }
            }
        }
        handler.sendMsgToPlayer(GetActHilarityPrayRs.ext, builder.build());
    }

    /**
     * 领取狂欢祈福奖励
     *
     * @param req
     * @param handler
     */
    public void receiveActHilarityPray(ReceiveActHilarityPrayRq req, ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null || null == player.lord) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }
        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_HILARITY_PRAY_ID);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        StaticActHilarityPray actHilarityPray = staticActivityDataMgr.getActHilarityPrayMap().get(req.getKeyId());
        if (actHilarityPray == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }
        ReceiveActHilarityPrayRs.Builder builder = ReceiveActHilarityPrayRs.newBuilder();
        builder.setKeyId(actHilarityPray.getId());
        List<Long> statusList = activity.getStatusList();
        if (actHilarityPray.getType() == 1) { // 连续充值领挂件
            int count = 0;
            for (int i = 1; i < statusList.size(); i++) {
                if (statusList.get(i) == 1L) {
                    count++;
                } else {
                    break;
                }
            }
            if (activity.getStatusMap().size() > 0) { // 已经领过
                handler.sendErrorMsgToPlayer(GameError.HAVE_RECEIVE);
                return;
            } else if (count < actHilarityPray.getValue()) { // 天数不足
                handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
                return;
            }
            activity.getStatusMap().put(0, 1); // 设置成已领取
            builder.setStatus(-1);
            builder.setValue(count);
        } else if (actHilarityPray.getType() == 2) { // 每日首充领奖
            if (statusList.get(0) != 1L) {
                handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
                return;
            }
            statusList.set(0, -1L);
            builder.setStatus(-1);
            builder.setValue(0);
        } else if (actHilarityPray.getType() == 3) { // 充值额度兑换领奖
            Integer value = activity.getSaveMap().get(0);
            if (value == null || value < ActivityConst.SCORE_FOR_HILARITY_PRAY) {
                handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
                return;
            }
            int has = value - ActivityConst.SCORE_FOR_HILARITY_PRAY;
            activity.getSaveMap().put(0, has);
            if (has >= ActivityConst.SCORE_FOR_HILARITY_PRAY) {
                builder.setStatus(1);
            } else {
                builder.setStatus(0);
            }
            builder.setValue(has);
        }

        for (List<Integer> award : actHilarityPray.getAwards()) {
            int keyId = playerDataManager.addAward(player, award.get(0), award.get(1), award.get(2), AwardFrom.ACT_HILARITY_PRAY);
            builder.addAwards(PbHelper.createAwardPb(award.get(0), award.get(1), award.get(2), keyId));
        }
        handler.sendMsgToPlayer(ReceiveActHilarityPrayRs.ext, builder.build());
    }

    /**
     * 获取新年狂欢祈福活动祈福信息
     *
     * @param handler
     */
    public void getActHilarityPrayAction(ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null || null == player.lord) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }
        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_HILARITY_PRAY_ID);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        GetActHilarityPrayActionRs.Builder builder = GetActHilarityPrayActionRs.newBuilder();
        for (Integer propId : activity.getPropMap().keySet()) {
            builder.addActProp(PbHelper.createAtom2Pb(AwardType.ACTIVITY_PROP, propId, activity.getPropMap().get(propId)));
        }
        for (Integer id : activity.getSaveMap().keySet()) {
            if (id > 0) {
                builder.addIndex(id);
                builder.addTime(activity.getSaveMap().get(id)); // 大于0记录 时间
                builder.addPropId(activity.getSaveMap().get(-id)); // 小于0记录 道具
            }
        }
        handler.sendMsgToPlayer(GetActHilarityPrayActionRs.ext, builder.build());
    }

    /**
     * 新年狂欢祈福活动祈福
     *
     * @param handler
     */
    public void doActHilarityPrayAction(DoActHilarityPrayActionRq req, ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null || null == player.lord) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }
        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_HILARITY_PRAY_ID);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        int index = req.getIndex();
        if (index > 6 || index < 1) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }
        if (activity.getSaveMap().containsKey(index)) { // 已祈福
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }
        int propId = req.getProp();
        StaticActivityProp prop = staticActivityDataMgr.getActivityPropById(propId);
        if (prop == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }
        if (prop.getActivityId() != ActivityConst.ACT_HILARITY_PRAY_ID) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }
        Integer propNum = activity.getPropMap().get(propId);
        if (propNum == null || propNum <= 0) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }
        int time = TimeHelper.getCurrentSecond();
        activity.getPropMap().put(propId, propNum - 1); // 扣除道具个数
        activity.getSaveMap().put(index, time); // 记录祈福时间
        activity.getSaveMap().put(-index, propId); // 记录祈福道具
        DoActHilarityPrayActionRs.Builder builder = DoActHilarityPrayActionRs.newBuilder();
        for (Integer id : activity.getPropMap().keySet()) {
            builder.addActProp(PbHelper.createAtom2Pb(AwardType.ACTIVITY_PROP, id, activity.getPropMap().get(id)));
        }
        builder.setIndex(index);
        builder.setTime(time);
        builder.setPropId(propId);
        handler.sendMsgToPlayer(DoActHilarityPrayActionRs.ext, builder.build());
    }

    /**
     * 领取祈福奖励
     *
     * @param handler
     */
    public void receiveActHilarityPrayAction(ReceiveActHilarityPrayActionRq req, ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null || null == player.lord) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }
        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_HILARITY_PRAY_ID);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        int index = req.getIndex();
        if (index > 6 || index < 1) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }
        if (!activity.getSaveMap().containsKey(index)) { // 未祈福
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }
        int time = activity.getSaveMap().get(index);
        StaticActivityProp prop = staticActivityDataMgr.getActivityPropById(activity.getSaveMap().get(-index));
        if (TimeHelper.getCurrentSecond() < time + prop.getValue() * 60) {
            handler.sendErrorMsgToPlayer(GameError.ARENA_CD);
            return;
        }
        activity.getSaveMap().remove(index);
        activity.getSaveMap().remove(-index);
        ReceiveActHilarityPrayActionRs.Builder builder = ReceiveActHilarityPrayActionRs.newBuilder();
        List<Integer> award = new ArrayList<>();
        int random = 0;
        for (List<Integer> list : prop.getAwards()) {
            random += list.get(3);
        }
        random = RandomHelper.randomInSize(random);
        int total = 0;
        for (List<Integer> list : prop.getAwards()) {
            if (list.size() < 4) {
                continue;
            }
            total += list.get(3);
            if (random <= total) {
                award = list;
                break;
            }
        }
        List<CommonPb.Award> awardPbList = new ArrayList<>();
        int keyId = playerDataManager.addAward(player, award.get(0), award.get(1), award.get(2), AwardFrom.ACT_HILARITY_PRAY);
        awardPbList.add(PbHelper.createAwardPb(award.get(0), award.get(1), award.get(2), keyId));
        builder.addAwards(PbHelper.createAwardPb(award.get(0), award.get(1), award.get(2), keyId));
        builder.setIndex(index);
        handler.sendMsgToPlayer(ReceiveActHilarityPrayActionRs.ext, builder.build());

        // 发送加入活动消息
        propService.sendJoinActivityMsg(ActivityConst.ACT_HILARITY_PRAY_ID, player, awardPbList);
    }

    /**
     * 新年狂欢祈福活动祈福加速
     *
     * @param handler
     */
    public void speedActHilarityPrayAction(SpeedActHilarityPrayActionRq req, ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null || null == player.lord) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }
        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_HILARITY_PRAY_ID);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        int index = req.getIndex();
        if (index > 6 || index < 1) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }
        if (!activity.getSaveMap().containsKey(index)) { // 未祈福
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }
        int time = activity.getSaveMap().get(index);
        StaticActivityProp prop = staticActivityDataMgr.getActivityPropById(activity.getSaveMap().get(-index));
        double hasTime = time + prop.getValue() * 60 - TimeHelper.getCurrentSecond();
        if (hasTime <= 0) { // 已经是可以领取状态
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }
        int cost = (int) Math.ceil(hasTime / 60);
        if (player.lord.getGold() < cost) {
            handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
            return;
        }
        // 扣除金币消耗
        playerDataManager.subGold(player, cost, AwardFrom.ACT_HILARITY_PRAY);
        // 重设时间
        activity.getSaveMap().put(index, 1);
        SpeedActHilarityPrayActionRs.Builder builder = SpeedActHilarityPrayActionRs.newBuilder();
        builder.setIndex(index);
        builder.setTime(1);
        builder.setGold(player.lord.getGold());
        handler.sendMsgToPlayer(SpeedActHilarityPrayActionRs.ext, builder.build());
    }

    /**
     * 请求清盘计划界面
     *
     * @param handler
     */
    public void getActOverRebate(ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null || null == player.lord) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_OVER_REBATE_ID);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_OVER_REBATE_ID);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        int activityKeyId = activityBase.getKeyId();
        List<StaticActGamble> gambleList = staticActivityDataMgr.getActGambleList(activityKeyId);
        if (gambleList == null || gambleList.size() == 0) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }
        StaticActGamble actGamble = gambleList.get(0);
        List<Long> statusList = activity.getStatusList();
        List<List<Integer>> awardList = actGamble.getAwardList();

        GetOverRebateActRs.Builder builder = GetOverRebateActRs.newBuilder();
        builder.setGambleId(actGamble.getGambleId());
        builder.setPayNum((int) (statusList.get(0) == null ? 0 : statusList.get(0)));
        for (int i = 0; i < awardList.size(); i++) {
            if (statusList.get(i + 1) == 1) {
                builder.addHasIndex(i + 1);
            }
        }
        handler.sendMsgToPlayer(GetOverRebateActRs.ext, builder.build());
    }

    /**
     * 请求清盘计划抽奖
     *
     * @param handler
     */
    public void doActOverRebate(ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null || null == player.lord) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_OVER_REBATE_ID);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_OVER_REBATE_ID);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        int activityKeyId = activityBase.getKeyId();
        List<StaticActGamble> gambleList = staticActivityDataMgr.getActGambleList(activityKeyId);
        if (gambleList == null || gambleList.size() == 0) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }

        StaticActGamble actGamble = gambleList.get(0);
        List<List<Integer>> awardList = actGamble.getAwardList();
        List<Long> statusList = activity.getStatusList();
        Long payNum = statusList.get(0);
        int hasNum = 0;
        for (int i = 0; i < awardList.size(); i++) {
            if (statusList.get(i + 1) == 1) {
                hasNum++;
            }
        }
        if (payNum == null || (payNum / actGamble.getTopup()) <= hasNum) {
            handler.sendErrorMsgToPlayer(GameError.COUNT_NOT_ENOUGH);
            return;
        }
        List<CommonPb.Award> awardPbList = new ArrayList<>();

        int random = 0, total = 0, randomId = 0;
        for (int i = 0; i < awardList.size(); i++) {
            if (statusList.get(i + 1) != 1) {
                random += actGamble.getAwardList().get(i).get(3);
            }
        }
        random = RandomHelper.randomInSize(random);
        for (int i = 0; i < awardList.size(); i++) {
            if (statusList.get(i + 1) != 1) {
                total += actGamble.getAwardList().get(i).get(3);
                if (random <= total) {
                    randomId = i;
                    break;
                }
            }
        }
        statusList.set(randomId + 1, 1L); // 记录抽中的次数
        List<Integer> award = awardList.get(randomId);
        int keyId = playerDataManager.addAward(player, award.get(0), award.get(1), award.get(2), AwardFrom.ACT_OVER_REBATE_AWARD);
        awardPbList.add(PbHelper.createAwardPb(award.get(0), award.get(1), award.get(2), keyId));
        DoOverRebateActRs.Builder builder = DoOverRebateActRs.newBuilder();
        builder.setIndex(randomId + 1);
        builder.addAwards(PbHelper.createAwardPb(award.get(0), award.get(1), award.get(2), keyId));
        handler.sendMsgToPlayer(DoOverRebateActRs.ext, builder.build());
        // 发送加入活动消息
        propService.sendJoinActivityMsg(ActivityConst.ACT_OVER_REBATE_ID, player, awardPbList);
    }

    /**
     * 请求拜神界面信息
     *
     * @param handler
     */
    public void getActWorshipGod(ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null || null == player.lord) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }
        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_WORSHIP_ID);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_WORSHIP_ID);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        Date beginTime = activityBase.getBeginTime();
        int dayiy = DateHelper.dayiy(beginTime, new Date()); // 活动第几天
        Map<Integer, Integer> statusMap = activity.getStatusMap();
        Map<Integer, Integer> saveMap = activity.getSaveMap();
        for (int i = 1; i <= dayiy; i++) {
            if (saveMap.get(0) == null) {
                saveMap.put(0, 0);
            }
            if (statusMap.get(i) == null) {
                StaticActWorshipGod data = staticActivityDataMgr.getActWorshipGod(i);
                saveMap.put(0, saveMap.get(0) + (data != null ? data.getNum() : 0));
                statusMap.put(i, 1);
            }
        }
        GetWorshipGodActRs.Builder builder = GetWorshipGodActRs.newBuilder();
        builder.setCount(saveMap.get(0));
        for (Integer time : saveMap.keySet()) {
            if (time != 0 && time != 1) {
                builder.addRecord(PbHelper.createTwoIntPb(time, saveMap.get(time)));
            }
        }

        handler.sendMsgToPlayer(GetWorshipGodActRs.ext, builder.build());
    }

    /**
     * 拜神
     *
     * @param handler
     */
    public void doActWorshipGod(ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null || null == player.lord) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }
        if (player.lord.getVip() < 5) {
            handler.sendErrorMsgToPlayer(GameError.VIP_NOT_ENOUGH);
            return;
        }
        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_WORSHIP_ID);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_WORSHIP_ID);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        Map<Integer, Integer> saveMap = activity.getSaveMap();
        if (saveMap.get(0) == null || saveMap.get(0) <= 0) {
            handler.sendErrorMsgToPlayer(GameError.COUNT_NOT_ENOUGH);
            return;
        }

        int count = 0;
        for (Integer time : saveMap.keySet()) {
            if (time != 0 && time != 1) {
                count++;
            }
        }
        StaticActWorshipGodData godData = staticActivityDataMgr.getActWorshipGodData(count + 1);
        if (godData == null) {
            handler.sendErrorMsgToPlayer(GameError.COUNT_NOT_ENOUGH);
            return;
        }
        if (player.lord.getGold() < godData.getPrice()) {
            handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
            return;
        }
        int random = 0, total = 0;
        for (List<Integer> list : godData.getRebate()) {
            random += list.get(1);
        }
        random = RandomHelper.randomInSize(random);
        for (List<Integer> list : godData.getRebate()) {
            total += list.get(1);
            if (random <= total) {
                random = list.get(0);
                break;
            }
        }
        playerDataManager.subGold(player, godData.getPrice(), AwardFrom.ACT_WORSHIP_GOD);
        saveMap.put(0, saveMap.get(0) - 1); // 消耗次数
        int time = TimeHelper.getCurrentSecond();
        saveMap.put(time, random); // 记录抽奖信息
        playerDataManager.addGold(player, godData.getPrice() * random / 100, AwardFrom.ACT_WORSHIP_GOD_ADD);
        DoWorshipGodActRs.Builder builder = DoWorshipGodActRs.newBuilder();
        builder.setTime(time);
        builder.setProportion(random);
        handler.sendMsgToPlayer(DoWorshipGodActRs.ext, builder.build());
    }

    /**
     * 请求许愿界面信息
     *
     * @param handler
     */
    public void getActWorshipTask(ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null || null == player.lord) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }
        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_WORSHIP_ID);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_WORSHIP_ID);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        int activityKeyId = activityBase.getKeyId();
        Date beginTime = activityBase.getBeginTime();
        int dayiy = DateHelper.dayiy(beginTime, new Date()); // 活动第几天
        StaticActWorshipTask worshipTask = staticActivityDataMgr.getActWorshipTask(activityKeyId, dayiy);
        GetWorshipTaskActRs.Builder builder = GetWorshipTaskActRs.newBuilder();
        builder.setAwardId(activityKeyId);
        builder.setCount(activity.getSaveMap().get(1) == null ? 0 : activity.getSaveMap().get(1));
        for (int i = 1; i <= worshipTask.getTask().size(); i++) {
            Long num = activity.getStatusList().get(i);
            builder.addTaskNum(PbHelper.createTwoIntPb(i, num == null ? 0 : (int) num.longValue()));
        }
        handler.sendMsgToPlayer(GetWorshipTaskActRs.ext, builder.build());
    }

    /**
     * 许愿
     *
     * @param handler
     */
    public void doActWorshipTask(ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null || null == player.lord) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }
        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_WORSHIP_ID);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        Map<Integer, Integer> saveMap = activity.getSaveMap();
        if (saveMap.get(1) == null || saveMap.get(1) <= 0) {
            handler.sendErrorMsgToPlayer(GameError.COUNT_NOT_ENOUGH);
            return;
        }
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_WORSHIP_ID);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        int activityKeyId = activityBase.getKeyId();
        Date beginTime = activityBase.getBeginTime();
        int dayiy = DateHelper.dayiy(beginTime, new Date()); // 活动第几天
        StaticActWorshipTask worshipTask = staticActivityDataMgr.getActWorshipTask(activityKeyId, dayiy);
        saveMap.put(1, saveMap.get(1) - 1); // 消耗次数
        List<List<Integer>> awardList = worshipTask.getAwards();
        List<CommonPb.Award> awardPbList = new ArrayList<>();
        List<Integer> award = new ArrayList<Integer>();
        int random = 0, total = 0;
        for (int i = 0; i < awardList.size(); i++) {
            random += awardList.get(i).get(3);
        }
        random = RandomHelper.randomInSize(random);
        for (int i = 0; i < awardList.size(); i++) {
            total += awardList.get(i).get(3);
            if (random <= total) {
                award = awardList.get(i);
                break;
            }
        }
        int keyId = playerDataManager.addAward(player, award.get(0), award.get(1), award.get(2), AwardFrom.ACT_OVER_REBATE_AWARD);
        awardPbList.add(PbHelper.createAwardPb(award.get(0), award.get(1), award.get(2), keyId));
        DoWorshipTaskActRs.Builder builder = DoWorshipTaskActRs.newBuilder();
        builder.addAward(PbHelper.createAwardPb(award.get(0), award.get(1), award.get(2), keyId));
        handler.sendMsgToPlayer(DoWorshipTaskActRs.ext, builder.build());
        propService.sendJoinActivityMsg(ActivityConst.ACT_WORSHIP_ID, player, awardPbList);
    }

    /**
     * 叛军活动时钟
     */
    public void actRebelLogic() {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_REBEL);
        if (activityBase == null) {
            return;
        }

        ActRebel actRebel = activityDataManager.getActRebel();
        if (actRebel == null) {
            return;
        }

        int step = activityBase.getStep();
        if (step != ActivityConst.OPEN_STEP) {
            if (actRebel.getRebel().size() > 0) {
                activityDataManager.actRebelEnd();
                actRebel.getRebel().clear();
                LogUtil.common("活动叛军活动结束");
            }
            return;
        }

        Calendar c = Calendar.getInstance();
        StaticActRebel staticActRebel = staticActivityDataMgr.getActRebel();

        Integer curHour = c.get(Calendar.HOUR_OF_DAY);
        if (!staticActRebel.getHour().contains(curHour)) {
            return;
        }

        Integer curMinute = c.get(Calendar.MINUTE);
        if (!staticActRebel.getMinute().contains(curMinute)) {
            return;
        }

        int second = TimeHelper.getSecond(curHour, curMinute, 0);
        if (second == actRebel.getLastSecond()) {
            return;// 已经刷新一波
        }
        int count = activityDataManager.refreshActRebel(actRebel, staticActRebel);
        if (count > 0) {
            LogUtil.common("活动叛军刷新成功:" + second + ",当前刷新人数：" + count);
            actRebel.setLastSecond(second);
        }
    }

    /**
     * 侦查时提前发送判断
     */
    public void actRebelIsDead(int pos, ClientHandler handler) {
        ActRebelIsDeadRs.Builder builder = ActRebelIsDeadRs.newBuilder();
        builder.setPos(pos);

        ActRebelData rebel = activityDataManager.getActRebelByPos(pos);
        if (null == rebel) {
            builder.setIsDead(true);
        } else {
            builder.setIsDead(false);
        }
        handler.sendMsgToPlayer(ActRebelIsDeadRs.ext, builder.build());
    }

    /**
     * 获取活动叛军入侵活动的排行榜数据
     *
     * @param page 分页，每一页显示20个，第一页page=0，第二页page=1
     */
    public void getActRebelRank(int page, ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_REBEL);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_REBEL);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        ActRebel actRebel = activityDataManager.getActRebel();
        if (actRebel == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        List<Long> statusList = activity.getStatusList();
        Long killNum = statusList.get(ActRebelConst.INDEX_KILL);
        Long score = statusList.get(ActRebelConst.INDEX_SCORE);

        int rank = activityDataManager.getActRebelRank(actRebel, player.roleId);

        GetActRebelRankRs.Builder builder = GetActRebelRankRs.newBuilder();
        builder.setKillNum(killNum.intValue());
        builder.setScore(score.intValue());
        builder.setRank(rank);

        int step = activityBase.getStep();
        if (step != ActivityConst.OPEN_STEP) {
            List<StaticActRank> listRank = staticActivityDataMgr.getActRankList(ActivityConst.ACT_REBEL, ActivityConst.TYPE_DEFAULT);
            if (listRank != null && listRank.size() > 0) {
                if (rank >= listRank.get(0).getRankBegin() && rank <= listRank.get(listRank.size() - 1).getRankEnd()) {
                    builder.setGetReward(activity.getStatusMap().containsKey(ActivityConst.TYPE_DEFAULT));
                }
            }
        }

        LinkedList<ActRebelRank> rankList = actRebel.getRebelRank();

        ActRebelRank data = null;
        int startIndex = page * 20;
        int endIndex = startIndex + 20;
        for (int i = startIndex; i < endIndex; i++) {
            if (i < rankList.size()) {
                data = rankList.get(i);
                Player dataPlayer = playerDataManager.getPlayer(data.getLordId());
                if (dataPlayer != null) {
                    builder.addRebelRanks(PbHelper.createActRebelRankPb(i + 1, data.getLordId(), dataPlayer.lord.getNick(),
                            data.getKillNum(), data.getScore()));
                }
            }
        }
        handler.sendMsgToPlayer(GetActRebelRankRs.ext, builder.build());
    }

    /**
     * 领取活动叛军入侵活动的排行奖励
     */
    public void actRebelRankReward(ClientHandler handler) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_REBEL);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        ActRebel actRebel = activityDataManager.getActRebel();
        if (actRebel == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        int step = activityBase.getStep();
        if (step != ActivityConst.OPEN_AWARD) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_FINISH);
            return;
        }

        Player player = playerDataManager.getPlayer(handler.getRoleId());

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_REBEL);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        ActRebelRankRewardRs.Builder builder = ActRebelRankRewardRs.newBuilder();
        int rank = activityDataManager.getActRebelRank(actRebel, player.roleId);
        if (rank == 0) {
            handler.sendErrorMsgToPlayer(GameError.NOT_ON_RANK);
            return;
        }

        if (activity.getStatusMap().containsKey(ActivityConst.TYPE_DEFAULT)) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_GOT);
            return;
        }

        List<StaticActRank> listRank = staticActivityDataMgr.getActRankList(ActivityConst.ACT_REBEL, ActivityConst.TYPE_DEFAULT);
        if (listRank != null && listRank.size() > 0) {
            for (StaticActRank sActRank : listRank) {
                if (rank <= sActRank.getRankBegin() || rank <= sActRank.getRankEnd()) {
                    for (List<Integer> award : sActRank.getAwardList()) {
                        int keyId = playerDataManager.addAward(player, award.get(0), award.get(1), award.get(2),
                                AwardFrom.ACT_REBEL_RANK_REWARD);
                        builder.addAward(PbHelper.createAwardPb(award.get(0), award.get(1), award.get(2), keyId));
                    }
                    activity.getStatusMap().put(ActivityConst.TYPE_DEFAULT, 0);
                    break;
                }
            }
        }

        handler.sendMsgToPlayer(ActRebelRankRewardRs.ext, builder.build());
    }

    /**
     * 西点学院主界面数据
     */
    public void getActCollege(ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null || null == player.lord) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }
        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_COLLEGE);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        refreshActCollegeFreeBook(activity);
        List<Long> statusList = activity.getStatusList();

        GetActCollegeRs.Builder builder = GetActCollegeRs.newBuilder();

        builder.setId(statusList.get(ActCollegeConst.INDEX_SUBJECT).intValue());// 当前学科id
        builder.setPoint(statusList.get(ActCollegeConst.INDEX_POINT).intValue());// 当前学科点数
        builder.setTotalPoint(statusList.get(ActCollegeConst.INDEX_TOTAL_POINT).intValue());// 累计学科点数
        for (Integer id : activity.getPropMap().keySet()) {// 当前书数
            builder.setActProp(PbHelper.createAtom2Pb(AwardType.ACTIVITY_PROP, id, activity.getPropMap().get(id)));
        }
        builder.setFreeTime(statusList.get(ActCollegeConst.INDEX_FREE_TIME).intValue());// 下次免费赠送结束时间
        builder.setBuyPropNum(statusList.get(ActCollegeConst.INDEX_BUY_PROP_NUM).intValue());

        handler.sendMsgToPlayer(GetActCollegeRs.ext, builder.build());
    }

    /**
     * 初始化西点学院免费书
     *
     * @param activity void
     */
    private void refreshActCollegeFreeBook(Activity activity) {
        List<Long> statusList = activity.getStatusList();
        int subject = statusList.get(ActCollegeConst.INDEX_SUBJECT).intValue();
        if (subject == 0) {// 活动初始化
            statusList.set(ActCollegeConst.INDEX_SUBJECT, ActCollegeConst.INIT_SUBJECT);
            activity.getPropMap().put(ActPropIdConst.ID_COLLEGE_BOOK, ActCollegeConst.INIT_BOOK_COUNT);
        }
        // 免费书获取
        int oldFreeTime = statusList.get(ActCollegeConst.INDEX_FREE_TIME).intValue();
        if (oldFreeTime != 0) {
            // 赠送
            int addBookCount = (int) ((TimeHelper.getCurrentSecond() - oldFreeTime) / ActCollegeConst.FREE_BOOK_SECOND);
            if (addBookCount > 0) {
                int curBookCount = activity.getPropMap().get(ActPropIdConst.ID_COLLEGE_BOOK);
                if (curBookCount + addBookCount > ActCollegeConst.INIT_BOOK_COUNT) {
                    activity.getPropMap().put(ActPropIdConst.ID_COLLEGE_BOOK, ActCollegeConst.INIT_BOOK_COUNT);
                } else {
                    activity.getPropMap().put(ActPropIdConst.ID_COLLEGE_BOOK, curBookCount + addBookCount);
                }
                statusList.set(ActCollegeConst.INDEX_FREE_TIME, oldFreeTime + ActCollegeConst.FREE_BOOK_SECOND * addBookCount);

                curBookCount = activity.getPropMap().get(ActPropIdConst.ID_COLLEGE_BOOK);
                if (curBookCount >= ActCollegeConst.INIT_BOOK_COUNT) {
                    statusList.set(ActCollegeConst.INDEX_FREE_TIME, 0L);
                }
            }
        }
    }

    /**
     * 购买活动道具id
     */
    public void buyActProp(BuyActPropRq req, ClientHandler handler) {
        int id = req.getId();
        int count = req.getCount();
        if (count < 1 || count > 1000) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }

        StaticActivityProp sap = staticActivityDataMgr.getActivityPropById(id);
        if (sap == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }

        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null || null == player.lord) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }
        Activity activity = activityDataManager.getActivityInfo(player, sap.getActivityId());
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        if (sap.getCanbuy() != 1) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }

        BuyActPropRs.Builder builder = BuyActPropRs.newBuilder();

        // 西典军校
        if (sap.getActivityId() == ActivityConst.ACT_COLLEGE) {
            refreshActCollegeFreeBook(activity);

            List<Long> statusList = activity.getStatusList();
            int buyNum = statusList.get(ActCollegeConst.INDEX_BUY_PROP_NUM).intValue();
            int costGold = staticActivityDataMgr.getActCollegePropGold(sap, buyNum, count);
            if (costGold <= 0) {
                handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
                return;
            }

            if (!playerDataManager.checkPropIsEnougth(player, AwardType.GOLD, 0, costGold)) {
                handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
                return;
            }

            playerDataManager.addActivityProp(player, id, count, AwardFrom.BUY_ACT_PROP);

            for (Integer propId : activity.getPropMap().keySet()) {// 当前书数
                builder.addAtom2(PbHelper.createAtom2Pb(AwardType.ACTIVITY_PROP, propId, activity.getPropMap().get(id)));
            }

            int bookCount = activity.getPropMap().get(ActPropIdConst.ID_COLLEGE_BOOK);
            if (bookCount >= ActCollegeConst.INIT_BOOK_COUNT) {
                statusList.set(ActCollegeConst.INDEX_FREE_TIME, 0L);
            }
            statusList.set(ActCollegeConst.INDEX_BUY_PROP_NUM, (long) (buyNum + count));

            playerDataManager.subGold(player, costGold, AwardFrom.BUY_ACT_PROP);

            builder.addAtom2(PbHelper.createAtom2Pb(AwardType.GOLD, 0, player.lord.getGold()));
            builder.setFreeTime(statusList.get(ActCollegeConst.INDEX_FREE_TIME).intValue());// 下次免费赠送结束时间
            builder.setBuyPropNum(statusList.get(ActCollegeConst.INDEX_BUY_PROP_NUM).intValue());

            // 坦克转换活动
        } else if (sap.getActivityId() == ActivityConst.ACT_TANK_CONVERT) {
            if (!playerDataManager.checkPropIsEnougth(player, AwardType.GOLD, 0, sap.getPrice())) {
                handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
                return;
            }
            playerDataManager.addActivityProp(player, id, count, AwardFrom.TANK_CONVERT);
            playerDataManager.subGold(player, sap.getPrice() * count, AwardFrom.BUY_ACT_PROP);
            builder.addAtom2(PbHelper.createAtom2Pb(AwardType.GOLD, 0, player.lord.getGold()));

            builder.setBuyPropNum(player.activitys.get(ActivityConst.ACT_TANK_CONVERT).getPropMap().get(id));
        } else {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }

        handler.sendMsgToPlayer(BuyActPropRs.ext, builder.build());
    }

    /**
     * 西点学院进修
     */
    public void doActCollege(DoActCollegeRq req, ClientHandler handler) {
        int times = req.getTimes();
        boolean useGold = req.getUseGold();
        if (times < 1 || times > 100) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null || null == player.lord) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }
        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_COLLEGE);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        refreshActCollegeFreeBook(activity);

        List<Long> statusList = activity.getStatusList();
        int subject = statusList.get(ActCollegeConst.INDEX_SUBJECT).intValue();
        // int point = statusList.get(ActCollegeConst.INDEX_POINT).intValue();
        int totalPoint = statusList.get(ActCollegeConst.INDEX_TOTAL_POINT).intValue();

        StaticActCollegeSubject curSubject = staticActivityDataMgr.getActCollegeSubject(subject);
        if (curSubject == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }
        int buyNum = statusList.get(ActCollegeConst.INDEX_BUY_PROP_NUM).intValue();
        List<Integer> cost = new ArrayList<Integer>();
        if (useGold) {
            StaticActivityProp sap = staticActivityDataMgr.getActivityPropById(ActPropIdConst.ID_COLLEGE_BOOK);
            if (sap == null) {
                handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
                return;
            }
            int costGold = staticActivityDataMgr.getActCollegePropGold(sap, buyNum, times);
            if (costGold <= 0) {
                handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
                return;
            }
            cost.add(AwardType.GOLD);
            cost.add(0);
            cost.add(costGold);
            if (!playerDataManager.checkPropIsEnougth(player, cost.get(0), cost.get(1), cost.get(2))) {
                handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
                return;
            }
        } else {
            cost.addAll(curSubject.getNeedbook());
            if (!playerDataManager.checkPropIsEnougth(player, cost.get(0), cost.get(1), cost.get(2) * times)) {
                handler.sendErrorMsgToPlayer(GameError.PROP_NOT_ENOUGH);
                return;
            }
        }

        int oldBookCount = activity.getPropMap().get(ActPropIdConst.ID_COLLEGE_BOOK);

        String costLog;

        if (useGold) {
            playerDataManager.subProp(player, cost.get(0), cost.get(1), cost.get(2), AwardFrom.DO_ACT_COLLEGE);
            costLog = "[" + cost.get(0) + "," + cost.get(1) + "," + cost.get(2) + "]";
        } else {
            playerDataManager.subProp(player, cost.get(0), cost.get(1), cost.get(2) * times, AwardFrom.DO_ACT_COLLEGE);
            costLog = "[" + cost.get(0) + "," + cost.get(1) + "," + cost.get(2) * times + "]";
        }
        statusList.set(ActCollegeConst.INDEX_BUY_PROP_NUM, (long) (buyNum + times));

        Map<Integer, Map<Integer, Integer>> awardsMap = new HashMap<>();

        for (int i = 0; i < times; i++) {
            StaticActCollegeEducation curEducation = staticActivityDataMgr.getActCollegeEducation(totalPoint + (i + 1));
            if (curEducation == null) {
                LogUtil.error("西点学院累计学分表未配置：" + totalPoint + (i + 1));
                continue;
            }
            // 固定奖励--如果配置奖励活动道具有问题-客户端会多显示一倍奖励
            for (List<Integer> award : curEducation.getFixedbonus()) {
                staticActivityDataMgr.addMapNum(awardsMap, award.get(0), award.get(1), award.get(2));
                playerDataManager.addAward(player, award.get(0), award.get(1), award.get(2), AwardFrom.DO_ACT_COLLEGE);
            }

            // 额外随机奖励--如果配置奖励活动道具有问题-客户端会多显示一倍奖励
            if (RandomHelper.isHitRangeIn10000(curEducation.getRandomrate())) {
                List<Integer> award = ListHelper.getRandomAward(curEducation.getRandombonus());
                staticActivityDataMgr.addMapNum(awardsMap, award.get(0), award.get(1), award.get(2));
                playerDataManager.addAward(player, award.get(0), award.get(1), award.get(2), AwardFrom.DO_ACT_COLLEGE);
            }
        }

        // 学科点增长
        List<StaticActCollegeSubject> endSubjects = staticActivityDataMgr.addActCollegePoint(curSubject, statusList, times);

        // 学业结业奖励
        for (StaticActCollegeSubject s : endSubjects) {
            for (List<Integer> award : s.getAwards()) {
                playerDataManager.addAward(player, award.get(0), award.get(1), award.get(2), AwardFrom.DO_ACT_COLLEGE);
            }
        }
        // 累计学业点奖励
        List<List<Integer>> pointAward = staticActivityDataMgr.getActCollegeEducation(totalPoint,
                statusList.get(ActCollegeConst.INDEX_TOTAL_POINT).intValue());
        for (List<Integer> award : pointAward) {
            playerDataManager.addAward(player, award.get(0), award.get(1), award.get(2), AwardFrom.DO_ACT_COLLEGE);
        }

        // 免费赠送时间更新
        int bookCount = activity.getPropMap().get(ActPropIdConst.ID_COLLEGE_BOOK);
        if (bookCount >= ActCollegeConst.INIT_BOOK_COUNT) {
            statusList.set(ActCollegeConst.INDEX_FREE_TIME, 0l);
        } else {
            if (oldBookCount >= ActCollegeConst.INIT_BOOK_COUNT && bookCount < ActCollegeConst.INIT_BOOK_COUNT) {
                statusList.set(ActCollegeConst.INDEX_FREE_TIME, (long) TimeHelper.getCurrentSecond());
            }
        }

        DoActCollegeRs.Builder builder = DoActCollegeRs.newBuilder();
        builder.setId(statusList.get(ActCollegeConst.INDEX_SUBJECT).intValue());// 当前学科id
        builder.setPoint(statusList.get(ActCollegeConst.INDEX_POINT).intValue());// 当前学科点数
        builder.setTotalPoint(statusList.get(ActCollegeConst.INDEX_TOTAL_POINT).intValue());// 累计学科点数
        for (Integer id : activity.getPropMap().keySet()) {// 当前书数
            builder.setActProp(PbHelper.createAtom2Pb(AwardType.ACTIVITY_PROP, id, activity.getPropMap().get(id)));
        }
        builder.setFreeTime(statusList.get(ActCollegeConst.INDEX_FREE_TIME).intValue());// 下次免费赠送结束时间
        // 返回增加奖励信息
        StringBuilder awardLog = new StringBuilder();// 记录奖励日志
        for (Entry<Integer, Map<Integer, Integer>> entry : awardsMap.entrySet()) {
            int type = entry.getKey();
            Map<Integer, Integer> entryMap = entry.getValue();
            for (Entry<Integer, Integer> entry1 : entryMap.entrySet()) {
                CommonPb.Award.Builder award = CommonPb.Award.newBuilder();
                award.setType(type);
                award.setId(entry1.getKey());
                award.setCount(entry1.getValue());
                builder.addAward(award);

                // 记录奖励日志
                awardLog.append("[" + type + "," + entry1.getKey() + "," + entry1.getValue() + "],");
            }
        }
        if (awardLog.length() > 0)
            awardLog.setLength(awardLog.length() - 1);

        handler.sendMsgToPlayer(DoActCollegeRs.ext, builder.build());

        // 格式[当前学科,当前学科点数,累计学科点数]
        String subjectLog = "[" + statusList.get(ActCollegeConst.INDEX_SUBJECT).intValue() + ","
                + statusList.get(ActCollegeConst.INDEX_POINT).intValue() + ","
                + statusList.get(ActCollegeConst.INDEX_TOTAL_POINT).intValue() + "]";

        // 进修后的总学科点数
        int newTotalPoint = statusList.get(ActCollegeConst.INDEX_TOTAL_POINT).intValue();
        // 增加的学科点数
        int increase = newTotalPoint - totalPoint;
        // 记录进修日志
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_COLLEGE);
        LogLordHelper.actCollege(player, activityBase.getPlan().getAwardId(), newTotalPoint, increase, subjectLog, costLog,
                "[" + awardLog + "]");
    }

    /**
     * 部件淬炼大师活动
     *
     * @param handler
     */
    public void getSmeltPartMasterActivity(ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }
        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_PART_SMELT_MASTER);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        UsualActivityData usualActivity = activityDataManager.getUsualActivity(ActivityConst.ACT_PART_SMELT_MASTER);
        if (usualActivity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        GetActSmeltPartMasterRs.Builder builder = GetActSmeltPartMasterRs.newBuilder();
        if (!activity.getPropMap().isEmpty()) {
            for (Entry<Integer, Integer> entry : activity.getPropMap().entrySet()) {
                builder.addProps(PbHelper.createAtom2Pb(AwardType.ACTIVITY_PROP, entry.getKey(), entry.getValue()));
            }
        }

        if (!usualActivity.getBroadcast().isEmpty()) {
            for (String[] msg : usualActivity.getBroadcast()) {
                builder.addBroadcast(PbHelper.createBroadcast(msg));
            }
        }

        builder.setPoint(activity.getStatusList().get(0).intValue());
        handler.sendMsgToPlayer(GetActSmeltPartMasterRs.ext, builder.build());
    }

    /**
     * 淬炼大师活动排行榜
     *
     * @param handler
     */
    public void getPartSmeltMasterRank(ClientHandler handler) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_PART_SMELT_MASTER);
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

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_PART_SMELT_MASTER);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        UsualActivityData usualActivity = activityDataManager.getUsualActivity(ActivityConst.ACT_PART_SMELT_MASTER);
        if (usualActivity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        GetActSmeltPartMasterRankRs.Builder builder = GetActSmeltPartMasterRankRs.newBuilder();
        builder.setScore(activity.getStatusList().get(0).intValue());
        builder.setStatus(0);
        if (step == ActivityConst.OPEN_STEP) {
            builder.setOpen(false);
        } else if (step == ActivityConst.OPEN_AWARD) {
            builder.setOpen(true);
            Map<Integer, Integer> statusMap = activity.getStatusMap();
            if (statusMap.containsKey(ActivityConst.TYPE_DEFAULT)) {
                builder.setStatus(1);
            }
        }

        // 排名信息
        LinkedList<ActPlayerRank> rankList = usualActivity.getPlayerRanks(ActivityConst.TYPE_DEFAULT);
        // 去重
        if (!CheckNull.isEmpty(rankList)) {
            Set<Long> lordIdSet = new HashSet<>();
            Iterator<ActPlayerRank> its = rankList.iterator();
            while (its.hasNext()) {
                ActPlayerRank rk = its.next();
                if (lordIdSet.contains(rk.getLordId())) {
                    its.remove();
                    continue;
                }
                lordIdSet.add(rk.getLordId());
            }
            lordIdSet.clear();
        }

        for (int i = 0; i < rankList.size() && i < ActivityConst.RANK_PART_SMELT_MASTER; i++) {
            ActPlayerRank e = rankList.get(i);
            long lordId = e.getLordId();
            Player rankPlayer = playerDataManager.getPlayer(lordId);
            if (rankPlayer != null && rankPlayer.lord != null) {
                builder.addActPlayerRank(PbHelper.createActPlayerRank(e, rankPlayer.lord.getNick()));
            }
        }

        // LogUtil.error("pary smalt master rank list : "+Arrays.toString(rankList.toArray()));

        // 排名奖励
        List<StaticActRank> staticActRankList = staticActivityDataMgr.getActRankList(activityKeyId, ActivityConst.TYPE_DEFAULT);
        if (staticActRankList != null) {
            for (StaticActRank e : staticActRankList) {
                builder.addRankAward(PbHelper.createRankAwardPb(e));
            }
        }

        handler.sendMsgToPlayer(GetActSmeltPartMasterRankRs.ext, builder.build());
    }

    /**
     * 淬炼大师活动中氪金抽奖
     *
     * @param req
     * @param handler
     */
    public void lotteryInSmeltPartMaster(LotteryInSmeltPartMasterRq req, ClientHandler handler) {
        int times = req.getTimes(); // 抽奖次数
        if (times < 0)
            return;
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_PART_SMELT_MASTER);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        int step = activityBase.getStep();
        if (step != ActivityConst.OPEN_STEP) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_FINISYH);
            return;
        }

        Player player = playerDataManager.getPlayer(handler.getRoleId());

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_PART_SMELT_MASTER);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        UsualActivityData usualActivity = activityDataManager.getUsualActivity(ActivityConst.ACT_PART_SMELT_MASTER);
        if (usualActivity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        StaticActPartMasterLottery data = staticActivityDataMgr.getStaticActPartMasterLottery(times);
        if (data == null || data.getRewards() == null) {
            handler.sendErrorMsgToPlayer(GameError.STATIC_DATA_NOT_FOUND);
            return;
        }

        // 剩余氪金数量不足
        Integer remainCount = activity.getPropMap().get(ActPropIdConst.ID_KRYPTON_GOLD);
        if (remainCount == null || remainCount < data.getPrice()) {
            handler.sendErrorMsgToPlayer(GameError.PROP_NOT_ENOUGH);
            return;
        }

        // 计算掉落道具
        List<List<Integer>> drops = new ArrayList<>();
        for (int i = 0; i < times; i++) {
            List<Integer> rdmGot = RandomHelper.getRandomByWeight(data.getRewards());
            List<Integer> drop = new ArrayList<>(3);
            drop.add(rdmGot.get(0));
            drop.add(rdmGot.get(1));
            drop.add(rdmGot.get(2));
            drops.add(drop);
        }

        // 扣除氪金淀
        playerDataManager.subProp(player, AwardType.ACTIVITY_PROP, ActPropIdConst.ID_KRYPTON_GOLD, data.getPrice(),
                AwardFrom.PART_SMELT_MASTER_LOTTERY);

        // 给予奖励
        List<CommonPb.Award> pbAwards = playerDataManager.addAwardsBackPb(player, drops, AwardFrom.PART_SMELT_MASTER_LOTTERY);

        // 获得积分
        long point = activity.getStatusList().get(0) + data.getPoint();
        activity.getStatusList().set(0, point);
        // 积分大于200则进入排行榜进行排名
        if (point >= 100) {
            usualActivity.addPlayerRank(player.lord.getLordId(), point, ActivityConst.RANK_PART_SMELT_MASTER, ActivityConst.DESC);
        }

        LotteryInSmeltPartMasterRs.Builder builder = LotteryInSmeltPartMasterRs.newBuilder();
        builder.setPoint((int) point);
        builder.addAllAward(pbAwards);
        if (!activity.getPropMap().isEmpty()) {
            for (Entry<Integer, Integer> entry : activity.getPropMap().entrySet()) {
                builder.addProps(PbHelper.createAtom2Pb(AwardType.ACTIVITY_PROP, entry.getKey(), entry.getValue()));
            }
        }
        handler.sendMsgToPlayer(LotteryInSmeltPartMasterRs.ext, builder.build());

        // 世界频道广播
        propService.sendJoinActivityMsgAdd2Broadcast(usualActivity, player, pbAwards, 20);

        // 计算玩家在排名榜上的名次
        LinkedList<ActPlayerRank> rankList = activityDataManager.getUsualActivity(ActivityConst.ACT_PART_SMELT_MASTER)
                .getPlayerRanks(ActivityConst.DESC);
        int rank = 0;
        for (int i = 0; i < rankList.size(); i++) {
            if (rankList.get(i).getLordId() == player.lord.getLordId()) {
                rank = i + 1;
                break;
            }
        }
        // 记录玩家排行榜日志
        LogLordHelper.logRank(player, activityBase.getPlan().getAwardId(), point, data.getPoint(), rank);
    }

    /**
     * 能量灌注活动处理
     *
     * @param player
     * @param topup
     */
    public void payCumulative(Player player, int topup) {
        try {
            // 活动开启没有
            ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_CUMULATIVE);
            if (activityBase == null) {
                return;
            }

            // 活动开始没有
            if (activityBase.getStep() == ActivityConst.OPEN_AWARD) {
                return;
            }

            Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_CUMULATIVE);
            if (activity == null) {
                return;
            }

            Date now = new Date();
            Date beginTime = activityBase.getBeginTime();
            int dayiy = DateHelper.dayiy(beginTime, now);

            Integer repayDay = playerDataManager.getRePay(player.lord.getLordId());
            if (repayDay != null) {
                // 补充日期在今天之前才可补充
                if (repayDay > 0 && repayDay < dayiy) {
                    dayiy = repayDay;
                    playerDataManager.removeRePay(player.lord.getLordId());
                }
            }

            // saveMap的结构：1，2，3，...保存第1，2，3，...天之前充值能量，1+活动天数，2+活动天数，3+活动天数，...保存第1，2，3，...天总充值能量
            Map<Integer, Integer> saveMap = activity.getSaveMap();

            // 设置总充值能量
            List<StaticActCumulativePay> sActCumulativePayList = staticActivityDataMgr.getStaticActCumulativePayMap()
                    .get(activityBase.getPlan().getAwardId());

            int cumulativeint = sActCumulativePayList.size();
            Integer total = saveMap.get(dayiy + cumulativeint);
            if (total == null) {
                total = 0;
            }
            total += topup;
            if (total > sActCumulativePayList.get(dayiy - 1).getDaypay()) {
                total = sActCumulativePayList.get(dayiy - 1).getDaypay();
            }
            saveMap.put(dayiy + cumulativeint, total);

            Map<Integer, Integer> statusMap = activity.getStatusMap();

            Integer status = statusMap.get(dayiy);
            if (status == null) {
                status = 0;
                statusMap.put(dayiy, status);
            }

            // 如果总充值能量达到标准，并且没有领奖，则状态为可领奖
            // 状态 1 可领 0 不可领 -1 已领
            if (status == 0 && total >= sActCumulativePayList.get(dayiy - 1).getDaypay()) {
                statusMap.put(dayiy, 1);
            }

            // 如果三天都达标，且没有领过大奖，则设置状态为可领大奖
            status = statusMap.get(0);
            if (status == null) {
                status = 0;
                statusMap.put(0, status);
            }
            if (status == 0) {
                boolean isBigPrize = true;
                // 循环比较是否各天都达标
                for (int i = 1; i <= cumulativeint; i++) {
                    Integer dayStatus = statusMap.get(i);
                    // 不可领奖状态
                    if (dayStatus == null || dayStatus == 0) {
                        isBigPrize = false;
                        break;
                    }
                }

                // 如果各天都达到领奖标准，则大奖设置成可领奖状态
                if (isBigPrize) {
                    statusMap.put(0, 1);
                }
            }

            LogLordHelper.logPayCumulative(player, dayiy, topup, statusMap);
        } catch (Exception e) {
            LogUtil.error(e);
        }
    }

    /**
     * 请求充值详情信息
     *
     */
    public void getActCumulativePayInfo(ClientHandler handler) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_CUMULATIVE);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        int step = activityBase.getStep();
        if (step != ActivityConst.OPEN_STEP) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_FINISYH);
            return;
        }

        Player player = playerDataManager.getPlayer(handler.getRoleId());

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_CUMULATIVE);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        Map<Integer, Integer> saveMap = activity.getSaveMap();
        Map<Integer, Integer> statusMap = activity.getStatusMap();

        GetActCumulativePayInfoRs.Builder builder = GetActCumulativePayInfoRs.newBuilder();

        Integer total;
        Integer oldTotal;
        Integer status;
        ActCumulativePayInfo.Builder b;
        int cumulativeint = staticActivityDataMgr.getStaticActCumulativePayMap().get(activityBase.getPlan().getAwardId()).size();

        for (int i = 1; i <= cumulativeint; i++) {
            b = ActCumulativePayInfo.newBuilder();
            // 获取总充值能量
            total = saveMap.get(i + cumulativeint);
            if (total == null) {
                total = 0;
            }
            // 获取上次访问本接口后增加的充值量
            oldTotal = saveMap.get(i);
            if (oldTotal == null) {
                oldTotal = 0;
            }

            status = statusMap.get(i);
            if (status == null) {
                status = 0;
            }

            b.setAddPay(total - oldTotal);
            b.setTotalPay(oldTotal);// 客户端获取上次值
            b.setStatus(status);
            b.setDayId(i);

            builder.addPay(b.build());

            // 之前充值量重置为当前充值量
            saveMap.put(i, total);
        }

        status = statusMap.get(0);
        if (status == null) {
            status = 0;
        }

        Date now = new Date();
        Date beginTime = activityBase.getBeginTime();
        // 今天是第几天
        int dayiy = DateHelper.dayiy(beginTime, now);

        builder.setStatus(status);
        builder.setKeyId(staticActivityDataMgr.getActAwardById(activityBase.getPlan().getAwardId()).get(0).getKeyId());
        builder.setDay(dayiy);
        builder.setAwardId(activityBase.getPlan().getAwardId());

        handler.sendMsgToPlayer(GetActCumulativePayInfoRs.ext, builder.build());
    }

    /**
     * 获取充值奖励
     *
     * @param req
     */
    public void getActCumulativePayAward(GetActCumulativePayAwardRq req, ClientHandler handler) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_CUMULATIVE);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        int step = activityBase.getStep();
        if (step != ActivityConst.OPEN_STEP) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_FINISYH);
            return;
        }

        Player player = playerDataManager.getPlayer(handler.getRoleId());

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_CUMULATIVE);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        Map<Integer, Integer> statusMap = activity.getStatusMap();
        GetActCumulativePayAwardRs.Builder builder = GetActCumulativePayAwardRs.newBuilder();
        int day = req.getDay();

        // 检查是否可领奖
        Integer status = statusMap.get(day);
        if (status == null || status == 0) {
            handler.sendErrorMsgToPlayer(GameError.NO_POWER);
            return;
        }

        // 已领奖
        if (status == -1) {
            handler.sendErrorMsgToPlayer(GameError.ACT_GETAWARD);
            return;
        }

        // 设置状态为已领
        statusMap.put(day, -1);

        // day=0 大奖
        List<List<Integer>> awardList;
        if (req.getDay() == 0) {
            StaticActAward sActAward = staticActivityDataMgr.getActAwardById(activityBase.getPlan().getAwardId()).get(0);
            awardList = sActAward.getAwardList();
        } else {
            StaticActCumulativePay staticActCumulativePay = staticActivityDataMgr.getStaticActCumulativePayMap()
                    .get(activityBase.getPlan().getAwardId()).get(day - 1);
            awardList = staticActCumulativePay.getDayawards();
        }

        for (List<Integer> award : awardList) {
            // 奖励发给玩家
            playerDataManager.addAward(player, award.get(0), award.get(1), award.get(2), AwardFrom.ACT_CUMULATIVE);

            Award.Builder b = Award.newBuilder();
            b.setType(award.get(0));
            b.setId(award.get(1));
            b.setCount(award.get(2));
            builder.addAward(b);
        }

        handler.sendMsgToPlayer(GetActCumulativePayAwardRs.ext, builder.build());

        LogLordHelper.logGetActCumulative(player, day);
    }

    /**
     * 补充功能
     *
     * @param req
     */
    public void ActCumulativeRePay(ActCumulativeRePayRq req, ClientHandler handler) {
        playerDataManager.setRePay(handler.getRoleId(), req.getDay());

        ActCumulativeRePayRs.Builder builder = ActCumulativeRePayRs.newBuilder();
        handler.sendMsgToPlayer(ActCumulativeRePayRs.ext, builder.build());
    }

    /**
     * 进入自选豪礼界面
     *
     * @param handler
     */
    public void getActChooseGift(ClientHandler handler) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_CHOOSE_GIFT);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        int step = activityBase.getStep();
        if (step != ActivityConst.OPEN_STEP) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_FINISYH);
            return;
        }

        Player player = playerDataManager.getPlayer(handler.getRoleId());

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_CHOOSE_GIFT);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        int awardId = activityBase.getPlan().getAwardId();

        Map<Integer, StaticActChooseGift> actChooseGiftMap = staticActivityDataMgr.getStaticActChooseGiftMap();
        int qualification = 0;
        int limitnumber = 0;
        for (StaticActChooseGift act : actChooseGiftMap.values()) {
            if (act.getAwardid() == awardId) {
                qualification = act.getQualification();
                limitnumber = act.getLimitnumber();
                break;
            }
        }

        // 没有找到对应awardId的配置
        if (qualification == 0) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }

        // 更新活动记录
        activityDataManager.updActivity(player, ActivityConst.ACT_CHOOSE_GIFT, 0, 0);

        List<Long> list = activity.getStatusList();

        // 累计可领取次数
        int count = list.get(0).intValue() / qualification;
        if (count > limitnumber) {
            count = limitnumber;
        }
        // 剩余可领次数
        int left = limitnumber - list.get(1).intValue();
        // 还有多少次没领
        int canGet = count - list.get(1).intValue();

        GetActChooseGiftRs.Builder builder = GetActChooseGiftRs.newBuilder();
        builder.setAwardId(awardId);
        builder.setLeft(left);
        builder.setLimit(limitnumber);
        builder.setStates(canGet > 0 ? 1 : 0);

        handler.sendMsgToPlayer(GetActChooseGiftRs.ext, builder.build());
    }

    /**
     * 自选豪礼领奖
     *
     * @param req
     * @param handler
     */
    public void doActChooseGift(DoActChooseGiftRq req, ClientHandler handler) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_CHOOSE_GIFT);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        int step = activityBase.getStep();
        if (step != ActivityConst.OPEN_STEP) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_FINISYH);
            return;
        }

        Player player = playerDataManager.getPlayer(handler.getRoleId());

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_CHOOSE_GIFT);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        int awardId = activityBase.getPlan().getAwardId();

        Map<Integer, StaticActChooseGift> actChooseGiftMap = staticActivityDataMgr.getStaticActChooseGiftMap();
        StaticActChooseGift act = actChooseGiftMap.get(req.getId());

        // 领取的奖励错误
        if (act == null || act.getAwardid() != awardId) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }

        // 刷新一下玩家记录
        activityDataManager.updActivity(player, ActivityConst.ACT_CHOOSE_GIFT, 0, 0);

        List<Long> list = activity.getStatusList();

        // 累计可领取次数
        int count = list.get(0).intValue() / act.getQualification();
        if (count > act.getLimitnumber()) {
            count = act.getLimitnumber();
        }

        // 剩余可领次数
        int left = act.getLimitnumber() - list.get(1).intValue();

        // 还有多少次没领
        int canGet = count - list.get(1).intValue();
        if (canGet == 0) {
            handler.sendErrorMsgToPlayer(GameError.ACT_NOT_ENOUGH);
            return;
        }

        // 已领次数+1
        activityDataManager.updActivity(player, ActivityConst.ACT_CHOOSE_GIFT, 1, 1);
        left--;
        canGet--;

        // 领奖
        for (List<Integer> award : act.getAwardlist()) {
            playerDataManager.addAward(player, award.get(0), award.get(1), award.get(2), AwardFrom.ACT_CHOOSE_GIFT);
        }

        DoActChooseGiftRs.Builder builder = DoActChooseGiftRs.newBuilder();
        builder.setLeft(left);
        builder.setLimit(act.getLimitnumber());
        builder.setStates(canGet > 0 ? 1 : 0);

        handler.sendMsgToPlayer(DoActChooseGiftRs.ext, builder.build());

        LogLordHelper.logActChooseGift(player, req.getId(), list.get(0).intValue(), list.get(1).intValue());
    }

    /**
     * 更新兄弟同心任务列表
     *
     * @param type 1 打飞艇 2 占领飞艇
     */
    public void updActBrotherTask(List<Army> armys, int type) {
        // 活动是否开启
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_BROTHER);
        if (activityBase == null) {
            return;
        }
        int step = activityBase.getStep();
        if (step != ActivityConst.OPEN_STEP) {
            return;
        }

        List<StaticActBrotherTask> tasks = staticActivityDataMgr.getStaticActBrotherTaskMap().get(type);
        int sortId = type - 1;

        // 参与打飞艇的军团成员任务都更新
        for (Army army : armys) {
            Player player = army.player;
            Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_BROTHER);
            if (activity == null) {
                continue;
            }

            Member partyMember = partyDataManager.getMemberById(player.roleId);
            // 没有加入军团
            if (partyMember == null) {
                continue;
            }

            // 更新活动状态
            activityDataManager.updActivity(player, ActivityConst.ACT_BROTHER, 1, sortId);

            // 完成任务的数量
            long taskNum = activity.getStatusList().get(sortId);
            Map<Integer, Integer> taskMap = activity.getStatusMap();

            // 设置完成任务情况
            for (StaticActBrotherTask task : tasks) {
                Integer status = taskMap.get(task.getId());
                if (status != null && status >= 0) { // 已领奖或未完成任务
                    continue;
                }

                // 如果任务数达到配置值，则设置该任务为完成状态
                if (taskNum >= task.getNumber()) {
                    taskMap.put(task.getId(), 0);
                }
            }

            // 攻打飞艇发通知，占领飞艇不用发
            if (type == 1) {
                // 发送同步消息通知客户端更新结果
                playerDataManager.synUpActBrotherTask(player, type);
            }
        }
    }

    /**
     * 兄弟同心活动战损减少
     *
     * @return int
     */
    public int getActBrotherReduceloss() {
        // 活动是否开启
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_BROTHER);
        if (activityBase == null) {
            return 0;
        }
        int step = activityBase.getStep();
        if (step != ActivityConst.OPEN_STEP) {
            return 0;
        }

        return staticActivityDataMgr.getActBrotherReduceloss();
    }

    /**
     * 获取兄弟同心活动页面
     *
     */
    public void getActBrotherTask(ClientHandler handler) {
        // 活动是否开启
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_BROTHER);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        int step = activityBase.getStep();
        if (step != ActivityConst.OPEN_STEP) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_FINISYH);
            return;
        }

        Player player = playerDataManager.getPlayer(handler.getRoleId());

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_BROTHER);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        Member partyMember = partyDataManager.getMemberById(handler.getRoleId());

        GetActBrotherTaskRs.Builder builder = GetActBrotherTaskRs.newBuilder();

        // 加入军团才能获取军团的buff列表
        if (partyMember != null) {
            // 返回军团buff列表
            Activity partyActivy = getPartyActivity(partyMember.getPartyId(), ActivityConst.ACT_BROTHER, activityBase);

            if (partyActivy != null) {
                List<Integer> buffId = getBrotherBuff(partyActivy);
                builder.addAllBuffId(buffId);
            }
        }
        Map<Integer, Integer> taskMap = activity.getStatusMap();

        // 玩家活动状态表里遍历任务状态
        for (List<StaticActBrotherTask> tasks : staticActivityDataMgr.getStaticActBrotherTaskMap().values()) {
            for (StaticActBrotherTask task : tasks) {
                Integer status = taskMap.get(task.getId());
                if (status == null) {
                    status = -1; // 没有完成任务
                }
                TwoInt.Builder taskStatus = TwoInt.newBuilder();
                taskStatus.setV1(task.getId());
                taskStatus.setV2(status);

                builder.addTask(taskStatus);
            }
        }

        handler.sendMsgToPlayer(GetActBrotherTaskRs.ext, builder.build());
    }

    /**
     * 升级buff
     *
     * @param type                 升级的buff类型
     */
    public void upBrotherBuff(int type, ClientHandler handler) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_BROTHER);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        int step = activityBase.getStep();
        if (step != ActivityConst.OPEN_STEP) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_FINISYH);
            return;
        }

        Player player = playerDataManager.getPlayer(handler.getRoleId());

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_BROTHER);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        Member partyMember = partyDataManager.getMemberById(handler.getRoleId());
        // 没有加入军团
        if (partyMember == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
            return;
        }

        Activity partyActivity = getPartyActivity(partyMember.getPartyId(), ActivityConst.ACT_BROTHER, activityBase);

        if (partyActivity == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
            return;
        }

        UpBrotherBuffRs.Builder builder = UpBrotherBuffRs.newBuilder();

        // 找出军团对应type的等级
        Map<Integer, Integer> lvMap = partyActivity.getStatusMap();
        Integer lv = lvMap.get(type);
        if (lv == null) {
            lv = 0;
        }

        // 升级后的等级
        lv++;

        StaticActBrotherBuff buff = staticActivityDataMgr.getActBrotherBuff(type, lv);

        // 不能升级
        if (buff == null) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }

        // 金币不够
        if (buff.getPrice() > player.lord.getGold()) {
            handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
            return;
        }

        // 升级扣除金币
        playerDataManager.subGold(player, buff.getPrice(), AwardFrom.ACT_BROTHER_UP_BUFF);

        // 更新军团buff对应type的等级
        lvMap.put(type, lv);

        List<Integer> buffId = getBrotherBuff(partyActivity);

        builder.addAllBuffId(buffId);

        handler.sendMsgToPlayer(UpBrotherBuffRs.ext, builder.build());

        // 给在线的军团成员发送消息
        for (Member member : partyDataManager.getMemberList(partyMember.getPartyId())) {
            playerDataManager.synUpActBrotherBuff(member.getLordId(), buff.getId(), player.lord.getNick());
        }
    }

    /**
     * 获取兄弟同心完成的任务奖励
     *
     * @param id
     */
    public void getBrotherAward(int id, ClientHandler handler) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_BROTHER);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        int step = activityBase.getStep();
        if (step != ActivityConst.OPEN_STEP) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_FINISYH);
            return;
        }

        Player player = playerDataManager.getPlayer(handler.getRoleId());

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_BROTHER);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        Member partyMember = partyDataManager.getMemberById(handler.getRoleId());
        // 没有加入军团
        if (partyMember == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
            return;
        }

        Map<Integer, Integer> taskMap = activity.getStatusMap();
        // 是否完成任务且未领奖
        Integer status = taskMap.get(id);
        if (status == null || status != 0) {
            handler.sendErrorMsgToPlayer(GameError.TASK_NO_FINISH);
            return;
        }

        // 不存在的任务
        StaticActBrotherTask task = getBrotherTask(id);
        if (task == null) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }

        // 设置状态为已领奖
        taskMap.put(id, 1);

        // 领奖
        List<List<Integer>> awards = task.getAwards();
        for (List<Integer> award : awards) {
            playerDataManager.addAward(player, award.get(0), award.get(1), award.get(2), AwardFrom.ACT_BROTHER_GET_AWARD);
        }

        GetBrotherAwardRs.Builder builder = GetBrotherAwardRs.newBuilder();

        // 玩家活动状态表里遍历任务状态
        for (List<StaticActBrotherTask> tasks : staticActivityDataMgr.getStaticActBrotherTaskMap().values()) {
            for (StaticActBrotherTask temp : tasks) {
                status = taskMap.get(temp.getId());
                if (status == null) {
                    status = -1; // 没有完成任务
                }
                TwoInt.Builder taskStatus = TwoInt.newBuilder();
                taskStatus.setV1(temp.getId());
                taskStatus.setV2(status);

                builder.addTask(taskStatus);
            }
        }

        handler.sendMsgToPlayer(GetBrotherAwardRs.ext, builder.build());
    }

    /**
     * 兄弟同心任务
     *
     * @param taskId 任务编号
     * @return StaticActBrotherTask
     */
    private StaticActBrotherTask getBrotherTask(int taskId) {
        for (List<StaticActBrotherTask> tasks : staticActivityDataMgr.getStaticActBrotherTaskMap().values()) {
            for (StaticActBrotherTask task : tasks) {
                if (task.getId() == taskId) {
                    return task;
                }
            }
        }
        return null;
    }

    /**
     * 获取军团活动数据
     *
     * @param partyId
     * @param activityId
     * @return
     */
    public Activity getPartyActivity(int partyId, int activityId, ActivityBase activityBase) {
        Date beginTime = activityBase.getBeginTime();
        int begin = TimeHelper.getDay(beginTime);

        PartyData party = partyDataManager.getParty(partyId);
        if (party == null) {
            return null;
        }

        Map<Integer, Activity> activitys = party.getActivitys();
        Activity activity = activitys.get(activityId);
        if (activity == null) {
            activity = new Activity(activityBase, begin);
            activitys.put(activityId, activity);
        } else {
            activity.isReset(begin);// 是否重新设置活动
        }

        return activity;
    }

    /**
     * 获取军团兄弟同心活动数据
     *
     * @param partyId
     * @param activityId
     * @return Activity
     */
    public Activity getPartyActivity(int partyId, int activityId) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_BROTHER);
        if (activityBase == null) {
            return null;
        }
        int step = activityBase.getStep();
        if (step != ActivityConst.OPEN_STEP) {
            return null;
        }

        return getPartyActivity(partyId, activityId, activityBase);
    }

    /**
     * 获取飞艇的兄弟同心活动中的buffId列表
     *
     * @return
     */
    public List<Integer> getBrotherBuff(Activity activity) {
        Map<Integer, Integer> lvMap = activity.getStatusMap();
        // 活动重置后，初始化飞艇buff
        if (lvMap.size() == 0) {
            for (Entry<Integer, Map<Integer, StaticActBrotherBuff>> entry : staticActivityDataMgr.getActBrotherBuffMap().entrySet()) {
                lvMap.put(entry.getKey(), 0);
            }
        }

        List<Integer> list = new ArrayList<>();
        StaticActBrotherBuff buff;
        Integer lv;
        // 遍历飞艇buff，返回buff列表
        for (Entry<Integer, Integer> entry : lvMap.entrySet()) {
            lv = entry.getValue();
            buff = staticActivityDataMgr.getActBrotherBuff(entry.getKey(), lv);
            list.add(buff.getId());
        }

        return list;
    }

    /**
     * 请求坦克转换界面
     *
     * @param handler
     */
    public void getTankConvert(ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null || null == player.lord) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_TANK_CONVERT);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        GetTankConvertInfoRs.Builder builder = GetTankConvertInfoRs.newBuilder();

        int count = 0;
        for (int value : activity.getPropMap().values()) {
            // 只有一个道具
            count = value;
        }
        builder.setCount(count);
        handler.sendMsgToPlayer(GetTankConvertInfoRs.ext, builder.build());
    }

    /**
     * 坦克转换
     *
     * @param :count     转换数量
     * @param :srcTankId 消耗的tankId
     * @param :dstTankId 产生的新tankId
     */
    public void tankConvert(ClientHandler handler, int count, int srcTankId, int dstTankId) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        Map<Integer, Tank> tanks = player.tanks;
        Tank tank = tanks.get(srcTankId);

        // 确认活动是否开启
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_TANK_CONVERT);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        // 确认本次活动是否支持此次转换
        if (!canConvert(srcTankId, dstTankId)) {
            handler.sendErrorMsgToPlayer(GameError.DONT_SUP_CONVERT);
            return;
        }

        // 确认原坦克数量是否充足
        if (tank == null || tank.getCount() < count) {
            handler.sendErrorMsgToPlayer(GameError.TANK_NOT_ENOUGH);
            return;
        }

        StaticTankConvert convertConfig = tankConvertDataMgr.getTankConvertConfig(activityBase.getKeyId(), srcTankId);
        List<List<Integer>> priceList = convertConfig.getConvertPrice();
        int index = convertConfig.getConvertType().indexOf(dstTankId);

        List<Integer> convertPrice = priceList.get(index);

        // 确认玩家货币数量是否足够
        if (!playerDataManager.checkPropIsEnougth(player, convertPrice.get(0), convertPrice.get(1), convertPrice.get(2) * count)) {
            handler.sendErrorMsgToPlayer(GameError.MATERIRALS_NOT_ENOUGH);
            return;
        }

        // 扣除材料道具
        playerDataManager.subProp(player, convertPrice.get(0), convertPrice.get(1), convertPrice.get(2) * count, AwardFrom.TANK_CONVERT);

        // 扣除原坦克
        playerDataManager.subTank(player, tank, count, AwardFrom.TANK_CONVERT);

        // 增加新坦克
        playerDataManager.addTank(player, dstTankId, count, AwardFrom.TANK_CONVERT);

        LogLordHelper.tankConvert(player, count, srcTankId, dstTankId);
        handler.sendMsgToPlayer(TankConvertRs.ext, TankConvertRs.newBuilder().build());

    }

    /**
     * 坦克转换活动 判断本次活动是否支持此次转换
     *
     * @param :srcTankId
     * @param :dstTankId
     */
    private boolean canConvert(int srcTankId, int dstTankId) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_TANK_CONVERT);
        if (activityBase == null) {
            return false;
        }

        List<StaticTankConvert> configList = tankConvertDataMgr.getTankConvertListByAwardId(activityBase.getKeyId());
        if (configList == null) {
            return false;
        }

        for (StaticTankConvert config : configList) {
            if (config.getTankId() == srcTankId && config.getConvertType().contains(dstTankId)) {
                return true;
            }
        }
        return false;
    }

    /**
     * 获取图纸兑换配方列表
     *
     * @param handler
     */
    public void getDrawingCash(ClientHandler handler) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_DRAWING_EXCHANGE);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null || player.lord == null) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }
        GetDrawingCashRs.Builder builder = GetDrawingCashRs.newBuilder();
        List<StaticActExchange> exchangeList = staticActivityDataMgr.getActExchange(activityBase.getKeyId());
        if (exchangeList == null || exchangeList.size() == 0) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }
        int today = TimeHelper.getCurrentDay();
        for (StaticActExchange e : exchangeList) {
            int exchangeId = e.getExchangeId();
            Cash cash = player.cashs.get(exchangeId);
            if (cash == null || cash.getRefreshDate() != today) {
                cash = activityDataManager.freshCash(player, cash, e, true);
                cash.setRefreshDate(today);
                player.cashs.put(exchangeId, cash);
            }
            builder.addCash(PbHelper.createCashPb(cash));
        }
        handler.sendMsgToPlayer(GetDrawingCashRs.ext, builder.build());
    }

    /**
     * 军备图纸兑换
     */
    public void doDrawingCash(DoDrawingCashRq req, ClientHandler handler) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_DRAWING_EXCHANGE);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null || player.lord == null) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }
        int cashId = req.getCashId();
        StaticActExchange actExchange = staticActivityDataMgr.getActExchange(activityBase.getKeyId(), cashId);
        if (actExchange == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }
        int today = TimeHelper.getCurrentDay();
        Cash cash = player.cashs.get(cashId);
        if (cash == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        if (cash.getRefreshDate() != today) {
            handler.sendErrorMsgToPlayer(GameError.ACT_NOT_REFRESH_DATA);
            return;
        }

        if (cash.getState() <= 0) {
            handler.sendErrorMsgToPlayer(GameError.COUNT_NOT_ENOUGH);
            return;
        }

        DoDrawingCashRs.Builder builder = DoDrawingCashRs.newBuilder();
        List<Equip> equipList = new ArrayList<Equip>();
        for (List<Integer> e : cash.getList()) {
            int type = e.get(0);// 类型
            int id = e.get(1);// ID
            int count = e.get(2);// 数量
            if (type == AwardType.PROP) {//
                Prop prop = player.props.get(id);
                if (prop == null || prop.getCount() < count) {
                    handler.sendErrorMsgToPlayer(GameError.PROP_NOT_ENOUGH);
                    return;
                }
                playerDataManager.subProp(player, prop, count, AwardFrom.EXCHANGE_EQUIP_METERIAL);
                builder.addCostList(PbHelper.createAwardPb(type, id, count, 0));
            } else if (type == AwardType.GOLD) {
                if (player.lord.getGold() < count) {
                    handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
                    return;
                }
                playerDataManager.subGold(player, count, AwardFrom.EXCHANGE_EQUIP_METERIAL);
                builder.addCostList(PbHelper.createAwardPb(type, id, count, 0));
            } else if (type == AwardType.LORD_EQUIP) {
                List<Equip> costList = playerDataManager.getMinLvEquipById(player, id);
                if (costList.size() < count) {
                    handler.sendErrorMsgToPlayer(GameError.NO_EQUIP);
                    return;
                }
                Collections.sort(costList, new CompareEquipLv());
                for (int i = 0; i < count; i++) {
                    equipList.add(costList.get(i));
                }
            } else if (type == AwardType.LORD_EQUIP_METERIAL) {
                Prop prop = player.leqInfo.getLeqMat().get(id);
                if (prop == null || prop.getCount() < count) {
                    handler.sendErrorMsgToPlayer(GameError.PROP_NOT_ENOUGH);
                    return;
                }
                playerDataManager.subProp(player, type, id, (long) count, AwardFrom.EXCHANGE_EQUIP_METERIAL);
                builder.addCostList(PbHelper.createAwardPb(type, id, count, 0));
            } else {
                handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
                return;
            }
        }

        for (Equip equip : equipList) {
            player.equips.get(0).remove(equip.getKeyId());
            LogLordHelper.equip(AwardFrom.EXCHANGE_EQUIP_METERIAL, player.account, player.lord, equip.getKeyId(), equip.getEquipId(),
                    equip.getLv(), 0);
            builder.addCostList(PbHelper.createAwardPb(AwardType.EQUIP, equip.getEquipId(), 1, equip.getKeyId()));
        }

        int type = cash.getAwardList().get(0);
        int id = cash.getAwardList().get(1);
        int count = cash.getAwardList().get(2);

        cash.setState(cash.getState() - 1);

        int awardKeyId = playerDataManager.addAward(player, type, id, count, AwardFrom.EXCHANGE_EQUIP_METERIAL);

        builder.setAward(PbHelper.createAwardPb(type, id, count, awardKeyId));
        handler.sendMsgToPlayer(DoDrawingCashRs.ext, builder.build());
    }

    /**
     * 刷新军备图纸兑换配方
     *
     * @param handler
     */
    public void refreshDrawingCash(RefshDrawingCashRq req, ClientHandler handler) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_DRAWING_EXCHANGE);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null || player.lord == null) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }
        int cashId = req.getCashId();
        StaticActExchange actExchange = staticActivityDataMgr.getActExchange(activityBase.getKeyId(), cashId);
        if (actExchange == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }
        int today = TimeHelper.getCurrentDay();
        Cash cash = player.cashs.get(cashId);
        if (cash == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }

        if (cash.getRefreshDate() != today) {
            handler.sendErrorMsgToPlayer(GameError.ACT_NOT_REFRESH_DATA);
            return;
        } else if (cash.getRefreshDate() == today && cash.getFree() > 0) {
            cash = activityDataManager.freshCash(player, cash, actExchange, false);
            cash.setFree(cash.getFree() - 1);
        } else {
            int price = actExchange.getPrice();
            if (player.lord.getGold() < price) {
                handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
                return;
            }
            playerDataManager.subGold(player, price, AwardFrom.EXCHANGE_EQUIP);
            cash = activityDataManager.freshCash(player, cash, actExchange, false);
        }

        RefshDrawingCashRs.Builder builder = RefshDrawingCashRs.newBuilder();
        builder.setCash(PbHelper.createCashPb(cash));
        handler.sendMsgToPlayer(RefshDrawingCashRs.ext, builder.build());
    }

    /**
     * 装备转盘-主页面
     *
     * @param handler
     */
    public void getActEquipDial(ClientHandler handler) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_EQUIP_DIAL);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null || player.lord == null) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_EQUIP_DIAL);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        GetActEquipDialRs.Builder builder = GetActEquipDialRs.newBuilder();
        int day = TimeHelper.getCurrentDay();
        if (day != player.lord.getFreeEquipDial()) {
            builder.setFree(1);
        } else {
            builder.setFree(0);
        }

        long score = activity.getStatusList().get(0);
        List<StaticActFortune> condList = staticActivityDataMgr.getActFortuneList(ActivityConst.ACT_EQUIP_DIAL);
        for (StaticActFortune e : condList) {
            builder.addFortune(PbHelper.createFortunePb(e));
            builder.setDisplayList(e.getDisplayList());
        }
        builder.setScore((int) score);// 我的积分
        handler.sendMsgToPlayer(GetActEquipDialRs.ext, builder.build());
    }

    /**
     * 装备转盘-排行榜{前十名,其他均为未入榜}
     *
     * @param handler
     */
    public void getActEquipDialRank(ClientHandler handler) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_EQUIP_DIAL);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        int step = activityBase.getStep();
        int activityKeyId = activityBase.getKeyId();
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null || player.lord == null) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }

        UsualActivityData activityData = activityDataManager.getUsualActivity(ActivityConst.ACT_EQUIP_DIAL);
        if (activityData == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_EQUIP_DIAL);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        // 我的积分
        long score = activity.getStatusList().get(0);

        GetActEquipDialRankRs.Builder builder = GetActEquipDialRankRs.newBuilder();
        LinkedList<ActPlayerRank> rankList = activityData.getPlayerRanks(ActivityConst.TYPE_DEFAULT);
        for (int i = 0; i < rankList.size() && i < ActivityConst.RANK_EQUIP_DIAL; i++) {
            ActPlayerRank e = rankList.get(i);
            long lordId = e.getLordId();
            Player rankPlayer = playerDataManager.getPlayer(lordId);
            if (rankPlayer != null && rankPlayer.lord != null) {
                builder.addActPlayerRank(PbHelper.createActPlayerRank(e, rankPlayer.lord.getNick()));
            }
        }
        builder.setStatus(0);
        builder.setScore((int) score);
        if (step == ActivityConst.OPEN_STEP) {
            builder.setOpen(false);
        } else if (step == ActivityConst.OPEN_AWARD) {
            builder.setOpen(true);
            Map<Integer, Integer> statusMap = activity.getStatusMap();
            if (statusMap.containsKey(ActivityConst.TYPE_DEFAULT)) {
                builder.setStatus(1);
            }
        }

        List<StaticActRank> staticActRankList = staticActivityDataMgr.getActRankList(activityKeyId, ActivityConst.TYPE_DEFAULT);
        if (staticActRankList != null) {
            for (StaticActRank e : staticActRankList) {
                builder.addRankAward(PbHelper.createRankAwardPb(e));
            }
        }
        handler.sendMsgToPlayer(GetActEquipDialRankRs.ext, builder.build());
    }

    /**
     * 装备转盘-抽取
     *
     * @param req
     * @param handler
     */
    public void doActEquip(DoActEquipDialRq req, ClientHandler handler) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_EQUIP_DIAL);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        int step = activityBase.getStep();
        if (step != 0) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null || player.lord == null) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }

        UsualActivityData activityData = activityDataManager.getUsualActivity(ActivityConst.ACT_EQUIP_DIAL);
        if (activityData == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_EQUIP_DIAL);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        int fortuneId = req.getFortuneId();
        StaticActFortune staticActFortune = staticActivityDataMgr.getActFortune(fortuneId);
        if (staticActFortune == null) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }

        int day = TimeHelper.getCurrentDay();
        if (player.lord.getFreeEquipDial() != day && staticActFortune.getCount() == 1) {// 单抽免费次数
            player.lord.setFreeEquipDial(day);
        } else {
            int price = staticActFortune.getPrice();
            if (player.lord.getGold() < price) {
                handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
                return;
            }
            playerDataManager.subGold(player, price, AwardFrom.EQUIP_DIAL);
        }

        DialDailyGoalInfo equipInfo = player.getEquipDialDayInfo();
        if (equipInfo.getLastDay() == day) {
            equipInfo.setCount(equipInfo.getCount() + staticActFortune.getCount());
        } else {
            equipInfo.setLastDay(day);
            equipInfo.setCount(staticActFortune.getCount());
            equipInfo.getRewardStatus().clear();
        }

        List<StaticActAward> awards = staticActivityDataMgr.getActAwardById(activityBase.getKeyId());
        if (awards == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }
        // 更新每日目标奖励状态
        Map<Integer, Integer> status = equipInfo.getRewardStatus();
        for (StaticActAward award : awards) {
            if (equipInfo.getCount() >= award.getCond() && (!status.containsKey(award.getKeyId()) || status.get(award.getKeyId()) == -1)) {
                status.put(award.getKeyId(), 0);
            }
        }

        DoActEquipDialRs.Builder builder = DoActEquipDialRs.newBuilder();
        int scoreAdd = 0;
        // 发放奖励
        int repeat = staticActFortune.getCount();
        for (int i = 0; i < repeat; i++) {
            List<Integer> list = staticActivityDataMgr.randomAwardList(staticActFortune.getAwardList());
            if (list == null || list.size() < 5) {
                continue;
            }
            int type = list.get(0);
            int id = list.get(1);
            int count = list.get(2);
            int keyId = playerDataManager.addAward(player, type, id, count, AwardFrom.EQUIP_DIAL);
            scoreAdd += list.get(4);// 增加积分
            builder.addAward(PbHelper.createAwardPb(type, id, count, keyId));
        }

        long score = activity.getStatusList().get(0);
        score += scoreAdd;
        activity.getStatusList().set(0, score);

        // 计算排名
        if (score >= 600 && player.lord.getLevel() >= 10) {// 积分超过600才可进入排行
            activityData.addPlayerRank(player.lord.getLordId(), score, ActivityConst.RANK_EQUIP_DIAL, ActivityConst.DESC);
        }
        builder.setScore((int) score);// 我的积分
        handler.sendMsgToPlayer(DoActEquipDialRs.ext, builder.build());
    }

    /**
     * 装备转盘-抽取 获取每日目标界面信息
     *
     * @param handler
     */
    public void getActEquipDayInfo(ClientHandler handler) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_EQUIP_DIAL);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null || player.lord == null) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }
        List<StaticActAward> list = staticActivityDataMgr.getActAwardById(activityBase.getKeyId());
        if (list == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }
        DialDailyGoalInfo equipInfo = player.getEquipDialDayInfo();
        Map<Integer, Integer> status = equipInfo.getRewardStatus();
        // 清除前一天的奖励信息
        int day = TimeHelper.getCurrentDay();
        if (equipInfo.getLastDay() != day) {
            status.clear();
            equipInfo.setCount(0);
        }
        for (StaticActAward award : list) {
            if (!status.containsKey(award.getKeyId())) {
                // -1 默认奖励不可领取状态
                status.put(award.getKeyId(), -1);
            }
        }
        GetEquipDialDayInfoRs.Builder builder = GetEquipDialDayInfoRs.newBuilder();
        builder.setCount(equipInfo.getCount());
        for (StaticActAward award : list) {
            builder.addRewardStatus(PbHelper.createTwoIntPb(award.getKeyId(), status.get(award.getKeyId())));
        }
        handler.sendMsgToPlayer(GetEquipDialDayInfoRs.ext, builder.build());
    }

    /**
     * 装备转盘 领取每日目标奖励
     *
     * @param handler, rq
     */
    public void getActEquipDayAward(ClientHandler handler, GetEquipDialDayAwardRq rq) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_EQUIP_DIAL);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null || player.lord == null) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }
        int awardId = rq.getAwardId();
        StaticActAward award = staticActivityDataMgr.getActAward(awardId);
        DialDailyGoalInfo equipInfo = player.getEquipDialDayInfo();
        Map<Integer, Integer> status = equipInfo.getRewardStatus();
        int day = TimeHelper.getCurrentDay();
        if (equipInfo.getLastDay() != day) {
            handler.sendErrorMsgToPlayer(GameError.ACT_NOT_REFRESH_DATA);
            return;
        }
        if (status.get(award.getKeyId()) == null || status.get(award.getKeyId()) != 0) {
            handler.sendErrorMsgToPlayer(GameError.ACT_AWARD_COND_LIMIT);
            return;
        }
        GetEquipDialDayAwardRs.Builder builder = GetEquipDialDayAwardRs.newBuilder();
        List<List<Integer>> awardList = award.getAwardList();
        builder.addAllAward(playerDataManager.addAwardsBackPb(player, awardList, AwardFrom.EQUIPDIAL_DAYILGOAL_AWARD));
        // 将奖励状态置为已领取
        status.put(award.getKeyId(), 1);
        handler.sendMsgToPlayer(GetEquipDialDayAwardRs.ext, builder.build());
    }

    /**
     * 勋章分解兑换-主页面
     *
     * @param handler
     */
    public void getActMedalResolveRq(ClientHandler handler) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_MEDAL_RESOLVE);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null || player.lord == null) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_MEDAL_RESOLVE);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        int activityKeyId = activityBase.getKeyId();
        List<Long> statusList = activity.getStatusList();
        long score = statusList.get(0);

        GetActMedalResolveRs.Builder builder = GetActMedalResolveRs.newBuilder();
        List<StaticActPartResolve> condList = staticActivityDataMgr.getActPartResolveList(activityKeyId);
        for (StaticActPartResolve e : condList) {
            builder.addPartResolve(PbHelper.createPartResolvePb(e));
        }
        builder.setState((int) score);
        handler.sendMsgToPlayer(GetActMedalResolveRs.ext, builder.build());
    }

    /**
     * 勋章分解兑换
     *
     * @param req
     * @param handler
     */
    public void doActMedalResolveRq(DoActMedalResolveRq req, ClientHandler handler) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_MEDAL_RESOLVE);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null || player.lord == null) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_MEDAL_RESOLVE);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        int resolveId = req.getResolveId();
        int activityKeyId = activityBase.getKeyId();
        List<Long> statusList = activity.getStatusList();
        long score = statusList.get(0);
        StaticActPartResolve staticActPartResolve = staticActivityDataMgr.getActPartResolve(activityKeyId, resolveId);
        if (staticActPartResolve.getSlug() > score) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_FINISH);
            return;
        }
        DoActMedalResolveRs.Builder builder = DoActMedalResolveRs.newBuilder();
        statusList.set(0, score - staticActPartResolve.getSlug());
        for (int i = 0; i < staticActPartResolve.getAwardList().size(); i++) {
            List<Integer> elist = staticActPartResolve.getAwardList().get(0);
            if (elist.size() < 3) {
                continue;
            }
            int type = elist.get(0);
            int id = elist.get(1);
            int count = elist.get(2);
            int keyId = playerDataManager.addAward(player, type, id, count, AwardFrom.MEDAL_RESOLVE);
            builder.addAward(PbHelper.createAwardPb(type, id, count, keyId));
        }
        handler.sendMsgToPlayer(DoActMedalResolveRs.ext, builder.build());
    }

    /**
     * 批量购买，兑换道具
     *
     * @param handler
     * @param activityId 活动ID
     * @param goodId     物品ID
     * @param count      物品数量
     */
    public void buyInBuck(ClientHandler handler, int activityId, int goodId, int count) {
        if (count <= 0) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(activityId);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null || player.lord == null) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }
        Activity activity = activityDataManager.getActivityInfo(player, activityId);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        BuyInBuckRs.Builder builder = BuyInBuckRs.newBuilder();

        if (activityId == ActivityConst.ACT_MEDAL_RESOLVE || activityId == ActivityConst.ACT_PART_RESOLVE_ID) {
            int activityKeyId = activityBase.getKeyId();
            List<Long> statusList = activity.getStatusList();
            long score = statusList.get(0);
            StaticActPartResolve staticActPartResolve = staticActivityDataMgr.getActPartResolve(activityKeyId, goodId);
            if (staticActPartResolve == null) {
                handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
                return;
            }
            if (staticActPartResolve.getSlug() * count > score) {
                handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_FINISH);
                return;
            }
            statusList.set(0, score - staticActPartResolve.getSlug() * count);
            for (int i = 0; i < staticActPartResolve.getAwardList().size(); i++) {
                List<Integer> elist = staticActPartResolve.getAwardList().get(0);
                if (elist.size() < 3) {
                    continue;
                }
                int type = elist.get(0);
                int id = elist.get(1);
                int amount = elist.get(2);
                int keyId;
                // 非堆叠物品，需要对每一个都产生对应的流水keyID
                if (playerDataManager.isKeyIdAward(type)) {
                    for (int j = 0; j < amount * count; j++) {
                        keyId = playerDataManager.addAward(player, type, id, 1,
                                activityId == ActivityConst.ACT_PART_RESOLVE_ID ? AwardFrom.PART_RESOLVE : AwardFrom.MEDAL_RESOLVE);
                        builder.addAward(PbHelper.createAwardPb(type, id, 1, keyId));
                    }
                } else {
                    keyId = playerDataManager.addAward(player, type, id, amount * count,
                            activityId == ActivityConst.ACT_PART_RESOLVE_ID ? AwardFrom.PART_RESOLVE : AwardFrom.MEDAL_RESOLVE);
                    builder.addAward(PbHelper.createAwardPb(type, id, amount * count, keyId));
                }
            }

        } else if (activityId == ActivityConst.ACT_DAY_BUY || activityId == ActivityConst.ACT_FLASH_META
                || activityId == ActivityConst.ACT_MONTH_SALE || activityId == ActivityConst.ACT_FES_SALE
                || activityId == ActivityConst.ACT_TECHSELL || activityId == ActivityConst.ACT_BUILDSELL) {
            activityDataManager.refreshDay(activity);
            StaticActQuota staticActQuota = staticActivityDataMgr.getQuotaById(goodId);
            if (staticActQuota == null || staticActQuota.getActivityId() != activityBase.getKeyId()) {
                handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
                return;
            }
            if (player.lord.getGold() < staticActQuota.getPrice() * count) {
                handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
                return;
            }
            Integer status = activity.getStatusMap().get(goodId);
            if (status == null) {
                status = 0;
            }
            if (status > staticActQuota.getCount() - count) {
                handler.sendErrorMsgToPlayer(GameError.COUNT_NOT_ENOUGH);
                return;
            }

            activity.getStatusMap().put(goodId, status + count);
            playerDataManager.subGold(player, staticActQuota.getPrice() * count, AwardFrom.HALF_COST);
            List<List<Integer>> awardList = staticActQuota.getAwardList();
            for (List<Integer> e : awardList) {
                if (e.size() != 3) {
                    continue;
                }
                int type = e.get(0);
                int id = e.get(1);
                int amount = e.get(2);
                // 非堆叠物品，需要对每一个都产生对应的流水keyID
                if (type == AwardType.EQUIP || type == AwardType.PART || type == AwardType.MEDAL) {
                    for (int i = 0; i < amount * count; i++) {
                        int keyId = playerDataManager.addAward(player, type, id, 1, AwardFrom.HALF_COST);
                        builder.addAward(PbHelper.createAwardPb(type, id, 1, keyId));
                    }
                } else {
                    int keyId = playerDataManager.addAward(player, type, id, amount * count, AwardFrom.HALF_COST);
                    builder.addAward(PbHelper.createAwardPb(type, id, amount * count, keyId));
                }
            }
            builder.setActProp(PbHelper.createAtom2Pb(AwardType.GOLD, 0, player.lord.getGold()));
            LogLordHelper.logActivity(staticActivityDataMgr, player, activityId, AwardFrom.HALF_COST, awardList, staticActQuota.getPrice());

        } else if (activityId == ActivityConst.ACT_PIRATE) {
            StaticActivityChange staticChange = staticActivityDataMgr.getActivityChangeMap(activityBase.getKeyId()).get(goodId);
            if (staticChange == null) {
                handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
                return;
            }
            Map<Integer, Integer> statusMap = activity.getStatusMap();
            if (statusMap.containsKey(goodId) && statusMap.get(goodId) > staticChange.getItemNum() - count
                    && staticChange.getItemNum() >= 0) { // 该物品已经超出兑换数量
                handler.sendErrorMsgToPlayer(GameError.COUNT_NOT_ENOUGH);
                return;
            }
            for (List<Integer> list : staticChange.getMore()) {
                if (!playerDataManager.checkPropIsEnougth(player, list.get(0), list.get(1), list.get(2) * count)) {
                    handler.sendErrorMsgToPlayer(GameError.PROP_NOT_ENOUGH);
                    return;
                }
            }
            for (List<Integer> need : staticChange.getMore()) { // 减去兑换需要的活动道具
                playerDataManager.subProp(player, need.get(0), need.get(1), need.get(2) * count, AwardFrom.ACT_PIRATE_CHANGE);
            }
            Integer num = statusMap.get(goodId);
            if (num == null) {
                statusMap.put(goodId, count);
            } else {
                statusMap.put(goodId, num + count);
            }
            // 添加兑换奖励
            for (List<Integer> award : staticChange.getAward()) { // 发放活动奖励
                if (award.size() != 3) {
                    continue;
                }
                int type = award.get(0);
                int id = award.get(1);
                int amount = award.get(2);
                // 非堆叠物品，需要对每一个都产生对应的流水keyID
                if (type == AwardType.EQUIP || type == AwardType.PART || type == AwardType.MEDAL) {
                    for (int i = 0; i < amount * count; i++) {
                        int keyId = playerDataManager.addAward(player, type, id, 1, AwardFrom.ACT_PIRATE_CHANGE);
                        builder.addAward(PbHelper.createAwardPb(type, id, 1, keyId));
                    }
                } else {
                    int keyId = playerDataManager.addAward(player, type, id, amount * count, AwardFrom.ACT_PIRATE_CHANGE);
                    builder.addAward(PbHelper.createAwardPb(type, id, amount * count, keyId));
                }
            }
            for (StaticActivityChange change : staticActivityDataMgr.getActivityChangeMap(activityId).values()) {
                if (change.getItemNum() < 0) { // -1 为无限制
                    continue;
                }
                if (statusMap.containsKey(change.getId())) { // 该物品兑换过 减去兑换的数量
                    builder.addChangeNum(PbHelper.createTwoIntPb(change.getId(), change.getItemNum() - statusMap.get(change.getId())));
                } else {
                    builder.addChangeNum(PbHelper.createTwoIntPb(change.getId(), change.getItemNum()));
                }
            }
            for (Integer propId : activity.getPropMap().keySet()) {
                builder.setActProp(PbHelper.createAtom2Pb(AwardType.ACTIVITY_PROP, propId, activity.getPropMap().get(propId)));
            }
        }

        handler.sendMsgToPlayer(BuyInBuckRs.ext, builder.build());
    }

    /**
     * 拉取每日登陆福利界面
     *
     * @param handler
     */
    public void getLoginWelfareInfo(ClientHandler handler) throws ParseException {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null || player.lord == null) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_LOGIN_WELFARE);
        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_LOGIN_WELFARE);
        if (activity == null || activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        GetLoginWelfareInfoRs.Builder builder = GetLoginWelfareInfoRs.newBuilder();
        int hasLogin = 0;
        for (int i = 0; i < activity.getStatusList().size() - 1; i++) {
            Long status = activity.getStatusList().get(i);
            if (status != 0) {
                hasLogin++;
            }
        }

        Date parse = new SimpleDateFormat("yyyyMMdd").parse(activity.getBeginTime() + "");
        int today = TimeHelper.daysOfTwo(System.currentTimeMillis(), parse.getTime());
        builder.setIndex(today);
        builder.setDays(hasLogin);
        builder.addAllStatus(activity.getStatusList());
        handler.sendMsgToPlayer(GetLoginWelfareInfoRs.ext, builder.build());
    }

    /**
     * 领取登陆福利
     *
     * @param handler
     */
    public void getLoginWelfareAward(ClientHandler handler, GetLoginWelfareAwardRq req) {
        int awardId = req.getAwardId();

        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null || player.lord == null) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_LOGIN_WELFARE);
        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_LOGIN_WELFARE);
        if (activity == null || activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        List<StaticActAward> list = staticActivityDataMgr.getActAwardById(activityBase.getKeyId());
        StaticActAward award = staticActivityDataMgr.getActAward(awardId);
        if (award == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }
        // 活动开启的第几天
        int dayIndex = award.getCond();
        if (dayIndex <= 0 || dayIndex > list.size()) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }
        if (activity.getStatusList().get(dayIndex - 1) != 1) {
            handler.sendErrorMsgToPlayer(GameError.LOGIN_AWARD_SATTUS_ERROR);
            return;
        }
        GetLoginWelfareAwardRs.Builder builder = GetLoginWelfareAwardRs.newBuilder();
        builder.addAllAwards(playerDataManager.addAwardsBackPb(player, award.getAwardList(), AwardFrom.ACT_LOGIN_WELFARE));
        activity.getStatusList().set(dayIndex - 1, 2L);
        handler.sendMsgToPlayer(GetLoginWelfareAwardRs.ext, builder.build());
    }

    /**
     * 问卷调查活动答题及发送奖励
     *
     * @param handler
     * @param rq
     */
    public void queSendAnswer(ClientHandler handler, QueSendAnswerRq rq) {
        List<CommonPb.QueAnswer> answerList = rq.getAnswerList();
        if (answerList == null || answerList.size() == 0) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null || player.lord == null) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_QUESTIONNAIRE_SURVEY);
        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_QUESTIONNAIRE_SURVEY);
        if (activity == null || activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        int minLv = activityBase.getStaticActivity().getMinLv();
        if (player.lord.getLevel() < minLv) {
            handler.sendErrorMsgToPlayer(GameError.LV_NOT_ENOUGH);
            return;
        }
        if (activity.getStatusList().get(0) != 0) {
            handler.sendErrorMsgToPlayer(GameError.QUESTIONNAIRE_TWICE_ERROR);
            return;
        }
        StaticActAward award = staticActivityDataMgr.getActAwardById(ActivityConst.ACT_QUESTIONNAIRE_SURVEY).get(0);
        if (award == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }
        QueSendAnswerRs.Builder builder = QueSendAnswerRs.newBuilder();
        builder.addAllAward(playerDataManager.addAwardsBackPb(player, award.getAwardList(), AwardFrom.QUESTIONNAIRE_SURVEY));
        builder.setQueStatus(1);
        handler.sendMsgToPlayer(QueSendAnswerRs.ext, builder.build());

        activity.getStatusList().set(0, 1L);
        // 后台记录答案日志
        LogLordHelper.logQuestionnaire(AwardFrom.QUESTIONNAIRE_SURVEY, player, activity.getBeginTime(), answerList);
    }

    /**
     * 问卷活动状态拉取
     *
     * @param handler
     */
    public void getQueAwardStatus(GetQueAwardStatusHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null || player.lord == null) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_QUESTIONNAIRE_SURVEY);
        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_QUESTIONNAIRE_SURVEY);
        if (activity == null || activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        GetQueAwardStatusRs.Builder builder = GetQueAwardStatusRs.newBuilder();
        int status = activity.getStatusList().get(0).intValue();
        builder.setQueStatus(status);
        handler.sendMsgToPlayer(GetQueAwardStatusRs.ext, builder.build());
    }


    /**
     * 战术转盘-主页面
     *
     * @param handler
     */
    public void getActTicStoneDialRq(ClientHandler handler) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_TIC_DIAL_ID);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
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
        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_TIC_DIAL_ID);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        GetActTicDialRs.Builder builder = GetActTicDialRs.newBuilder();
        int monthAndDay = TimeHelper.getMonthAndDay(new Date());
        int energyStoneDial = lord.getTicDial();
        if (energyStoneDial / 100 != monthAndDay / 100) {
            energyStoneDial = monthAndDay;
        }
        int useCount = energyStoneDial % 100;
        int free = 0;
        free = 1 - useCount < 0 ? 0 : 1 - useCount;
        builder.setFree(free);// 剩余次数

        List<Long> stus = activity.getStatusList();
        if (stus == null || stus.isEmpty()) {
            stus = new ArrayList<>();
            for (int i = 0; i < 10; i++) {
                stus.add(0L);
            }
            activity.setStatusList(stus);
        }
        long score = stus.get(0);
        List<StaticActFortune> condList = staticActivityDataMgr.getActFortuneList(ActivityConst.ACT_TIC_DIAL_ID);
        for (StaticActFortune e : condList) {
            builder.addFortune(PbHelper.createFortunePb(e));
            builder.setDisplayList(e.getDisplayList());
        }
        builder.setScore((int) score);// 我的积分
        handler.sendMsgToPlayer(GetActTicDialRs.ext, builder.build());
    }

    /**
     * 战术转盘排行榜{前十名,其他均为未入榜}
     *
     * @param handler
     */
    public void getActTicDialRankRq(ClientHandler handler) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_TIC_DIAL_ID);
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
        UsualActivityData activityData = activityDataManager.getUsualActivity(ActivityConst.ACT_TIC_DIAL_ID);
        if (activityData == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_TIC_DIAL_ID);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        // 我的积分
        long score = 0;
        List<Long> stus = activity.getStatusList();
        if (stus != null && !stus.isEmpty()) {
            score = activity.getStatusList().get(0);
        }
        GetActTicDialRankRs.Builder builder = GetActTicDialRankRs.newBuilder();
        LinkedList<ActPlayerRank> rankList = activityData.getPlayerRanks(ActivityConst.TYPE_DEFAULT);
        for (int i = 0; i < rankList.size() && i < ActivityConst.RANK_ENERGYSTONE_DESTORY; i++) {
            ActPlayerRank e = rankList.get(i);
            long lordId = e.getLordId();
            Player rankPlayer = playerDataManager.getPlayer(lordId);
            if (rankPlayer != null && rankPlayer.lord != null) {
                builder.addActPlayerRank(PbHelper.createActPlayerRank(e, rankPlayer.lord.getNick()));
            }
        }
        builder.setStatus(0);
        builder.setScore((int) score);
        if (step == ActivityConst.OPEN_STEP) {
            builder.setOpen(false);
        } else if (step == ActivityConst.OPEN_AWARD) {
            builder.setOpen(true);
            Map<Integer, Integer> statusMap = activity.getStatusMap();
            if (statusMap.containsKey(ActivityConst.TYPE_DEFAULT)) {
                builder.setStatus(1);
            }
        }

        List<StaticActRank> staticActRankList = staticActivityDataMgr.getActRankList(activityKeyId, ActivityConst.TYPE_DEFAULT);
        if (staticActRankList != null) {
            for (StaticActRank e : staticActRankList) {
                builder.addRankAward(PbHelper.createRankAwardPb(e));
            }
        }
        handler.sendMsgToPlayer(GetActTicDialRankRs.ext, builder.build());
    }

    /**
     * 战术转盘-抽取
     *
     * @param req
     * @param handler
     */
    public void doActTicDialRq(ClientHandler handler, DoActTicDialRq req) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_TIC_DIAL_ID);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        int step = activityBase.getStep();
        if (step != 0) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
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

        UsualActivityData activityData = activityDataManager.getUsualActivity(ActivityConst.ACT_TIC_DIAL_ID);
        if (activityData == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_TIC_DIAL_ID);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        int fortuneId = req.getFortuneId();
        StaticActFortune staticActFortune = staticActivityDataMgr.getActFortune(fortuneId);
        if (staticActFortune == null) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }

        int monthAndDay = TimeHelper.getMonthAndDay(new Date());
        int ticStoneDial = lord.getTicDial();
        if (ticStoneDial / 100 != monthAndDay / 100) {
            ticStoneDial = monthAndDay;
        }
        int useCount = ticStoneDial % 100;
        int free = 0;
        free = 1 - useCount < 0 ? 0 : 1 - useCount;
        if (free > 0 && staticActFortune.getCount() == 1) {// 单抽免费次数
            lord.setTicDial(ticStoneDial + 1);
        } else {
            int price = staticActFortune.getPrice();
            if (lord.getGold() < price) {
                handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
                return;
            }
            playerDataManager.subGold(player, price, AwardFrom.TIC_DIAL);
        }

        DoActTicDialRs.Builder builder = DoActTicDialRs.newBuilder();

        // 发放奖励
        int scoreAdd = 0;
        int repeat = staticActFortune.getCount();
        for (int i = 0; i < repeat; i++) {
            List<Integer> list = staticActivityDataMgr.randomAwardList(staticActFortune.getAwardList());
            if (list == null || list.size() < 5) {
                continue;
            }
            int type = list.get(0);
            int id = list.get(1);
            int count = list.get(2);
            int keyId = playerDataManager.addAward(player, type, id, count, AwardFrom.TIC_DIAL);
            scoreAdd += list.get(4);// 增加积分
            builder.addAward(PbHelper.createAwardPb(type, id, count, keyId));
        }
        long score = 0;
        List<Long> stus = activity.getStatusList();
        if (stus != null && !stus.isEmpty()) {
            score = activity.getStatusList().get(0);
        }
        score += scoreAdd;
        activity.getStatusList().set(0, score);

        // 优化：转盘新增每日目标
        int day = TimeHelper.getCurrentDay();
        DialDailyGoalInfo ticDialDayInfo = player.ticDialDayInfo;
        if (ticDialDayInfo.getLastDay() == day) {
            ticDialDayInfo.setCount(ticDialDayInfo.getCount() + staticActFortune.getCount());
        } else {
            ticDialDayInfo.setLastDay(day);
            ticDialDayInfo.setCount(staticActFortune.getCount());
            ticDialDayInfo.getRewardStatus().clear();
        }

        List<StaticActAward> awards = staticActivityDataMgr.getActAwardById(activityBase.getKeyId());
        if (awards == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }
        // 更新每日目标奖励状态
        Map<Integer, Integer> status = ticDialDayInfo.getRewardStatus();
        for (StaticActAward award : awards) {
            if (ticDialDayInfo.getCount() >= award.getCond()
                    && (!status.containsKey(award.getKeyId()) || status.get(award.getKeyId()) == -1)) {
                status.put(award.getKeyId(), 0);
            }
        }

        // 计算排名
        if (score >= 600) {// 积分超过600才可进入排行
            activityData.addPlayerRank(lord.getLordId(), score, ActivityConst.RANK_ENERGYSTONE_DESTORY, ActivityConst.DESC);
        }

        builder.setScore((int) score);// 我的积分
        handler.sendMsgToPlayer(DoActTicDialRs.ext, builder.build());
    }

    /**
     * 战术转盘 获取每日目标界面信息
     *
     * @param handler
     */
    public void getTicDialDayInfo(ClientHandler handler) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_TIC_DIAL_ID);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null || player.lord == null) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }
        List<StaticActAward> list = staticActivityDataMgr.getActAwardById(activityBase.getKeyId());
        DialDailyGoalInfo enengyInfo = player.ticDialDayInfo;
        Map<Integer, Integer> status = enengyInfo.getRewardStatus();
        // 清除前一天的奖励信息
        int day = TimeHelper.getCurrentDay();
        if (enengyInfo.getLastDay() != day) {
            enengyInfo.setCount(0);
            status.clear();
        }
        for (StaticActAward award : list) {
            if (!status.containsKey(award.getKeyId())) {
                // -1 默认奖励不可领取状态
                status.put(award.getKeyId(), -1);
            }
        }
        GetTicDialDayInfoRs.Builder builder = GetTicDialDayInfoRs.newBuilder();
        builder.setCount(enengyInfo.getCount());
        for (StaticActAward award : list) {
            builder.addRewardStatus(PbHelper.createTwoIntPb(award.getKeyId(), status.get(award.getKeyId())));
        }
        handler.sendMsgToPlayer(GetTicDialDayInfoRs.ext, builder.build());
    }

    /**
     * 战术转盘 领取每日目标奖励
     *
     * @param handler,rq
     */
    public void getTicDialDayAward(ClientHandler handler, GetTicDialDayAwardRq rq) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_TIC_DIAL_ID);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null || player.lord == null) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }
        int awardId = rq.getAwardId();
        StaticActAward award = staticActivityDataMgr.getActAward(awardId);
        DialDailyGoalInfo enengyInfo = player.ticDialDayInfo;
        Map<Integer, Integer> status = enengyInfo.getRewardStatus();
        int day = TimeHelper.getCurrentDay();
        if (enengyInfo.getLastDay() != day) {
            handler.sendErrorMsgToPlayer(GameError.ACT_NOT_REFRESH_DATA);
            return;
        }
        if (status.get(award.getKeyId()) == null || status.get(award.getKeyId()) != 0) {
            handler.sendErrorMsgToPlayer(GameError.ACT_AWARD_COND_LIMIT);
            return;
        }
        GetTicDialDayAwardRs.Builder builder = GetTicDialDayAwardRs.newBuilder();
        List<List<Integer>> awardList = award.getAwardList();
        builder.addAllAward(playerDataManager.addAwardsBackPb(player, awardList, AwardFrom.TIC_DAYILGOAL_AWARD));
        // 将奖励状态置为已领取
        status.put(award.getKeyId(), 1);
        handler.sendMsgToPlayer(GetTicDialDayAwardRs.ext, builder.build());
    }
}
