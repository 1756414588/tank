package com.game.service;

import com.game.constant.*;
import com.game.dataMgr.StaticGifttoryDataMgr;
import com.game.dataMgr.StaticWarAwardDataMgr;
import com.game.domain.Player;
import com.game.domain.s.StaticGifttory;
import com.game.domain.sort.ActRedBag;
import com.game.domain.sort.GrabRedBag;
import com.game.manager.*;
import com.game.message.handler.ClientHandler;
import com.game.pb.CommonPb;
import com.game.pb.GamePb4.GetRebelDataRs;
import com.game.pb.GamePb4.GetRebelRankRs;
import com.game.pb.GamePb4.RebelIsDeadRs;
import com.game.pb.GamePb4.RebelRankRewardRs;
import com.game.pb.GamePb6;
import com.game.pb.GamePb6.GetRebelBoxAwardRs;
import com.game.rebel.domain.PartyRebelData;
import com.game.rebel.domain.Rebel;
import com.game.rebel.domain.RoleRebelData;
import com.game.server.util.ChannelUtil;
import com.game.util.*;
import org.apache.commons.lang3.RandomUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.Map.Entry;

/**
 * @author TanDonghai
 * @ClassName RebelService.java
 * @Description 叛军相关
 * @date 创建时间：2016年9月2日 下午2:37:29
 */
@Service
public class RebelService {
    @Autowired
    private StaticWarAwardDataMgr staticWarAwardDataMgr;

    @Autowired
    private PlayerDataManager playerDataManager;

    @Autowired
    private RebelDataManager rebelDataManager;

    @Autowired
    private RewardService rewardService;

    @Autowired
    private StaticGifttoryDataMgr staticGifttoryDataMgr;

    @Autowired
    private WorldDataManager worldDataManager;

    @Autowired
    private ChatService chatService;

    @Autowired
    private PartyDataManager partyDataManager;

    @Autowired
    private ChatDataManager chatDataManager;

    /**
     * 获取叛军入侵活动相关数据
     *
     * @param handler
     */
    public void getRebelData(ClientHandler handler) {
        GetRebelDataRs.Builder builder = GetRebelDataRs.newBuilder();

        int restUnit = 0;
        int restGuard = 0;
        int restLeader = 0;
        int bossLeader = 0;
        Map<Integer, Rebel> rebelMap = rebelDataManager.getRebelMap();
        for (Rebel rebel : rebelMap.values()) {
            if (rebel.getType() == RebelConstant.REBEL_TYPE_UNIT) {
                builder.addUnitRebels(PbHelper.createRebelPb(rebel));
                if (rebel.isAlive()) {
                    restUnit++;
                }
            }
            if (rebel.getType() == RebelConstant.REBEL_TYPE_GUARD) {
                builder.addGuardRebels(PbHelper.createRebelPb(rebel));
                if (rebel.isAlive()) {
                    restGuard++;
                }
            }
            if (rebel.getType() == RebelConstant.REBEL_TYPE_LEADER) {
                builder.addLeaderRebels(PbHelper.createRebelPb(rebel));
                if (rebel.isAlive()) {
                    restLeader++;
                }
            }


            if (rebel.getType() == RebelConstant.REBEL_TYPE_BOOS) {
                builder.addBossRebels(PbHelper.createRebelPb(rebel));
                if (rebel.isAlive()) {
                    bossLeader++;
                }
            }
        }
        builder.setRestUnit(restUnit);
        builder.setRestGuard(restGuard);
        builder.setRestLeader(restLeader);
        builder.setRestBoss(bossLeader);
        builder.setState(rebelDataManager.getRebelStatus());
        builder.setChangeTime(rebelDataManager.getChangeStatusTime());

        RoleRebelData data = rebelDataManager.getRoleRebelData(handler.getRoleId());
        if (rebelDataManager.getLastOpenTime() != data.getLastUpdateTime()) {// 更新玩家爱数据
            data.setKillNum(0);
            data.setLastUpdateTime(rebelDataManager.getLastOpenTime());
            data.setLastUpdateWeek(rebelDataManager.getLastOpenWeek());
            // if (rebelDataManager.getLastOpenWeek() != data.getLastUpdateWeek()) {
            // data.cleanWeekData(rebelDataManager.getLastOpenWeek());
            // }
        }


        builder.setKillNum(data.getKillNum());
        handler.sendMsgToPlayer(GetRebelDataRs.ext, builder.build());
    }

