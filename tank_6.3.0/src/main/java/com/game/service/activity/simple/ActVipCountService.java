package com.game.service.activity.simple;

import com.game.constant.ActivityConst;
import com.game.constant.GameError;
import com.game.constant.SysChatId;
import com.game.dataMgr.StaticActivityDataMgr;
import com.game.dataMgr.activity.simple.StaticActVipDataMgr;
import com.game.domain.ActivityBase;
import com.game.domain.Player;
import com.game.domain.UsualActivityData;
import com.game.domain.p.Activity;
import com.game.domain.s.StaticActAward;
import com.game.domain.s.StaticActVipCount;
import com.game.manager.ActivityDataManager;
import com.game.manager.PlayerDataManager;
import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5;
import com.game.service.ChatService;
import com.game.util.LogUtil;
import com.game.util.PbHelper;
import com.game.util.StringHelper;
import com.game.util.TimeHelper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * @author zhangdh
 * @ClassName: ActVipCountService
 * @Description:
 * @date 2018-01-17 14:12
 */
@Service
public class ActVipCountService {

    @Autowired
    private StaticActivityDataMgr staticActivityDataMgr;
    @Autowired
    private StaticActVipDataMgr staticActVipDataMgr;

    @Autowired
    private ActivityDataManager activityDataManager;
    @Autowired
    private PlayerDataManager playerDataManager;

    @Autowired
    private ChatService chatService;

    public void activityTimeLogic() {
        try {
            ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_VIP_COUNT);
            if (activityBase == null) {
                return;
            }

            UsualActivityData usualActivity = activityDataManager.getUsualActivity(ActivityConst.ACT_VIP_COUNT);
            Map<Integer, Integer> statusMap = usualActivity.getStatusMap();
            Map<Integer, Integer> saveMap = usualActivity.getSaveMap();
            Set<Integer> vipChatSet = StringHelper.string2IntSet(usualActivity.getParams());
            //活动刚开启时处理所有VIP玩家
            if (statusMap.isEmpty() && saveMap.isEmpty()) {
                for (Map.Entry<Long, Player> entry : playerDataManager.getPlayers().entrySet()) {
                    Player player = entry.getValue();
                    int vip = player.lord != null ? player.lord.getVip() : 0;
                    if (vip > 0) {
                        for (int i = 1; i <= vip; i++) {
                            Integer cnt = statusMap.get(i);
                            statusMap.put(i, 1 + (cnt != null ? cnt : 0));
                        }
                    }
                }
                for (Map.Entry<Integer, Integer> entry : statusMap.entrySet()) {
                    checkAndSendWorldChat(activityBase, usualActivity, vipChatSet, entry.getKey(), 0, entry.getValue());
                }
            }

            //vip人数活动,自增处理
            int nowSec = TimeHelper.getCurrentSecond();
            //每隔一段时间
            Map<Integer, StaticActVipCount> dataMap = staticActVipDataMgr.getActVipCountMap(activityBase.getKeyId());
            if (dataMap == null) return;
            List<StaticActAward> awardList = staticActivityDataMgr.getActAwardById(activityBase.getKeyId());
            if (awardList == null || awardList.isEmpty()) return;
            for (Map.Entry<Integer, StaticActVipCount> entry : dataMap.entrySet()) {
                //VIP等级
                StaticActVipCount data = entry.getValue();
                int vip = data.getVip();//VIP等级
                int incSec = data.getIncSec(); //自增时间间隔单位分
                int incCnt = data.getIncCnt();//自增数量
                if (data.getIncCnt() >= 0 && incCnt >= 0) {
                    //上一次增加的时间
                    Integer lastIncSec = saveMap.get(vip);
                    if (lastIncSec == null) {
                        saveMap.put(vip, nowSec);
                    } else {
                        int subSec = nowSec - lastIncSec;
                        if (subSec >= incSec) {
                            //当前达到此VIP的玩家数量
                            Integer oldCount = statusMap.get(vip);
                            oldCount = oldCount != null ? oldCount : 0;
                            for (StaticActAward staticActAward : awardList) {
                                int awardVip = staticActAward.getSortId();
                                //只有小于完成条件所需的数量才会自增
                                if (awardVip == vip && oldCount < staticActAward.getCond()) {
                                    int curCount = oldCount + incCnt;
                                    statusMap.put(vip, curCount);
                                    saveMap.put(vip, nowSec);
                                    checkAndSendWorldChat(activityBase, usualActivity, vipChatSet, vip, oldCount, curCount);
                                }
                            }
                        }
                    }
                }
            }
            usualActivity.setParams(StringHelper.collectionInt2String(vipChatSet));
//            LogUtil.error("status map : " + statusMap.toString());
//            LogUtil.error("chat set : " + usualActivity.getParams());
        } catch (Exception e) {
            LogUtil.error("", e);
        }
    }

    public void getActVipCountInfo(GamePb5.GetActVipCountInfoRq req, ClientHandler handler) {

        Player player = playerDataManager.getPlayer(handler.getRoleId());
        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_VIP_COUNT);

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

        UsualActivityData usualActivity = activityDataManager.getUsualActivity(ActivityConst.ACT_VIP_COUNT);
        if (usualActivity == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        //奖励领取信息
        int activityKeyId = activityBase.getKeyId();
        GamePb5.GetActVipCountInfoRs.Builder builder = GamePb5.GetActVipCountInfoRs.newBuilder();
        List<StaticActAward> condList = staticActivityDataMgr.getActAwardById(activityKeyId);
        Map<Integer, Integer> statusMap = usualActivity.getStatusMap();
        for (Map.Entry<Integer, Integer> entry : statusMap.entrySet()) {
            builder.addTwoInt(PbHelper.createTwoIntPb(entry.getKey(), entry.getValue()));
        }
        for (StaticActAward e : condList) {
            int keyId = e.getKeyId();
            if (activity.getStatusMap().containsKey(keyId)) {// 已领取奖励
                builder.addCond(PbHelper.createActivityCondPb(e, 1));
            } else {// 未领取奖励
                builder.addCond(PbHelper.createActivityCondPb(e, 0));
            }
        }
        handler.sendMsgToPlayer(GamePb5.GetActVipCountInfoRs.ext, builder.build());
    }

    public void onPlayerVipLevelUp(Player player, int oldLv, int newLv) {
        if (oldLv >= newLv) return;
//        LogUtil.error(String.format("nick :%s, old vip :%d, new vip :%d", player.lord.getNick(), oldLv, newLv));
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_VIP_COUNT);
        if (activityBase == null) return;
        UsualActivityData usualActivity = activityDataManager.getUsualActivity(ActivityConst.ACT_VIP_COUNT);
        if (usualActivity == null) return;
        Map<Integer, Integer> statusMap = usualActivity.getStatusMap();
        Set<Integer> vipChatSet = StringHelper.string2IntSet(usualActivity.getParams());
        for (int i = oldLv + 1; i <= newLv; i++) {
            int oldCount = statusMap.containsKey(i) ? statusMap.get(i) : 0;
            int count = 1 + oldCount;
            statusMap.put(i, count);
//            LogUtil.error(String.format("status map :%s, vip chat set :%s, vip :%d, oldCount :%d, new Count :%d", statusMap, Arrays.toString(vipChatSet.toArray()), i, oldCount, count));
            checkAndSendWorldChat(activityBase, usualActivity, vipChatSet, i, oldCount, count);
        }
        usualActivity.setParams(StringHelper.collectionInt2String(vipChatSet));
