package com.game.service;

import com.game.constant.ActivityConst;
import com.game.constant.AwardFrom;
import com.game.constant.GameError;
import com.game.dataMgr.StaticActivateKingMgr;
import com.game.dataMgr.StaticActivityDataMgr;
import com.game.domain.ActivityBase;
import com.game.domain.Member;
import com.game.domain.PartyData;
import com.game.domain.Player;
import com.game.domain.p.KingRankRewardInfo;
import com.game.domain.p.PartyRankInfo;
import com.game.domain.p.PersonKingInfo;
import com.game.domain.p.PersonRankInfo;
import com.game.domain.s.StaticActKingRank;
import com.game.domain.s.StaticKingActAward;
import com.game.domain.s.StaticKingActRatio;
import com.game.manager.GlobalDataManager;
import com.game.manager.PartyDataManager;
import com.game.manager.PlayerDataManager;
import com.game.message.handler.ClientHandler;
import com.game.pb.CommonPb;
import com.game.pb.GamePb6;
import com.game.util.DateHelper;
import com.game.util.LogUtil;
import com.game.util.PbHelper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.*;

@Component
public class ActivityKingService {

    @Autowired
    private PlayerDataManager playerDataManager;
    @Autowired
    private GlobalDataManager globalDataManager;
    @Autowired
    private StaticActivateKingMgr staticActivateKingMgr;
    @Autowired
    private StaticActivityDataMgr staticActivityDataMgr;
    @Autowired
    private PartyDataManager partyDataManager;
    @Autowired
    private RewardService rewardService;