    /**
     * 获取叛军入侵活动的排行榜数据
     *
     * @param rankType 排行榜类型，1：个人周榜，2：总榜 ，3：军团周榜
     * @param page     分页，每一页显示20个，第一页page=0，第二页page=1
     * @param handler
     */
    public void getRebelRank(int rankType, int page, ClientHandler handler) {
        GetRebelRankRs.Builder builder = GetRebelRankRs.newBuilder();
        long roleId = handler.getRoleId();
        if (partyDataManager.getPartyId(roleId) == 0 && rankType == RebelConstant.RANK_TYPE_WEEK_PARTY) {
            handler.sendErrorMsgToPlayer(GameError.REBEL_NO_PARTY);
        }
        RoleRebelData data = rebelDataManager.getRoleRebelData(roleId);
        PartyRebelData partyData = rebelDataManager.getPartyRebelDataByRoleId(roleId);

        LinkedList<RoleRebelData> playerRankList = new LinkedList<>();
        LinkedList<PartyRebelData> partyRankList = new LinkedList<>();
        if (rankType == RebelConstant.RANK_TYPE_WEEK_PLAYER) {
            builder.setKillUnit(data.getKillUnit());
            builder.setKillGuard(data.getKillGuard());
            builder.setKillLeader(data.getKillLeader());
            builder.setScore(data.getScore());
            builder.setRank(rebelDataManager.getCurrentRank(roleId));
            builder.setLastRank(rebelDataManager.getRoleLastWeekRank(roleId, rankType));
            if (builder.getLastRank() >= 1 && builder.getLastRank() <= 30) {
                builder.setGetReward(rebelDataManager.isGetReward(roleId, rankType));
            }

            playerRankList = rebelDataManager.getRebelWeekRank();
        } else if (rankType == RebelConstant.RANK_TYPE_TOTAL_PLAYER) {
            builder.setKillUnit(data.getTotalUnit());
            builder.setKillGuard(data.getTotalGuard());
            builder.setKillLeader(data.getTotalLeader());
            builder.setScore(data.getTotalScore());
            builder.setRank(rebelDataManager.getTotalRank(roleId));

            playerRankList = rebelDataManager.getRebelTotalRank();
        } else if (rankType == RebelConstant.RANK_TYPE_WEEK_PARTY) {
            builder.setKillUnit(partyData.getKillUnit());
            builder.setKillGuard(partyData.getKillGuard());
            builder.setKillLeader(partyData.getKillLeader());
            builder.setScore(partyData.getScore());
            builder.setRank(rebelDataManager.getCurrentPartyRank(partyData.getPartyId()));
            builder.setLastRank(rebelDataManager.getRoleLastWeekRank(roleId, rankType));
            if (builder.getLastRank() >= 1 && builder.getLastRank() <= 10) {
                builder.setGetReward(rebelDataManager.isGetReward(roleId, rankType));
            }
            partyRankList = rebelDataManager.getPartyWeekRank();
        }

        int startIndex = page * 20;
        int endIndex = startIndex + 20;
        for (int i = startIndex; i < endIndex; i++) {
            if (rankType == RebelConstant.RANK_TYPE_WEEK_PLAYER || rankType == RebelConstant.RANK_TYPE_TOTAL_PLAYER) {
                if (i < playerRankList.size()) {
                    data = playerRankList.get(i);
                    if (rankType == RebelConstant.RANK_TYPE_WEEK_PLAYER) {
                        builder.addRebelRanks(PbHelper.createRebelRankPb(i + 1, data.getLordId(), data.getNick(),
                                data.getKillUnit(), data.getKillGuard(), data.getKillLeader(), data.getScore()));
                    } else if (rankType == RebelConstant.RANK_TYPE_TOTAL_PLAYER) {
                        builder.addRebelRanks(
                                PbHelper.createRebelRankPb(i + 1, data.getLordId(), data.getNick(), data.getTotalUnit(),
                                        data.getTotalGuard(), data.getTotalLeader(), data.getTotalScore()));
                    }
                }

            } else if (rankType == RebelConstant.RANK_TYPE_WEEK_PARTY) {
                if (i < partyRankList.size()) {
                    partyData = partyRankList.get(i);
                    builder.addRebelRanks(PbHelper.createRebelRankPb(i + 1, partyData.getPartyId(),
                            partyData.getPartyName(), partyData.getKillUnit(), partyData.getKillGuard(),
                            partyData.getKillLeader(), partyData.getScore()));
                }
            }
        }
        handler.sendMsgToPlayer(GetRebelRankRs.ext, builder.build());
    }

