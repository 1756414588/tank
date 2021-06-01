package com.game.service;

import com.game.constant.AwardFrom;
import com.game.constant.GameError;
import com.game.dataMgr.StaticSignDataMgr;
import com.game.domain.Player;
import com.game.domain.p.Account;
import com.game.domain.p.MonthSign;
import com.game.domain.s.StaticMonthSign;
import com.game.domain.s.StaticSign;
import com.game.domain.s.StaticSignLogin;
import com.game.manager.PlayerDataManager;
import com.game.message.handler.ClientHandler;
import com.game.pb.CommonPb;
import com.game.pb.GamePb2.GetSignRs;
import com.game.pb.GamePb2.SignRq;
import com.game.pb.GamePb2.SignRs;
import com.game.pb.GamePb3.AcceptEveLoginRs;
import com.game.pb.GamePb3.EveLoginRq;
import com.game.pb.GamePb3.EveLoginRs;
import com.game.pb.GamePb5;
import com.game.util.DateHelper;
import com.game.util.LogLordHelper;
import com.game.util.PbHelper;
import com.game.util.TimeHelper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.*;

/**
 * @author ChenKui
 * @version 创建时间：2015-9-21 上午10:00:33
 * @declare 签到相关
 */
@Service
public class SignService {

    @Autowired
    private PlayerDataManager playerDataManager;

    @Autowired
    private StaticSignDataMgr staticSignDataMgr;