    /**
     * 获取信息
     *
     * @param rq
     * @param handler
     */
    public void getPsnKillRankRq(GamePb6.GetPsnKillRankRq rq, ClientHandler handler) {
        if (!isOpen()) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_FINISYH);
            return;
        }

        int type = rq.getType();

        if (type < 1 || type > 5) {
            return;
        }

        Player player = playerDataManager.getPlayer(handler.getRoleId());

        PersonKingInfo globalKingInfo = globalDataManager.gameGlobal.getKingInfo();
        String activateVersion = getActivateVersion();
        if (!activateVersion.equals(globalKingInfo.getVersion())) {
            globalKingInfo.setVersion(activateVersion);
            globalKingInfo.clear();

        }
        KingRankRewardInfo kingRankRewardInfo = player.kingRankRewardInfo;
        if (!activateVersion.equals(kingRankRewardInfo.getVersion())) {
            kingRankRewardInfo.setVersion(activateVersion);
            kingRankRewardInfo.clear();
        }

        GamePb6.GetPsnKillRankRs.Builder builder = GamePb6.GetPsnKillRankRs.newBuilder();

        long[] openTime = getOpenTime(type);
        builder.setStartTime(openTime[0]);
        builder.setEndTime(openTime[1]);
        PersonRankInfo personRankInfo = null;
        if (type == 1) {
            personRankInfo = globalKingInfo.getKillInfo().get(player.lord.getLordId());
        } else if (type == 2) {
            personRankInfo = globalKingInfo.getSourceInfo().get(player.lord.getLordId());

        } else if (type == 3) {
            personRankInfo = globalKingInfo.getCreditInfo().get(player.lord.getLordId());

        }

        if (personRankInfo != null) {
            builder.setPoints(personRankInfo.getPoints());
            builder.setTotalNumber(personRankInfo.getTotalNumber());
        } else {
            builder.setPoints(0);
            builder.setTotalNumber(0);
        }

        Map<Integer, Integer> pointsStatus = kingRankRewardInfo.getPointsStatus();
        Set<Map.Entry<Integer, Integer>> entries = pointsStatus.entrySet();
        for (Map.Entry<Integer, Integer> e : entries) {
            builder.addStatus(PbHelper.createTwoIntPb(e.getKey(), e.getValue()));
        }

        handler.sendMsgToPlayer(GamePb6.GetPsnKillRankRs.ext, builder.build());

    }

    /**
     * 获取榜首信息
     *
     * @param rq
     * @param handler
     */
    public void getAllRanksRq(GamePb6.GetAllRanksRq rq, ClientHandler handler) {
        if (!isOpen()) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_FINISYH);
            return;
        }

        Player player = playerDataManager.getPlayer(handler.getRoleId());

        PersonKingInfo globalKingInfo = globalDataManager.gameGlobal.getKingInfo();
        String activateVersion = getActivateVersion();
        if (!activateVersion.equals(globalKingInfo.getVersion())) {
            globalKingInfo.setVersion(activateVersion);
            globalKingInfo.clear();

        }
        KingRankRewardInfo kingRankRewardInfo = player.kingRankRewardInfo;
        if (!activateVersion.equals(kingRankRewardInfo.getVersion())) {
            kingRankRewardInfo.setVersion(activateVersion);
            kingRankRewardInfo.clear();
        }


        GamePb6.GetAllRanksRs.Builder builder = GamePb6.GetAllRanksRs.newBuilder();

        PersonRankInfo personRankInfo = globalKingInfo.getTotalKillInfo().get(player.lord.getLordId());

        if (personRankInfo == null) {
            builder.setPoints(0);
        } else {
            builder.setPoints(personRankInfo.getPoints());
        }

        PartyRankInfo partyRankInfo = null;
        int partyId = partyDataManager.getPartyId(player.lord.getLordId());
        if (partyId != 0) {
            partyRankInfo = globalKingInfo.getPartyInfo().get((long) partyId);
        }

        if (partyRankInfo == null) {
            builder.setPartyPoint(0);
        } else {
            builder.setPartyPoint(partyRankInfo.getPoints());
        }


        if (!globalKingInfo.getKillInfo().isEmpty()) {
            List<PersonRankInfo> killInfoRank = sortRank(new ArrayList<PersonRankInfo>(globalKingInfo.getKillInfo().values()));
            PersonRankInfo rankInfo = killInfoRank.get(0);
            Player player1 = playerDataManager.getPlayer(rankInfo.getLordId());
            if (player1 != null) {
                CommonPb.KvString.Builder kvString = CommonPb.KvString.newBuilder();
                kvString.setKey(1);
                kvString.setValue(player1.lord.getNick());
                builder.addFirstRankInfo(kvString);
            }
        } else {
            CommonPb.KvString.Builder kvString = CommonPb.KvString.newBuilder();
            kvString.setKey(1);
            kvString.setValue("");
            builder.addFirstRankInfo(kvString);
        }


        if (!globalKingInfo.getSourceInfo().isEmpty()) {
            List<PersonRankInfo> sourceInfoRank = sortRank(new ArrayList<PersonRankInfo>(globalKingInfo.getSourceInfo().values()));
            PersonRankInfo rankInfo = sourceInfoRank.get(0);
            Player player1 = playerDataManager.getPlayer(rankInfo.getLordId());
            if (player1 != null) {
                CommonPb.KvString.Builder kvString = CommonPb.KvString.newBuilder();
                kvString.setKey(2);
                kvString.setValue(player1.lord.getNick());
                builder.addFirstRankInfo(kvString);
            }
        } else {
            CommonPb.KvString.Builder kvString = CommonPb.KvString.newBuilder();
            kvString.setKey(2);
            kvString.setValue("");
            builder.addFirstRankInfo(kvString);
        }


        if (!globalKingInfo.getCreditInfo().isEmpty()) {
            List<PersonRankInfo> creditInfoRank = sortRank(new ArrayList<PersonRankInfo>(globalKingInfo.getCreditInfo().values()));
            PersonRankInfo rankInfo = creditInfoRank.get(0);
            Player player1 = playerDataManager.getPlayer(rankInfo.getLordId());
            if (player1 != null) {
                CommonPb.KvString.Builder kvString = CommonPb.KvString.newBuilder();
                kvString.setKey(3);
                kvString.setValue(player1.lord.getNick());
                builder.addFirstRankInfo(kvString);
            }
        } else {
            CommonPb.KvString.Builder kvString = CommonPb.KvString.newBuilder();
            kvString.setKey(3);
            kvString.setValue("");
            builder.addFirstRankInfo(kvString);
        }


        if (!globalKingInfo.getTotalKillInfo().isEmpty()) {
            List<PersonRankInfo> totalKillInfoRank = sortRank(new ArrayList<PersonRankInfo>(globalKingInfo.getTotalKillInfo().values()));
            PersonRankInfo rankInfo = totalKillInfoRank.get(0);
            Player player1 = playerDataManager.getPlayer(rankInfo.getLordId());
            if (player1 != null) {
                CommonPb.KvString.Builder kvString = CommonPb.KvString.newBuilder();
                kvString.setKey(4);
                kvString.setValue(player1.lord.getNick());
                builder.addFirstRankInfo(kvString);
            }
        } else {
            CommonPb.KvString.Builder kvString = CommonPb.KvString.newBuilder();
            kvString.setKey(4);
            kvString.setValue("");
            builder.addFirstRankInfo(kvString);
        }


        if (!globalKingInfo.getPartyInfo().isEmpty()) {
            List<PartyRankInfo> partyInfoRank = sortPartyRank(new ArrayList<PartyRankInfo>(globalKingInfo.getPartyInfo().values()));
            PartyRankInfo rankInfo = partyInfoRank.get(0);
            PartyData partyData = partyDataManager.getParty((int) rankInfo.getPartyId());
            if (partyData != null) {
                CommonPb.KvString.Builder kvString = CommonPb.KvString.newBuilder();
                kvString.setKey(5);
                kvString.setValue(partyData.getPartyName());
                builder.addFirstRankInfo(kvString);
            } else {
                CommonPb.KvString.Builder kvString = CommonPb.KvString.newBuilder();
                kvString.setKey(5);
                kvString.setValue("");
                builder.addFirstRankInfo(kvString);
            }
        } else {
            CommonPb.KvString.Builder kvString = CommonPb.KvString.newBuilder();
            kvString.setKey(5);
            kvString.setValue("");
            builder.addFirstRankInfo(kvString);
        }


        handler.sendMsgToPlayer(GamePb6.GetAllRanksRs.ext, builder.build());

    }

    /**
     * 获取排行榜分榜信息
     *
     * @param rq
     * @param handler
     */
    public void getRanksInfoRq(GamePb6.GetRanksInfoRq rq, ClientHandler handler) {

        if (!isOpen()) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_FINISYH);
            return;
        }
        int type = rq.getType();

        if (type < 1 || type > 5) {
            return;
        }

        Player player = playerDataManager.getPlayer(handler.getRoleId());

        PersonKingInfo globalKingInfo = globalDataManager.gameGlobal.getKingInfo();
        String activateVersion = getActivateVersion();
        if (!activateVersion.equals(globalKingInfo.getVersion())) {
            globalKingInfo.setVersion(activateVersion);
            globalKingInfo.clear();

        }
        KingRankRewardInfo kingRankRewardInfo = player.kingRankRewardInfo;
        if (!activateVersion.equals(kingRankRewardInfo.getVersion())) {
            kingRankRewardInfo.setVersion(activateVersion);
            kingRankRewardInfo.clear();
        }

        int myRank = 0;
        long myPoint = 0;

        GamePb6.GetRanksInfoRs.Builder builder = GamePb6.GetRanksInfoRs.newBuilder();

        if (kingRankRewardInfo.getRankStatus().containsKey(type)) {
            builder.setStatus(kingRankRewardInfo.getRankStatus().get(type));
        } else {
            builder.setStatus(0);
        }

        if (type == 1) {
            Map<Long, PersonRankInfo> killInfo = globalKingInfo.getKillInfo();
            List<PersonRankInfo> killInfoRank = sortRank(new ArrayList<PersonRankInfo>(killInfo.values()));
            myRank = getMyRank(player.lord.getLordId(), killInfo, killInfoRank);
            if (killInfo.containsKey(player.lord.getLordId())) {
                myPoint = killInfo.get(player.lord.getLordId()).getPoints();
            }

            List<PersonRankInfo> rankList = killInfoRank;
            if (killInfoRank.size() > 20) {
                rankList = killInfoRank.subList(0, 20);
            }

            for (PersonRankInfo in : rankList) {

                CommonPb.KingRankInfo.Builder i = CommonPb.KingRankInfo.newBuilder();
                i.setPoints(in.getPoints());
                Player p = playerDataManager.getPlayer(in.getLordId());

                if (p == null) {
                    i.setNick(in.getLordId() + "");
                } else {
                    i.setNick(p.lord.getNick());
                }
                builder.addKingRankInfo(i);

            }


        }

        if (type == 2) {
            Map<Long, PersonRankInfo> sourceInfo = globalKingInfo.getSourceInfo();
            List<PersonRankInfo> sourceInfoRank = sortRank(new ArrayList<PersonRankInfo>(sourceInfo.values()));
            myRank = getMyRank(player.lord.getLordId(), sourceInfo, sourceInfoRank);
            if (sourceInfo.containsKey(player.lord.getLordId())) {
                myPoint = sourceInfo.get(player.lord.getLordId()).getPoints();
            }


            List<PersonRankInfo> rankList = sourceInfoRank;
            if (sourceInfoRank.size() > 20) {
                rankList = sourceInfoRank.subList(0, 20);
            }

            for (PersonRankInfo in : rankList) {

                CommonPb.KingRankInfo.Builder i = CommonPb.KingRankInfo.newBuilder();
                i.setPoints(in.getPoints());
                Player p = playerDataManager.getPlayer(in.getLordId());

                if (p == null) {
                    i.setNick(in.getLordId() + " ");
                } else {
                    i.setNick(p.lord.getNick());
                }
                builder.addKingRankInfo(i);

            }


        }


        if (type == 3) {
            Map<Long, PersonRankInfo> creditInfo = globalKingInfo.getCreditInfo();
            List<PersonRankInfo> creditInfoRank = sortRank(new ArrayList<PersonRankInfo>(creditInfo.values()));
            myRank = getMyRank(player.lord.getLordId(), creditInfo, creditInfoRank);
            if (creditInfo.containsKey(player.lord.getLordId())) {
                myPoint = creditInfo.get(player.lord.getLordId()).getPoints();
            }

            List<PersonRankInfo> rankList = creditInfoRank;
            if (creditInfoRank.size() > 20) {
                rankList = creditInfoRank.subList(0, 20);
            }

            for (PersonRankInfo in : rankList) {

                CommonPb.KingRankInfo.Builder i = CommonPb.KingRankInfo.newBuilder();
                i.setPoints(in.getPoints());
                Player p = playerDataManager.getPlayer(in.getLordId());

                if (p == null) {
                    i.setNick(in.getLordId() + "  ");
                } else {
                    i.setNick(p.lord.getNick());
                }
                builder.addKingRankInfo(i);

            }

        }

        if (type == 4) {
            Map<Long, PersonRankInfo> totalKillInfo = globalKingInfo.getTotalKillInfo();
            List<PersonRankInfo> totalKillInfoRank = sortRank(new ArrayList<PersonRankInfo>(totalKillInfo.values()));
            myRank = getMyRank(player.lord.getLordId(), totalKillInfo, totalKillInfoRank);
            if (totalKillInfo.containsKey(player.lord.getLordId())) {
                myPoint = totalKillInfo.get(player.lord.getLordId()).getPoints();
            }

            List<PersonRankInfo> rankList = totalKillInfoRank;
            if (totalKillInfoRank.size() > 20) {
                rankList = totalKillInfoRank.subList(0, 20);
            }

            for (PersonRankInfo in : rankList) {

                CommonPb.KingRankInfo.Builder i = CommonPb.KingRankInfo.newBuilder();
                i.setPoints(in.getPoints());
                Player p = playerDataManager.getPlayer(in.getLordId());

                if (p == null) {
                    i.setNick(in.getLordId() + "   ");
                } else {
                    i.setNick(p.lord.getNick());
                }
                builder.addKingRankInfo(i);

            }

        }


        if (type == 5) {
            Map<Long, PartyRankInfo> partyInfo = globalKingInfo.getPartyInfo();
            List<PartyRankInfo> partyInfoRank = sortPartyRank(new ArrayList<PartyRankInfo>(partyInfo.values()));
            int partyId = partyDataManager.getPartyId(player.lord.getLordId());
            myRank = getMyPartyRank(partyId, partyInfo, partyInfoRank);
            if (partyInfo.containsKey((long) partyId)) {
                myPoint = partyInfo.get((long) partyId).getPoints();
            }

            List<PartyRankInfo> rankList = partyInfoRank;
            if (partyInfoRank.size() > 20) {
                rankList = partyInfoRank.subList(0, 20);
            }

            for (PartyRankInfo in : rankList) {

                CommonPb.KingRankInfo.Builder i = CommonPb.KingRankInfo.newBuilder();
                i.setPoints(in.getPoints());
                PartyData partyData = partyDataManager.getParty((int) in.getPartyId());

                if (partyData == null) {
                    i.setNick(in.getPartyId() + "");
                } else {
                    i.setNick(partyData.getPartyName());
                }
                builder.addKingRankInfo(i);
            }

        }

        builder.setMyPoint(myPoint);
        builder.setMyRank(myRank);


        handler.sendMsgToPlayer(GamePb6.GetRanksInfoRs.ext, builder.build());

    }

    /**
     * 获取工会排名
     *
     * @param partyId
     * @param baseData
     * @param killInfoRank
     * @return
     */
    private int getMyPartyRank(long partyId, Map<Long, PartyRankInfo> baseData, List<PartyRankInfo> killInfoRank) {

        //说明没有上榜
        if (partyId == 0 || !baseData.containsKey(partyId)) {
            return 0;
        }

        int rank = 0;

        for (PartyRankInfo info : killInfoRank) {
            rank++;

            if (info.getPartyId() == partyId) {
                return rank;
            }

        }
        return rank;
    }


    private int getMyRank(long lordId, Map<Long, PersonRankInfo> baseData, List<PersonRankInfo> killInfoRank) {

        //说明没有上榜
        if (!baseData.containsKey(lordId)) {
            return 0;
        }

        int rank = 0;

        for (PersonRankInfo info : killInfoRank) {
            rank++;

            if (info.getLordId() == lordId) {
                return rank;
            }

        }
        return rank;
    }


    public void getKingRankAwardRq(GamePb6.GetKingRankAwardRq rq, ClientHandler handler) {

        int type = rq.getType();

        if (type < 1 || type > 5) {
            return;
        }

        if (!isOpen()) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_FINISYH);
            return;
        }

        Player player = playerDataManager.getPlayer(handler.getRoleId());

        PersonKingInfo globalKingInfo = globalDataManager.gameGlobal.getKingInfo();
        String activateVersion = getActivateVersion();
        if (!activateVersion.equals(globalKingInfo.getVersion())) {
            globalKingInfo.setVersion(activateVersion);
            globalKingInfo.clear();

        }
        KingRankRewardInfo kingRankRewardInfo = player.kingRankRewardInfo;
        if (!activateVersion.equals(kingRankRewardInfo.getVersion())) {
            kingRankRewardInfo.setVersion(activateVersion);
            kingRankRewardInfo.clear();
        }

        if (kingRankRewardInfo.getRankStatus().containsKey(type)) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }

        int myRank = 0;


        if (type == 1) {
            long[] openTime = getOpenTime(type);
            if (System.currentTimeMillis() < openTime[1]) {
                handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
                return;
            }

            Map<Long, PersonRankInfo> killInfo = globalKingInfo.getKillInfo();
            List<PersonRankInfo> killInfoRank = sortRank(new ArrayList<PersonRankInfo>(killInfo.values()));
            myRank = getMyRank(player.lord.getLordId(), killInfo, killInfoRank);

        }

        if (type == 2) {

            long[] openTime = getOpenTime(type);
            if (System.currentTimeMillis() < openTime[1]) {
                handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
                return;
            }

            Map<Long, PersonRankInfo> sourceInfo = globalKingInfo.getSourceInfo();
            List<PersonRankInfo> sourceInfoRank = sortRank(new ArrayList<PersonRankInfo>(sourceInfo.values()));
            myRank = getMyRank(player.lord.getLordId(), sourceInfo, sourceInfoRank);


        }


        if (type == 3) {

            long[] openTime = getOpenTime(type);
            if (System.currentTimeMillis() < openTime[1]) {
                handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
                return;
            }


            Map<Long, PersonRankInfo> creditInfo = globalKingInfo.getCreditInfo();
            List<PersonRankInfo> totalKillInfoRank = sortRank(new ArrayList<PersonRankInfo>(creditInfo.values()));
            myRank = getMyRank(player.lord.getLordId(), creditInfo, totalKillInfoRank);


        }

        if (type == 4) {

            ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_ACTIVITY_KING);

            if (activityBase.getBaseOpen() != 1) {
                handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
                return;
            }

            Map<Long, PersonRankInfo> totalKillInfo = globalKingInfo.getTotalKillInfo();
            List<PersonRankInfo> totalKillInfoRank = sortRank(new ArrayList<PersonRankInfo>(totalKillInfo.values()));
            myRank = getMyRank(player.lord.getLordId(), totalKillInfo, totalKillInfoRank);


        }


        if (type == 5) {

            ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_ACTIVITY_KING);

            if (activityBase.getBaseOpen() != 1) {
                handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
                return;
            }

            Member member = partyDataManager.getMemberById(player.lord.getLordId());
            if (member == null) {
                handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
                return;
            }

            String formatTime = DateHelper.formatTime(System.currentTimeMillis(), "yyyyMMdd");

            if (formatTime.equals(member.getEnterTime() + "")) {
                handler.sendErrorMsgToPlayer(GameError.RANK_KING_REWARD);
                return;
            }


            Map<Long, PartyRankInfo> partyInfo = globalKingInfo.getPartyInfo();
            List<PartyRankInfo> partyInfoRank = sortPartyRank(new ArrayList<PartyRankInfo>(partyInfo.values()));
            int partyId = partyDataManager.getPartyId(player.lord.getLordId());
            myRank = getMyPartyRank(partyId, partyInfo, partyInfoRank);

        }

        StaticActKingRank kingRankRewardConfig = staticActivateKingMgr.getKingRankRewardConfig(getAwardId(), type, myRank);

        if (kingRankRewardConfig == null) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }

        kingRankRewardInfo.getRankStatus().put(type, 1);

        GamePb6.GetKingRankAwardRs.Builder builder = GamePb6.GetKingRankAwardRs.newBuilder();

        for (List<Integer> it : kingRankRewardConfig.getAwardList()) {
            int itemType = it.get(0);
            int count = it.get(2);
            int itemId = it.get(1);
            int keyId = playerDataManager.addAward(player, itemType, itemId, count, AwardFrom.KING_RANK_1);
            CommonPb.Award awardPb = PbHelper.createAwardPb(itemType, itemId,count,keyId);
            builder.addAward(awardPb);
        }

        builder.setStatus(kingRankRewardInfo.getRankStatus().get(type));
        handler.sendMsgToPlayer(GamePb6.GetKingRankAwardRs.ext, builder.build());

    }


    /**
     * 领取条件奖励
     *
     * @param rq
     * @param handler
     */
    public void getKingAwardRq(GamePb6.GetKingAwardRq rq, ClientHandler handler) {


        if (!isOpen()) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_FINISYH);
            return;
        }
        Player player = playerDataManager.getPlayer(handler.getRoleId());

        PersonKingInfo globalKingInfo = globalDataManager.gameGlobal.getKingInfo();
        String activateVersion = getActivateVersion();
        if (!activateVersion.equals(globalKingInfo.getVersion())) {
            globalKingInfo.setVersion(activateVersion);
            globalKingInfo.clear();

        }
        KingRankRewardInfo kingRankRewardInfo = player.kingRankRewardInfo;
        if (!activateVersion.equals(kingRankRewardInfo.getVersion())) {
            kingRankRewardInfo.setVersion(activateVersion);
            kingRankRewardInfo.clear();
        }

        StaticKingActAward kingActAwardConfig = staticActivateKingMgr.getKingActAwardConfig(rq.getId());
        if (kingRankRewardInfo.getPointsStatus().containsKey(kingActAwardConfig.getId())) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }

        if (kingActAwardConfig.getAwardId() != getAwardId()) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }


        long cond = 0;


        if (kingActAwardConfig.getType() == 1) {
            Map<Long, PersonRankInfo> killInfo = globalKingInfo.getKillInfo();
            PersonRankInfo personRankInfo = killInfo.get(player.lord.getLordId());
            if (personRankInfo != null) {
                cond = personRankInfo.getPoints();
            }

        }

        if (kingActAwardConfig.getType() == 2) {

            Map<Long, PersonRankInfo> sourceInfo = globalKingInfo.getSourceInfo();
            PersonRankInfo personRankInfo = sourceInfo.get(player.lord.getLordId());
            if (personRankInfo != null) {
                cond = personRankInfo.getPoints();
            }

        }


        if (kingActAwardConfig.getType() == 3) {

            Map<Long, PersonRankInfo> totalKillInfo = globalKingInfo.getCreditInfo();
            PersonRankInfo personRankInfo = totalKillInfo.get(player.lord.getLordId());
            if (personRankInfo != null) {
                cond = personRankInfo.getPoints();
            }

        }


        if (cond < kingActAwardConfig.getCond()) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }

        kingRankRewardInfo.getPointsStatus().put(kingActAwardConfig.getId(), 1);

        GamePb6.GetKingAwardRs.Builder builder = GamePb6.GetKingAwardRs.newBuilder();

        for (List<Integer> it : kingActAwardConfig.getAwardList()) {
            int type = it.get(0);
            int itemId = it.get(1);
            int count = it.get(2);
            int keyId = playerDataManager.addAward(player, type, itemId, count, AwardFrom.KING_RANK_2);
            CommonPb.Award awardPb = PbHelper.createAwardPb(type, itemId,count,keyId);
            builder.addAward(awardPb);
        }

        Map<Integer, Integer> pointsStatus = kingRankRewardInfo.getPointsStatus();
        Set<Map.Entry<Integer, Integer>> entries = pointsStatus.entrySet();
        for (Map.Entry<Integer, Integer> e : entries) {
            builder.addStatus(PbHelper.createTwoIntPb(e.getKey(), e.getValue()));
        }
        handler.sendMsgToPlayer(GamePb6.GetKingAwardRs.ext, builder.build());

    }


    /**
     * 铁，油，铜，水晶，钛
     *
     * @param player
     * @param rs
     */
    public void updataResourceData(Player player, long[] rs) {

        updateData(player, 2, 1, rs[0]);
        updateData(player, 2, 2, rs[1]);
        updateData(player, 2, 3, rs[2]);
        updateData(player, 2, 4, rs[3]);
        updateData(player, 2, 5, rs[4]);
    }

    /**
     * 击杀叛军
     *
     * @param player
     * @param countType 头目，卫队，分队 1 2 3
     * @param count
     */
    public void updataRebelData(Player player, int countType, long count) {

        if (countType < 1 || countType > 3) {
            return;
        }

        updateData(player, 1, countType, count);

    }

    /**
     * @param player
     * @param type      1-击杀叛军 2-采集资源 3-获取军功'
     * @param countType 叛军类型 或者资源类型
     * @param count
     */
    public void updateData(Player player, int type, int countType, long count) {

        try {

            if (count <= 0) {
                return;
            }

            if (!isOpen()) {
                return;
            }

            if (!isOpen(type)) {
                return;
            }

            PersonKingInfo globalKingInfo = globalDataManager.gameGlobal.getKingInfo();

            String activateVersion = getActivateVersion();
            if (!activateVersion.equals(globalKingInfo.getVersion())) {
                globalKingInfo.setVersion(activateVersion);
                globalKingInfo.clear();

            }


            KingRankRewardInfo kingRankRewardInfo = player.kingRankRewardInfo;
            if (!activateVersion.equals(kingRankRewardInfo.getVersion())) {
                kingRankRewardInfo.setVersion(activateVersion);
                kingRankRewardInfo.clear();
            }


            StaticKingActRatio kingActRatioConfig = staticActivateKingMgr.getKingActRatioConfig(type);
            if (kingActRatioConfig == null) {
                return;
            }
            long point = 0;
            //1-叛军榜
            if (kingActRatioConfig.getType() == 1) {
                int val = kingActRatioConfig.getRatio().get(countType - 1);
                point = (long) Math.ceil((count / (val / 10000.0f)));

                if (point <= 0) {
                    return;
                }


                PersonRankInfo killInfo = globalKingInfo.getKillInfo().get(player.lord.getLordId());
                if (killInfo == null) {
                    killInfo = new PersonRankInfo();
                    killInfo.setLordId(player.lord.getLordId());
                    globalKingInfo.getKillInfo().put(player.lord.getLordId(), killInfo);
                }
                killInfo.setTime(System.currentTimeMillis());
                killInfo.setTotalNumber(killInfo.getTotalNumber() + count);
                killInfo.setPoints(killInfo.getPoints() + point);


            }

            // 2-采集资源
            if (kingActRatioConfig.getType() == 2) {
                int val = kingActRatioConfig.getRatio().get(countType - 1);
                point = (long) Math.ceil((count / (val / 10000.0f)));

                if (point <= 0) {
                    return;
                }


                PersonRankInfo sourceInfo = globalKingInfo.getSourceInfo().get(player.lord.getLordId());
                if (sourceInfo == null) {
                    sourceInfo = new PersonRankInfo();
                    sourceInfo.setLordId(player.lord.getLordId());
                    globalKingInfo.getSourceInfo().put(player.lord.getLordId(), sourceInfo);
                }
                sourceInfo.setTime(System.currentTimeMillis());
                sourceInfo.setTotalNumber(sourceInfo.getTotalNumber() + count);
                sourceInfo.setPoints(sourceInfo.getPoints() + point);
            }


            // 3-获取军功
            if (kingActRatioConfig.getType() == 3) {
                int val = kingActRatioConfig.getRatio().get(0);
                point = (long) Math.ceil((count / (val / 10000.0f)));

                if (point <= 0) {
                    return;
                }

                PersonRankInfo creditInfo = globalKingInfo.getCreditInfo().get(player.lord.getLordId());
                if (creditInfo == null) {
                    creditInfo = new PersonRankInfo();
                    creditInfo.setLordId(player.lord.getLordId());
                    globalKingInfo.getCreditInfo().put(player.lord.getLordId(), creditInfo);
                }
                creditInfo.setTime(System.currentTimeMillis());
                creditInfo.setTotalNumber(creditInfo.getTotalNumber() + count);
                creditInfo.setPoints(creditInfo.getPoints() + point);
            }


            //个人总积分榜
            PersonRankInfo personRankInfo = globalKingInfo.getTotalKillInfo().get(player.lord.getLordId());
            if (personRankInfo == null) {
                personRankInfo = new PersonRankInfo();
                personRankInfo.setLordId(player.lord.getLordId());
                globalKingInfo.getTotalKillInfo().put(player.lord.getLordId(), personRankInfo);

            }
            personRankInfo.setTime(System.currentTimeMillis());
            personRankInfo.setTotalNumber(personRankInfo.getTotalNumber() + count);
            personRankInfo.setPoints(personRankInfo.getPoints() + point);


            //军团榜

            int partyId = partyDataManager.getPartyId(player.lord.getLordId());
            if (partyId != 0) {
                PartyRankInfo partyRankInfo = globalKingInfo.getPartyInfo().get((long) partyId);
                if (partyRankInfo == null) {
                    partyRankInfo = new PartyRankInfo();
                    partyRankInfo.setPartyId(partyId);
                    globalKingInfo.getPartyInfo().put((long) partyId, partyRankInfo);
                }
                partyRankInfo.setTime(System.currentTimeMillis());
                partyRankInfo.setPoints(partyRankInfo.getPoints() + point);
            }
        } catch (Exception e) {
            LogUtil.error(e);
        }


    }


    /**
     * 先按照积分排序 在安装时间排序
     *
     * @param infolist
     */
    private List<PersonRankInfo> sortRank(List<PersonRankInfo> infolist) {

        Collections.sort(infolist, new Comparator<PersonRankInfo>() {
            @Override
            public int compare(PersonRankInfo o1, PersonRankInfo o2) {


                long point1 = o1.getPoints();
                long point2 = o2.getPoints();

                if (point1 > point2) {
                    return -1;
                }

                if (point1 < point2) {
                    return 1;
                }

                if (point1 == point2) {
                    long time1 = o1.getTime();
                    long time2 = o2.getTime();
                    if (time1 < time2) {
                        return -1;
                    }
                    if (time1 > time2) {
                        return 1;
                    }

                    return 0;
                }
                return 0;
            }
        });
        return infolist;
    }

    /**
     * 先按照积分排序 在安装时间排序
     *
     * @param infolist
     */
    private List<PartyRankInfo> sortPartyRank(List<PartyRankInfo> infolist) {

        Collections.sort(infolist, new Comparator<PartyRankInfo>() {
            @Override
            public int compare(PartyRankInfo o1, PartyRankInfo o2) {


                long point1 = o1.getPoints();
                long point2 = o2.getPoints();

                if (point1 < point2) {
                    return 1;
                }

                if (point1 > point2) {
                    return -1;
                }

                if (point1 == point2) {
                    long time1 = o1.getTime();
                    long time2 = o2.getTime();

                    if (time1 > time2) {
                        return 1;
                    }
                    if (time1 < time2) {
                        return -1;
                    }
                    return 0;
                }
                return 0;
            }
        });
        return infolist;
    }


    /**
     * 获取活动版本号 更具活动开始时间 活动开始时间变了 版本号就变了
     *
     * @return
     */
    private String getActivateVersion() {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_ACTIVITY_KING);
        if (activityBase == null) {
            return null;
        }
        return DateHelper.formatDateTime(activityBase.getBeginTime(), "yyyy-MM-dd");
    }


    public boolean isOpen() {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_ACTIVITY_KING);
        if (activityBase == null) {
            return false;
        }
        return true;
    }

    /**
     * 活动是否开启
     *
     * @param activityType 1-击杀叛军 2-采集资源 3-获取军功'
     * @return
     */
    public boolean isOpen(int activityType) {
        long[] openTime = getOpenTime(activityType);

        if (System.currentTimeMillis() > openTime[0] && System.currentTimeMillis() < openTime[1]) {
            return true;
        }
        return false;
    }

    /**
     * 获取活动开始介绍时间
     *
     * @param activityType
     * @return
     */
    private long[] getOpenTime(int activityType) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_ACTIVITY_KING);

        if (activityBase == null) {
            return new long[]{0, 0};

        }

        StaticKingActRatio kingActRatioConfig = staticActivateKingMgr.getKingActRatioConfig(activityType);

        Calendar calendar = Calendar.getInstance();
        calendar.setTimeInMillis(activityBase.getBeginTime().getTime());
        calendar.add(Calendar.DAY_OF_YEAR, kingActRatioConfig.getDate());

        long endTime = calendar.getTimeInMillis();
        if (endTime > activityBase.getEndTime().getTime()) {
            endTime = activityBase.getEndTime().getTime();
        }

        calendar.add(Calendar.DAY_OF_YEAR, -3);

        long startTime = calendar.getTimeInMillis();
        if (startTime < activityBase.getBeginTime().getTime()) {
            startTime = activityBase.getBeginTime().getTime();
        }
        return new long[]{startTime, endTime};
    }

    /**
     * 获取活动奖励id
     *
     * @return
     */
    private int getAwardId() {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_ACTIVITY_KING);
        if (activityBase == null) {
            return 0;
        }
        return activityBase.getPlan().getAwardId();
    }


    /**
     * 初始化排行榜
     */
    public void gmRank() {
        Map<Long, Player> players = playerDataManager.getPlayers();
        for (Player player : players.values()) {
            updateData(player, 2, 1, new Random().nextInt(1000000));
            updateData(player, 2, 2, new Random().nextInt(1000000));
            updateData(player, 2, 3, new Random().nextInt(1000000));
            updateData(player, 2, 4, new Random().nextInt(1000000));
            updateData(player, 2, 5, new Random().nextInt(1000000));
            updateData(player, 1, 3, new Random().nextInt(100));
            updateData(player, 3, 0, new Random().nextInt(1000000));

        }

    }

    /**
     * 清空排行榜
     */
    public void gmClearRank() {
        PersonKingInfo globalKingInfo = globalDataManager.gameGlobal.getKingInfo();
        globalKingInfo.clear();
        Map<Long, Player> players = playerDataManager.getPlayers();
        for (Player player : players.values()) {
            player.kingRankRewardInfo.clear();
        }
    }

    /**
     * 设置单个排行积分
     *
     * @param player
     * @param type
     * @param point
     */
    public void gmSetRank(Player player, int type, int point) {

        PersonKingInfo globalKingInfo = globalDataManager.gameGlobal.getKingInfo();

        String activateVersion = getActivateVersion();
        if (!activateVersion.equals(globalKingInfo.getVersion())) {
            globalKingInfo.setVersion(activateVersion);
            globalKingInfo.clear();

        }


        KingRankRewardInfo kingRankRewardInfo = player.kingRankRewardInfo;
        if (!activateVersion.equals(kingRankRewardInfo.getVersion())) {
            kingRankRewardInfo.setVersion(activateVersion);
            kingRankRewardInfo.clear();
        }


        //1-叛军榜
        if (type == 1) {

            PersonRankInfo killInfo = globalKingInfo.getKillInfo().get(player.lord.getLordId());
            if (killInfo == null) {
                killInfo = new PersonRankInfo();
                killInfo.setLordId(player.lord.getLordId());
                globalKingInfo.getKillInfo().put(player.lord.getLordId(), killInfo);
            }
            killInfo.setTime(System.currentTimeMillis());
            killInfo.setTotalNumber(killInfo.getTotalNumber() + point);
            killInfo.setPoints(killInfo.getPoints() + point);


        }

        // 2-采集资源
        if (type == 2) {


            PersonRankInfo sourceInfo = globalKingInfo.getSourceInfo().get(player.lord.getLordId());
            if (sourceInfo == null) {
                sourceInfo = new PersonRankInfo();
                sourceInfo.setLordId(player.lord.getLordId());
                globalKingInfo.getSourceInfo().put(player.lord.getLordId(), sourceInfo);
            }
            sourceInfo.setTime(System.currentTimeMillis());
            sourceInfo.setTotalNumber(sourceInfo.getTotalNumber() + point);
            sourceInfo.setPoints(sourceInfo.getPoints() + point);
        }


        // 3-获取军功
        if (type == 3) {

            PersonRankInfo creditInfo = globalKingInfo.getCreditInfo().get(player.lord.getLordId());
            if (creditInfo == null) {
                creditInfo = new PersonRankInfo();
                creditInfo.setLordId(player.lord.getLordId());
                globalKingInfo.getCreditInfo().put(player.lord.getLordId(), creditInfo);
            }
            creditInfo.setTime(System.currentTimeMillis());
            creditInfo.setTotalNumber(creditInfo.getTotalNumber() + point);
            creditInfo.setPoints(creditInfo.getPoints() + point);
        }

        if (type == 4) {

            //个人总积分榜
            PersonRankInfo personRankInfo = globalKingInfo.getTotalKillInfo().get(player.lord.getLordId());
            if (personRankInfo == null) {
                personRankInfo = new PersonRankInfo();
                personRankInfo.setLordId(player.lord.getLordId());
                globalKingInfo.getTotalKillInfo().put(player.lord.getLordId(), personRankInfo);

            }
            personRankInfo.setTime(System.currentTimeMillis());
            personRankInfo.setTotalNumber(personRankInfo.getTotalNumber() + point);
            personRankInfo.setPoints(personRankInfo.getPoints() + point);

        }
        if (type == 5) {
            //军团榜
            int partyId = partyDataManager.getPartyId(player.lord.getLordId());
            if (partyId != 0) {
                PartyRankInfo partyRankInfo = globalKingInfo.getPartyInfo().get((long) partyId);
                if (partyRankInfo == null) {
                    partyRankInfo = new PartyRankInfo();
                    partyRankInfo.setPartyId(partyId);
                    globalKingInfo.getPartyInfo().put((long) partyId, partyRankInfo);
                }
                partyRankInfo.setTime(System.currentTimeMillis());
                partyRankInfo.setPoints(partyRankInfo.getPoints() + point);
            }
        }


    }
}