    /**
     * 领取叛军入侵活动的排行奖励
     *
     * @param handler
     * @param awardType
     */
    public void rebelRankReward(ClientHandler handler, int awardType) {
        RebelRankRewardRs.Builder builder = RebelRankRewardRs.newBuilder();
        int lastRank = rebelDataManager.getRoleLastWeekRank(handler.getRoleId(), awardType);

        if (lastRank <= 0) {
            handler.sendErrorMsgToPlayer(GameError.NOT_ON_RANK);
            return;
        }
        if (rebelDataManager.isGetReward(handler.getRoleId(), awardType)) {
            handler.sendErrorMsgToPlayer(GameError.REBEL_GET_REWARD);
            return;
        }

        Player player = playerDataManager.getPlayer(handler.getRoleId());
        List<List<Integer>> rewardList;
        if (awardType == RebelConstant.AWARD_TYPE_WEEK_PLAYER) {
            if (lastRank > 30) {
                handler.sendErrorMsgToPlayer(GameError.REBEL_NO_REWARD);
                return;
            }
            rewardList = staticWarAwardDataMgr.getRebelRankReward(lastRank);
            // 记录玩家领奖
            rebelDataManager.getRebelRewardSet().add(handler.getRoleId());
            builder.addAllAward(
                    playerDataManager.addAwardsBackPb(player, rewardList, AwardFrom.REBEL_PLAYER_RANK_REWARD));
        } else {
            if (lastRank > 10) {
                handler.sendErrorMsgToPlayer(GameError.REBEL_NO_REWARD);
                return;
            }
            rewardList = staticWarAwardDataMgr.getRebelPartyRankReward(lastRank);
            rebelDataManager.getPartyRewardSet().add(handler.getRoleId());
            builder.addAllAward(
                    playerDataManager.addAwardsBackPb(player, rewardList, AwardFrom.REBEL_PARTY_RANK_REWARD));
        }
        handler.sendMsgToPlayer(RebelRankRewardRs.ext, builder.build());
    }

    /**
     * 获取叛军是否死亡
     *
     * @param pos
     * @param handler
     */
    public void rebelIsDead(int pos, ClientHandler handler) {
        RebelIsDeadRs.Builder builder = RebelIsDeadRs.newBuilder();
        builder.setPos(pos);

        Rebel rebel = rebelDataManager.getRebelByPos(pos);
        if (null == rebel || !rebel.isAlive()) {
            builder.setIsDead(true);
        } else {
            builder.setIsDead(false);
        }
        handler.sendMsgToPlayer(RebelIsDeadRs.ext, builder.build());
    }

    /**
     * 叛军数据持久化 void
     */
    public void rebelTimerLogic() {
        int openServerDay = DateHelper.getServerOpenDay();
        int dayOfWeek = TimeHelper.getCNDayOfWeek();
        if (openServerDay >= RebelConstant.REBEL_FIRST_OPEN_DAY
                && RebelConstant.RebelOpenWeekDayList.contains(dayOfWeek)) {
            if (rebelDataManager.getRebelStatus() == RebelConstant.REBEL_STATUS_END) {
                for (Entry<Integer, Integer> entry : RebelConstant.RebelOpenTimeMap.entrySet()) {
                    if (TimeHelper.isTime(entry.getKey(), entry.getValue())) {
                        LogUtil.common("叛军入侵活动开始，刷新第一波叛军");
                        rebelDataManager.rebelStart();
                        break;
                    }
                }
            } else {
                int time = TimeHelper.getCurrentSecond();
                int nextTime = rebelDataManager.getNextAppearanceTime();
                if (nextTime > 0 && nextTime <= time) {// 分批创建叛军
                    LogUtil.common("叛军入侵活动，刷新第" + rebelDataManager.getNextRebelType() + "波叛军");
                    rebelDataManager.initRebels(rebelDataManager.getNextRebelType());
                }

                if (time >= rebelDataManager.getChangeStatusTime()) {
                    rebelDataManager.rebelEnd();
                    LogUtil.common("叛军入侵活动结束");
                }
            }
        }

        // 每周一0点刷新叛军排行榜
        if (dayOfWeek == 1) {// && TimeHelper.isTime(0, 0)) {
            rebelDataManager.refreshRebelWeekRank();
        }
    }

