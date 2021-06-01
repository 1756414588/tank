/**
 * @Title: PayService.java
 * @Package com.game.service
 * @Description:
 * @author ZhangJun
 * @date 2015年11月7日 上午11:55:08
 * @version V1.0
 */
package com.game.service;

import com.game.constant.*;
import com.game.dataMgr.StaticActivityDataMgr;
import com.game.dataMgr.StaticVipDataMgr;
import com.game.domain.Player;
import com.game.domain.p.Lord;
import com.game.domain.s.StaticActAward;
import com.game.domain.s.StaticPay;
import com.game.manager.ActivityDataManager;
import com.game.manager.PlayerDataManager;
import com.game.message.handler.DealType;
import com.game.message.handler.ServerHandler;
import com.game.pb.BasePb.Base;
import com.game.pb.CommonPb.Award;
import com.game.pb.InnerPb.PayBackRq;
import com.game.pb.InnerPb.PayConfirmRq;
import com.game.server.GameServer;
import com.game.server.ICommand;
import com.game.service.activity.ActRedBagsService;
import com.game.service.activity.simple.ActVipCountService;
import com.game.util.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

/**
 * @author ZhangJun
 * @ClassName: PayService
 * @Description: 支付
 * @date 2015年11月7日 上午11:55:08
 */
@Service
public class PayService {
    public final static String ODERID_NBBD = "BL1705_NBBD";//内部补单不记录数据库

    @Autowired
    private StaticVipDataMgr staticVipDataMgr;

    @Autowired
    private ActivityDataManager activityDataManager;

    @Autowired
    private StaticActivityDataMgr staticActivityDataMgr;

    @Autowired
    private WorldService worldService;

    @Autowired
    private ChatService chatService;

    @Autowired
    private ActionCenterService actionCenterService;

    @Autowired
    private ActVipCountService actVipCountService;

    @Autowired
    private ActRedBagsService redBagsService;

    @Autowired
    private ActivityNewService activityNewService;

    @Autowired
    private PlayerDataManager playerDataManager;

    /**
     * 支付回调
     *
     * @param req
     * @param handler void
     */
    public void payBackRq(final PayBackRq req, final ServerHandler handler) {
        GameServer.getInstance().mainLogicServer.addCommand(new ICommand() {
            @Override
            public void action() {
                //Auto-generated method stub

                long roleId = req.getRoleId();
                Player player = playerDataManager.getPlayer(roleId);
                payLogic(req, player);
            }
        }, DealType.MAIN);

    }

    /**
     * 支付后增加金币
     *
     * @param target
     * @param topup
     * @param extraGold
     * @param serialId
     * @param from
     * @return boolean
     */
    public boolean addPayGold(Player target, int topup, int extraGold, String serialId, AwardFrom from) {
        if (topup <= 0) {
            return false;
        }

        boolean upVip = false;
        Lord lord = target.lord;

        lord.setGold(lord.getGold() + topup + extraGold);
        lord.setGoldGive(lord.getGoldGive() + topup + extraGold);
        lord.setTopup(lord.getTopup() + topup);
        if (lord.getTopup1st() == 0) {
            lord.setTopup1st(topup);
        }
        int vip = staticVipDataMgr.calcVip(lord.getTopup());
        int oldLv = lord.getVip();
        if (vip > oldLv) {
            lord.setVip(vip);
            if (vip > 0) {
                chatService.sendWorldChat(chatService.createSysChat(SysChatId.BECOME_VIP, lord.getNick(), "" + vip));
            }
            upVip = true;
            //更新大咖带队活动VIP达成数量
            actVipCountService.onPlayerVipLevelUp(target, oldLv, vip);
        }

        LogLordHelper.gold(from, target.account, lord, topup + extraGold, topup);
        try {
            playerDataManager.synGoldToPlayer(target, topup + extraGold, topup, serialId);
        } catch (Exception e) {
            LogUtil.error(e);
        }

        try {
            //充值红包活动
            redBagsService.onPayGold(target, topup);
        } catch (Exception e) {
            LogUtil.error(e);
        }

        try {
            if (upVip) {
                worldService.recalcArmyMarch(target);
            }
        } catch (Exception e) {
            LogUtil.error(e);
        }
        return true;
    }