//        LogUtil.error("chat set : " + usualActivity.getParams());
    }


    /**
     * VIP达成数量发生变化时判断并发送广播
     *
     * @param activityBase
     * @param usualActivity
     * @param vipChatSet
     * @param vip
     * @param oldCount
     * @param count
     */
    private void checkAndSendWorldChat(ActivityBase activityBase, UsualActivityData usualActivity, Set<Integer> vipChatSet, int vip, int oldCount, int count) {
        if (!vipChatSet.contains(vip)) {
            List<StaticActAward> awardList = staticActivityDataMgr.getActAwardById(activityBase.getKeyId());
            int finishCount = getAwardFinishCond(awardList, vip);
            if (finishCount <= 0) return;
            if (count >= finishCount) {
                chatService.sendWorldChat(chatService.createSysChat(SysChatId.VIP_COUNT_FINISH, String.valueOf(vip)));
//                LogUtil.error(String.format("activity id :%d, vip :%d chat finish", activityBase.getActivityId(), vip));
                vipChatSet.add(vip);
            } else {
                //VIP人数不足
                Map<Integer, StaticActVipCount> vipMap = staticActVipDataMgr.getActVipCountMap(activityBase.getKeyId());
                StaticActVipCount vipData = vipMap != null ? vipMap.get(vip) : null;
                if (vipData != null) {
                    //如果VIP人数一次增加太多，则只广播最大人数的那一条
                    List<Integer> list = vipData.getNotFinishCnt();
                    if (list != null && !list.isEmpty()) {
                        for (int i = list.size() - 1; i >= 0; i--) {
                            int cnt = list.get(i);
                            if (oldCount < cnt && cnt <= count) {
                                chatService.sendWorldChat(chatService.createSysChat(SysChatId.VIP_COUNT_NOT_FINISH, String.valueOf(vip), String.valueOf(finishCount - cnt)));
                                break;
                            }
                        }
                    }
                }
            }
        }
    }

    private int getAwardFinishCond(List<StaticActAward> awardList, int vip) {
        for (StaticActAward staticActAward : awardList) {
            if (staticActAward.getSortId() == vip) {
                return staticActAward.getCond();
            }
        }
        return -1;
    }
}
