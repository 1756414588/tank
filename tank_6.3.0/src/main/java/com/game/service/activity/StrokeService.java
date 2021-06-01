package com.game.service.activity;

import com.game.constant.ActivityConst;
import com.game.constant.AwardFrom;
import com.game.constant.GameError;
import com.game.dataMgr.StaticActivityDataMgr;
import com.game.dataMgr.activity.simple.StaticActStrokeDataMgr;
import com.game.domain.ActivityBase;
import com.game.domain.Player;
import com.game.domain.p.Activity;
import com.game.domain.s.StaticActStroke;
import com.game.manager.ActivityDataManager;
import com.game.manager.PlayerDataManager;
import com.game.message.handler.ClientHandler;
import com.game.pb.CommonPb;
import com.game.pb.GamePb5;
import com.game.util.TimeHelper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

/**
 * @author zhangdh
 * @ClassName: OpenServerAwardService
 * @Description: 闪击行动(开服奖励)
 * @date 2018-01-15 14:01
 */
@Service
public class StrokeService {

    @Autowired
    private PlayerDataManager playerDataManager;

    @Autowired
    private ActivityDataManager activityDataManager;

    @Autowired
    private StaticActStrokeDataMgr staticActStrokeDataMgr;

    @Autowired
    private StaticActivityDataMgr staticActivityDataMgr;

    /**
     * 获取闪击行动信息
     *
     * @param req
     * @param handler
     */
    public void getActStrokeRq(GamePb5.GetActStrokeRq req, ClientHandler handler) {
        GamePb5.GetActStrokeRs.Builder builder = GamePb5.GetActStrokeRs.newBuilder();
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_STROKE);
        if (activity == null) {
            builder.setActivityId(0);
        } else {
            ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_STROKE);
            builder.setActivityId(activityBase.getKeyId());
            builder.setBeginTime((int) (activityBase.getBeginTime().getTime() / 1000));
            builder.setEndTime((int) (activityBase.getEndTime().getTime() / 1000));
            builder.setServerTime(TimeHelper.getCurrentSecond());
            Map<Integer, Integer> statusMap = activity.getStatusMap();
            if (!statusMap.isEmpty()) {
                builder.addAllId(statusMap.keySet());
            }
        }
        handler.sendMsgToPlayer(GamePb5.GetActStrokeRs.ext, builder.build());
    }

    /**
     * 领取闪击行动奖励
     *
     * @param req
     * @param handler
     */
    public void drawActStrokeAward(GamePb5.DrawActStrokeAwardRq req, ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_STROKE);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_STROKE);
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        int id = req.getId();

        //已经领取过奖励
        if (activity.getStatusMap().containsKey(req.getId())) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_GOT);
            return;
        }

        Map<Integer, StaticActStroke> dataMap = staticActStrokeDataMgr.getStaticActStroke(activityBase.getKeyId());
        StaticActStroke data = dataMap != null ? dataMap.get(id) : null;
        if (data == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }
        int nowSec = TimeHelper.getCurrentSecond();
        int startSec = (int) (activityBase.getBeginTime().getTime() / 1000);
        if (nowSec - startSec < data.getPeriod()) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_FINISH);
            return;
        }
        //获得奖励
        activity.getStatusMap().put(data.getId(), nowSec);
        List<CommonPb.Award> awards = playerDataManager.addAwardsBackPb(player, data.getAward(), AwardFrom.DRAW_ACT_STROKE);
        GamePb5.DrawActStrokeAwardRs.Builder builder = GamePb5.DrawActStrokeAwardRs.newBuilder();
        builder.setId(id);
        if (awards != null) {
            builder.addAllAward(awards);
        }
        handler.sendMsgToPlayer(GamePb5.DrawActStrokeAwardRs.ext, builder.build());
    }

}
