package com.game.service.activity.simple;

import com.game.constant.ActivityConst;
import com.game.constant.GameError;
import com.game.constant.LotteryCost;
import com.game.dataMgr.StaticActivityDataMgr;
import com.game.domain.ActivityBase;
import com.game.domain.Player;
import com.game.domain.p.Activity;
import com.game.domain.s.StaticActAward;
import com.game.manager.ActivityDataManager;
import com.game.manager.PlayerDataManager;
import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5;
import com.game.util.LogUtil;
import com.game.util.PbHelper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * @author zhangdh
 * @ClassName: ActLotteryExploreService
 * @Description: 探宝积分活动
 * @date 2018-01-31 9:44
 */
@Service
public class ActLotteryExploreService {
    @Autowired
    private PlayerDataManager playerDataManager;

    @Autowired
    private StaticActivityDataMgr staticActivityDataMgr;

    @Autowired
    private ActivityDataManager activityDataManager;


    public void getActLotteryExplore(GamePb5.GetActLotteryExploreRq req, ClientHandler handler) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_LOTTERY_EXPLORE);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        Player player = playerDataManager.getPlayer(handler.getRoleId());
        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_LOTTERY_EXPLORE);
        //奖励领取信息
        int activityKeyId = activityBase.getKeyId();
        GamePb5.GetActLotteryExploreRs.Builder builder = GamePb5.GetActLotteryExploreRs.newBuilder();
        List<Long> statusList = activity.getStatusList();
        builder.setScore(statusList.isEmpty() ? 0 : statusList.get(0).intValue());
        List<StaticActAward> condList = staticActivityDataMgr.getActAwardById(activityKeyId);
        for (StaticActAward e : condList) {
            int keyId = e.getKeyId();
            if (activity.getStatusMap().containsKey(keyId)) {// 已领取奖励
                builder.addCond(PbHelper.createActivityCondPb(e, 1));
            } else {// 未领取奖励
                builder.addCond(PbHelper.createActivityCondPb(e, 0));
            }
        }

        handler.sendMsgToPlayer(GamePb5.GetActLotteryExploreRs.ext, builder.build());
    }

    public void onLotteryExploreActivity(Player player, int type) {
        try {
            long addScore = type == LotteryCost.EXPLORE_SINGLE ? 1 : type == LotteryCost.EXPLORE_THREE ? 3 : 0;
            if (addScore > 0) {
                ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_LOTTERY_EXPLORE);
                if (activityBase != null) {
                    Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_LOTTERY_EXPLORE);
                    List<Long> statusList = activity.getStatusList();
                    if (statusList.isEmpty()) {
                        statusList.add(addScore);
                    } else {
                        long scroe = statusList.get(0);
                        statusList.set(0, scroe + addScore);
                    }
                }
            }
        } catch (Exception e) {
            LogUtil.error("", e);
        }
    }

}
