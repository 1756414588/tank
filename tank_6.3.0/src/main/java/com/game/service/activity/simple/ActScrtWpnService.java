package com.game.service.activity.simple;

import com.game.constant.ActivityConst;
import com.game.constant.GameError;
import com.game.dataMgr.StaticActivityDataMgr;
import com.game.domain.ActivityBase;
import com.game.domain.Player;
import com.game.domain.p.Activity;
import com.game.domain.s.StaticActAward;
import com.game.manager.ActivityDataManager;
import com.game.manager.PlayerDataManager;
import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5;
import com.game.util.PbHelper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * @author zhangdh
 * @ClassName: ActScrtWpnService
 * @Description: 秘密武器活动
 * @date 2017-12-19 11:58
 */
@Service
public class ActScrtWpnService {

    @Autowired
    private ActivityDataManager activityDataManager;

    @Autowired
    private StaticActivityDataMgr staticActivityDataMgr;

    @Autowired
    private PlayerDataManager playerDataManager;


    /**
     * 
    * 秘密武器洗练次数奖励面板
    * @param req
    * @param handler  
    * void
     */

    public void getActScrtWpnStdCntRq(GamePb5.GetActScrtWpnStdCntRq req, ClientHandler handler) {

        Player player = playerDataManager.getPlayer(handler.getRoleId());
        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_SECRET_STUDY_COUNT);

        //活动未开启
        if (activity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        ActivityBase activityBase = staticActivityDataMgr.getActivityById(activity.getActivityId());
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        //奖励领取信息
        int activityKeyId = activityBase.getKeyId();
        GamePb5.GetActScrtWpnStdCntRs.Builder builder = GamePb5.GetActScrtWpnStdCntRs.newBuilder();
        Long cnt = activity.getStatusList().get(0);
        builder.setCnt(cnt != null ? cnt.intValue() : 0);
        List<StaticActAward> condList = staticActivityDataMgr.getActAwardById(activityKeyId);
        for (StaticActAward e : condList) {
            int keyId = e.getKeyId();
            if (activity.getStatusMap().containsKey(keyId)) {// 已领取奖励
                builder.addCond(PbHelper.createActivityCondPb(e, 1));
            } else {// 未领取奖励
                builder.addCond(PbHelper.createActivityCondPb(e, 0));
            }
        }
        handler.sendMsgToPlayer(GamePb5.GetActScrtWpnStdCntRs.ext, builder.build());
    }
}
