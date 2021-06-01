package com.game.service.activity;

import com.game.constant.*;
import com.game.dataMgr.StaticActivityDataMgr;
import com.game.dataMgr.activity.StaticActRedBagDataMgr;
import com.game.domain.*;
import com.game.domain.p.Activity;
import com.game.domain.s.StaticActRedBag;
import com.game.domain.s.StaticActivityProp;
import com.game.domain.sort.ActRedBag;
import com.game.domain.sort.GrabRedBag;
import com.game.manager.ActivityDataManager;
import com.game.manager.PartyDataManager;
import com.game.manager.PlayerDataManager;
import com.game.message.handler.ClientHandler;
import com.game.pb.CommonPb;
import com.game.pb.GamePb5;
import com.game.service.ChatService;
import com.game.util.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.*;

/**
 * @author zhangdh
 * @ClassName: GrabRedBagsService
 * @Description: 抢红包活动
 * @date 2018-01-31 10:53
 */
@Service
public class ActRedBagsService {
    @Autowired
    private PlayerDataManager playerDataManager;

    @Autowired
    private ActivityDataManager activityDataManager;

    @Autowired
    private StaticActivityDataMgr staticActivityDataMgr;

    @Autowired
    private StaticActRedBagDataMgr staticActRedBagDataMgr;

    @Autowired
    private PartyDataManager partyDataManager;

    @Autowired
    private ChatService chatService;


