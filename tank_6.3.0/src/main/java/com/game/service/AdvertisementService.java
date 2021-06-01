/**   
 * @Title: ADService.java    
 * @Package com.game.service    
 * @Description:   
 * @author LiuYiFan   
 * @date 2017年5月23日19:34:21
 * @version V1.0   
 */
package com.game.service;

import com.game.common.ServerSetting;
import com.game.constant.*;
import com.game.dataMgr.StaticActivityDataMgr;
import com.game.domain.Player;
import com.game.domain.p.Advertisement;
import com.game.domain.s.StaticActAward;
import com.game.manager.AdvertisementDateManager;
import com.game.manager.PlayerDataManager;
import com.game.message.handler.ClientHandler;
import com.game.pb.AdvertisementPb.*;
import com.game.pb.CommonPb.Award;
import com.game.util.PbHelper;
import com.game.util.TimeHelper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;

/**
 * @ClassName: ADService
 * @Description:广告业务类
 * @author LiuYiFan
 * @date 2017年5月23日19:34:21
 * 
 */
@Service
public class AdvertisementService {
	@Autowired
	private ServerSetting serverSetting;

	@Autowired
	private PlayerDataManager playerDataManager;

	@Autowired
	private StaticActivityDataMgr staticActivityDataMgr;

	@Autowired
	private AdvertisementDateManager advertisementDateManager;