    /**
     * 首冲礼包
     *
     * @param player void
     */
    private void firstPayAward(Player player) {
        StaticActAward award = staticActivityDataMgr.getActAwardById(ActivityConst.ACT_PAY_FIRST).get(0);
        List<Award> awards = new ArrayList<>();
        List<List<Integer>> awardList = award.getAwardList();
        for (List<Integer> e : awardList) {
            if (e.size() != 3) {
                continue;
            }

            int type = e.get(0);
            int itemId = e.get(1);
            int count = e.get(2);
            awards.add(PbHelper.createAwardPb(type, itemId, count));
        }

        playerDataManager.sendAttachMail(AwardFrom.PAY_FRIST, player, awards, MailType.MOLD_FIRST_PAY, TimeHelper.getCurrentSecond());
    }

    /**
     * 支付给金币逻辑
     *
     * @param req
     * @param player
     * @return boolean
     */
    public boolean payLogic(final PayBackRq req, Player player) {
        boolean isSelf = req.getOrderId().startsWith(ODERID_NBBD); //是否是内部充值
        int topup = req.getAmount() * 10;
        int extraGold;
        int platNo = req.getPlatNo();
        StaticPay staticPay = null;

        if (platNo == 94 || platNo == 95 || platNo >= 500) {
            extraGold = staticVipDataMgr.getExtraGold(topup, true);
            staticPay = staticVipDataMgr.getExtraGoldConfig(topup, true);

        } else {
            extraGold = staticVipDataMgr.getExtraGold(topup, false);
            staticPay = staticVipDataMgr.getExtraGoldConfig(topup, false);
        }

        if (player == null) {
            return false;
        }

        int originTopup = player.lord.getTopup();
        if (originTopup == 0 || player.lord.getTopup1st() == 0) {
            extraGold += topup;
        }

        if (addPayGold(player, topup, extraGold, req.getSerialId(), AwardFrom.PAY)) {
            try {
                playerDataManager.sendNormalMail(player, MailType.MOLD_PAY_DONE, TimeHelper.getCurrentSecond(),
                        String.valueOf(topup + extraGold), String.valueOf(topup), String.valueOf(extraGold));
            } catch (Exception e) {
                LogUtil.error(e);
            }

            try {
                if (originTopup == 0) {
                    firstPayAward(player);
                }
            } catch (Exception e) {
                LogUtil.error(e);
            }

            try {
                activityDataManager.updActivity(player, ActivityConst.ACT_RED_GIFT, topup, 0);
            } catch (Exception e) {
                LogUtil.error(e);
            }
            try {
                activityDataManager.updActivity(player, ActivityConst.ACT_PAY_EVERYDAY, topup, 0);
            } catch (Exception e) {
                LogUtil.error(e);
            }
            try {
                activityDataManager.updActivity(player, ActivityConst.ACT_DAY_PAY, topup, 0);
            } catch (Exception e) {
                LogUtil.error(e);
            }
            try {
                activityDataManager.payContinue(player, topup);
            } catch (Exception e) {
                LogUtil.error(e);
            }
            try {
                activityDataManager.payFoison(player, topup);
            } catch (Exception e) {
                LogUtil.error(e);
            }
            try {
                activityDataManager.amyRebate(player, req.getAmount(), null, ActivityConst.ACT_AMY_ID);
            } catch (Exception e) {
                LogUtil.error(e);
            }
            try {
                activityDataManager.amyRebate(player, req.getAmount(), null, ActivityConst.ACT_AMY_ID2);
            } catch (Exception e) {
                LogUtil.error(e);
            }
            try {
                activityDataManager.reFirstPay(player, topup);
            } catch (Exception e) {
                LogUtil.error(e);
            }
            try {
                activityDataManager.giftPay(player, topup, ActivityConst.ACT_GIFT_PAY);
            } catch (Exception e) {
                LogUtil.error(e);
            }
            try {
                activityDataManager.giftPay(player, topup, ActivityConst.ACT_GIFT_PAY_MERGE);
            } catch (Exception e) {
                e.printStackTrace();
            }
            try {
                activityDataManager.payContu4(player, topup);
            } catch (Exception e) {
                LogUtil.error(e);
            }
            try {
                activityDataManager.payEveryday(player, topup);
            } catch (Exception e) {
                LogUtil.error(e);
            }
            try {
                activityDataManager.payVacationland(player, topup);
            } catch (Exception e) {
                LogUtil.error(e);
            }
            try {
                activityDataManager.payGamble(player, topup);
            } catch (Exception e) {
                LogUtil.error(e);
            }
            try {
                activityDataManager.payTrunTable(player, topup);
            } catch (Exception e) {
                e.printStackTrace();
            }
            try {
                activityDataManager.payRebate(player, topup);
            } catch (Exception e) {
                LogUtil.error(e);
            }
            try {
                activityDataManager.payContinueMore(player, topup);
            } catch (Exception e) {
                LogUtil.error(e);
            }
            try {
                activityDataManager.payHilarityPray(player, topup);
            } catch (Exception e) {
                LogUtil.error(e);
            }
            try {
                activityDataManager.payOverRebate(player, topup);
            } catch (Exception e) {
                LogUtil.error(e);
            }
            try {
                playerDataManager.updDay7ActSchedule(player, 17, topup);
            } catch (Exception e) {
                LogUtil.error(e);
            }
            try {
                activityDataManager.playerBackPay(player, topup);
            } catch (Exception e) {
                LogUtil.error(e);
            }
            try {
                activityNewService.recharge(player, topup);
            } catch (Exception e) {
                LogUtil.error(e);
            }

            try {
                //能量灌注活动
                actionCenterService.payCumulative(player, topup);
            } catch (Exception e) {
                LogUtil.error(e);
            }

            try {
                //自选豪礼
                activityDataManager.updActivity(player, ActivityConst.ACT_CHOOSE_GIFT, topup, 0);
            } catch (Exception e) {
                LogUtil.error(e);
            }

            try {
                activityNewService.newPayAct(player, staticPay);
            } catch (Exception e) {
                LogUtil.error(e);
            }
            try {
                activityNewService.new2PayAct(player, staticPay);
            } catch (Exception e) {
                LogUtil.error(e);
            }
            try {
                //新的累计充值
                activityDataManager.payEverydayNew(ActivityConst.ACT_PAY_EVERYDAY_NEW_1, player, topup);
            } catch (Exception e) {
                LogUtil.error(e);
            }
            try {
                activityDataManager.payEverydayNew(ActivityConst.ACT_PAY_EVERYDAY_NEW_2, player, topup);
            } catch (Exception e) {
                LogUtil.error(e);
            }
            try {
                //军团充值
                activityDataManager.payPartyRecharge(ActivityConst.ACT_PAY_PARTY, player, topup);
            } catch (Exception e) {
                LogUtil.error(e);
            }

            PayConfirmRq.Builder builder = PayConfirmRq.newBuilder();
            builder.setPlatNo(req.getPlatNo());
            builder.setOrderId(req.getOrderId());
            builder.setAddGold(topup + extraGold);
            try {
                playerDataManager.updTask(player, TaskType.COND_PAY_LIVE, topup);// 充值活跃进度刷新
            } catch (Exception e) {
                LogUtil.error(e);
            }
            Base.Builder baseBuilder = PbHelper.createRqBase(PayConfirmRq.EXT_FIELD_NUMBER, null, PayConfirmRq.ext,
                    builder.build());
            try {
                GameServer.getInstance().sendMsgToPublic(baseBuilder);
            } catch (Exception e) {
                LogUtil.error(e);
            }

            if (isSelf) {
                LogHelper.logPaySelf(player.lord, player.account, req.getServerId(), req.getOrderId(), req.getSerialId(),
                        req.getAmount(), DateHelper.formatDateMiniTime(new Date()));
            } else {
                LogHelper.logPay(player.lord, player.account, req.getServerId(), req.getOrderId(), req.getSerialId(),
                        req.getAmount(), DateHelper.formatDateMiniTime(new Date()));
            }
            return true;
        }

        return false;
    }
}