    /**
     * Function:签到值：该值表示已领取标记
     *
     * @param handler
     */
    public void getSignRq(ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }
        Account account = player.account;
        if (account == null) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }
        GetSignRs.Builder builder = GetSignRs.newBuilder();

        boolean display = false;// 客户端未用到这个字段
        // 当前第几天
        int logins = account.getLoginDays() > 30 ? 30 : account.getLoginDays();

        List<Integer> signs = player.signs;
        int size = signs.size();
        if (size == 0) {
            for (int i = 0; i < 30; i++) {
                signs.add(0);
            }
        }

        builder.setLogins(logins);
        Iterator<Integer> it = signs.iterator();
        while (it.hasNext()) {
            int sign = it.next();
            if (sign != 0) {
                builder.addSigns(1);// 已领取
            } else {
                builder.addSigns(0);// 未领取
                display = true;
            }
        }
        builder.setDisplay(display);
        handler.sendMsgToPlayer(GetSignRs.ext, builder.build());
    }

    /**
     * 领取签到奖励  30天之内的
    * 
    * @param req
    * @param handler  
    * void
     */
    public void signRq(SignRq req, ClientHandler handler) {
        int signId = req.getSignId();
        if (signId > 30 || signId < 1) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }
        Account account = player.account;
        if (account == null) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }
        int logins = account.getLoginDays();
        if (signId > logins) {
            handler.sendErrorMsgToPlayer(GameError.UN_LOGIN);
            return;
        }
        SignRs.Builder builder = SignRs.newBuilder();
        List<Integer> signList = player.signs;
        int status = signList.get(signId - 1);
        if (status != 0) {
            handler.sendErrorMsgToPlayer(GameError.AWARD_HAD_GOT);
            return;
        }
        StaticSign staticSign = staticSignDataMgr.getSign(signId);
        if (staticSign == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }
        signList.set(signId - 1, 1);// 签到领奖
        List<List<Integer>> awardList = staticSign.getAwardList();
        for (List<Integer> e : awardList) {
            int type = e.get(0);
            int id = e.get(1);
            int count = e.get(2);
            int keyId = playerDataManager.addAward(player, type, id, count, AwardFrom.SIGN_AWARD);
            builder.addAward(PbHelper.createAwardPb(type, id, count, keyId));
        }
        handler.sendMsgToPlayer(SignRs.ext, builder.build());
    }

    /**
     * 
    * 是否显示30天后的每日签到
    * @param req
    * @param handler  
    * void
     */
    public void eveLoginRq(EveLoginRq req, ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }
        Account account = player.account;
        if (account == null) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }
        EveLoginRs.Builder builder = EveLoginRs.newBuilder();
        boolean display = true;

        List<Integer> signs = player.signs;
        Iterator<Integer> it = signs.iterator();
        while (it.hasNext()) {
            int sign = it.next();
            if (sign == 0) {
                display = false;// 有未领取的奖励 不能显示新版每月签到
                break;
            }
        }

        //如果奖励全部领取了，则判断是否登录次数大于30天，大于30天display才为true
        if(display == true) {
        	//签到第30天还不能显示新版每月签到，必须登录第31天后才显示新版每月签到
        	if(account.getLoginDays() == 30) {
        		display = false;
        	}
        }
        
        int sign = player.getSignLogin();
        int monthAndDay = TimeHelper.getMonthAndDay(new Date()) / 100;//MMdd格式的int日期   MMddHHmmdd
        int signDate = sign / 1000000;
        if (signDate == monthAndDay) {
            builder.setAccept(true);
            builder.addLogins((sign % 1000000) / 10000);//MMdd000000求余1000000永远是0 这里3个Logins有何意义 这里本来是用来取出签到的时分秒的 ⊙﹏⊙b汗
            builder.addLogins((sign % 10000) / 100);
            builder.addLogins(sign % 100);
        } else {
            builder.setAccept(false);
            builder.addLogins(0);
            builder.addLogins(0);
            builder.addLogins(0);
        }
        builder.setDisplay(display);

        handler.sendMsgToPlayer(EveLoginRs.ext, builder.build());
    }

    int[] p = {10000, 100, 1};

    /**
     * 
    * 领取签到登录奖励30天之后
    * @param handler  
    * void
     */
    public void acceptEveLoginRq(ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }
        Account account = player.account;
        if (account == null) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }
        boolean display = true;
        List<Integer> signs = player.signs;
        Iterator<Integer> it = signs.iterator();
        while (it.hasNext()) {
            int sign = it.next();
            if (sign == 0) {
                display = false;// 有未领取的奖励
                break;
            }
        }

        if (!display) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }

        int sign = player.getSignLogin();
        int monthAndDay = TimeHelper.getMonthAndDay(new Date()) / 100;
        int signDate = sign / 1000000;
        if (signDate == monthAndDay) {
            handler.sendErrorMsgToPlayer(GameError.HAD_ACCEPT);
            return;
        }
        sign = monthAndDay * 1000000;
        AcceptEveLoginRs.Builder builder = AcceptEveLoginRs.newBuilder();
        for (int i = 0; i < 3; i++) {
            StaticSignLogin signLogin = staticSignDataMgr.getSignLoginByGrid(i + 1);
            int loginId = signLogin.getLoginId();
            int type = signLogin.getType();
            int id = signLogin.getItemId();
            int count = signLogin.getCount();
            sign += p[i] * signLogin.getLoginId();
            int keyId = playerDataManager.addAward(player, type, id, count, AwardFrom.SIGN_LOGIN);
            builder.addLogins(loginId);
            builder.addAward(PbHelper.createAwardPb(type, id, count, keyId));
        }
        player.setSignLogin(sign);
        handler.sendMsgToPlayer(AcceptEveLoginRs.ext, builder.build());
    }


    /**
     * 获取每月签到信息
     *
     * @param handler
     */
    public void getMothSignInfo(ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        MonthSign monthSign = player.monthSign;
        int[] md = TimeHelper.getCurrentMonthAndDay();
        signCheck(monthSign, md[0], md[1]);
        GamePb5.GetMonthSignRs.Builder builder = GamePb5.GetMonthSignRs.newBuilder();
        builder.setTodaySign(monthSign.getTodaySign());
        builder.setDays(monthSign.getDays());
        if (!monthSign.getExt().isEmpty()) {
            builder.addAllDayExt(monthSign.getExt());
        }
        handler.sendMsgToPlayer(GamePb5.GetMonthSignRs.ext, builder.build());
    }


    /**
     * 领取每月签到签到奖励
     *
     * @param handler
     */
    public void monthSign(ClientHandler handler) {
        if (DateHelper.getServerOpenDay() < 30) return;
        int[] md = TimeHelper.getCurrentMonthAndDay();
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        MonthSign monthSign = player.monthSign;
        signCheck(monthSign, md[0], md[1]);
        if (monthSign.getTodaySign() >= 2) return; //今天已经VIP签到完成
        int signToday = monthSign.getTodaySign();
        StaticMonthSign staticSign = staticSignDataMgr.getStaticMonthSign(md[0], monthSign.getDays() + (signToday == 0 ? 1 : 0));
        List<Integer> reward = staticSign != null ? staticSign.getReward() : null;
        if (reward == null) return;//静态数据出错
        CommonPb.Award award = null;
        if (signToday == 0) {//今天未签到
            boolean isVipAdd = staticSign.getVip() > 0 && player.lord.getVip() >= staticSign.getVip();
            int mutil = staticSign.getMultiple();
            monthSign.setTodaySign(isVipAdd ? 2 : 1);
            monthSign.setDays(monthSign.getDays() + 1);
            monthSign.setSignMonth(md[0]);
            monthSign.setSignDay(md[1]);
            if (isVipAdd) {
                List<Integer> reward0 = new ArrayList<>(reward);
                reward0.set(2, reward.get(2) * mutil);
                award = playerDataManager.addAwardBackPb(player, reward0, AwardFrom.MONTH_SIGN);
            } else {
                award = playerDataManager.addAwardBackPb(player, reward, AwardFrom.MONTH_SIGN);
            }
        } else {//今天已普通签到
            if (staticSign.getVip() < 1 || player.lord.getVip() < staticSign.getVip()) { //VIP等级不足
                return; //没有VIP翻倍奖励或者VIP等级不足
            }
            monthSign.setTodaySign(2);
            monthSign.setSignMonth(md[0]);
            monthSign.setSignDay(md[1]);
            List<Integer> reward0 = new ArrayList<>(reward);
            reward0.set(2, reward.get(2) * (staticSign.getMultiple() - 1));
            award = playerDataManager.addAwardBackPb(player, reward0, AwardFrom.MONTH_SIGN);
        }
        GamePb5.MonthSignRs.Builder builder = GamePb5.MonthSignRs.newBuilder();
        builder.setDays(monthSign.getDays());
        builder.setTodaySign(monthSign.getTodaySign());
        if (award != null) builder.addAward(award);
        handler.sendMsgToPlayer(GamePb5.MonthSignRs.ext, builder.build());
        
        LogLordHelper.logMonthSign(AwardFrom.MONTH_SIGN, player, monthSign.getSignMonth(), monthSign.getSignDay(), monthSign.getDays());
    }

    /**
     * 领取额外的累计签到奖励
     *
     * @param rq
     * @param handler
     */
    public void drawExtReward(GamePb5.DrawMonthSignExtRq rq, ClientHandler handler) {
        if (DateHelper.getServerOpenDay() < 30) return;
        int ext_day = rq.getDays();
        if (ext_day < 1 || ext_day > 31) return;
        int[] md = TimeHelper.getCurrentMonthAndDay();
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        MonthSign monthSign = player.monthSign;
        signCheck(monthSign, md[0], md[1]);
        if (ext_day > monthSign.getDays()) return;
        StaticMonthSign staticSign = staticSignDataMgr.getStaticMonthSign(md[0], ext_day);
        List<List<Integer>> extReward = staticSign != null ? staticSign.getExtReward() : null;
        if (extReward == null) return;
        Set<Integer> extMap = monthSign.getExt();
        if (extMap.contains(ext_day)) return;//累计签到天数不足, 已经领取过了累计签到额外奖励
        extMap.add(ext_day);
        List<CommonPb.Award> pbAward = playerDataManager.addAwardsBackPb(player, extReward, AwardFrom.MONTH_SIGN_EXT);
        GamePb5.DrawMonthSignExtRs.Builder builder = GamePb5.DrawMonthSignExtRs.newBuilder();
        builder.setDays(monthSign.getDays());
        builder.addAllDayExt(monthSign.getExt());
        if (pbAward != null && !pbAward.isEmpty()) builder.addAllAward(pbAward);
        handler.sendMsgToPlayer(GamePb5.DrawMonthSignExtRs.ext, builder.build());
        LogLordHelper.logMonthSign(AwardFrom.MONTH_SIGN_EXT, player, monthSign.getSignMonth(), monthSign.getSignDay(), monthSign.getDays());
	}


    /**
     * 
    * 如果签到信息不是当月的 就先重置签到信息
    * @param sign
    * @param month
    * @param day  
    * void
     */
    private void signCheck(MonthSign sign, int month, int day) {
        if (month != sign.getSignMonth()) {
            sign.resetMonth(month);
        }else{
            if (sign.getTodaySign() > 0 && day != sign.getSignDay()) {
                sign.resetDay();
            }
        }
    }
}