    /**
     * 点击叛军礼盒获得奖励
     *
     * @param handler
     */
    public void getRebelBoxReward(ClientHandler handler, int pos) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());

        Map<Integer, Integer> leftCount = rebelDataManager.getBoxLeftCount();
        int count = (leftCount.get(pos) == null) ? 0 : leftCount.get(pos);

        GetRebelBoxAwardRs.Builder builder = GetRebelBoxAwardRs.newBuilder();
        // 判断该位置是否存在礼盒
        if (count < 1) {
            builder.setLeftCount(0);
            handler.sendMsgToPlayer(GetRebelBoxAwardRs.ext, builder.build());
            return;
        }

        if (rebelDataManager.getRebelStatus() == RebelConstant.REBEL_STATUS_END) {
            builder.setLeftCount(-3);
            handler.sendMsgToPlayer(GetRebelBoxAwardRs.ext, builder.build());
            return;
        }

        // 单个礼盒每人只能领一次
        if (!(player.rebelBoxCount.indexOf(pos) < 0)) {
            builder.setLeftCount(-2);
            handler.sendMsgToPlayer(GetRebelBoxAwardRs.ext, builder.build());
            return;
        }

        // 等级限制
        if (player.lord.getLevel() < RebelConstant.GET_BOX_LEVEL) {
            handler.sendErrorMsgToPlayer(GameError.LV_NOT_ENOUGH);
            return;
        }

        // 如果不是同一天就重置次数
        if (player.rebelBoxTime != 0 && !DateHelper.isSameDate(new Date(), new Date(player.rebelBoxTime * 1000L))) {
            player.rebelBoxCount.clear();
        }

        // 每日领取限额
        if (player.rebelBoxCount.size() >= RebelConstant.BOX_DAILY_LIMIT) {
            builder.setLeftCount(-1);
            handler.sendMsgToPlayer(GetRebelBoxAwardRs.ext, builder.build());
            return;
        }

        // 该礼盒的可领取次数-1
        leftCount.put(pos, count - 1);
        worldDataManager.setRebelBox(pos, count - 1);

        // 若是最后一次领取
        if (count == 1) {
            rebelDataManager.getBoxLeftCount().remove(pos);
            rebelDataManager.getBoxDropTime().remove(pos);
            worldDataManager.removeReblBoxFromMap(pos);
        }

        // 开始摇奖
        StaticGifttory config = staticGifttoryDataMgr.getStaticRebelConfig();
        List<List<Integer>> reward = config.getReward();
        Map<List<Integer>, Float> rewardMap = new HashMap<>();
        for (List<Integer> it : reward) {
            float roll = (float) (it.get(3) * 1.0);
            rewardMap.put(it, roll);
        }

        // 最后随机出的奖励
        List<Integer> item = LotteryUtil.getRandomKey(rewardMap);

        // 更新领奖记录
        player.rebelBoxTime = TimeHelper.getCurrentSecond();
        player.rebelBoxCount.add(pos);

        builder.setLeftCount(count);
        // 如果获得的奖励是世界红包
        if (item.get(0) == AwardType.WORLD_RED_BAG) {
            // 创建红包
            ActRedBag arb = createRedBag(player, item.get(2), RebelConstant.WORLD_REDBAG_COUNT);
            // 记录红包信息
            recordRedBag(arb);
            // 发送红包
            chatService.sendHornChat(chatService.createRebelRedBagChat(SysChatId.REBEL_RED_BAG, arb.getId(), player.lord.getNick()), 1);
        } else {
            CommonPb.Award award = PbHelper.createAwardPb(item.get(0), item.get(1), item.get(2));
            builder.setAward(award);
            rewardService.addAward(player, item.get(0), item.get(1), item.get(2), AwardFrom.REBEL_HEAD_BOX);
        }
        handler.sendMsgToPlayer(GetRebelBoxAwardRs.ext, builder.build());
    }

    /**
     * 抢红包
     *
     * @param req
     * @param handler
     */
    public void grabRedBag(GamePb6.GrabRebelRedBagRq req, ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_LORD);
            return;
        }
        GamePb6.GrabRebelRedBagRs.Builder builder = GamePb6.GrabRebelRedBagRs.newBuilder();
        // 红包不存在
        Map<Integer, ActRedBag> redBags = rebelDataManager.getRedBags();
        ActRedBag arb = redBags.get(req.getUid());
        if (arb == null) {
            builder.setGrabMoney(-3);
            handler.sendMsgToPlayer(GamePb6.GrabRebelRedBagRs.ext, builder.build());
            return;
        }
        // 如果不是同一天就重置次数
        if (player.rebelRedBagTime != 0 && !DateHelper.isSameDate(new Date(), new Date(player.rebelRedBagTime * 1000L))) {
            player.rebelRedBagCount.clear();
        }
        Map<Long, GrabRedBag> grabs = arb.getGrabs();
        String clientIP;
        /*if (arb.getGrabCnt() - grabs.size() > 0 && !grabs.containsKey(player.roleId)) {

        }*/
        // 每日领取限额
        if (grabs.containsKey(player.roleId) || grabs.size() >= arb.getGrabCnt()) {
            // 已经抢过此红包或红包已被领完,显示红包详细信
            List<Player> players = new ArrayList<>();
            for (long lordId : grabs.keySet()) {
                players.add(playerDataManager.getPlayer(lordId));
            }
            builder.setGrabMoney(0);
            builder.setRedBag(PbHelper.createActRedBag(playerDataManager.getPlayer(arb.getLordId()), players, arb));
        } else if (player.rebelRedBagCount.size() >= RebelConstant.BOX_DAILY_LIMIT) {
            builder.setGrabMoney(-1);

        } else {
            // 剩余可抢次数
            clientIP = ChannelUtil.getIp(handler.getCtx(), player.roleId);
            if (clientIP != null && arb.playerIps.containsKey(clientIP)) {
                handler.sendErrorMsgToPlayer(GameError.SAME_IP);
                return;
            }
            int remainCnt = arb.getGrabCnt() - grabs.size();
            int grabMoney = 0;// 固定给1金币
            if (remainCnt == 1) {
                grabMoney = arb.getRemainMoney();
            } else {
                // 随机给金币
                int randomMoney = arb.getRemainMoney();
                if (randomMoney > 0) {
                    grabMoney = RandomUtils.nextInt(1, (randomMoney / remainCnt) * 2 - 1);
                }
            }
            GrabRedBag grab = new GrabRedBag(player.roleId, grabMoney);
            grabs.put(player.roleId, grab);
            if (clientIP != null) {
                arb.playerIps.put(clientIP, player.roleId);
            }
            arb.setRemainMoney(arb.getRemainMoney() - grabMoney);

            // 给予金币
            playerDataManager.addGold(player, grabMoney, AwardFrom.REBEL_RED_BAG);

            // 更新个人抢红包记录
            player.rebelRedBagTime = TimeHelper.getCurrentSecond();
            player.rebelRedBagCount.add(arb.getId());

            builder.setGrabMoney(grabMoney);
        }

        handler.sendMsgToPlayer(GamePb6.GrabRebelRedBagRs.ext, builder.build());
    }

    /**
     * 创建世界红包
     *
     * @param player
     * @param money  红包总金额
     * @param count  红包个数（可供几人领取）
     */
    public ActRedBag createRedBag(Player player, int money, int count) {
        ActRedBag arb = new ActRedBag();
        arb.setId(TimeHelper.getCurrentSecond());
        arb.setLordId(player.roleId);
        arb.setTotalMoney(money);
        arb.setRemainMoney(money);
        arb.setGrabCnt(count);
        arb.setSendTime(System.currentTimeMillis());
        return arb;
    }

    /**
     * 记录世界红包信息
     *
     * @param arb
     */
    public void recordRedBag(ActRedBag arb) {
        Map<Integer, ActRedBag> redBags = rebelDataManager.getRedBags();
        redBags.put(arb.getId(), arb);
    }

    /**
     * 定时检查并删除红包 1.每天凌晨3点，清除所有红包
     */
    public void clearRedBagLogic() {
        Map<Integer, ActRedBag> redBags = rebelDataManager.getRedBags();

        // 清除红包
        redBags.clear();

        // 清除世界聊天红包信息
        List<CommonPb.Chat> list = chatDataManager.getWorldChat();
        for (int i = list.size() - 1; i > 0; i--) {
            if (list.get(i).hasUid()) {
                list.remove(i);
            }
        }
    }

}