	/**
	 * 查询观看广告
	 * 
	 * @param handler
	 */
	public void getLoginADStatus(ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());// 确认该服是否有该角色
		if (player == null) {
			handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);// 不存在该角色结束调用返回错误信息
			return;
		}
		int plat = player.account.getPlatNo();// 获取渠道唯一ID
		if (platFlag(plat)) {
			handler.sendErrorMsgToPlayer(GameError.AD_NOEXIST);// 不存在该角色结束调用返回错误信息
			return;
		}
		// 以上为活动判定
		// 以下为活动执行
		Advertisement advertisement = player.advertisement;
		Date now = new Date();
		int value;
		if (advertisement == null) {// 玩家未观看广告
			value = 0;
		} else {
			if (advertisement.getLastLoginTime().after(getDateZeroTime(now))) {// 今天已观看过广告
				value = 1;
			} else {
				value = 0;
				advertisementDateManager.getLoginADStatus(advertisement);// 更新登陆广告奖励状态
			}
			SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
			try {
				Date open = df.parse(serverSetting.getOpenTime());
				int now1 = (int) (now.getTime() / 1000);
				int open1 = (int) (open.getTime() / 1000);
				if (now1 - open1 > 2592000) {
					value = 2;
				}
			} catch (ParseException e) {
				e.printStackTrace();
			}
		}
		GetLoginADStatusRs.Builder builder = GetLoginADStatusRs.newBuilder();// 返回数据对象
		builder.addAward(PbHelper.createAwardPb(AwardType.PROP, 103, 1));
		builder.addAward(PbHelper.createAwardPb(AwardType.PROP, 57, 3));
		builder.setPlayStatus(value);// 添加观看状态信息
		handler.sendMsgToPlayer(GetLoginADStatusRs.ext, builder.build());// 返回
	}

	/**
	 * 播放广告返回奖励
	 * 
	 * @param handler
	 */
	public void playLoginAD(ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());// 确认该服是否有该角色
		if (player == null) {
			handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);// 不存在该角色结束调用返回错误信息
			return;
		}
		int plat = player.account.getPlatNo();// 获取渠道唯一ID
		if (platFlag(plat)) {
			handler.sendErrorMsgToPlayer(GameError.AD_NOEXIST);// 不存在该角色结束调用返回错误信息
			return;
		}
		// 以上为活动判定
		// 以下为活动执行
		Advertisement advertisement = player.advertisement;
		Date now = new Date();
		int value = advertisementDateManager.playLoginAD(now, advertisement);
		PlayLoginADRs.Builder builder = PlayLoginADRs.newBuilder();// 返回数据对象
		if (value == 1) {
			// 发放奖励 新手资源箱X1(103) 技能书X3(57)
			int key1 = playerDataManager.addAward(player, AwardType.PROP, 103, 1, AwardFrom.LOGIN_AD);
			int key2 = playerDataManager.addAward(player, AwardType.PROP, 57, 3, AwardFrom.LOGIN_AD);
			builder.addAward(PbHelper.createAwardPb(AwardType.PROP, 103, 1, key1));
			builder.addAward(PbHelper.createAwardPb(AwardType.PROP, 57, 3, key2));
		} else {
			handler.sendErrorMsgToPlayer(GameError.AD_GETAWARD); // 已经发放过了奖励不发放
			return;
		}
		handler.sendMsgToPlayer(PlayLoginADRs.ext, builder.build());// 返回
	}

	/**
	 * 获取首冲广告的信息，并返回连续观看天数与今天观看的次数
	 * 
	 * @param handler
	 */
	public void getFirstGiftADStatus(ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());// 确认该服是否有该角色
		if (player == null) {
			handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);// 不存在该角色结束调用返回错误信息
			return;
		}
		int plat = player.account.getPlatNo();// 获取渠道唯一ID
		if (platFlag(plat)) {
			handler.sendErrorMsgToPlayer(GameError.AD_NOEXIST);// 不存在该角色结束调用返回错误信息
			return;
		}
		Advertisement advertisement = player.advertisement;
		advertisement = advertisementDateManager.getFirstGiftADStatus(advertisement);
		int value;
		value = advertisement.getFirstPay();
		SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
		try {
			Date now = new Date();
			Date open = df.parse(serverSetting.getOpenTime());
			int now1 = (int) (now.getTime() / 1000);
			int open1 = (int) (open.getTime() / 1000);
			if (now1 - open1 < 259200) {
				value = -1;
			}
		} catch (ParseException e) {
			e.printStackTrace();
		}
		GetFirstGiftADStatusRs.Builder builder = GetFirstGiftADStatusRs.newBuilder();// 返回对象
		builder.setPlayDays(advertisement.getFirstPayCount());// 返回今日的播放次数
		builder.setPlayTimes(value);// 返回连续的播放天数
		handler.sendMsgToPlayer(GetFirstGiftADStatusRs.ext, builder.build());// 返回
	}

	/**
	 * 播放首冲广告，并返回今天播放的广告次数
	 * 
	 * @param handler
	 */
	public void playFirstGiftAD(ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());// 确认该服是否有该角色
		if (player == null) {
			handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);// 不存在该角色结束调用返回错误信息
			return;
		}
		int plat = player.account.getPlatNo();// 获取渠道唯一ID
		if (platFlag(plat)) {
			handler.sendErrorMsgToPlayer(GameError.AD_NOEXIST);// 不存在该角色结束调用返回错误信息
			return;
		}
		Advertisement advertisement = player.advertisement;
		advertisement = advertisementDateManager.playFirstGiftAD(advertisement);
		if (advertisement.getFirstPay() > 5) {
			handler.sendErrorMsgToPlayer(GameError.AD_FIRSTPAY_COUNT);// 不存在结束调用返回活动未开启
			return;
		}
		PlayFirstGiftADRs.Builder builder = PlayFirstGiftADRs.newBuilder();// 返回对象
		builder.setPlayTimes(advertisement.getFirstPay());// 返回今日播放次数
		builder.setPlayDays(advertisement.getFirstPayCount());// 返回播放天数
		handler.sendMsgToPlayer(PlayFirstGiftADRs.ext, builder.build());// 返回
	}

	/**
	 * 领取广告首冲，返回奖励信息
	 * 
	 * @param handler
	 */
	public void awardFirstGiftAD(ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());// 确认该服是否有该角色
		if (player == null) {
			handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);// 不存在该角色结束调用返回错误信息
			return;
		}
		int plat = player.account.getPlatNo();// 获取渠道唯一ID
		if (platFlag(plat)) {
			handler.sendErrorMsgToPlayer(GameError.AD_NOEXIST);// 不存在该角色结束调用返回错误信息
			return;
		}
		Advertisement advertisement = player.advertisement;
		AwardFirstGiftADRs.Builder builder = AwardFirstGiftADRs.newBuilder();// 返回对象
		if (advertisement.getFirstPayStatus() == 1 && player.lord.getTopup() == 0) {
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
			int originTopup = player.lord.getTopup();
			if (originTopup == 0) {
				player.lord.setTopup(10);
				builder.setTopUp(player.lord.getTopup());
			}
		} else if (player.lord.getTopup() != 0) {
			handler.sendErrorMsgToPlayer(GameError.AD_FIRSTPAY_VIP); // 已经领取过首冲奖励了
			return;
		} else {
			handler.sendErrorMsgToPlayer(GameError.AD_FIRSTPAY_NO); // 未达成领取条件
			return;
		}
		handler.sendMsgToPlayer(AwardFirstGiftADRs.ext, builder.build());// 返回
	}

	/**
	 * 获取广告经验加成信息，返回广告播放次数与加成数
	 * 
	 * @param handler
	 */
	public void getExpAddStatus(ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());// 确认该服是否有该角色
		if (player == null) {
			handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);// 不存在该角色结束调用返回错误信息
			return;
		}
		int plat = player.account.getPlatNo();// 获取渠道唯一ID
		if (platFlag(plat)) {
			handler.sendErrorMsgToPlayer(GameError.AD_NOEXIST);// 不存在该角色结束调用返回错误信息
			return;
		}
		Advertisement advertisement = player.advertisement;
		advertisement = advertisementDateManager.getExpAddStatus(advertisement);
		GetExpAddStatusRs.Builder builder = GetExpAddStatusRs.newBuilder();// 返回对象
		builder.setPlayTimes(advertisement.getBuffCount2());// 返回当日播放次数
		handler.sendMsgToPlayer(GetExpAddStatusRs.ext, builder.build());// 返回
	}

	/**
	 * 播放经验加成的广告，返回播放次数与加成量
	 * 
	 * @param handler
	 */
	public void playExpAddAD(ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());// 确认该服是否有该角色
		if (player == null) {
			handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);// 不存在该角色结束调用返回错误信息
			return;
		}
		int plat = player.account.getPlatNo();// 获取渠道唯一ID
		if (platFlag(plat)) {
			handler.sendErrorMsgToPlayer(GameError.AD_NOEXIST);// 不存在该角色结束调用返回错误信息
			return;
		}
		Advertisement advertisement = player.advertisement;
		advertisement = advertisementDateManager.playExpAddAD(advertisement);
		if (advertisement.getBuffCount2() > 5) {
			handler.sendErrorMsgToPlayer(GameError.AD_BUFF1_COUNT);// 编制经验加成次数超过
			return;
		}
		setAddExp(player, advertisement.getBuffCount2());
		PlayExpAddADRs.Builder builder = PlayExpAddADRs.newBuilder();// 返回对象
		builder.setPlayTimes(advertisement.getBuffCount2());// 返回当日播放次数
		handler.sendMsgToPlayer(PlayExpAddADRs.ext, builder.build());// 返回
	}

	/**
	 * 获取秒升一级的信息，返回秒升一级的状态
	 * 
	 * @param handler
	 */
	public void getDay7ActLvUpADStatus(ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());// 确认该服是否有该角色
		if (player == null) {
			handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);// 不存在该角色结束调用返回错误信息
			return;
		}
		int plat = player.account.getPlatNo();// 获取渠道唯一ID
		if (platFlag(plat)) {
			handler.sendErrorMsgToPlayer(GameError.AD_NOEXIST);// 不存在该角色结束调用返回错误信息
			return;
		}
		Advertisement advertisement = player.advertisement;
		advertisement = advertisementDateManager.getDay7ActLvUpADStatus(advertisement);
		GetDay7ActLvUpADStatusRs.Builder builder = GetDay7ActLvUpADStatusRs.newBuilder();// 返回对象
		builder.setStatus(advertisement.getLvUpStatus());// 返回秒升一级是否可用
		Date now = new Date();
		long now1 = now.getTime();
		Date beginTime = TimeHelper.getDateZeroTime(player.account.getCreateDate());
		long time = beginTime.getTime() + (7) * TimeHelper.DAY_S * 1000;
		if (now1 > time) {
			int value = 2;
			builder.setStatus(value);
		}
		handler.sendMsgToPlayer(GetDay7ActLvUpADStatusRs.ext, builder.build());// 返回
	}

	/**
	 * 播放秒升一级的广告
	 * 
	 * @param handler
	 */
	public void playDay7ActLvUpAD(ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());// 确认该服是否有该角色
		if (player == null) {
			handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);// 不存在该角色结束调用返回错误信息
			return;
		}
		int plat = player.account.getPlatNo();// 获取渠道唯一ID
		if (platFlag(plat)) {
			handler.sendErrorMsgToPlayer(GameError.AD_NOEXIST);// 不存在该角色结束调用返回错误信息
			return;
		}
		Advertisement advertisement = player.advertisement;
		advertisement = advertisementDateManager.playDay7ActLvUpAD(advertisement);
		PlayDay7ActLvUpADRs.Builder builder = PlayDay7ActLvUpADRs.newBuilder();// 返回对象
		handler.sendMsgToPlayer(PlayDay7ActLvUpADRs.ext, builder.build());// 返回
	}

	/**
	 * 播放经验加成buff广告
	 * 
	 * @param handler
	 */
	public void playStaffingAddAD(ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());// 确认该服是否有该角色
		if (player == null) {
			handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);// 不存在该角色结束调用返回错误信息
			return;
		}
		int plat = player.account.getPlatNo();// 获取渠道唯一ID
		if (platFlag(plat)) {
			handler.sendErrorMsgToPlayer(GameError.AD_NOEXIST);// 不存在该角色结束调用返回错误信息
			return;
		}
		Advertisement advertisement = player.advertisement;
		advertisement = advertisementDateManager.playStaffingAddAD(advertisement);
		if (advertisement.getBuffCount() > 5) {
			handler.sendErrorMsgToPlayer(GameError.AD_BUFF2_COUNT);// 编制经验加成次数超过
			return;
		}
		addStaffing(player, advertisement.getBuffCount());
		PlayStaffingAddADRs.Builder builder = PlayStaffingAddADRs.newBuilder();// 返回对象
		builder.setPlayTimes(advertisement.getBuffCount());
		handler.sendMsgToPlayer(PlayStaffingAddADRs.ext, builder.build());// 返回
	}

	/**
	 * 获取指挥官经验加成广告
	 * 
	 * @param handler
	 */
	public void getStaffingAddStatus(ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());// 确认该服是否有该角色
		if (player == null) {
			handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);// 不存在该角色结束调用返回错误信息
			return;
		}
		int plat = player.account.getPlatNo();// 获取渠道唯一ID
		if (platFlag(plat)) {
			handler.sendErrorMsgToPlayer(GameError.AD_NOEXIST);// 不存在该角色结束调用返回错误信息
			return;
		}
		Advertisement advertisement = player.advertisement;
		advertisement = advertisementDateManager.getStaffingAddStatus(advertisement);
		SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
		int value = advertisement.getBuffCount();
		try {
			Date now = new Date();
			Date open = df.parse(serverSetting.getOpenTime());
			int now1 = (int) (now.getTime() / 1000);
			int open1 = (int) (open.getTime() / 1000);
			if (now1 - open1 < 2592000) {
				value = -1;
			}
		} catch (ParseException e) {
			e.printStackTrace();
		}
		GetStaffingAddStatusRs.Builder builder = GetStaffingAddStatusRs.newBuilder();// 返回对象
		builder.setPlayTimes(value);
		handler.sendMsgToPlayer(GetStaffingAddStatusRs.ext, builder.build());// 返回
	}

	/**
	 * 恢复体力广告
	 * 
	 * @param handler
	 */
	public void playAddPowerAD(ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());// 确认该服是否有该角色
		if (player == null) {
			handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);// 不存在该角色结束调用返回错误信息
			return;
		}
		int plat = player.account.getPlatNo();// 获取渠道唯一ID
		if (platFlag(plat)) {
			handler.sendErrorMsgToPlayer(GameError.AD_NOEXIST);// 不存在该角色结束调用返回错误信息
			return;
		}
		Advertisement advertisement = player.advertisement;
		advertisement = advertisementDateManager.playAddPowerAD(advertisement);
		PlayAddPowerADRs.Builder builder = PlayAddPowerADRs.newBuilder();// 返回对象
		if (advertisement.getPowerCount() < 6) {
			int key1 = playerDataManager.addAward(player, AwardType.PROP, 246, 1, AwardFrom.LOGIN_AD);
			builder.addAward(PbHelper.createAwardPb(AwardType.PROP, 246, 1, key1));
		} else {
			handler.sendErrorMsgToPlayer(GameError.AD_POWER_COUNT); // 体力恢复达到上限
			return;
		}
		builder.setPlayTimes(advertisement.getPowerCount());
		handler.sendMsgToPlayer(PlayAddPowerADRs.ext, builder.build());// 返回
	}

	/**
	 * 获取统率书广告
	 * 
	 * @param handler
	 */
	public void playAddCommandAD(ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());// 确认该服是否有该角色
		if (player == null) {
			handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);// 不存在该角色结束调用返回错误信息
			return;
		}
		int plat = player.account.getPlatNo();// 获取渠道唯一ID
		if (platFlag(plat)) {
			handler.sendErrorMsgToPlayer(GameError.AD_NOEXIST);// 不存在该角色结束调用返回错误信息
			return;
		}
		Advertisement advertisement = player.advertisement;
		advertisement = advertisementDateManager.playAddCommandAD(advertisement);
		PlayAddCommandADRs.Builder builder = PlayAddCommandADRs.newBuilder();// 返回对象
		if (advertisement.getCommondCount() == 2) {
			int key1 = playerDataManager.addAward(player, AwardType.PROP, 56, 1, AwardFrom.LOGIN_AD);
			builder.addAward(PbHelper.createAwardPb(AwardType.PROP, 56, 1, key1));
		} else if (advertisement.getCommondCount() > 2) {
			handler.sendErrorMsgToPlayer(GameError.AD_COMMOND_COUNT); // 统率书领取达到上限
			return;
		}
		builder.setPlayTimes(advertisement.getCommondCount());
		handler.sendMsgToPlayer(PlayAddCommandADRs.ext, builder.build());// 返回
	}

	/**
	 * 查询体力广告次数
	 * 
	 * @param handler
	 */
	public void getAddPowerAD(ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());// 确认该服是否有该角色
		if (player == null) {
			handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);// 不存在该角色结束调用返回错误信息
			return;
		}
		int plat = player.account.getPlatNo();// 获取渠道唯一ID
		if (platFlag(plat)) {
			handler.sendErrorMsgToPlayer(GameError.AD_NOEXIST);// 不存在该角色结束调用返回错误信息
			return;
		}
		Advertisement advertisement = player.advertisement;
		advertisement = advertisementDateManager.getAddPowerAD(advertisement);
		GetAddPowerADRs.Builder builder = GetAddPowerADRs.newBuilder();// 返回对象
		builder.setPlayTimes(advertisement.getPowerCount());
		handler.sendMsgToPlayer(GetAddPowerADRs.ext, builder.build());// 返回
	}

	/**
	 * 查询统率书广告次数
	 * 
	 * @param handler
	 */
	public void getAddCommandAD(ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());// 确认该服是否有该角色
		if (player == null) {
			handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);// 不存在该角色结束调用返回错误信息
			return;
		}
		int plat = player.account.getPlatNo();// 获取渠道唯一ID
		if (platFlag(plat)) {
			handler.sendErrorMsgToPlayer(GameError.AD_NOEXIST);// 不存在该角色结束调用返回错误信息
			return;
		}
		Advertisement advertisement = player.advertisement;
		advertisement = advertisementDateManager.getAddCommandAD(advertisement);
		GetAddCommandADRs.Builder builder = GetAddCommandADRs.newBuilder();// 返回对象
		builder.setPlayTimes(advertisement.getCommondCount());
		handler.sendMsgToPlayer(GetAddCommandADRs.ext, builder.build());// 返回
	}

	/**
	 * 
	 * 获得人物经验加成
	 * 
	 * @param player
	 * @param count void
	 */
	private void setAddExp(Player player, int count) {
		Date now = new Date();
		Date last = TimeHelper.getSecondDayZeroTime(now);
		int time = (int) ((last.getTime() - now.getTime()) / 1000);
		if (time <= 0)
			return;
		switch (count) {
		case 1:
			playerDataManager.addEffect(player, EffectType.ADD_STAFFING_ADEXP1, time);
			break;
		case 2:
			player.effects.remove(EffectType.ADD_STAFFING_ADEXP1);
			playerDataManager.addEffect(player, EffectType.ADD_STAFFING_ADEXP2, time);
			break;
		case 3:
			player.effects.remove(EffectType.ADD_STAFFING_ADEXP2);
			playerDataManager.addEffect(player, EffectType.ADD_STAFFING_ADEXP3, time);
			break;
		case 4:
			player.effects.remove(EffectType.ADD_STAFFING_ADEXP3);
			playerDataManager.addEffect(player, EffectType.ADD_STAFFING_ADEXP4, time);
			break;
		default:
			player.effects.remove(EffectType.ADD_STAFFING_ADEXP4);
			player.effects.remove(EffectType.ADD_STAFFING_ADEXP5);
			playerDataManager.addEffect(player, EffectType.ADD_STAFFING_ADEXP5, time);
			break;
		}
	}

	/**
	 * @Title: getDateZeroTime
	 * @Description: 将时间转为当天凌点整
	 * @param date
	 * @return Date
	 * 
	 */
	private static Date getDateZeroTime(Date date) {
		Calendar cal = Calendar.getInstance();
		cal.setTime(date);
		cal.set(Calendar.HOUR_OF_DAY, 0);
		cal.set(Calendar.MINUTE, 0);
		cal.set(Calendar.SECOND, 0);
		cal.set(Calendar.MILLISECOND, 0);
		return cal.getTime();
	}

	/**
	 * 
	 * 获得编制经验加成
	 * 
	 * @param player
	 * @param count void
	 */
	private void addStaffing(Player player, int count) {
		Date now = new Date();
		Date last = TimeHelper.getSecondDayZeroTime(now);
		int time = (int) ((last.getTime() - now.getTime()) / 1000);
		if (time <= 0)
			return;
		switch (count) {
		case 1:
			playerDataManager.addEffect(player, EffectType.ADD_STAFFING_AD1, time);
			break;
		case 2:
			player.effects.remove(EffectType.ADD_STAFFING_AD1);
			playerDataManager.addEffect(player, EffectType.ADD_STAFFING_AD2, time);
			break;
		case 3:
			player.effects.remove(EffectType.ADD_STAFFING_AD2);
			playerDataManager.addEffect(player, EffectType.ADD_STAFFING_AD3, time);
			break;
		case 4:
			player.effects.remove(EffectType.ADD_STAFFING_AD3);
			playerDataManager.addEffect(player, EffectType.ADD_STAFFING_AD4, time);
			break;
		default:
			player.effects.remove(EffectType.ADD_STAFFING_AD4);
			player.effects.remove(EffectType.ADD_STAFFING_AD5);
			playerDataManager.addEffect(player, EffectType.ADD_STAFFING_AD5, time);
			break;
		}
	}

	/**
	 * 
	 * 
	 * @param platId
	 * @return boolean
	 */
	public boolean platFlag(int platId) {
		boolean platFlag = true;
		if (platId == 501) {
			platFlag = false;
		}
		return platFlag;
	}
}
