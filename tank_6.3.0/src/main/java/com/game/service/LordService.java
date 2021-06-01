package com.game.service;

import com.game.actor.rank.RankEventService;
import com.game.actor.role.PlayerEventService;
import com.game.constant.AwardFrom;
import com.game.constant.GameError;
import com.game.dataMgr.StaticFunctionPlanDataMgr;
import com.game.dataMgr.StaticLordDataMgr;
import com.game.domain.Player;
import com.game.domain.p.Lord;
import com.game.domain.s.StaticMilitaryRank;
import com.game.manager.PlayerDataManager;
import com.game.manager.RankDataManager;
import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * @author zhangdh
 * @ClassName: LordService
 * @Description: 改变Lord属性的逻辑
 * @date 2017-05-26 13:54
 */
@Service
public class LordService {

    @Autowired
    private PlayerDataManager playerDataManager;

    @Autowired
    private StaticLordDataMgr staticLordDataMgr;

    @Autowired
    private RankDataManager rankDataManager;

    @Autowired
    private RankEventService rankEventService;

    @Autowired
    private PlayerEventService playerEventService;

    @Autowired
    private StaticFunctionPlanDataMgr staticFunctionPlanDataMgr;

    /**
     * 获取玩家军衔相关信息
     *
     * @param handler
     */
    public void getMilitaryRankInfo(ClientHandler handler) {
        if (!staticFunctionPlanDataMgr.isMilitaryRankOpen()) return;
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        Lord lord = player.lord;
        GamePb5.GetMilitaryRankRs.Builder builder = GamePb5.GetMilitaryRankRs.newBuilder();
        builder.setMilitaryRank(lord.getMilitaryRank());
        builder.setMilitaryExploit(lord.getMilitaryExploit());
        builder.setSortRank(rankDataManager.getMilitaryRankSort(lord) + 1);
        builder.setMpltGotToday(playerDataManager.getMpltGetToday(lord));
        handler.sendMsgToPlayer(GamePb5.GetMilitaryRankRs.ext, builder.build());
    }

    /**
     * 升级军衔
     *
     * @param handler
     */
    public void upMilitaryRank(ClientHandler handler) {
        if (!staticFunctionPlanDataMgr.isMilitaryRankOpen()) return;
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        int mrId = player.lord.getMilitaryRank();
        if (staticLordDataMgr.isMaxMilitaryRank(mrId)) {
            handler.sendErrorMsgToPlayer(GameError.MILITARY_RANK_MAX_ERROR);
            return;
        }
        StaticMilitaryRank data = staticLordDataMgr.getHigherMilitaryRank(mrId);
        if (data == null || data.getLordLv() > player.lord.getLevel()) {
            handler.sendErrorMsgToPlayer(GameError.STATIC_DATA_NOT_FOUND);
            return;
        }
        List<List<Integer>> upCost = data.getUpCost();
        if (upCost == null || upCost.isEmpty()) {
            handler.sendErrorMsgToPlayer(GameError.STATIC_DATA_ERROR);
            return;
        }

        //资源是否足够判断
        for (List<Integer> list : upCost) {
            if (!playerDataManager.checkPropIsEnougth(player, list.get(0), list.get(1), list.get(2))) {
                handler.sendErrorMsgToPlayer(GameError.RESOURCE_NOT_ENOUGH);
                return;
            }
        }

        //扣除资源
        for (List<Integer> list : upCost) {
            playerDataManager.subProp(player, list.get(0), list.get(1), list.get(2), AwardFrom.UP_MILITARY_RANK);
        }

        player.lord.setMilitaryRank(data.getId());
        player.lord.setMilitaryRankUpTime(System.currentTimeMillis());
        rankEventService.upsertMilitaryRankSort(player);//更新排名
        playerEventService.calcStrongestFormAndFight(player);//重新计算玩家最强实力
        rankDataManager.upStrongestFormRankSortInfo(player.lord);//更新玩家最强战力排名
        GamePb5.UpMilitaryRankRs.Builder builder = GamePb5.UpMilitaryRankRs.newBuilder();
        builder.setMilitaryRank(player.lord.getMilitaryRank());
        builder.setMilitaryExploit(player.lord.getMilitaryExploit());
        builder.setCurRank(rankDataManager.getMilitaryRankSort(player.lord) + 1);
        handler.sendMsgToPlayer(GamePb5.UpMilitaryRankRs.ext, builder.build());
    }

}