    /**
     * 获取红包活动信息
     *
     * @param req
     * @param handler
     */
    public void getActRedBagInfo(GamePb5.GetActRedBagInfoRq req, ClientHandler handler) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_GRAB_RED_BAGS);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        //等级限制
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        int minLv = activityBase.getStaticActivity().getMinLv();
        if (player.lord.getLevel() < minLv) {
            handler.sendErrorMsgToPlayer(GameError.LV_NOT_ENOUGH);
            return;
        }


        UsualActivityData usualActivity = activityDataManager.getUsualActivity(ActivityConst.ACT_GRAB_RED_BAGS);
        String params = usualActivity.getParams();
        int money = params != null && params.length() > 0 ? Integer.parseInt(params) : 0;
        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_GRAB_RED_BAGS);
        Map<Integer, Integer> statusMap = activity.getStatusMap();
        GamePb5.GetActRedBagInfoRs.Builder builder = GamePb5.GetActRedBagInfoRs.newBuilder();
        builder.setActivityId(activityBase.getKeyId());
        builder.setMoney(money);
        if (!statusMap.isEmpty()) {
            builder.addAllStage(statusMap.keySet());
        }
        for (Map.Entry<Integer, Integer> entry : activity.getPropMap().entrySet()) {
            builder.addProp(PbHelper.createAtom2Pb(AwardType.ACTIVITY_PROP, entry.getKey(), entry.getValue()));
        }

        TreeMap<Integer, ActRedBag> redBags = usualActivity.getRedBags();
        //清除过期红包
        checkAndClearExpire(redBags);

        //发送最后10个红包到世界频道
        Member meber = partyDataManager.getMemberById(player.roleId);
        int partyId = meber != null ? meber.getPartyId() : 0;
        int worldChatCnt = 0, partyChatCnt = 0;
        for (Map.Entry<Integer, ActRedBag> entry : redBags.descendingMap().entrySet()) {
            ActRedBag arb = entry.getValue();
            if (arb.getPartyId() == 0) {
                if (worldChatCnt < 10) {//世界聊天频道最多显示10个世界频道红包
                    Player sender = playerDataManager.getPlayer(arb.getLordId());
                    builder.addWorldChat(PbHelper.createRedBagChat(sender, arb));
                    worldChatCnt++;
                }
            } else {
                if (partyChatCnt < 10) {//军团聊天频道最多显示10个军团红包
                    if (partyId == arb.getPartyId()) {
                        Player sender = playerDataManager.getPlayer(arb.getLordId());
                        builder.addPartyChat(PbHelper.createRedBagChat(sender, arb));
                        partyChatCnt++;
                    }

                }
            }
            if (worldChatCnt >= 10 && partyChatCnt >= 10) {
                break;
            }
        }

        handler.sendMsgToPlayer(GamePb5.GetActRedBagInfoRs.ext, builder.build());
    }

    /**
     * 领取充值红包阶段奖励
     *
     * @param req
     * @param handler
     */
    public void drawActRedBagStageAward(GamePb5.DrawActRedBagStageAwardRq req, ClientHandler handler) {
        if (req.getStage() <= 0 || req.getStage() > 20) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_GRAB_RED_BAGS);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        //等级限制
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        int minLv = activityBase.getStaticActivity().getMinLv();
        if (player.lord.getLevel() < minLv) {
            handler.sendErrorMsgToPlayer(GameError.LV_NOT_ENOUGH);
            return;
        }

        //活动未配置
        TreeMap<Integer, StaticActRedBag> dataMap = staticActRedBagDataMgr.getStageMap(activityBase.getKeyId());
        StaticActRedBag data = dataMap != null ? dataMap.get(req.getStage()) : null;
        List<List<Integer>> awards = data != null ? data.getAwards() : null;
        if (awards == null || awards.isEmpty()) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }

        //已经领取过该奖励
        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_GRAB_RED_BAGS);
        Map<Integer, Integer> statusMap = activity.getStatusMap();
        if (statusMap.containsKey(req.getStage())) {
            handler.sendErrorMsgToPlayer(GameError.AWARD_HAD_GOT);
            return;
        }

        //充值未完成
        UsualActivityData usualActivity = activityDataManager.getUsualActivity(ActivityConst.ACT_GRAB_RED_BAGS);
        String params = usualActivity.getParams();
        int money = params != null && params.length() > 0 ? Integer.parseInt(params) : 0;
        if (money < data.getMoney()) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }

        //记录领取信息
        statusMap.put(req.getStage(), 1);
        //给予奖励
        List<CommonPb.Award> pbAwards = playerDataManager.addAwardsBackPb(player, awards, AwardFrom.DRAW_ACT_RED_BAG_STAGE_AWARD);

        GamePb5.DrawActRedBagStageAwardRs.Builder builder = GamePb5.DrawActRedBagStageAwardRs.newBuilder();
        builder.addAllAward(pbAwards);

        handler.sendMsgToPlayer(GamePb5.DrawActRedBagStageAwardRs.ext, builder.build());
    }

    /**
     * 获取红包列表
     *
     * @param req
     * @param handler
     */
    public void getActRedBagList(GamePb5.GetActRedBagListRq req, ClientHandler handler) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_GRAB_RED_BAGS);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        //等级限制
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        int minLv = activityBase.getStaticActivity().getMinLv();
        if (player.lord.getLevel() < minLv) {
            handler.sendErrorMsgToPlayer(GameError.LV_NOT_ENOUGH);
            return;
        }

        UsualActivityData usualActivity = activityDataManager.getUsualActivity(ActivityConst.ACT_GRAB_RED_BAGS);
        TreeMap<Integer, ActRedBag> redBags = usualActivity.getRedBags();
        GamePb5.GetActRedBagListRs.Builder builder = GamePb5.GetActRedBagListRs.newBuilder();
        for (Map.Entry<Integer, ActRedBag> entry : redBags.entrySet()) {
            ActRedBag arb = entry.getValue();
            //军团限制
            if (arb.getPartyId() > 0) {
                Member member = partyDataManager.getMemberById(player.roleId);
                if (member == null || member.getPartyId() != arb.getPartyId()) {
                    continue;
                }
            }
            builder.addRedBag(createRedBagSummaryBuilder(player, arb));
        }
        handler.sendMsgToPlayer(GamePb5.GetActRedBagListRs.ext, builder.build());
    }

    /**
     * 抢红包
     *
     * @param req
     * @param handler
     */
    public void grabRedBag(GamePb5.GrabRedBagRq req, ClientHandler handler) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_GRAB_RED_BAGS);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        //等级限制
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player.lord.getLevel() < activityBase.getStaticActivity().getMinLv()) {
            handler.sendErrorMsgToPlayer(GameError.LV_NOT_ENOUGH);
            return;
        }

        //红包不存在
        UsualActivityData usualActivity = activityDataManager.getUsualActivity(ActivityConst.ACT_GRAB_RED_BAGS);
        Map<Integer, ActRedBag> redBags = usualActivity.getRedBags();
        ActRedBag arb = redBags.get(req.getUid());
        if (arb == null) {
            handler.sendErrorMsgToPlayer(GameError.ACT_RED_BAG_NOT_FOUND);
            return;
        }
        //红包指定了军团
        if (arb.getPartyId() > 0) {
            Member member = partyDataManager.getMemberById(player.roleId);
            if (member == null || member.getPartyId() != arb.getPartyId()) {
                handler.sendErrorMsgToPlayer(GameError.NOT_IN_PARTY);
                return;
            }
        }
        GamePb5.GrabRedBagRs.Builder builder = GamePb5.GrabRedBagRs.newBuilder();
        Map<Long, GrabRedBag> grabs = arb.getGrabs();
        List<Player> players = new ArrayList<>();
		for (long lordId : grabs.keySet()) {
			players.add(playerDataManager.getPlayer(lordId));
		}
        //已经抢过此红包或者红包被抢完了，显示红包详细信息
        if (grabs.containsKey(player.roleId) || grabs.size() >= arb.getGrabCnt()) {
            builder.setRedBag(PbHelper.createActRedBag(player, players, arb));
        } else {
            //剩余可抢次数
            int remainCnt = arb.getGrabCnt() - grabs.size();
            int grabMoney = 1;//固定给1金币
            if (remainCnt == 1) {
                grabMoney = arb.getRemainMoney();
            } else {
                //随机给金币
                int randomMoney = arb.getRemainMoney() - (remainCnt);
                if (randomMoney > 0) {
                    grabMoney += RandomHelper.randomInSize(randomMoney);
                }
            }
            GrabRedBag grab = new GrabRedBag(player.roleId, grabMoney);
            grabs.put(player.roleId, grab);
            arb.setRemainMoney(arb.getRemainMoney() - grabMoney);


            //给予金币
            playerDataManager.addGold(player, grabMoney, AwardFrom.ACT_GRAB_RED_BAG);

            builder.setGrabMoney(grabMoney);
        }
        handler.sendMsgToPlayer(GamePb5.GrabRedBagRs.ext, builder.build());
    }

    /**
     * 发放红包
     *
     * @param req
     * @param handler
     */
    public void sendActRedBagRq(GamePb5.SendActRedBagRq req, ClientHandler handler) {

        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_GRAB_RED_BAGS);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        //等级限制
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        int minLv = activityBase.getStaticActivity().getMinLv();
        if (player.lord.getLevel() < minLv) {
            handler.sendErrorMsgToPlayer(GameError.LV_NOT_ENOUGH);
            return;
        }
        //红包可发数量检测,

        StaticActivityProp data = staticActivityDataMgr.getActivityPropById(req.getPropId());
        if (data == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }

        int partyId = 0;
        //发军团红包检测
        if (req.getIsPartyRedBag()) {
            Member member = partyDataManager.getMemberById(player.roleId);
            PartyData partyData = member != null ? partyDataManager.getParty(member.getPartyId()) : null;
            if (partyData == null) {
                handler.sendErrorMsgToPlayer(GameError.PARTY_NOT_EXIST);
                return;
            }
            partyId = partyData.getPartyId();
        }

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_GRAB_RED_BAGS);
        Map<Integer, Integer> propMap = activity.getPropMap();
        Integer count = propMap.get(req.getPropId());
        if (count == null || count <= 0) {
            handler.sendErrorMsgToPlayer(GameError.PROP_NOT_ENOUGH);
            return;
        }

        //扣除红包道具
        CommonPb.Atom2 atom2 = playerDataManager.subProp(player, AwardType.ACTIVITY_PROP, req.getPropId(), 1, AwardFrom.ACT_SEND_RED_BAG_TOPUP);

        //发放红包
        UsualActivityData usualActivity = activityDataManager.getUsualActivity(ActivityConst.ACT_GRAB_RED_BAGS);
        TreeMap<Integer, ActRedBag> redBags = usualActivity.getRedBags();
        //红包唯一ID
        usualActivity.setGoal(usualActivity.getGoal() + 1);
        ActRedBag arb = new ActRedBag(usualActivity.getGoal(), player.roleId, partyId);
        arb.setGrabCnt(req.getGrabCnt());
        arb.setTotalMoney(data.getPrice());
        arb.setRemainMoney(data.getPrice());
        redBags.put(arb.getId(), arb);

        //返回剩余道具信息，与红包摘要信息给Client
        GamePb5.SendActRedBagRs.Builder builder = GamePb5.SendActRedBagRs.newBuilder();
        builder.setAtom2(atom2);
        builder.setSummary(createRedBagSummaryBuilder(player, arb));

        //广播红包信息
        StcHelper.synSendActRedBag(player, arb);


        handler.sendMsgToPlayer(GamePb5.SendActRedBagRs.ext, builder.build());
    }

    public void onPayGold(Player player, int topup) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_GRAB_RED_BAGS);
        if (activityBase == null) return;
        TreeMap<Integer, StaticActRedBag> dataMap = staticActRedBagDataMgr.getMoneyMap(activityBase.getKeyId());
        if (dataMap == null || dataMap.isEmpty()) return;

        UsualActivityData usualActivity = activityDataManager.getUsualActivity(ActivityConst.ACT_GRAB_RED_BAGS);
        String params = usualActivity.getParams();
        int money = params != null && params.length() > 0 ? Integer.parseInt(params) : 0;
        int lastMoney = money + topup;
        usualActivity.setParams(String.valueOf(lastMoney));

        //充值金额发红包
        Map.Entry<Integer, StaticActRedBag> moneyEntry = dataMap.floorEntry(money);
        StaticActRedBag stageData = moneyEntry != null ? moneyEntry.getValue() : null;
        if (stageData != null && topup >= stageData.getMini()) {
            addRedBag(player, topup, stageData);
        }

        //全服充值达标广播
        for (Map.Entry<Integer, StaticActRedBag> entry : dataMap.entrySet()) {
            StaticActRedBag data = entry.getValue();
            if (money < data.getMoney() && data.getMoney() <= lastMoney) {
                chatService.sendWorldChat(chatService.createSysChat(SysChatId.ACT_RED_BAG_MONEY, String.valueOf(data.getStage())));
            }
        }

    }

    /**
     * 充值转化为活动红包道具
     *
     * @param player
     * @param topup
     * @param staticActRedBag
     */
    private void addRedBag(Player player, int topup, StaticActRedBag staticActRedBag) {
        int redBagMoney = (int) (1.0d * topup * staticActRedBag.getRatio() / NumberHelper.TEN_THOUSAND);
        List<StaticActivityProp> props = staticActRedBagDataMgr.getRedBagProps();
        for (StaticActivityProp data : props) {
            int rbc = redBagMoney / data.getPrice();
            if (rbc > 0) {
                redBagMoney %= data.getPrice();
                playerDataManager.addAward(player, AwardType.ACTIVITY_PROP, data.getId(), rbc, AwardFrom.ACT_RED_BAG_TOPUP);
            }
        }

        //切分完所有红包后还有剩余则给一个最小红包
        if (redBagMoney != 0) {
            StaticActivityProp data = props.get(props.size() - 1);
            if (data != null) {
                playerDataManager.addAward(player, AwardType.ACTIVITY_PROP, data.getId(), 1, AwardFrom.ACT_RED_BAG_TOPUP);
            }
        }
    }

    /**
     * 删除过期红包, 一次最多只删除30个
     * 红包过期条件
     * 1.红包被抢完了
     * 2.红包存在超过1天了
     *
     * @param redBags
     */
    private void checkAndClearExpire(TreeMap<Integer, ActRedBag> redBags) {
        if (redBags.size() >= 100) {
            long curMill = System.currentTimeMillis();
            Set<Integer> rmSet = new HashSet<>();
            for (Map.Entry<Integer, ActRedBag> entry : redBags.entrySet()) {
                ActRedBag arb = entry.getValue();
                if (arb.getGrabCnt() <= arb.getGrabs().size() || arb.getRemainMoney() <= 0) {
                    if (curMill - arb.getSendTime() >= TimeHelper.DAY_MS) {
                        rmSet.add(arb.getId());
                        if (rmSet.size() >= 30) break;
                    }
                }
            }
            if (!rmSet.isEmpty()) {
                for (Integer id : rmSet) {
                    ActRedBag arb = redBags.remove(id);
                    LogUtil.info("删除过期红包, 一次最多只删除30个 act red bag info :" + arb.paserPb());
                }
            }
        }
    }

    /**
     * 创建红包摘要信息
     *
     * @param player
     * @param redBag
     * @return
     */
    private CommonPb.RedBagSummary.Builder createRedBagSummaryBuilder(Player player, ActRedBag arb) {
        CommonPb.RedBagSummary.Builder builder = CommonPb.RedBagSummary.newBuilder();
        builder.setUid(arb.getId());
        Player redBagPlayer = playerDataManager.getPlayer(arb.getLordId());
        builder.setLordName(redBagPlayer.lord.getNick());
        Map<Long, GrabRedBag> grabs = arb.getGrabs();
        builder.setRemainGrab(arb.getGrabCnt() - grabs.size());
        return builder;
    }

}
