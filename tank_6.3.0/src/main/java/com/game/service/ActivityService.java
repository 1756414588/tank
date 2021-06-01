package com.game.service;

import com.game.constant.*;
import com.game.dataMgr.StaticActivityDataMgr;
import com.game.dataMgr.StaticBackDataMgr;
import com.game.dataMgr.StaticEquipDataMgr;
import com.game.dataMgr.StaticFunctionPlanDataMgr;
import com.game.domain.*;
import com.game.domain.p.*;
import com.game.domain.s.*;
import com.game.manager.*;
import com.game.message.handler.ClientHandler;
import com.game.pb.CommonPb;
import com.game.pb.GamePb2.*;
import com.game.pb.GamePb3.*;
import com.game.pb.GamePb5;
import com.game.pb.GamePb5.*;
import com.game.pb.GamePb6;
import com.game.pb.GamePb6.GetNewPayEverydayRs;
import com.game.pb.GamePb6.GetPartyRechargeRs;
import com.game.server.GameServer;
import com.game.util.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.*;

/**
 * @author ChenKui
 * @version 创建时间：2015-10-24 下午15:16:23
 * @declare 活动处理模块
 */
@Service
public class ActivityService {

	@Autowired
	private PlayerDataManager playerDataManager;

	@Autowired
	private ActivityDataManager activityDataManager;

	@Autowired
	private PartyDataManager partyDataManager;

	@Autowired
	private RankDataManager rankDataManager;

	@Autowired
	private StaticEquipDataMgr staticEquipDataMgr;

	@Autowired
	private StaticActivityDataMgr staticActivityDataMgr;

	@Autowired
	private StaticBackDataMgr staticBackDataMgr;

	@Autowired
	private PlayerService playerService;

	@Autowired
	private StaticFunctionPlanDataMgr staticFunctionPlanDataMgr;
	
	@Autowired
    private GlobalDataManager globalDataManager;
	

	/**
	 * Function:活动开启列表
	 *
	 * @param handler
	 */
	public void getActivityList(ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		if (player == null) {
			handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
			return;
		}
		int platFlag = 1;// 默认为安卓玩家
		int platNo = player.account.getPlatNo();
		if (platNo == 94 || platNo == 95 || platNo > 500) {// IOS玩家
			platFlag = 2;
		}
		List<ActivityBase> list = staticActivityDataMgr.getActivityList();
		GetActivityListRs.Builder builder = GetActivityListRs.newBuilder();
		for (ActivityBase e : list) {
			int activityId = e.getActivityId();
			if (activityId >= 100) {
				continue;
			}
			// 特别处理首充活动,不发送给客户端，该活动单独另做
			if (activityId == ActivityConst.ACT_PAY_FIRST) {
				continue;
			}
			int open = e.getBaseOpen();
			if (open == ActivityConst.OPEN_CLOSE) {// 活动未开启
				continue;
			}
			int plat = e.getPlan().getPlat();
			if (plat == 1 && platFlag == 2) {// 如果是安卓平台,IOS玩家不可见
				continue;
			} else if (plat == 2 && platFlag == 1) {// 如果是IOS平台,安卓玩家不可见
				continue;
			}
			int tips = 0;
			boolean cangetAward = false;// 可领奖，不可领奖
			Activity activity = null;
			if (open == ActivityConst.OPEN_AWARD) {// 活动状况为可领奖
				cangetAward = true;
				if (activityId != ActivityConst.ACT_RANK_PARTY_FIGHT && activityId != ActivityConst.ACT_RANK_PARTY_LV) {
					activity = activityDataManager.getActivityInfo(player, activityId);
					if (activity != null) {// 奖励
						List<ActStatus> statusList = getActivityTips(player, e, activity);
						for (ActStatus actStatus : statusList) {
							if (actStatus.isAcceptAward()) {
								tips++;
							}
						}
					}
				}
			}
			builder.addActivity(PbHelper.createActivityPb(e, cangetAward, tips));
		}
		handler.sendMsgToPlayer(GetActivityListRs.ext, builder.build());
	}

	/**
	 * 领取奖励
	 *
	 * @param req
	 * @param handler
	 */
	public void getActivityAward(GetActivityAwardRq req, ClientHandler handler) {
		int activityId = req.getActivityId();
		int keyId = req.getKeyId();
		StaticActAward actAward = staticActivityDataMgr.getActAward(keyId);
		if (actAward == null) {
			handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
			return;
		}
		ActivityBase activityBase = staticActivityDataMgr.getActivityById(activityId);
		if (activityBase == null) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}

		if (!staticActivityDataMgr.isValidAwardId(activityId, actAward.getActivityId())
				|| (activityBase.getKeyId() != actAward.getActivityId() && activityId != 41)) {
			LogUtil.error("警告，协议内容不正常（怀疑玩家模拟协议）, keyId:" + keyId + ", activityId:" + activityId + ", lordId:" + handler.getRoleId()
					+ ", ActAward:" + actAward);
			LogUtil.warn("警告，协议内容不正常（怀疑玩家模拟协议）, keyId:" + keyId + ", activityId:" + activityId + ", lordId:" + handler.getRoleId()
					+ ", ActAward:" + actAward);
			handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
			return;
		}

		Player player = playerDataManager.getPlayer(handler.getRoleId());
		if (player == null) {
			handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
			return;
		}

		Activity activity;
		if (activityId == ActivityConst.ACT_RANK_PARTY_FIGHT || activityId == ActivityConst.ACT_RANK_PARTY_LV) {
			PartyData partyData = partyDataManager.getPartyByLordId(handler.getRoleId());
			if (partyData == null) {
				handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
				return;
			}
			activity = partyData.getActivitys().get(activityId);
		} else {
			activity = player.activitys.get(activityId);
		}
		if (activity == null) {
			handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
			return;
		}
		if (activity.getOpen() == 0) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		int sortId = actAward.getSortId();
		int status = currentActivity(player, activity, sortId);
		if (status == 0) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_FINISH);
			return;
		}

		int serverId = player.account.getServerId();
		List<List<Integer>> awardList = actAward.getAwardList();
		// 领奖条件判定(排名类条件值)
		if (activityId == ActivityConst.ACT_RANK_FIGHT || activityId == ActivityConst.ACT_RANK_COMBAT
				|| activityId == ActivityConst.ACT_RANK_HONOUR) {
			if (status > actAward.getCond()) {
				handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_FINISH);
				return;
			}
			Integer awardStatus = activity.getStatusMap().get(keyId);
			if (awardStatus != null && awardStatus == 1) {
				handler.sendErrorMsgToPlayer(GameError.AWARD_HAD_GOT);
				return;
			}
			List<StaticActAward> condList = staticActivityDataMgr.getActAwardById(activityBase.getKeyId());
			if (condList == null) {
				handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
				return;
			}
			for (StaticActAward award : condList) {
				activity.getStatusMap().put(award.getKeyId(), 1);
			}
		} else if (activityId == ActivityConst.ACT_RANK_PARTY_FIGHT) {// 军团战力排行
			if (status > actAward.getCond()) {
				handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_FINISH);
				return;
			}
			// 不在记录中的玩家不可领奖
			List<Long> statusList = activity.getStatusList();
			Long lordId = handler.getRoleId();
			int index = statusList.lastIndexOf(lordId);
			if (index < 1) {// 第一位是排名
				handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_FINISH);
				return;
			}
			Lord lord = player.lord;
			if (lord == null) {
				handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
				return;
			}
			if (lord.getPartyFightAward() == activity.getBeginTime()) {
				handler.sendErrorMsgToPlayer(GameError.AWARD_HAD_GOT);
				return;
			}
			lord.setPartyFightAward(activity.getBeginTime());
		} else if (activityId == ActivityConst.ACT_MONTH_LOGIN) {// 每月登录
			Calendar calendar = Calendar.getInstance();
			int dayOfMonth = calendar.get(Calendar.DAY_OF_MONTH);
			if (dayOfMonth == 1) {
				handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_FINISH);
				return;
			}
			if (status < actAward.getCond()) {
				handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_FINISH);
				return;
			}
			Integer awardStatus = activity.getStatusMap().get(keyId);
			if (awardStatus != null && awardStatus == 1) {
				handler.sendErrorMsgToPlayer(GameError.AWARD_HAD_GOT);
				return;
			}
			activity.getStatusMap().put(keyId, 1);
		} else if (activityId == ActivityConst.ACT_RANK_PARTY_LV) {// 军团等级排行
			if (status > actAward.getCond()) {
				handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_FINISH);
				return;
			}
			// 后加入成员不可领取军团等级奖励
			Member member = partyDataManager.getMemberById(handler.getRoleId());
			if (member == null || member.getEnterTime() > activity.getEndTime()) {
				handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_FINISH);
				return;
			}
			Lord lord = player.lord;
			if (lord == null) {
				handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
				return;
			}
			if (lord.getPartyLvAward() == activity.getBeginTime()) {
				handler.sendErrorMsgToPlayer(GameError.AWARD_HAD_GOT);
				return;
			}
			lord.setPartyLvAward(activity.getBeginTime());
		} else if (activityId == ActivityConst.ACT_MERGE_GIFT) { //
			Date beginTime = activityBase.getBeginTime();
			int dayiy = DateHelper.dayiy(beginTime, new Date()); // 活动第几天
			if (actAward.getCond() != dayiy) {
				handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_FINISH);
				return;
			}
			Integer awardStatus = activity.getStatusMap().get(keyId);
			if (awardStatus != null && awardStatus == 1) {
				handler.sendErrorMsgToPlayer(GameError.AWARD_HAD_GOT);
				return;
			}
			activity.getStatusMap().put(keyId, 1);
		} else if (activityId == ActivityConst.ACT_INVEST_NEW) {// 投资计划
			if (status < actAward.getCond()) {
				handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_FINISH);
				return;
			}
			Integer awardStatus = activity.getStatusMap().get(keyId);
			if (awardStatus != null) {
				handler.sendErrorMsgToPlayer(GameError.AWARD_HAD_GOT);
				return;
			}
			int index = player.lord.getVip() - 2;
			if (index < 0) {
				handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
				return;
			}
			if (index > actAward.getAwardList().size() - 1) {
				index = actAward.getAwardList().size() - 1;
			}
			awardList = new ArrayList<>();
			awardList.add(actAward.getAwardList().get(index));
			activity.getStatusMap().put(keyId, index);
		} else if(activityId == ActivityConst.ACT_PAY_EVERYDAY_NEW_1||activityId == ActivityConst.ACT_PAY_EVERYDAY_NEW_2){
			if (actAward.getCond() == 1) { // 每日充值奖励
		        List<Long> statusList = activity.getStatusList();
		        if (statusList.get(0) == 2L) {
		            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_FINISH);
	                return;
		        }
		        if (statusList.get(0) == 1L) {
		            handler.sendErrorMsgToPlayer(GameError.AWARD_HAD_GOT);
	                return;
		        }
		        
		        int nowDay = TimeHelper.getCurrentDay();
				if (activity.getEndTime() != nowDay) {
					handler.sendErrorMsgToPlayer(GameError.ARTICLES_ARE_INVALID);
	                return;
				}
		        
		        globalDataManager.gameGlobal.removeNotGet(player.roleId, NotGetAwardType.PAY_EVERYDAY_NEW);
		        
		        statusList.set(0, 1L);// 设置已领奖
		        activity.setStatusList(statusList);
		    } else { // 累计充值奖励
		        Map<Integer, Integer> statusMap = activity.getStatusMap();
		        Integer totalStatus = statusMap.get(actAward.getKeyId());
		        if (totalStatus == null || totalStatus == 2) {
		            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_FINISH);
		            return;
		        }
		        if (totalStatus == 1){
		            handler.sendErrorMsgToPlayer(GameError.AWARD_HAD_GOT);
                    return;
		        }
		        statusMap.put(actAward.getKeyId(), 1);
		        activity.setStatusMap(statusMap);
		    }
		}else if(activityId == ActivityConst.ACT_PAY_PARTY){//军团充值
			Map<Integer, Integer> statusMap = activity.getStatusMap();
	        Integer totalStatus = statusMap.get(actAward.getKeyId());
	        if (totalStatus == null || totalStatus == 2) {
	            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_FINISH);
	            return;
	        }
	        if (totalStatus == 1){
	            handler.sendErrorMsgToPlayer(GameError.AWARD_HAD_GOT);
                return;
	        }
	        
	        Date currentDate = TimeHelper.getCurrentDate();
	        if(currentDate.after(activityBase.getPlan().getDisplayTime())) {
	        	handler.sendErrorMsgToPlayer(GameError.ARTICLES_ARE_INVALID);
                return;
	        }
	        statusMap.put(actAward.getKeyId(), 1);
	        activity.setStatusMap(statusMap);
		}else {
			if (status < actAward.getCond()) {
				handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_FINISH);
				return;
			}
			Integer awardStatus = activity.getStatusMap().get(keyId);
			if (awardStatus != null && awardStatus == 1) {
				handler.sendErrorMsgToPlayer(GameError.AWARD_HAD_GOT);
				return;
			}
			activity.getStatusMap().put(keyId, 1);
		}
		GetActivityAwardRs.Builder builder = GetActivityAwardRs.newBuilder();
		int size = awardList.size();

		for (int i = 0; i < size; i++) {
			List<Integer> e = awardList.get(i);
			int type = e.get(0);
			int itemId = e.get(1);
			int count = e.get(2);
			if (type == AwardType.EQUIP || type == AwardType.PART) {
				for (int c = 0; c < count; c++) {
					int itemkey = playerDataManager.addAward(player, type, itemId, 1, AwardFrom.ACTIVITY_AWARD);
					builder.addAward(PbHelper.createAwardPb(type, itemId, 1, itemkey));
				}
			} else {
				int itemkey = playerDataManager.addAward(player, type, itemId, count, AwardFrom.ACTIVITY_AWARD);
				builder.addAward(PbHelper.createAwardPb(type, itemId, count, itemkey));
			}
			LogHelper.logActivity(player.lord, activityId, 0, type, itemId, count, serverId);
		}

		handler.sendMsgToPlayer(GetActivityAwardRs.ext, builder.build());

		LogLordHelper.logActivity(staticActivityDataMgr, player, activityId, AwardFrom.ACTIVITY_AWARD, awardList, 0);
	}

	/**
	 * Function:等级活动
	 *
	 * @param handler
	 */
	public void actLevelRq(ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		if (player == null) {
			handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
			return;
		}
		Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_LEVEL);
		if (activity == null) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		ActivityBase activityBase = staticActivityDataMgr.getActivityById(activity.getActivityId());
		if (activityBase == null) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		int activityKeyId = activityBase.getKeyId();
		ActLevelRs.Builder builder = ActLevelRs.newBuilder();
		List<StaticActAward> condList = staticActivityDataMgr.getActAwardById(activityKeyId);
		for (StaticActAward e : condList) {
			int keyId = e.getKeyId();
			if (activity.getStatusMap().containsKey(keyId)) {// 已领取奖励
				builder.addActivityCond(PbHelper.createActivityCondPb(e, 1));
			} else {// 未领取奖励
				builder.addActivityCond(PbHelper.createActivityCondPb(e, 0));
			}
		}
		handler.sendMsgToPlayer(ActLevelRs.ext, builder.build());
	}

	/**
	 * 雷霆计划活动
	 *
	 * @param req
	 * @param handler void
	 */
	public void actAttackRq(ActAttackRq req, ClientHandler handler) {
		int activityId = req.getActivityId();
		if (activityId != ActivityConst.ACT_ATTACK && activityId != ActivityConst.ACT_ATTACK2) {
			handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
			return;
		}
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		if (player == null) {
			handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
			return;
		}
		Activity activity = activityDataManager.getActivityInfo(player, activityId);
		if (activity == null) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		ActivityBase activityBase = staticActivityDataMgr.getActivityById(activity.getActivityId());
		if (activityBase == null) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		int activityKeyId = activityBase.getKeyId();
		// 每天刷新{endTime最终记录时间}
		activityDataManager.refreshDay(activity);
		ActAttackRs.Builder builder = ActAttackRs.newBuilder();
		List<StaticActAward> condList = staticActivityDataMgr.getActAwardById(activityKeyId);
		for (StaticActAward e : condList) {
			int keyId = e.getKeyId();
			if (activity.getStatusMap().containsKey(keyId)) {// 已领取奖励
				builder.addActivityCond(PbHelper.createActivityCondPb(e, 1));
			} else {// 未领取奖励
				builder.addActivityCond(PbHelper.createActivityCondPb(e, 0));
			}
		}
		int state = currentActivity(player, activity, 0);
		builder.setState(state);
		handler.sendMsgToPlayer(ActAttackRs.ext, builder.build());
	}

	/**
	 * 开服7日战力排行榜信息
	 *
	 * @param handler
	 */
	public void actFightRq(ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		if (player == null) {
			handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
			return;
		}
		Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_RANK_FIGHT);
		if (activity == null) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		ActivityBase activityBase = staticActivityDataMgr.getActivityById(activity.getActivityId());
		if (activityBase == null) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		int activityKeyId = activityBase.getKeyId();
		ActFightRs.Builder builder = ActFightRs.newBuilder();
		List<StaticActAward> condList = staticActivityDataMgr.getActAwardById(activityKeyId);
		for (StaticActAward e : condList) {
			int keyId = e.getKeyId();
			if (activity.getStatusMap().containsKey(keyId)) {// 已领取奖励
				builder.addActivityCond(PbHelper.createActivityCondPb(e, 1));
			} else {// 未领取奖励
				builder.addActivityCond(PbHelper.createActivityCondPb(e, 0));
			}
		}
		int state = 0;
		if (activity.getOpen() == ActivityConst.OPEN_STEP) {
			state = rankDataManager.getPlayerRank(1, handler.getRoleId());
		} else {
			state = currentActivity(player, activity, 0);
		}
		builder.setState(state);
		handler.sendMsgToPlayer(ActFightRs.ext, builder.build());
	}

	/**
	 * 关卡排行
	 *
	 * @param handler void
	 */
	public void actCombatRq(ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		if (player == null) {
			handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
			return;
		}
		Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_RANK_COMBAT);
		if (activity == null) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		ActivityBase activityBase = staticActivityDataMgr.getActivityById(activity.getActivityId());
		if (activityBase == null) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		int activityKeyId = activityBase.getKeyId();
		ActCombatRs.Builder builder = ActCombatRs.newBuilder();
		List<StaticActAward> condList = staticActivityDataMgr.getActAwardById(activityKeyId);
		for (StaticActAward e : condList) {
			int keyId = e.getKeyId();
			if (activity.getStatusMap().containsKey(keyId)) {// 已领取奖励
				builder.addActivityCond(PbHelper.createActivityCondPb(e, 1));
			} else {// 未领取奖励
				builder.addActivityCond(PbHelper.createActivityCondPb(e, 0));
			}
		}
		int state = 0;
		if (activity.getOpen() == ActivityConst.OPEN_STEP) {
			state = rankDataManager.getPlayerRank(2, handler.getRoleId());
		} else {
			state = currentActivity(player, activity, 0);
		}
		builder.setState(state);
		handler.sendMsgToPlayer(ActCombatRs.ext, builder.build());
	}

	/**
	 * 荣誉排行榜活动
	 *
	 * @param handler
	 */
	public void actHonourRq(ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		if (player == null) {
			handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
			return;
		}
		Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_RANK_HONOUR);
		if (activity == null) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		ActivityBase activityBase = staticActivityDataMgr.getActivityById(activity.getActivityId());
		if (activityBase == null) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		int activityKeyId = activityBase.getKeyId();
		ActHonourRs.Builder builder = ActHonourRs.newBuilder();
		List<StaticActAward> condList = staticActivityDataMgr.getActAwardById(activityKeyId);
		for (StaticActAward e : condList) {
			int keyId = e.getKeyId();
			if (activity.getStatusMap().containsKey(keyId)) {// 已领取奖励
				builder.addActivityCond(PbHelper.createActivityCondPb(e, 1));
			} else {// 未领取奖励
				builder.addActivityCond(PbHelper.createActivityCondPb(e, 0));
			}
		}
		int state = 0;
		if (activity.getOpen() == ActivityConst.OPEN_STEP) {
			state = rankDataManager.getPlayerRank(3, handler.getRoleId());
		} else {
			state = currentActivity(player, activity, 0);
		}
		builder.setState(state);
		handler.sendMsgToPlayer(ActHonourRs.ext, builder.build());
	}

	/**
	 * 军团等级排行
	 *
	 * @param handler
	 */
	public void actPartyLvRq(ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		if (player == null) {
			handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
			return;
		}
		Lord lord = player.lord;
		if (lord == null) {
			handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
			return;
		}
		ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_RANK_PARTY_LV);
		if (activityBase == null) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		int activityKeyId = activityBase.getKeyId();
		ActPartyLvRs.Builder builder = ActPartyLvRs.newBuilder();
		List<StaticActAward> condList = staticActivityDataMgr.getActAwardById(activityKeyId);
		PartyData partyData = partyDataManager.getPartyByLordId(handler.getRoleId());
		if (partyData == null) {// 没有帮派时
			for (StaticActAward e : condList) {
				builder.addActivityCond(PbHelper.createActivityCondPb(e, 0));
			}
			builder.setState(0);
			handler.sendMsgToPlayer(ActPartyLvRs.ext, builder.build());
			return;
		}

		Activity activity = activityDataManager.getActivityInfo(partyData, ActivityConst.ACT_RANK_PARTY_LV);
		if (activity == null) {// 活动不展示给玩家看
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}

		int status = 0;
		if (lord.getPartyLvAward() == activity.getBeginTime()) {
			status = 1;
		}

		for (StaticActAward e : condList) {
			builder.addActivityCond(PbHelper.createActivityCondPb(e, status));
		}
		int state = 0;
		if (activity.getOpen() == ActivityConst.OPEN_STEP) {// 进行中..取军团当前等级排行
			PartyLvRank partyLvRank = activityDataManager.getPartyLvRank(partyData.getPartyId());
			if (partyLvRank != null) {
				state = partyLvRank.getRank();
			}
		} else {
			state = currentActivity(player, activity, 0);
			if (state != 0) {
				Member member = partyDataManager.getMemberById(lord.getLordId());
				if (member.getEnterTime() > activity.getEndTime()) {
					state = 0;
				}
			}
		}
		builder.setState(state);
		handler.sendMsgToPlayer(ActPartyLvRs.ext, builder.build());
	}

	/**
	 * 捐献活动
	 *
	 * @param handler
	 */
	public void actPartyDonateRq(ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		if (player == null) {
			handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
			return;
		}
		Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_PARTY_DONATE);
		if (activity == null) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		ActivityBase activityBase = staticActivityDataMgr.getActivityById(activity.getActivityId());
		if (activityBase == null) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		int activityKeyId = activityBase.getKeyId();
		// 每天刷新{endTime最终记录时间}
		activityDataManager.refreshDay(activity);
		ActPartyDonateRs.Builder builder = ActPartyDonateRs.newBuilder();
		List<StaticActAward> condList = staticActivityDataMgr.getActAwardById(activityKeyId);
		List<CommonPb.ActivityCond> hrList = new ArrayList<>();// 大厅资源
		List<CommonPb.ActivityCond> hgList = new ArrayList<>();// 大厅金币
		List<CommonPb.ActivityCond> crList = new ArrayList<>();// 科技资源
		List<CommonPb.ActivityCond> cgList = new ArrayList<>();// 科技金币
		for (StaticActAward e : condList) {
			int keyId = e.getKeyId();
			Integer status = activity.getStatusMap().get(keyId);
			if (status == null) {
				status = 0;// 奖励未领取1为已领取
			}
			int sortId = e.getSortId();
			if (sortId == 0) {
				hrList.add(PbHelper.createActivityCondPb(e, status));
			} else if (sortId == 1) {
				hgList.add(PbHelper.createActivityCondPb(e, status));
			} else if (sortId == 2) {
				crList.add(PbHelper.createActivityCondPb(e, status));
			} else if (sortId == 3) {
				cgList.add(PbHelper.createActivityCondPb(e, status));
			}
		}
		// 军团大厅资源捐献
		int state = currentActivity(player, activity, 0);
		builder.setHallResource(PbHelper.createCondStatePb(state, hrList));

		// 军团大厅金币捐献
		state = currentActivity(player, activity, 1);
		builder.setHallGold(PbHelper.createCondStatePb(state, hgList));

		// 军团科技资源
		state = currentActivity(player, activity, 2);
		builder.setScienceResource(PbHelper.createCondStatePb(state, crList));

		// 军团科技金币
		state = currentActivity(player, activity, 3);
		builder.setScienceGold(PbHelper.createCondStatePb(state, cgList));
		handler.sendMsgToPlayer(ActPartyDonateRs.ext, builder.build());
	}

	/**
	 * 收集活动
	 *
	 * @param handler
	 */
	public void actCollectRq(ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		if (player == null) {
			handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
			return;
		}
		Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_COLLECT_RESOURCE);
		if (activity == null) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		ActivityBase activityBase = staticActivityDataMgr.getActivityById(activity.getActivityId());
		if (activityBase == null) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		int activityKeyId = activityBase.getKeyId();
		ActCollectRs.Builder builder = ActCollectRs.newBuilder();
		List<StaticActAward> condList = staticActivityDataMgr.getActAwardById(activityKeyId);
		List<CommonPb.ActivityCond> stoneList = new ArrayList<>();
		List<CommonPb.ActivityCond> ironList = new ArrayList<>();
		List<CommonPb.ActivityCond> oilList = new ArrayList<>();
		List<CommonPb.ActivityCond> copperList = new ArrayList<>();
		List<CommonPb.ActivityCond> siliconList = new ArrayList<>();
		for (StaticActAward e : condList) {
			int keyId = e.getKeyId();
			Integer status = activity.getStatusMap().get(keyId);
			if (status == null) {
				status = 0;
			}
			int sortId = e.getSortId();
			if (sortId == 0) {
				stoneList.add(PbHelper.createActivityCondPb(e, status));
			} else if (sortId == 1) {
				ironList.add(PbHelper.createActivityCondPb(e, status));
			} else if (sortId == 2) {
				oilList.add(PbHelper.createActivityCondPb(e, status));
			} else if (sortId == 3) {
				copperList.add(PbHelper.createActivityCondPb(e, status));
			} else if (sortId == 4) {
				siliconList.add(PbHelper.createActivityCondPb(e, status));
			}
		}
		int state = currentActivity(player, activity, 0);
		builder.setStone(PbHelper.createCondStatePb(state, stoneList));

		state = currentActivity(player, activity, 1);
		builder.setIron(PbHelper.createCondStatePb(state, ironList));

		state = currentActivity(player, activity, 2);
		builder.setOil(PbHelper.createCondStatePb(state, oilList));

		state = currentActivity(player, activity, 3);
		builder.setCopper(PbHelper.createCondStatePb(state, copperList));

		state = currentActivity(player, activity, 4);
		builder.setSilicon(PbHelper.createCondStatePb(state, siliconList));

		handler.sendMsgToPlayer(ActCollectRs.ext, builder.build());
	}

	/**
	 * 副本送技能书活动
	 *
	 * @param handler
	 */
	public void actCombatSkillRq(ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		if (player == null) {
			handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
			return;
		}
		Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_COMBAT);
		if (activity == null) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		ActivityBase activityBase = staticActivityDataMgr.getActivityById(activity.getActivityId());
		if (activityBase == null) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		int activityKeyId = activityBase.getKeyId();
		// 每天刷新{endTime最终记录时间}
		activityDataManager.refreshDay(activity);
		ActCombatSkillRs.Builder builder = ActCombatSkillRs.newBuilder();
		List<StaticActAward> condList = staticActivityDataMgr.getActAwardById(activityKeyId);
		for (StaticActAward e : condList) {
			int keyId = e.getKeyId();
			if (activity.getStatusMap().containsKey(keyId)) {// 已领取奖励
				builder.addActivityCond(PbHelper.createActivityCondPb(e, 1));
			} else {// 未领取奖励
				builder.addActivityCond(PbHelper.createActivityCondPb(e, 0));
			}
		}
		int state = currentActivity(player, activity, 0);
		builder.setState(state);
		handler.sendMsgToPlayer(ActCombatSkillRs.ext, builder.build());
	}

	/**
	 * 军团战斗力排行活动
	 *
	 * @param handler
	 */
	public void actPartyFightRq(ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		if (player == null) {
			handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
			return;
		}
		Lord lord = player.lord;
		if (lord == null) {
			handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
			return;
		}
		ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_RANK_PARTY_FIGHT);
		if (activityBase == null) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		ActPartyFightRs.Builder builder = ActPartyFightRs.newBuilder();
		List<StaticActAward> condList = staticActivityDataMgr.getActAwardById(activityBase.getKeyId());
		PartyData partyData = partyDataManager.getPartyByLordId(handler.getRoleId());
		if (partyData == null) {// 没有帮派时
			for (StaticActAward e : condList) {
				builder.addActivityCond(PbHelper.createActivityCondPb(e, 0));
			}
			builder.setState(0);
			handler.sendMsgToPlayer(ActPartyFightRs.ext, builder.build());
			return;
		}
		// 有帮派时
		Activity activity = activityDataManager.getActivityInfo(partyData, ActivityConst.ACT_RANK_PARTY_FIGHT);
		if (activity == null) {// 活动不展示给玩家看
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		int status = 0;
		if (lord.getPartyFightAward() == activity.getBeginTime()) {
			status = 1;
		}
		for (StaticActAward e : condList) {
			builder.addActivityCond(PbHelper.createActivityCondPb(e, status));
		}
		int state = 0;
		if (activity.getOpen() == ActivityConst.OPEN_STEP) {// 进行中.. 取军团当天战力排行
			state = partyDataManager.getRank(partyData.getPartyId());
		} else {
			state = currentActivity(player, activity, 0);
			if (state != 0) {
				List<Long> statusList = activity.getStatusList();
				int index = statusList.lastIndexOf(lord.getLordId());
				if (index < 1) {// 军团内部战力未上榜
					state = 0;
				}
			}
		}
		builder.setState(state);
		handler.sendMsgToPlayer(ActPartyFightRs.ext, builder.build());
	}

	/**
	 * 投资计划
	 *
	 * @param handler
	 */
	public void actInvestRq(ActInvestRq req, ClientHandler handler) {
		int actId = ActivityConst.ACT_INVEST;
		if (req.hasActivityId()) {
			actId = req.getActivityId();
		}
		if (actId != ActivityConst.ACT_INVEST && actId != ActivityConst.ACT_INVEST_NEW) {
			handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
			return;
		}
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		if (player == null) {
			handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
			return;
		}
		Activity activity = activityDataManager.getActivityInfo(player, actId);
		if (activity == null) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		ActivityBase activityBase = staticActivityDataMgr.getActivityById(activity.getActivityId());
		if (activityBase == null) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		int activityKeyId = activityBase.getKeyId();
		ActInvestRs.Builder builder = ActInvestRs.newBuilder();
		List<StaticActAward> condList = staticActivityDataMgr.getActAwardById(activityKeyId);
		for (StaticActAward e : condList) {
			int keyId = e.getKeyId();
			if (activity.getStatusMap().containsKey(keyId)) {// 已领取奖励
				builder.addActivityCond(PbHelper.createActivityCondPb(e, 1));
			} else {// 未领取奖励
				builder.addActivityCond(PbHelper.createActivityCondPb(e, 0));
			}
		}
		int state = currentActivity(player, activity, 0);
		builder.setState(state);
		handler.sendMsgToPlayer(ActInvestRs.ext, builder.build());
	}

	/**
	 * 参与投资计划
	 *
	 * @param handler
	 */
	public void doInvestRq(DoInvestRq req, ClientHandler handler) {
		int actId = ActivityConst.ACT_INVEST;
		if (req.hasActivityId()) {
			actId = req.getActivityId();
		}
		if (actId != ActivityConst.ACT_INVEST && actId != ActivityConst.ACT_INVEST_NEW) {
			handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
			return;
		}
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		if (player == null) {
			handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
			return;
		}
		Lord lord = player.lord;
		if (lord == null) {
			handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
			return;
		}
		if (lord.getVip() < 2) {
			handler.sendErrorMsgToPlayer(GameError.VIP_NOT_ENOUGH);
			return;
		}
		Activity activity = activityDataManager.getActivityInfo(player, actId);
		if (activity == null) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		int state = currentActivity(player, activity, 0);
		if (state != 0) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_GOT);
			return;
		}
		int cost = 500;
		if (lord.getGold() < cost) {
			handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
			return;
		}
		playerDataManager.subGold(player, 500, AwardFrom.ACTIVITY_INVEST);
		activity.getStatusList().set(0, 500L);
		DoInvestRs.Builder builder = DoInvestRs.newBuilder();
		builder.setGold(lord.getGold());
		handler.sendMsgToPlayer(DoInvestRs.ext, builder.build());

		LogLordHelper.logActivity(staticActivityDataMgr, player, actId, AwardFrom.ACTIVITY_INVEST, 0, 0, 0, 500);
	}

	/**
	 * 充值红包
	 *
	 * @param handler
	 */
	public void actPayRedGiftRq(ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		if (player == null) {
			handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
			return;
		}
		Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_RED_GIFT);
		if (activity == null) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		ActivityBase activityBase = staticActivityDataMgr.getActivityById(activity.getActivityId());
		if (activityBase == null) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		int activityKeyId = activityBase.getKeyId();
		// 每天刷新{endTime最后一次记录时间}
		activityDataManager.refreshDay(activity);
		ActPayRedGiftRs.Builder builder = ActPayRedGiftRs.newBuilder();
		List<StaticActAward> condList = staticActivityDataMgr.getActAwardById(activityKeyId);
		for (StaticActAward e : condList) {
			int keyId = e.getKeyId();
			if (activity.getStatusMap().containsKey(keyId)) {// 已领取奖励
				builder.addActivityCond(PbHelper.createActivityCondPb(e, 1));
			} else {// 未领取奖励
				builder.addActivityCond(PbHelper.createActivityCondPb(e, 0));
			}
		}
		int state = currentActivity(player, activity, 0);
		builder.setState(state);
		handler.sendMsgToPlayer(ActPayRedGiftRs.ext, builder.build());
	}

	/**
	 * 每日充值
	 *
	 * @param handler
	 */
	public void actEveryDayPayRq(ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		if (player == null) {
			handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
			return;
		}
		Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_PAY_EVERYDAY);
		if (activity == null) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		ActivityBase activityBase = staticActivityDataMgr.getActivityById(activity.getActivityId());
		if (activityBase == null) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		int activityKeyId = activityBase.getKeyId();
		// 每天刷新{endTime最后一次记录时间}
		activityDataManager.refreshDay(activity);
		ActEveryDayPayRs.Builder builder = ActEveryDayPayRs.newBuilder();
		List<StaticActAward> condList = staticActivityDataMgr.getActAwardById(activityKeyId);
		for (StaticActAward e : condList) {
			int keyId = e.getKeyId();
			if (activity.getStatusMap().containsKey(keyId)) {// 已领取奖励
				builder.addActivityCond(PbHelper.createActivityCondPb(e, 1));
			} else {// 未领取奖励
				builder.addActivityCond(PbHelper.createActivityCondPb(e, 0));
			}
		}
		int state = currentActivity(player, activity, 0);
		builder.setState(state);
		handler.sendMsgToPlayer(ActEveryDayPayRs.ext, builder.build());
	}

	/**
	 * 首次充值（废弃）
	 *
	 * @param handler
	 */
	public void actPayFirstRq(ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		if (player == null) {
			handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
			return;
		}
		Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_PAY_FIRST);
		if (activity == null) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		ActivityBase activityBase = staticActivityDataMgr.getActivityById(activity.getActivityId());
		if (activityBase == null) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		int activityKeyId = activityBase.getKeyId();
		ActPayFirstRs.Builder builder = ActPayFirstRs.newBuilder();
		List<StaticActAward> condList = staticActivityDataMgr.getActAwardById(activityKeyId);
		for (StaticActAward e : condList) {
			int keyId = e.getKeyId();
			if (activity.getStatusMap().containsKey(keyId)) {// 已领取奖励
				builder.addActivityCond(PbHelper.createActivityCondPb(e, 1));
			} else {// 未领取奖励
				builder.addActivityCond(PbHelper.createActivityCondPb(e, 0));
			}
		}
		int state = currentActivity(player, activity, 0);
		builder.setState(state);
		handler.sendMsgToPlayer(ActPayFirstRs.ext, builder.build());
	}

	/**
	 * 老玩家回归信息
	 *
	 * @param handler
	 */
	public void getPlayerBackMessageRq(ClientHandler handler) {
		if (!staticFunctionPlanDataMgr.isPlayerBackOpen()) {
			// handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		if (player == null) {
			handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
			return;
		}

		if (player.lord.getLevel() < 30) {
			handler.sendErrorMsgToPlayer(GameError.LV_NOT_ENOUGH);
			return;
		}
		GetPlayerBackMessageRs.Builder builder = GetPlayerBackMessageRs.newBuilder();

		// 保证前端发送请求不会出现loading
		if (player.account.getBackState() == 0) {
			builder.setBackTime(-1);
			builder.setEndTime(-1);
			builder.setToday(-1);
			handler.sendMsgToPlayer(GetPlayerBackMessageRs.ext, builder.build());
			return;
		}

		playerDataManager.playerBackAwardStatus(player);
		int backState = player.account.getBackState();
		long endTime = player.account.getBackEndTime().getTime();
		if (System.currentTimeMillis() > endTime) {
			backState = 0;
			builder.setBackTime(0);
		}
		if (backState == 1) {
			builder.setBackTime(7);
		} else if (backState == 2) {
			builder.setBackTime(14);
		} else if (backState == 3) {
			builder.setBackTime(21);
		} else if (backState == 4) {
			builder.setBackTime(28);
		}
		Set<Integer> set = player.backAward.keySet();
		for (Integer key : set) {
			builder.addStatus(player.backAward.get(key));
		}
		int day = 10;
		if (endTime > System.currentTimeMillis()) {
			int time = (int) ((endTime - System.currentTimeMillis()) / 1000);
			while (time > TimeHelper.DAY_S) {// 距离第二个回归点的秒数
				time = time - TimeHelper.DAY_S;
				day -= 1;
			}
			builder.setEndTime(time);
		} else {
			builder.setEndTime(0);
		}
		builder.setToday(day);
		handler.sendMsgToPlayer(GetPlayerBackMessageRs.ext, builder.build());
	}

	/**
	 * 老玩家回归奖励
	 *
	 * @param handler
	 */
	public void getPlayerBackAwards(GetPlayerBackAwardsRq req, ClientHandler handler) {
		if (!staticFunctionPlanDataMgr.isPlayerBackOpen())
			return;
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		int day = req.getAwardTypeId();
		if (player == null) {
			handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
			return;
		}
		if (player.account.getBackState() == 0) {// 判断玩家是否回归状态
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		if (player.lord.getLevel() < 30) {// 玩家等级大于30级
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		playerDataManager.playerBackAwardStatus(player);
		StaticBackOne staticBackOne = staticBackDataMgr.getBackOne(player.account.getBackState(), day);
		List<List<Integer>> awardList = (staticBackOne != null) ? staticBackOne.getAwardList() : null;
		if (awardList == null) {
			handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
			return;
		}
		GetPlayerBackAwardsRs.Builder builder = GetPlayerBackAwardsRs.newBuilder();
		if (player.backAward.get(staticBackOne.getKeyId()) == 0) {
			for (List<Integer> e : awardList) {
				if (e.size() != 3) {
					continue;
				}
				int type = e.get(0);
				int id = e.get(1);
				int count = e.get(2);

				playerDataManager.addAward(player, type, id, count, AwardFrom.PLAYER_BACK_PAY);
				builder.addAward(PbHelper.createAwardPb(type, id, count));
			}
			player.backAward.put(staticBackOne.getKeyId(), 1);
		} else if (player.backAward.get(staticBackOne.getKeyId()) == 2 && player.lord.getGold() >= 10) {
			if (playerDataManager.subGold(player, 10, AwardFrom.PLAYER_BACK_AWARD)) {
				for (List<Integer> e : awardList) {
					if (e.size() != 3) {
						continue;
					}
					int type = e.get(0);
					int id = e.get(1);
					int count = e.get(2);

					playerDataManager.addAward(player, type, id, count, AwardFrom.PLAYER_BACK_PAY);
					builder.addAward(PbHelper.createAwardPb(type, id, count));
					player.backAward.put(staticBackOne.getKeyId(), 1);
					builder.setGold(player.lord.getGold());
				}
			}
		}
		Set<Integer> set = player.backAward.keySet();
		for (Integer key : set) {
			builder.addStatus(player.backAward.get(key));
		}

		handler.sendMsgToPlayer(GetPlayerBackAwardsRs.ext, builder.build());
	}

	/**
	 * 老玩家回归buff
	 *
	 * @param handler
	 */
	public void getPlayerBackBuff(ClientHandler handler) {
		if (!staticFunctionPlanDataMgr.isPlayerBackOpen())
			return;
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		if (player == null) {
			handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
			return;
		}
		if (player.account.getBackState() == 0) {// 判断玩家是否回归状态
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		if (player.lord.getLevel() < 30) {// 玩家等级大于30级
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}

		GetPlayerBackBuffRs.Builder builder = GetPlayerBackBuffRs.newBuilder();
		playerService.playerBackBuff(player);
		if (player.effects.containsKey(45)) {
			builder.addBuff(45);
			builder.addBuffTime(player.effects.get(45).getEndTime());
		} else {
			builder.addBuff(0);
			builder.addBuffTime(0);
		}
		if (player.effects.containsKey(46)) {
			builder.addBuff(46);
			builder.addBuffTime(player.effects.get(46).getEndTime());
		} else {
			builder.addBuff(0);
			builder.addBuffTime(0);
		}
		if (player.effects.containsKey(47)) {
			builder.addBuff(47);
			builder.addBuffTime(player.effects.get(47).getEndTime());
		} else {
			builder.addBuff(0);
			builder.addBuffTime(0);
		}
		int lv = player.account.getBackState();
		if (lv == 1) {
			builder.addBackTime(7);
		} else if (lv == 2) {
			builder.addBackTime(14);
		} else if (lv == 3) {
			builder.addBackTime(21);
		} else if (lv == 4) {
			builder.addBackTime(28);
		}
		handler.sendMsgToPlayer(GetPlayerBackBuffRs.ext, builder.build());
	}

	/**
	 * 半价折扣
	 *
	 * @param handler
	 */
	public void actQuotaRq(ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		if (player == null) {
			handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
			return;
		}
		Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_QUOTA);
		if (activity == null) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		ActivityBase activityBase = staticActivityDataMgr.getActivityById(activity.getActivityId());
		if (activityBase == null) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		int activityKeyId = activityBase.getKeyId();
		// 每天刷新{endTime最终记录时间}
		activityDataManager.refreshDay(activity);
		ActQuotaRs.Builder builder = ActQuotaRs.newBuilder();
		List<StaticActQuota> quotaList = staticActivityDataMgr.getQuotaList(activityKeyId);
		if (quotaList == null) {
			handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
			return;
		}
		for (StaticActQuota e : quotaList) {
			int quotaId = e.getQuotaId();
			Integer status = activity.getStatusMap().get(quotaId);
			if (status == null) {
				status = 0;
			}
			builder.addQuota(PbHelper.createQuotaPb(e, status));
		}
		handler.sendMsgToPlayer(ActQuotaRs.ext, builder.build());
	}

	/**
	 * 折扣购买
	 *
	 * @param handler
	 */
	public void doQuotaRq(DoQuotaRq req, ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		if (player == null) {
			handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
			return;
		}
		Lord lord = player.lord;
		if (lord == null) {
			handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
			return;
		}
		int activityId = req.getActivityId();
		if (activityId == 0) {
			handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
			return;
		}
		ActivityBase activityBase = staticActivityDataMgr.getActivityById(activityId);
		if (activityBase == null) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		Activity activity = activityDataManager.getActivityInfo(player, activityId);
		if (activity == null) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		// 每天刷新{endTime最后一次}
		activityDataManager.refreshDay(activity);
		int quotaId = req.getQuotaId();

		StaticActQuota staticActQuota = staticActivityDataMgr.getQuotaById(quotaId);
		if (staticActQuota == null) {
			handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
			return;
		}

		if (staticActQuota.getActivityId() != activityBase.getKeyId()) {
			LogUtil.error("警告，协议内容不正常（怀疑玩家模拟协议）, quotaId:" + quotaId + ", activityId:" + activityId + ", lordId:" + handler.getRoleId());
			LogUtil.warn("警告，协议内容不正常（怀疑玩家模拟协议）, quotaId:" + quotaId + ", activityId:" + activityId + ", lordId:" + handler.getRoleId());
			handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
			return;
		}

		if (lord.getGold() < staticActQuota.getPrice()) {
			handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
			return;
		}
		Integer status = activity.getStatusMap().get(quotaId);
		if (status == null) {
			status = 0;
		}
		if (status >= staticActQuota.getCount()) {
			handler.sendErrorMsgToPlayer(GameError.COUNT_NOT_ENOUGH);
			return;
		}

		activity.getStatusMap().put(quotaId, status + 1);
		playerDataManager.subGold(player, staticActQuota.getPrice(), AwardFrom.HALF_COST);
		DoQuotaRs.Builder builder = DoQuotaRs.newBuilder();
		List<List<Integer>> awardList = staticActQuota.getAwardList();
		for (List<Integer> e : awardList) {
			if (e.size() != 3) {
				continue;
			}
			int type = e.get(0);
			int id = e.get(1);
			int count = e.get(2);
			if (type == AwardType.EQUIP || type == AwardType.PART) {
				for (int i = 0; i < count; i++) {
					int keyId = playerDataManager.addAward(player, type, id, 1, AwardFrom.HALF_COST);
					builder.addAward(PbHelper.createAwardPb(type, id, 1, keyId));
				}
			} else {
				int keyId = playerDataManager.addAward(player, type, id, count, AwardFrom.HALF_COST);
				builder.addAward(PbHelper.createAwardPb(type, id, count, keyId));
			}
		}
		builder.setGold(lord.getGold());
		handler.sendMsgToPlayer(DoQuotaRs.ext, builder.build());

		LogLordHelper.logActivity(staticActivityDataMgr, player, activityId, AwardFrom.HALF_COST, awardList, staticActQuota.getPrice());
	}

	/**
	 * 紫装收集
	 *
	 * @param handler
	 */
	public void actPurpleEqpCollRq(ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		if (player == null) {
			handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
			return;
		}
		Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_PURPLE_COLL);
		if (activity == null) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		ActivityBase activityBase = staticActivityDataMgr.getActivityById(activity.getActivityId());
		if (activityBase == null) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		int activityKeyId = activityBase.getKeyId();
		ActPurpleEqpCollRs.Builder builder = ActPurpleEqpCollRs.newBuilder();
		List<StaticActAward> staticActAwardList = staticActivityDataMgr.getActAwardById(activityKeyId);
		if (staticActAwardList == null) {
			handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
			return;
		}
		for (StaticActAward e : staticActAwardList) {
			int keyId = e.getKeyId();
			if (activity.getStatusMap().containsKey(keyId)) {
				builder.addActivityCond(PbHelper.createActivityCondPb(e, 1));
			} else {
				builder.addActivityCond(PbHelper.createActivityCondPb(e, 0));
			}
		}
		handler.sendMsgToPlayer(ActPurpleEqpCollRs.ext, builder.build());
	}

	/**
	 * 紫装升级
	 *
	 * @param handler
	 */
	public void actPurpleEqpUpRq(ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		if (player == null) {
			handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
			return;
		}
		Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_PURPLE_UP);
		if (activity == null) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		ActivityBase activityBase = staticActivityDataMgr.getActivityById(activity.getActivityId());
		if (activityBase == null) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		int activityKeyId = activityBase.getKeyId();
		ActPurpleEqpUpRs.Builder builder = ActPurpleEqpUpRs.newBuilder();
		List<StaticActAward> condList = staticActivityDataMgr.getActAwardById(activityKeyId);
		if (condList == null) {
			handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
			return;
		}
		for (StaticActAward e : condList) {
			int keyId = e.getKeyId();
			Integer status = activity.getStatusMap().get(keyId);// 领取状况
			if (status == null) {
				status = 0;
			}
			int sortId = e.getSortId();
			int state = currentActivity(player, activity, sortId);// 条件完成数量
			builder.addCondState(PbHelper.createCondStatePb(state, e, status));
		}
		handler.sendMsgToPlayer(ActPurpleEqpUpRs.ext, builder.build());
	}

	/**
	 * 疯狂竞技场
	 *
	 * @param handler
	 */
	public void actCrazyArenaRq(ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		if (player == null) {
			handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
			return;
		}
		Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_CRAZY_ARENA);
		if (activity == null) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		ActivityBase activityBase = staticActivityDataMgr.getActivityById(activity.getActivityId());
		if (activityBase == null) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		int activityKeyId = activityBase.getKeyId();
		ActCrazyArenaRs.Builder builder = ActCrazyArenaRs.newBuilder();
		List<StaticActAward> staticActAwardList = staticActivityDataMgr.getActAwardById(activityKeyId);
		if (staticActAwardList == null) {
			handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
			return;
		}
		for (StaticActAward e : staticActAwardList) {
			int keyId = e.getKeyId();
			if (activity.getStatusMap().containsKey(keyId)) {
				builder.addActivityCond(PbHelper.createActivityCondPb(e, 1));
			} else {
				builder.addActivityCond(PbHelper.createActivityCondPb(e, 0));
			}
		}
		int state = currentActivity(player, activity, 0);
		builder.setState(state);
		handler.sendMsgToPlayer(ActCrazyArenaRs.ext, builder.build());
	}

	/**
	 * 疯狂进阶
	 *
	 * @param handler
	 */
	public void actCrazyUpgradeRq(ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		if (player == null) {
			handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
			return;
		}
		Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_CRAZY_HERO);
		if (activity == null) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		ActivityBase activityBase = staticActivityDataMgr.getActivityById(activity.getActivityId());
		if (activityBase == null) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		int activityKeyId = activityBase.getKeyId();
		ActCrazyUpgradeRs.Builder builder = ActCrazyUpgradeRs.newBuilder();
		List<StaticActAward> condList = staticActivityDataMgr.getActAwardById(activityKeyId);
		if (condList == null) {
			handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
			return;
		}
		for (StaticActAward e : condList) {
			int keyId = e.getKeyId();
			Integer status = activity.getStatusMap().get(keyId);// 领取状况
			if (status == null) {
				status = 0;
			}
			int sortId = e.getSortId();
			int state = currentActivity(player, activity, sortId);// 条件完成数量
			builder.addCondState(PbHelper.createCondStatePb(state, e, status));
		}
		handler.sendMsgToPlayer(ActCrazyUpgradeRs.ext, builder.build());
	}

	/**
	 * 配件进阶
	 *
	 * @param handler
	 */
	public void actPartEvolveRq(ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		if (player == null) {
			handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
			return;
		}
		Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_PART_EVOLVE);
		if (activity == null) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		ActivityBase activityBase = staticActivityDataMgr.getActivityById(activity.getActivityId());
		if (activityBase == null) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		int activityKeyId = activityBase.getKeyId();
		// 每天刷新{endTime最终记录时间}
		activityDataManager.refreshDay(activity);
		ActPartEvolveRs.Builder builder = ActPartEvolveRs.newBuilder();
		List<StaticActQuota> staticActQuotaList = staticActivityDataMgr.getQuotaList(activityKeyId);
		if (staticActQuotaList == null) {
			handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
			return;
		}
		for (StaticActQuota e : staticActQuotaList) {
			int quotaId = e.getQuotaId();
			Integer status = activity.getStatusMap().get(quotaId);
			if (status == null) {
				status = 0;
			}
			builder.addQuota(PbHelper.createQuotaPb(e, status));
		}
		handler.sendMsgToPlayer(ActPartEvolveRs.ext, builder.build());
	}

	/**
	 * 限时出售
	 *
	 * @param handler
	 */
	public void actFlashSaleRq(ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		if (player == null) {
			handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
			return;
		}
		Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_FLASH_SALE);
		if (activity == null) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		ActivityBase activityBase = staticActivityDataMgr.getActivityById(activity.getActivityId());
		if (activityBase == null) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		int activityKeyId = activityBase.getKeyId();
		// 每天刷新{endTime最终记录时间}
		activityDataManager.refreshDay(activity);
		ActFlashSaleRs.Builder builder = ActFlashSaleRs.newBuilder();
		List<StaticActQuota> staticActQuotaList = staticActivityDataMgr.getQuotaList(activityKeyId);
		if (staticActQuotaList == null) {
			handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
			return;
		}
		for (StaticActQuota e : staticActQuotaList) {
			int quotaId = e.getQuotaId();
			Integer status = activity.getStatusMap().get(quotaId);
			if (status == null) {
				status = 0;
			}
			builder.addQuota(PbHelper.createQuotaPb(e, status));
		}
		handler.sendMsgToPlayer(ActFlashSaleRs.ext, builder.build());
	}

	/**
	 * 春节限购
	 *
	 * @param rq
	 * @param handler
	 */
	public void actFesSaleRq(ActFesSaleRq rq, ClientHandler handler) {
		int activityId = rq.hasActivityId() ? rq.getActivityId() : ActivityConst.ACT_FES_SALE;
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		if (player == null) {
			handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
			return;
		}
		Activity activity = activityDataManager.getActivityInfo(player, activityId);
		if (activity == null) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		ActivityBase activityBase = staticActivityDataMgr.getActivityById(activityId);
		if (activityBase == null) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		int activityKeyId = activityBase.getKeyId();
		ActFesSaleRs.Builder builder = ActFesSaleRs.newBuilder();
		List<StaticActQuota> staticActQuotaList = staticActivityDataMgr.getQuotaList(activityKeyId);
		if (staticActQuotaList == null) {
			handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
			return;
		}
		for (StaticActQuota e : staticActQuotaList) {
			int quotaId = e.getQuotaId();
			Integer status = activity.getStatusMap().get(quotaId);
			if (status == null) {
				status = 0;
			}
			builder.addQuota(PbHelper.createQuotaPb(e, status));
		}
		handler.sendMsgToPlayer(ActFesSaleRs.ext, builder.build());
	}

	/**
	 * 消费奖励
	 *
	 * @param rq
	 * @param handler
	 */
	public void actCostGoldRq(ActCostGoldRq rq, ClientHandler handler) {
		int activityId = rq.hasActivityId() ? rq.getActivityId() : ActivityConst.ACT_COST_GOLD;
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		if (player == null) {
			handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
			return;
		}
		Activity activity = activityDataManager.getActivityInfo(player, activityId);
		if (activity == null) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		ActivityBase activityBase = staticActivityDataMgr.getActivityById(activityId);
		if (activityBase == null) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		int activityKeyId = activityBase.getKeyId();
		ActCostGoldRs.Builder builder = ActCostGoldRs.newBuilder();
		List<StaticActAward> staticActAwardList = staticActivityDataMgr.getActAwardById(activityKeyId);
		if (staticActAwardList == null) {
			handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
			return;
		}
		for (StaticActAward e : staticActAwardList) {
			int keyId = e.getKeyId();
			if (activity.getStatusMap().containsKey(keyId)) {
				builder.addActivityCond(PbHelper.createActivityCondPb(e, 1));
			} else {
				builder.addActivityCond(PbHelper.createActivityCondPb(e, 0));
			}
		}
		int state = currentActivity(player, activity, 0);
		builder.setState(state);
		handler.sendMsgToPlayer(ActCostGoldRs.ext, builder.build());
	}

	/**
	 * 连续充值
	 *
	 * @param handler
	 */
	public void actContuPayRq(ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		if (player == null) {
			handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
			return;
		}
		Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_CONTU_PAY);
		if (activity == null) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		ActivityBase activityBase = staticActivityDataMgr.getActivityById(activity.getActivityId());
		if (activityBase == null) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		int activityKeyId = activityBase.getKeyId();
		ActContuPayRs.Builder builder = ActContuPayRs.newBuilder();
		List<StaticActAward> condList = staticActivityDataMgr.getActAwardById(activityKeyId);
		if (condList == null) {
			handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
			return;
		}
		for (StaticActAward e : condList) {
			int keyId = e.getKeyId();
			if (activity.getStatusMap().containsKey(keyId)) {
				builder.addActivityCond(PbHelper.createActivityCondPb(e, 1));
			} else {
				builder.addActivityCond(PbHelper.createActivityCondPb(e, 0));
			}
		}
		int stete = currentActivity(player, activity, 0);
		builder.setState(stete);
		handler.sendMsgToPlayer(ActContuPayRs.ext, builder.build());
	}

	/**
	 * 限时材料
	 *
	 * @param handler
	 */
	public void actFlashMetaRq(ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		if (player == null) {
			handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
			return;
		}
		Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_FLASH_META);
		if (activity == null) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		ActivityBase activityBase = staticActivityDataMgr.getActivityById(activity.getActivityId());
		if (activityBase == null) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		int activityKeyId = activityBase.getKeyId();
		// 每天刷新{endTime最终记录时间}
		activityDataManager.refreshDay(activity);
		ActFlashMetaRs.Builder builder = ActFlashMetaRs.newBuilder();
		List<StaticActQuota> staticActQuotaList = staticActivityDataMgr.getQuotaList(activityKeyId);
		if (staticActQuotaList == null) {
			handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
			return;
		}
		for (StaticActQuota e : staticActQuotaList) {
			int quotaId = e.getQuotaId();
			Integer status = activity.getStatusMap().get(quotaId);
			if (status == null) {
				status = 0;
			}
			builder.addQuota(PbHelper.createQuotaPb(e, status));
		}
		handler.sendMsgToPlayer(ActFlashMetaRs.ext, builder.build());
	}

	/**
	 * 科技优惠
	 *
	 * @param handler
	 */
	public void actTeachInfoRq(ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		if (player == null) {
			handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
			return;
		}
		Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_TECHSELL);
		if (activity == null) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		ActivityBase activityBase = staticActivityDataMgr.getActivityById(activity.getActivityId());
		if (activityBase == null) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		int activityKeyId = activityBase.getKeyId();
		// 每天刷新{endTime最终记录时间}
		activityDataManager.refreshDay(activity);
		GamePb6.ActTechInfoRs.Builder builder = GamePb6.ActTechInfoRs.newBuilder();
		List<StaticActQuota> staticActQuotaList = staticActivityDataMgr.getQuotaList(activityKeyId);
		if (staticActQuotaList == null) {
			handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
			return;
		}
		for (StaticActQuota e : staticActQuotaList) {
			int quotaId = e.getQuotaId();
			Integer status = activity.getStatusMap().get(quotaId);
			if (status == null) {
				status = 0;
			}
			builder.addQuota(PbHelper.createQuotaPb(e, status));
		}
		handler.sendMsgToPlayer(GamePb6.ActTechInfoRs.ext, builder.build());
	}
	
	/**
	 *   建筑优惠
	 * 
	 * @param handler
	 */
	public void actBuildInfoRq(ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		if (player == null) {
			handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
			return;
		}
		
		ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_BUILDSELL);
		Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_BUILDSELL);
		if (activityBase == null || activity == null) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		int activityKeyId = activityBase.getKeyId();
		// 每天刷新{endTime最终记录时间}
		activityDataManager.refreshDay(activity);
		GamePb6.ActBuildInfoRs.Builder builder = GamePb6.ActBuildInfoRs.newBuilder();
		List<StaticActQuota> staticActQuotaList = staticActivityDataMgr.getQuotaList(activityKeyId);
		if (staticActQuotaList == null) {
			handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
			return;
		}
		for (StaticActQuota e : staticActQuotaList) {
			int quotaId = e.getQuotaId();
			Integer status = activity.getStatusMap().get(quotaId);
			if (status == null) {
				status = 0;
			}
			builder.addQuota(PbHelper.createQuotaPb(e, status));
		}
		handler.sendMsgToPlayer(GamePb6.ActBuildInfoRs.ext, builder.build());
	}


	/**
	 * 天天充值
	 *
	 * @param handler
	 */
	public void actDayPay(ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		if (player == null) {
			handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
			return;
		}
		Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_DAY_PAY);
		if (activity == null) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		ActivityBase activityBase = staticActivityDataMgr.getActivityById(activity.getActivityId());
		if (activityBase == null) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		int activityKeyId = activityBase.getKeyId();
		// 每天刷新{endTime最终记录时间}
		activityDataManager.refreshDay(activity);
		ActDayPayRs.Builder builder = ActDayPayRs.newBuilder();
		List<StaticActAward> condList = staticActivityDataMgr.getActAwardById(activityKeyId);
		if (condList == null) {
			handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
			return;
		}
		for (StaticActAward e : condList) {
			int keyId = e.getKeyId();
			if (activity.getStatusMap().containsKey(keyId)) {
				builder.addActivityCond(PbHelper.createActivityCondPb(e, 1));
			} else {
				builder.addActivityCond(PbHelper.createActivityCondPb(e, 0));
			}
		}
		int state = currentActivity(player, activity, 0);
		builder.setState(state);
		handler.sendMsgToPlayer(ActDayPayRs.ext, builder.build());
	}

	/**
	 * 天天限购
	 *
	 * @param handler
	 */
	public void actDayBuyRq(ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		if (player == null) {
			handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
			return;
		}
		Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_DAY_BUY);
		if (activity == null) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		ActivityBase activityBase = staticActivityDataMgr.getActivityById(activity.getActivityId());
		if (activityBase == null) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		int activityKeyId = activityBase.getKeyId();
		// 每天刷新{endTime最终记录时间}
		activityDataManager.refreshDay(activity);
		ActDayBuyRs.Builder builder = ActDayBuyRs.newBuilder();
		List<StaticActQuota> staticActQuotaList = staticActivityDataMgr.getQuotaList(activityKeyId);
		if (staticActQuotaList == null) {
			handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
			return;
		}
		for (StaticActQuota e : staticActQuotaList) {
			int quotaId = e.getQuotaId();
			Integer status = activity.getStatusMap().get(quotaId);
			if (status == null) {
				status = 0;
			}
			builder.addQuota(PbHelper.createQuotaPb(e, status));
		}
		handler.sendMsgToPlayer(ActDayBuyRs.ext, builder.build());
	}

	/**
	 * 月末限购
	 *
	 * @param handler
	 */
	public void actMonthSaleRq(ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		if (player == null) {
			handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
			return;
		}
		Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_MONTH_SALE);
		if (activity == null) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		ActivityBase activityBase = staticActivityDataMgr.getActivityById(activity.getActivityId());
		if (activityBase == null) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		int activityKeyId = activityBase.getKeyId();
		// 每天刷新{endTime最终记录时间}
		activityDataManager.refreshDay(activity);
		ActMonthSaleRs.Builder builder = ActMonthSaleRs.newBuilder();
		List<StaticActQuota> staticActQuotaList = staticActivityDataMgr.getQuotaList(activityKeyId);
		if (staticActQuotaList == null) {
			handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
			return;
		}
		for (StaticActQuota e : staticActQuotaList) {
			int quotaId = e.getQuotaId();
			Integer status = activity.getStatusMap().get(quotaId);
			if (status == null) {
				status = 0;
			}
			builder.addQuota(PbHelper.createQuotaPb(e, status));
		}
		handler.sendMsgToPlayer(ActMonthSaleRs.ext, builder.build());
	}

	/**
	 * 登录时长送礼
	 *
	 * @param handler
	 */
	public void actGiftOLRq(ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		if (player == null) {
			handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
			return;
		}
		Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_GIFT_OL);
		if (activity == null) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		ActivityBase activityBase = staticActivityDataMgr.getActivityById(activity.getActivityId());
		if (activityBase == null) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		int activityKeyId = activityBase.getKeyId();
		// 每天刷新{endTime最终记录时间}
		activityDataManager.refreshDay(activity);
		ActGiftOLRs.Builder builder = ActGiftOLRs.newBuilder();
		List<StaticActAward> condList = staticActivityDataMgr.getActAwardById(activityKeyId);
		for (StaticActAward e : condList) {
			int keyId = e.getKeyId();
			if (activity.getStatusMap().containsKey(keyId)) {// 已领取奖励
				builder.addActivityCond(PbHelper.createActivityCondPb(e, 1));
			} else {// 未领取奖励
				builder.addActivityCond(PbHelper.createActivityCondPb(e, 0));
			}
		}
		int state = currentActivity(player, activity, 0);
		builder.setState(state);
		handler.sendMsgToPlayer(ActGiftOLRs.ext, builder.build());
	}

	/**
	 * 合服领奖
	 *
	 * @param handler
	 */
	public void actMergeGiftRq(ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		if (player == null) {
			handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
			return;
		}
		Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_MERGE_GIFT);
		if (activity == null) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		ActivityBase activityBase = staticActivityDataMgr.getActivityById(activity.getActivityId());
		if (activityBase == null) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		int activityKeyId = activityBase.getKeyId();
		GetActMergeGiftRs.Builder builder = GetActMergeGiftRs.newBuilder();
		List<StaticActAward> condList = staticActivityDataMgr.getActAwardById(activityKeyId);
		for (StaticActAward e : condList) {
			if (activity.getStatusMap().containsKey(e.getCond())) {// 已领取奖励
				builder.addConds(PbHelper.createActivityCondPb(e, 1));
			} else {// 未领取奖励
				builder.addConds(PbHelper.createActivityCondPb(e, 0));
			}
		}
		handler.sendMsgToPlayer(GetActMergeGiftRs.ext, builder.build());
	}

	/**
	 * 每月登录
	 *
	 * @param handler
	 */
	public void actMonthLoginRq(ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		if (player == null) {
			handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
			return;
		}
		Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_MONTH_LOGIN);
		if (activity == null) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		ActivityBase activityBase = staticActivityDataMgr.getActivityById(activity.getActivityId());
		if (activityBase == null) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		int activityKeyId = activityBase.getKeyId();
		ActMonthLoginRs.Builder builder = ActMonthLoginRs.newBuilder();
		List<StaticActAward> condList = staticActivityDataMgr.getActAwardById(activityKeyId);
		for (StaticActAward e : condList) {
			int keyId = e.getKeyId();
			if (activity.getStatusMap().containsKey(keyId)) {// 已领取奖励
				builder.addActivityCond(PbHelper.createActivityCondPb(e, 1));
			} else {// 未领取奖励
				builder.addActivityCond(PbHelper.createActivityCondPb(e, 0));
			}
		}
		builder.setState(player.lord.getOlMonth());
		handler.sendMsgToPlayer(ActMonthLoginRs.ext, builder.build());
	}

	/**
	 * 敌军兜售
	 *
	 * @param handler
	 */
	public void actEnemySaleRq(ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		if (player == null) {
			handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
			return;
		}
		Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_ENEMY_SALE);
		if (activity == null) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		ActivityBase activityBase = staticActivityDataMgr.getActivityById(activity.getActivityId());
		if (activityBase == null) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		int activityKeyId = activityBase.getKeyId();
		ActEnemySaleRs.Builder builder = ActEnemySaleRs.newBuilder();
		List<StaticActQuota> staticActQuotaList = staticActivityDataMgr.getQuotaList(activityKeyId);
		if (staticActQuotaList == null) {
			handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
			return;
		}
		for (StaticActQuota e : staticActQuotaList) {
			int quotaId = e.getQuotaId();
			Integer status = activity.getStatusMap().get(quotaId);
			if (status == null) {
				status = 0;
			}
			builder.addQuota(PbHelper.createQuotaPb(e, status));
		}
		handler.sendMsgToPlayer(ActEnemySaleRs.ext, builder.build());
	}

	/**
	 * 升装暴击
	 *
	 * @param handler
	 */
	public void actUpEquipCritRq(ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		if (player == null) {
			handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
			return;
		}
		Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_UP_EQUIP_CRIT);
		if (activity == null) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		ActivityBase activityBase = staticActivityDataMgr.getActivityById(activity.getActivityId());
		if (activityBase == null) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		// 每天刷新{endTime最终记录时间}
		activityDataManager.refreshDay(activity);
		int activityKeyId = activityBase.getKeyId();
		ActUpEquipCritRs.Builder builder = ActUpEquipCritRs.newBuilder();
		List<StaticActQuota> staticActQuotaList = staticActivityDataMgr.getQuotaList(activityKeyId);
		if (staticActQuotaList == null) {
			handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
			return;
		}
		for (StaticActQuota e : staticActQuotaList) {
			int quotaId = e.getQuotaId();
			Integer status = activity.getStatusMap().get(quotaId);
			if (status == null) {
				status = 0;
			}
			builder.addQuota(PbHelper.createQuotaPb(e, status));
		}
		handler.sendMsgToPlayer(ActUpEquipCritRs.ext, builder.build());
	}

	/**
	 * 部件淬炼暴击
	 *
	 * @param handler
	 */
	public void getSmeltPartActivity(ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		if (player == null) {
			handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
			return;
		}
		Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_SMELT_CRIT_EXP);
		if (activity == null) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		ActivityBase activityBase = staticActivityDataMgr.getActivityById(activity.getActivityId());
		if (activityBase == null) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		// 每天刷新{endTime最终记录时间}
		activityDataManager.refreshDay(activity);
		int activityKeyId = activityBase.getKeyId();
		GamePb5.GetActSmeltPartCritRs.Builder builder = GamePb5.GetActSmeltPartCritRs.newBuilder();
		List<StaticActQuota> staticActQuotaList = staticActivityDataMgr.getQuotaList(activityKeyId);
		if (staticActQuotaList == null) {
			handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
			return;
		}
		for (StaticActQuota e : staticActQuotaList) {
			int quotaId = e.getQuotaId();
			Integer status = activity.getStatusMap().get(quotaId);
			if (status == null) {
				status = 0;
			}
			builder.addQuota(PbHelper.createQuotaPb(e, status));
		}
		handler.sendMsgToPlayer(GamePb5.GetActSmeltPartCritRs.ext, builder.build());
	}

	/**
	 * 首充返利
	 *
	 * @param handler
	 */
	public void actReFristPayRq(ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		if (player == null) {
			handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
			return;
		}
		Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_RE_FRIST_PAY);
		if (activity == null) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		int plat = player.account.getPlatNo();
		ActivityBase activityBase = staticActivityDataMgr.getActivityById(activity.getActivityId(), plat);
		if (activityBase == null) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		int activityKeyId = activityBase.getKeyId();
		// 每天刷新{endTime最终记录时间}
		activityDataManager.refreshDay(activity);
		ActReFristPayRs.Builder builder = ActReFristPayRs.newBuilder();
		List<StaticActAward> condList = staticActivityDataMgr.getActAwardById(activityKeyId);
		for (StaticActAward e : condList) {
			int keyId = e.getKeyId();
			int sortId = e.getSortId();
			int state = currentActivity(player, activity, sortId);
			if (activity.getStatusMap().containsKey(keyId)) {// 已领取奖励
				builder.addCondState(PbHelper.createCondStatePb(state, e, 1));
			} else {// 未领取奖励
				builder.addCondState(PbHelper.createCondStatePb(state, e, 0));
			}
		}
		handler.sendMsgToPlayer(ActReFristPayRs.ext, builder.build());
	}

	/**
	 * 充值送礼
	 *
	 * @param rq
	 * @param handler
	 */
	public void actGiftPayRq(ActGiftPayRq rq, ClientHandler handler) {
		int activityId = rq.hasActivityId() ? rq.getActivityId() : ActivityConst.ACT_GIFT_PAY;
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		if (player == null) {
			handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
			return;
		}
		Activity activity = activityDataManager.getActivityInfo(player, activityId);
		if (activity == null) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		ActivityBase activityBase = staticActivityDataMgr.getActivityById(activityId);
		if (activityBase == null) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		int activityKeyId = activityBase.getKeyId();
		// 每天刷新{endTime最终记录时间}
		activityDataManager.refreshDay(activity);
		ActGiftPayRs.Builder builder = ActGiftPayRs.newBuilder();
		List<StaticActAward> condList = staticActivityDataMgr.getActAwardById(activityKeyId);
		for (StaticActAward e : condList) {
			int keyId = e.getKeyId();
			if (activity.getStatusMap().containsKey(keyId)) {// 已领取奖励
				builder.addActivityCond(PbHelper.createActivityCondPb(e, 1));
			} else {// 未领取奖励
				builder.addActivityCond(PbHelper.createActivityCondPb(e, 0));
			}
		}
		int state = currentActivity(player, activity, 0);
		builder.setState(state);
		handler.sendMsgToPlayer(ActGiftPayRs.ext, builder.build());
	}

	/**
	 * vip礼包
	 *
	 * @param handler
	 */
	public void actVipGift(ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		if (player == null) {
			handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
			return;
		}
		Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_VIP_GIFT);
		if (activity == null) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		ActivityBase activityBase = staticActivityDataMgr.getActivityById(activity.getActivityId());
		if (activityBase == null) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		int activityKeyId = activityBase.getKeyId();
		ActVipGiftRs.Builder builder = ActVipGiftRs.newBuilder();
		List<StaticActQuota> quotaList = staticActivityDataMgr.getQuotaList(activityKeyId);
		for (StaticActQuota e : quotaList) {
			int keyId = e.getQuotaId();
			if (activity.getStatusMap().containsKey(keyId)) {// 已领取奖励
				builder.addQuotaVip(PbHelper.createQuotaVipPb(e, 1));
			} else {// 未领取奖励
				builder.addQuotaVip(PbHelper.createQuotaVipPb(e, 0));
			}
		}
		handler.sendMsgToPlayer(ActVipGiftRs.ext, builder.build());
	}

	/**
	 * 购买vip礼包
	 *
	 * @param DoActVipGiftRq
	 * @param handler
	 */
	public void doActVipGiftRq(DoActVipGiftRq req, ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		if (player == null) {
			handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
			return;
		}
		Lord lord = player.lord;
		if (lord == null) {
			handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
			return;
		}
		Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_VIP_GIFT);
		if (activity == null) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		ActivityBase activityBase = staticActivityDataMgr.getActivityById(activity.getActivityId());
		if (activityBase == null) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		int vip = req.getVip();
		if (lord.getVip() < vip) {
			handler.sendErrorMsgToPlayer(GameError.VIP_NOT_ENOUGH);
			return;
		}

		int activityKeyId = activityBase.getKeyId();

		StaticActQuota staticActQuota = null;
		List<StaticActQuota> quotaList = staticActivityDataMgr.getQuotaList(activityKeyId);
		for (StaticActQuota e : quotaList) {
			if (vip == e.getCond()) {
				staticActQuota = e;
				break;
			}
		}
		if (staticActQuota == null) {
			handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
			return;
		}
		if (lord.getGold() < staticActQuota.getPrice()) {
			handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
			return;
		}
		Map<Integer, Integer> statusMap = activity.getStatusMap();
		if (statusMap.containsKey(staticActQuota.getQuotaId())) {
			handler.sendErrorMsgToPlayer(GameError.BUY_ONLY_ONCE);
			return;
		}
		// int serverId = player.account.getServerId();
		statusMap.put(staticActQuota.getQuotaId(), 1);

		playerDataManager.subGold(player, staticActQuota.getPrice(), AwardFrom.VIP_GIFT);
		DoActVipGiftRs.Builder builder = DoActVipGiftRs.newBuilder();

		List<List<Integer>> awardList = staticActQuota.getAwardList();
		for (List<Integer> e : awardList) {
			if (e.size() < 3) {
				continue;
			}
			int type = e.get(0);
			int id = e.get(1);
			int count = e.get(2);
			int keyId = playerDataManager.addAward(player, type, id, count, AwardFrom.VIP_GIFT);
			builder.addAward(PbHelper.createAwardPb(type, id, count, keyId));
			// LogHelper.logActivity(lord, activity.getActivityId(),
			// staticActQuota.getPrice(), type, id, count, serverId);
		}
		builder.setGold(lord.getGold());
		handler.sendMsgToPlayer(DoActVipGiftRs.ext, builder.build());

		LogLordHelper.logActivity(staticActivityDataMgr, player, ActivityConst.ACT_VIP_GIFT, AwardFrom.VIP_GIFT, awardList,
				staticActQuota.getPrice());
	}

	/**
	 * 连续充值
	 *
	 * @param handler
	 */
	public void actPayContu4(ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		if (player == null) {
			handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
			return;
		}
		Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_PAY_CONTINUE4);
		if (activity == null) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		ActivityBase activityBase = staticActivityDataMgr.getActivityById(activity.getActivityId());
		if (activityBase == null) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		int activityKeyId = activityBase.getKeyId();
		ActPayContu4Rs.Builder builder = ActPayContu4Rs.newBuilder();
		List<StaticActAward> condList = staticActivityDataMgr.getActAwardById(activityKeyId);
		for (StaticActAward e : condList) {
			int keyId = e.getKeyId();
			if (activity.getStatusMap().containsKey(keyId)) {// 已领取奖励
				builder.addActivityCond(PbHelper.createActivityCondPb(e, 1));
			} else {// 未领取奖励
				builder.addActivityCond(PbHelper.createActivityCondPb(e, 0));
			}
		}
		int status = currentActivity(player, activity, 0);
		builder.setState(status);
		handler.sendMsgToPlayer(ActPayContu4Rs.ext, builder.build());
	}

	/**
	 * 连续充值(新)
	 *
	 * @param handler
	 */
	public void actContuPayMoreRq(ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		if (player == null) {
			handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
			return;
		}
		Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_CONTU_PAY_MORE);
		if (activity == null) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		ActivityBase activityBase = staticActivityDataMgr.getActivityById(activity.getActivityId());
		if (activityBase == null) {
			handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
			return;
		}
		int activityKeyId = activityBase.getKeyId();
		ActContuPayMoreRs.Builder builder = ActContuPayMoreRs.newBuilder();
		List<StaticActAward> condList = staticActivityDataMgr.getActAwardById(activityKeyId);
		if (condList == null) {
			handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
			return;
		}
		for (StaticActAward e : condList) {
			int keyId = e.getKeyId();
			if (activity.getStatusMap().containsKey(keyId)) {
				builder.addActivityCond(PbHelper.createActivityCondPb(e, 1));
			} else {
				builder.addActivityCond(PbHelper.createActivityCondPb(e, 0));
			}
			int status = currentActivity(player, activity, e.getSortId());
			builder.addState(status);
		}
		handler.sendMsgToPlayer(ActContuPayMoreRs.ext, builder.build());
	}

	/**
	 * player活动状况
	 *
	 * @param player
	 * @param activity
	 * @return
	 */
	public List<ActStatus> getActivityTips(Player player, ActivityBase activityBase, Activity activity) {
		List<ActStatus> list = new ArrayList<>();
		if (activity == null) {
			return list;
		}
		int activityId = activity.getActivityId();
		if (activityBase.getStaticActivity().getClean() == 1) {// 活动如果需要每日刷新
			activityDataManager.refreshDay(activity);
		}
		Map<Integer, Integer> statusMap = activity.getStatusMap();
		List<StaticActAward> condList = staticActivityDataMgr.getActAwardById(activityBase.getKeyId());
		switch (activityId) {
		/***
		 * 单记录类 ：1等级,2雷霆计划,11激情关卡 13充值红包，14每日充值 ,22疯狂竞技,28消费有奖,34天天充值,36在线时长,37每月登录,42充值送礼
		 ***/
		case ActivityConst.ACT_LEVEL:
		case ActivityConst.ACT_ATTACK:
		case ActivityConst.ACT_ATTACK2:
		case ActivityConst.ACT_COMBAT:
		case ActivityConst.ACT_RED_GIFT:
		case ActivityConst.ACT_PAY_EVERYDAY:
		case ActivityConst.ACT_CRAZY_ARENA:
		case ActivityConst.ACT_COST_GOLD:
		case ActivityConst.ACT_COST_GOLD_MERGE:
		case ActivityConst.ACT_DAY_PAY:
		case ActivityConst.ACT_GIFT_OL:
		case ActivityConst.ACT_MONTH_LOGIN:
		case ActivityConst.ACT_GIFT_PAY_MERGE:
		case ActivityConst.ACT_GIFT_PAY:
		case ActivityConst.ACT_SECRET_STUDY_COUNT: {
			int status = currentActivity(player, activity, 0);
			if (status != 0) {
				for (StaticActAward e : condList) {
					if (status < e.getCond() || statusMap.containsKey(e.getKeyId())) {// 未完成或者已领取
						continue;
					}
					ActStatus actStatus = new ActStatus(activityId, e.getKeyId(), e.getCond(), status, 0);
					list.add(actStatus);
				}
			}
			break;
		}

		/*** 排行类：3战力排行，4关卡排行,5荣誉排行 ***/
		case ActivityConst.ACT_RANK_FIGHT: // 战力排行
		case ActivityConst.ACT_RANK_COMBAT: // 关卡排行
		case ActivityConst.ACT_RANK_HONOUR: // 荣誉排行
		{
			if (statusMap.size() == 0) {// 没有记录时
				int status = currentActivity(player, activity, 0);
				if (status != 0) {// 有排名
					StaticActAward entity = null;
					for (StaticActAward e : condList) {
						if (status <= e.getCond()) {
							if (entity == null) {
								entity = e;
							} else {
								if (entity.getCond() > e.getCond()) {
									entity = e;
								}
							}
						}
					}
					if (entity != null && statusMap.containsKey(entity.getKeyId())) {
						ActStatus actStatus = new ActStatus(activityId, entity.getKeyId(), entity.getCond(), status, 0);
						list.add(actStatus);
					}
				}
			}
			break;
		}

		/*** 多记录类：7军团募集,10资源采集 ,21紫装升级,23疯狂进阶 ,41每天充值返利 ***/
		case ActivityConst.ACT_PARTY_DONATE:
		case ActivityConst.ACT_COLLECT_RESOURCE:
		case ActivityConst.ACT_PURPLE_UP:
		case ActivityConst.ACT_CRAZY_HERO:
		case ActivityConst.ACT_RE_FRIST_PAY: {
			for (StaticActAward e : condList) {
				int status = currentActivity(player, activity, e.getSortId());
				if (status < e.getCond() || statusMap.containsKey(e.getKeyId())) {
					continue;
				}
				ActStatus actStatus = new ActStatus(activityId, e.getKeyId(), e.getCond(), status, 0);
				list.add(actStatus);
			}
			break;
		}
		/*** 特殊单独处理 ***/
		case ActivityConst.ACT_INVEST: {// 投资计划
			Long haveBuy = activity.getStatusList().get(0);
			if (haveBuy == 0) {// 没购买
				break;
			}
			int status = PlayerDataManager.getBuildingLv(BuildingId.COMMAND, player.building);
			for (StaticActAward e : condList) {
				if (status < e.getCond() || statusMap.containsKey(e.getKeyId())) {
					continue;
				}
				ActStatus actStatus = new ActStatus(activityId, e.getKeyId(), e.getCond(), status, 0);
				list.add(actStatus);
			}
			break;
		}
		case ActivityConst.ACT_PURPLE_COLL: {// 紫装收集
			int status = 0;
			for (int i = 0; i < 7; i++) {
				Map<Integer, Equip> equipMap = player.equips.get(i);
				Iterator<Equip> it = equipMap.values().iterator();
				while (it.hasNext()) {
					Equip next = it.next();
					if (next.getPos() == 0) {
						continue;
					}
					int equipId = next.getEquipId();
					StaticEquip staticEquip = staticEquipDataMgr.getStaticEquip(equipId);
					if (staticEquip != null && staticEquip.getQuality() == 4) {
						status++;
					}
				}
			}
			for (StaticActAward e : condList) {
				if (status < e.getCond() || statusMap.containsKey(e.getKeyId())) {
					continue;
				}
				ActStatus actStatus = new ActStatus(activityId, e.getKeyId(), e.getCond(), status, 0);
				list.add(actStatus);
			}
			break;
		}
		case ActivityConst.ACT_CONTU_PAY: {// 连续充值
			List<Long> statusList = activity.getStatusList();
			int status = 0;
			for (int i = 0; i < statusList.size() && i < 7; i++) {
				long ss = statusList.get(i);
				if (ss >= 1000) {
					status++;
				}
			}
			for (StaticActAward e : condList) {
				if (status < e.getCond() || statusMap.containsKey(e.getKeyId())) {
					continue;
				}
				ActStatus actStatus = new ActStatus(activityId, e.getKeyId(), e.getCond(), status, 0);
				list.add(actStatus);
			}
			break;
		}
		case ActivityConst.ACT_PAY_CONTINUE4: {// 连续充值
			List<Long> statusList = activity.getStatusList();
			int status = 0;
			for (int i = 0; i < statusList.size() && i < 4; i++) {
				long ss = statusList.get(i);
				if (ss > 0) {
					status++;
				}
			}
			for (StaticActAward e : condList) {
				if (status < e.getCond() || statusMap.containsKey(e.getKeyId())) {
					continue;
				}
				ActStatus actStatus = new ActStatus(activityId, e.getKeyId(), e.getCond(), status, 0);
				list.add(actStatus);
			}
			break;
		}
		case ActivityConst.ACT_POWER_GIVE: {// 能量赠送
			List<StaticActivityTime> timeList = staticActivityDataMgr.getActivityTimeById(ActivityConst.ACT_POWER_GIVE);
			if (CheckNull.isEmpty(timeList) || !timeList.get(0).getOpenWeekDay().contains(TimeHelper.getCNDayOfWeek())) {
				break;
			}
			if (null == activity.getStatusList() || activity.getStatusList().size() == 0) {
				activity.setStatusList(new ArrayList<Long>());
				int totday = TimeHelper.getCurrentDay();
				if (activity.getEndTime() != totday) {
					activity.setEndTime(totday);
					activity.getStatusList().clear();
					for (int i = 0; i < timeList.size(); i++) {
						activity.getStatusList().add(1L);
					}
				}
			}
			StaticActivityTime sat = activityDataManager.getCurActivityTime(ActivityConst.ACT_POWER_GIVE);
			if (sat != null) {
				int state = activity.getStatusList().get(sat.getTime() - 1).intValue();
				if (state == 1) {
					ActStatus actStatus = new ActStatus(activityId, 0, 0, 0, 0);
					list.add(actStatus);
				}
			}
			break;
		}
		case ActivityConst.ACT_TANK_ANNIVERSARY: { // 坦克周年庆
			Map<Integer, StaticActivityEffect> map = staticActivityDataMgr.getActivityEffectById(ActivityConst.ACT_TANK_ANNIVERSARY);
			int day = DateHelper.dayiy(activityBase.getBeginTime(), new Date());
			StaticActivityEffect effect = map.get(day);
			if (effect == null || activity.getStatusMap().containsKey(day)) {
				break;
			}
			int endTime = TimeHelper.getTomorrowZone() - TimeHelper.getCurrentSecond();
			for (Integer effectId : effect.getEffectId()) {
				if (player.effects.containsKey(effectId)) { // 如果之前有该buff 清楚掉
					player.effects.remove(effectId);
				}
				if (endTime > 0)
					playerDataManager.addEffect(player, effectId, endTime);
			}
			activity.getStatusMap().put(day, 1);
			break;
		}
		case ActivityConst.ACT_CONTU_PAY_MORE: {// 连续充值2
			List<Long> statusList = activity.getStatusList();
			for (StaticActAward e : condList) {
				int status = 0;
				for (int i = 0; i < statusList.size(); i++) {
					long ss = statusList.get(i);
					if (ss >= Integer.valueOf(e.getParam())) {
						status++;
					} else {
						break;
					}
				}
				if (status < e.getCond() || statusMap.containsKey(e.getKeyId())) {
					continue;
				}
				ActStatus actStatus = new ActStatus(activityId, e.getKeyId(), e.getCond(), status, 0);
				list.add(actStatus);
			}
			break;
		}
		case ActivityConst.ACT_MERGE_GIFT: {// 合服领奖
			Date beginTime = activityBase.getBeginTime();
			int dayiy = DateHelper.dayiy(beginTime, new Date()); // 活动第几天
			if (statusMap.get(dayiy) == null) {
				ActStatus actStatus = new ActStatus(activityId, 0, 0, 0, 0);
				list.add(actStatus);
			}
			break;
		}
		/*** 特殊单独处理 ***/
		case ActivityConst.ACT_INVEST_NEW: {// 投资计划
			Long haveBuy = activity.getStatusList().get(0);
			if (haveBuy == 0) {// 没购买
				break;
			}
			int status = PlayerDataManager.getBuildingLv(BuildingId.COMMAND, player.building);
			for (StaticActAward e : condList) {
				if (status < e.getCond() || statusMap.containsKey(e.getKeyId())) {
					continue;
				}
				ActStatus actStatus = new ActStatus(activityId, e.getKeyId(), e.getCond(), status, 0);
				list.add(actStatus);
			}
			break;
		}
		case ActivityConst.ACT_VIP_COUNT: {

			break;
		}
		case ActivityConst.ACT_PAY_EVERYDAY_NEW_1:
		case ActivityConst.ACT_PAY_EVERYDAY_NEW_2:{// 新每日充值 神秘部队
			int status = activity.getStatusList().get(0).intValue();
		    // 当日充值奖励情况
		    StaticActAward e = condList.get(0);
		    ActStatus actStatus;
		    if (status == 0) {// 代表未领取
		        actStatus = new ActStatus(activityId, e.getKeyId(), e.getCond(), 0, 0);
		    } else if (status == 1) { // 已领取
		        actStatus = new ActStatus(activityId, e.getKeyId(), e.getCond(), 1, 0);
		    } else { // 未充值
		        actStatus = new ActStatus(activityId, e.getKeyId(), e.getCond(), 2, 1);
		    }
		    list.add(actStatus); // 加入当日奖励情况
		    
		    // 累计奖励情况
		    for (int i = 1; i < condList.size(); i++) {
		        e = condList.get(i);
		        Integer totalStatus = statusMap.get(e.getKeyId());
		        if (totalStatus == null || totalStatus == 2) {// 未完成
		            actStatus = new ActStatus(activityId, e.getKeyId(), e.getCond(), 2, 0);
		        } else if (totalStatus == 1) {// 已领取
		            actStatus = new ActStatus(activityId, e.getKeyId(), e.getCond(), 1, 0);
		        } else {// 未领取
		            actStatus = new ActStatus(activityId, e.getKeyId(), e.getCond(), 0, 1);
		        }
		        list.add(actStatus);
		    }
		    break;
		}
		case ActivityConst.ACT_PAY_PARTY:{//军团充值 
			//int status = activity.getStatusList().get(0).intValue();
		    // 当日充值奖励情况
		    StaticActAward e = null;
		    ActStatus actStatus;
		    // 累计奖励情况
		    for (int i = 1; i < condList.size(); i++) {
		        e = condList.get(i);
		        Integer totalStatus = statusMap.get(e.getKeyId());
		        if (totalStatus == null || totalStatus == 2) {// 未完成
		            actStatus = new ActStatus(activityId, e.getKeyId(), e.getCond(), 2, 0);
		        } else if (totalStatus == 1) {// 已领取
		            actStatus = new ActStatus(activityId, e.getKeyId(), e.getCond(), 1, 0);
		        } else {// 未领取
		            actStatus = new ActStatus(activityId, e.getKeyId(), e.getCond(), 0, 1);
		        }
		        list.add(actStatus);
		    }
		    break;
		}
		
		
		default:
			break;
		}
		return list;
	}

	/**
	 * 活动最新状态值
	 *
	 * @param player
	 * @param activityId
	 * @param keyId
	 * @return
	 */
	public int currentActivity(Player player, Activity activity, int sortId) {
		ActivityBase activityBase = staticActivityDataMgr.getActivityById(activity.getActivityId());
		if(activityBase == null){
			return 0;
		}
		List<StaticActAward> condList = staticActivityDataMgr.getActAwardById(activityBase.getKeyId());
		switch (activity.getActivityId()) {
		case ActivityConst.ACT_LEVEL:// 等级
			return player.lord.getLevel();
		case ActivityConst.ACT_ATTACK: {// 攻打玩家
			return (int) activity.getStatusList().get(sortId).longValue();
		}
		case ActivityConst.ACT_RANK_FIGHT: {// 战力排行
			return (int) activity.getStatusList().get(sortId).longValue();
		}
		case ActivityConst.ACT_RANK_COMBAT: {// 关卡排行
			return (int) activity.getStatusList().get(sortId).longValue();
		}
		case ActivityConst.ACT_RANK_HONOUR: {// 荣誉排行
			return (int) activity.getStatusList().get(sortId).longValue();
		}
		case ActivityConst.ACT_RANK_PARTY_LV: {// 军团等级排行
			return (int) activity.getStatusList().get(sortId).longValue();
		}
		case ActivityConst.ACT_PARTY_DONATE: {// 捐献次数领奖
			return (int) activity.getStatusList().get(sortId).longValue();
		}
		case ActivityConst.ACT_COLLECT_RESOURCE: {// 资源收集
			long status = activity.getStatusList().get(sortId);
			if (status > Integer.MAX_VALUE) {
				return Integer.MAX_VALUE;
			}
			return (int) status;
		}
		case ActivityConst.ACT_COMBAT: {// 激情关卡
			return (int) activity.getStatusList().get(sortId).longValue();
		}
		case ActivityConst.ACT_RANK_PARTY_FIGHT: {// 军团战力排行
			if (activity.getStatusList().size() == 0) {
				return 0;
			}
			long status = activity.getStatusList().get(sortId);
			return (int) status;
		}
		case ActivityConst.ACT_INVEST: {// 投资计划
			Long status = activity.getStatusList().get(sortId);
			if (status == 0) {
				return 0;
			}
			return PlayerDataManager.getBuildingLv(BuildingId.COMMAND, player.building);
		}
		case ActivityConst.ACT_RED_GIFT: {// 充值红包
			return (int) activity.getStatusList().get(sortId).longValue();
		}
		case ActivityConst.ACT_PAY_EVERYDAY: {// 每日充值
			return (int) activity.getStatusList().get(sortId).longValue();
		}
		case ActivityConst.ACT_PAY_FIRST: {// 玩家首次充值
			return (int) activity.getStatusList().get(sortId).longValue();
		}
		case ActivityConst.ACT_QUOTA: {// 半价
			return 0;
		}
		case ActivityConst.ACT_PURPLE_COLL: {// 紫装收集
			long statusr = activity.getStatusList().get(sortId);
			if (statusr >= 18) {
				return (int) statusr;
			} else {
				int status = 0;
				for (int i = 0; i < 7; i++) {
					Map<Integer, Equip> equipMap = player.equips.get(i);
					Iterator<Equip> it = equipMap.values().iterator();
					while (it.hasNext()) {
						Equip next = it.next();
						if (next.getPos() == 0) {
							continue;
						}
						int equipId = next.getEquipId();
						StaticEquip staticEquip = staticEquipDataMgr.getStaticEquip(equipId);
						if (staticEquip != null && staticEquip.getQuality() == 4) {
							status++;
						}
					}
				}
				activity.getStatusList().set(sortId, (long) status);
				return status;
			}
		}
		case ActivityConst.ACT_PURPLE_UP: {// 紫装升级
			return (int) activity.getStatusList().get(sortId).longValue();
		}
		case ActivityConst.ACT_CRAZY_ARENA: {// 疯狂竞技
			return (int) activity.getStatusList().get(sortId).longValue();
		}
		case ActivityConst.ACT_CRAZY_HERO: {// 疯狂进阶
			return (int) activity.getStatusList().get(sortId).longValue();
		}
		case ActivityConst.ACT_PART_EVOLVE: {// 配件进化
			return 0;
		}
		case ActivityConst.ACT_FLASH_SALE: {// 限时出售
			return 0;
		}
		case ActivityConst.ACT_ENLARGE: {// 招兵买将
			return 0;
		}
		case ActivityConst.ACT_LOTTEY_EQUIP: {// 抽装折扣
			return 0;
		}
		case ActivityConst.ACT_COST_GOLD:
		case ActivityConst.ACT_COST_GOLD_MERGE: {// 消费有奖/合服消费
			return (int) activity.getStatusList().get(sortId).longValue();
		}
		case ActivityConst.ACT_EQUIP_FEED: {// 装备补给
			return 0;
		}
		case ActivityConst.ACT_CONTU_PAY: {// 连续充值
			List<Long> statusList = activity.getStatusList();
			int status = 0;
			for (int i = 0; i < statusList.size() && i < 7; i++) {
				long ss = statusList.get(i);
				if (ss > 0) {
					status++;
				}
			}
			return status;
		}
		case ActivityConst.ACT_PAY_FOISON: {// 充值丰收
			return (int) activity.getStatusList().get(sortId).longValue();
		}
		case ActivityConst.ACT_DAY_PAY: {// 天天充值
			return (int) activity.getStatusList().get(sortId).longValue();
		}
		case ActivityConst.ACT_DAY_BUY: // 天天限购
			return 0;
		case ActivityConst.ACT_FLASH_META: // 限购材料
			return 0;
		case ActivityConst.ACT_MONTH_SALE: {// 每月限购
			return 0;
		}
		case ActivityConst.ACT_GIFT_OL: {// 在线时长领奖
			return player.onLineTime();
		}
		case ActivityConst.ACT_MONTH_LOGIN: {// 每月登录天数领奖
			return player.lord.getOlMonth() % 100;
		}
		case ActivityConst.ACT_RE_FRIST_PAY: {// 首充返利
			return (int) activity.getStatusList().get(sortId).longValue();
		}
		case ActivityConst.ACT_GIFT_PAY:
		case ActivityConst.ACT_GIFT_PAY_MERGE: {// 充值送礼
			return (int) activity.getStatusList().get(sortId).longValue();
		}
		case ActivityConst.ACT_PAY_CONTINUE4: {// 充值送礼
			int status = 0;
			for (int i = 0; i < 4; i++) {
				long v = activity.getStatusList().get(i);
				if (v > 0)
					status++;
			}
			return status;
		}
		case ActivityConst.ACT_BEE_NEW_ID: // 勤劳致富 （新）
		case ActivityConst.ACT_BEE_ID: {// 勤劳致富
			long status = activity.getStatusList().get(sortId);
			if (status > Integer.MAX_VALUE) {
				return Integer.MAX_VALUE;
			}
			return (int) status;
		}
		case ActivityConst.ACT_TANK_DESTORY_ID: {// 疯狂歼灭
			return (int) activity.getStatusList().get(sortId).longValue();
		}
		case ActivityConst.ACT_CONTU_PAY_MORE: { // 连续充值(新)
			int status = 0;
			for (StaticActAward e : condList) {
				if (e.getSortId() != sortId) {
					continue;
				}
				for (int i = 0; i < activity.getStatusList().size(); i++) {
					long ss = activity.getStatusList().get(i);
					if (ss >= Integer.valueOf(e.getParam())) {
						status++;
					} else {
						break;
					}
				}
			}
			return status;
		}
		case ActivityConst.ACT_ATTACK2: {// 攻打玩家2
			return (int) activity.getStatusList().get(sortId).longValue();
		}
		case ActivityConst.ACT_INVEST_NEW: {// 投资计划
			Long status = activity.getStatusList().get(sortId);
			if (status == 0) {
				return 0;
			}
			return PlayerDataManager.getBuildingLv(BuildingId.COMMAND, player.building);
		}
		case ActivityConst.ACT_PAY_EVERYDAY_NEW_1:
		case ActivityConst.ACT_PAY_EVERYDAY_NEW_2:
		case ActivityConst.ACT_PAY_PARTY:
		case ActivityConst.ACT_MERGE_GIFT: {
			return 1;
		}
		case ActivityConst.ACT_SECRET_STUDY_COUNT: {// 秘密武器洗练次数活动
			return activity.getStatusList().get(sortId).intValue();
		}
		case ActivityConst.ACT_VIP_COUNT: {// VIP数量
			UsualActivityData usualActivity = activityDataManager.getUsualActivity(ActivityConst.ACT_VIP_COUNT);
			Integer cnt = usualActivity.getStatusMap().get(sortId);
			return cnt != null ? cnt : 0;
		}
		case ActivityConst.ACT_LOTTERY_EXPLORE: {// 秘密武器洗练次数活动
			return activity.getStatusList().get(sortId).intValue();
		}
		default:
			break;
		}
		return 0;
	}

	/**
	 * Funcion 凌晨定时对需要做记录的活动进行记录
	 */
	public void activityTimeLogic() {
		LogUtil.info("执行排行榜任务");
		Date now = new Date();
		/*** 战力排行(前三十名) ***/
		rankLogic(now, ActivityConst.ACT_RANK_FIGHT, 1, 30);
		/*** 关卡排行(前五名) ***/
		rankLogic(now, ActivityConst.ACT_RANK_COMBAT, 2, 5);
		/*** 荣誉排行(前五名) ***/
		rankLogic(now, ActivityConst.ACT_RANK_HONOUR, 3, 10);
		/*** 军团等级排行(前十名) ***/
		partyLvRankLogic(ActivityConst.ACT_RANK_PARTY_LV, 10);
		/*** 军团战力排行(前三名) ***/
		partyFightRankLogic(ActivityConst.ACT_RANK_PARTY_FIGHT, 3);
	}

	/**
	 * 活动个人排行结算
	 *
	 * @param now
	 * @param activityId
	 * @param type
	 * @param count void
	 */
	public void rankLogic(Date now, int activityId, int type, int count) {
		try {
			ActivityBase activityBase = staticActivityDataMgr.getActivityById(activityId);
			if (activityBase == null) {
				return;
			}
			long endTime = activityBase.getEndTime().getTime();
			long period[] = { endTime - 10 * 60 * 1000, endTime + 10 * 60 * 1000 };
			if (now.getTime() < period[0] || now.getTime() > period[1]) {
				return;
			}
			long rank = 1;
			Date beginTime = activityBase.getBeginTime();
			int begin = TimeHelper.getDay(beginTime);
			Iterator<Lord> it = rankDataManager.getRankList(type).iterator();
			while (it.hasNext()) {
				Lord next = it.next();
				Player player = playerDataManager.getPlayer(next.getLordId());
				Activity activity = player.activitys.get(activityId);
				if (activity == null) {
					activity = new Activity(activityBase, begin);
					activityDataManager.refreshStatus(activity);
					player.activitys.put(activityId, activity);
				} else {
					activity.isReset(begin);
				}
				activity.getStatusList().set(0, (long) rank++);
			}
		} catch (Exception e) {
			LogUtil.error("", e);
		}
	}

	/**
	 * 军团等级前十,等级相同ID小则排前面
	 *
	 * @param now
	 * @param activityId
	 * @param count
	 */
	public void partyLvRankLogic(int activityId, int count) {
		try {
			ActivityBase activityBase = staticActivityDataMgr.getActivityById(activityId);
			if (activityBase == null) {
				return;
			}
			Date now = new Date();
			long endTime = activityBase.getEndTime().getTime();
			long period[] = { endTime - 10 * 60 * 1000, endTime + 10 * 60 * 1000 };
			if (now.getTime() < period[0] || now.getTime() > period[1]) {
				return;
			}
			LogUtil.common("军团等级排行榜");
			int begin = TimeHelper.getDay(activityBase.getBeginTime());
			int end = TimeHelper.getDay(activityBase.getEndTime());
			List<PartyLvRank> list = activityDataManager.getPartyLvRankList();
			Collections.sort(list, new ComparePartyLv());
			Iterator<PartyLvRank> it = list.iterator();
			int rank = 1;
			while (it.hasNext()) {
				PartyLvRank next = it.next();
				PartyData partyData = partyDataManager.getParty(next.getPartyId());
				Activity activity = partyData.getActivitys().get(activityId);
				if (activity == null) {
					activity = new Activity(activityBase, begin);
					activityDataManager.refreshStatus(activity);
					partyData.getActivitys().put(activityId, activity);
				} else {
					activity.isReset(begin);
					// 兼容老数据
					if (activity.getStatusList().size() != 5) {
						List<Long> statusList = new ArrayList<>(5);
						for (int i = 0; i < 5; i++) {
							statusList.add(0L);
						}
						activity.setStatusList(statusList);
					}
				}
				activity.setEndTime(end);
				// 军团当前等级排名
				List<Long> statusList = activity.getStatusList();
				next.setRank(rank);
				statusList.set(0, (long) rank);
				statusList.set(1, (long) next.getPartyLv());
				statusList.set(2, (long) next.getScienceLv());
				statusList.set(3, (long) next.getWealLv());
				statusList.set(4, (long) next.getBuild());
				rank++;
				LogUtil.common("party lv rank info : " + next);
			}
		} catch (Exception e) {
			e.printStackTrace();
		}

	}

	/**
	 * 军团总战力前3,军团内部排名前10进行记录
	 *
	 * @param now
	 * @param activityId
	 * @param count
	 */
	public void partyFightRankLogic(int activityId, int count) {
		try {
			ActivityBase activityBase = staticActivityDataMgr.getActivityById(activityId);
			if (activityBase == null) {
				return;
			}
			Date now = new Date();
			long endTime = activityBase.getEndTime().getTime();
			LogUtil.info("endTime :" + endTime);
			LogUtil.info("nowTime :" + now.getTime());
			long period[] = { endTime - 10 * 60 * 1000, endTime + 10 * 60 * 1000 };
			if (now.getTime() < period[0] || now.getTime() > period[1]) {
				return;
			}
			Date beginTime = activityBase.getBeginTime();
			int begin = TimeHelper.getDay(beginTime);

			List<PartyRank> rankList = new ArrayList<>();
			Map<Integer, PartyData> partyMap = partyDataManager.getPartyMap();
			Iterator<PartyData> it = partyMap.values().iterator();
			while (it.hasNext()) {
				long fight = 0L;
				PartyData partyData = it.next();
				int partyId = partyData.getPartyId();
				List<Member> list = partyDataManager.getMemberList(partyId);
				if (list != null) {
					Iterator<Member> memberIt = list.iterator();
					while (memberIt.hasNext()) {
						Member member = memberIt.next();
						Player player = playerDataManager.getPlayer(member.getLordId());
						if (player != null) {
							fight += player.lord.getFight();
						}
					}
					PartyRank temp = new PartyRank(partyId, 0, fight);
					rankList.add(temp);
				}
			}
			Collections.sort(rankList, new CompareParty());
			Iterator<PartyRank> rankIt = rankList.iterator();
			long rank = 1;
			while (rankIt.hasNext()) {
				PartyRank next = rankIt.next();
				PartyData partyData = partyDataManager.getParty(next.getPartyId());
				Activity activity = partyData.getActivitys().get(activityId);
				if (activity == null) {
					activity = new Activity(activityBase, begin);
					activityDataManager.refreshStatus(activity);
					partyData.getActivitys().put(activityId, activity);
				} else {
					activity.isReset(begin);
				}
				// 军团当前等级排名
				List<Long> statusList = activity.getStatusList();
				statusList.clear();
				statusList.add(rank++);
				// 记录帮派战斗力前十玩家,
				if (rank < 5) {
					List<Member> list = partyDataManager.getMemberList(next.getPartyId());
					List<Lord> lordRankList = new ArrayList<>();
					Iterator<Member> mit = list.iterator();
					while (mit.hasNext()) {
						Player player = playerDataManager.getPlayer(mit.next().getLordId());
						lordRankList.add(player.lord);
					}

					Collections.sort(lordRankList, new CompareLordFight());

					int rankId = 1;
					for (int i = 0; i < 10 && i < lordRankList.size(); i++) {
						Lord lord = lordRankList.get(i);
						statusList.add(lord.getLordId());
						LogUtil.info("rankId" + rankId++ + "|nick:" + lord.getNick() + "|fight：" + lord.getFight());
					}
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	/**
	 * 定时玩家互动数据持久化 void
	 */
	public void saveActivityTimerLogic() {
		Iterator<UsualActivityData> iterator = activityDataManager.getActivityMap().values().iterator();
		int now = TimeHelper.getCurrentSecond();
		int saveCount = 0;
		while (iterator.hasNext()) {
			UsualActivityData usualActivity = iterator.next();
			if (now - usualActivity.getLastSaveTime() >= 150) {
				saveCount++;
				try {
					usualActivity.setLastSaveTime(now);
					GameServer.getInstance().saveActivityServer.saveData(usualActivity.copyData());
				} catch (Exception e) {
					LogUtil.error("save activity {" + usualActivity.getActivityId() + "} data error", e);
				}
			}
		}

		if (saveCount != 0) {
			LogUtil.save("save activity count:" + saveCount);
		}
	}

	
	/**
	 * 最新累计充值
	 * @param getNewPayEverydayHandler
	 */
	public void getNewPayEveryDay(ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }
        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_PAY_EVERYDAY_NEW_1);
        if (activity == null) {
            activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_PAY_EVERYDAY_NEW_2);
            if (activity == null) {
                handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
                return;
            }
        }
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(activity.getActivityId());
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        
        GetNewPayEverydayRs.Builder builder = GetNewPayEverydayRs.newBuilder();
        Map<Integer, Integer> statusMap = activity.getStatusMap();
        List<StaticActAward> condList = staticActivityDataMgr.getActAwardById(activityBase.getPlan().getAwardId());
        for (StaticActAward e : condList) {
            if (e.getCond() == 1) {
                builder.addActivityCond(PbHelper.createActivityCondPb(e, activity.getStatusList().get(0).intValue()));
            } else {
                int keyId = e.getKeyId();
                Integer status = statusMap.get(keyId);
                if (status == null) {
                    status = 2;
                }
                builder.addActivityCond(PbHelper.createActivityCondPb(e, status));
            }
        }
        int days = 0;
        Integer max = statusMap.get(0); // 充值天数
        if (max != null) {
            days = max;
        }
        builder.setDays(days);
        builder.setActivity(PbHelper.createActivityPb(activityBase, true, 0));
        handler.sendMsgToPlayer(GetNewPayEverydayRs.ext, builder.build());
	}
	
	/**
	 * 军团充值活动
	 * @param handler
	 */
	public void getPartyRecharge(ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }
        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_PAY_PARTY);
        if (activity == null) {
        	handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(activity.getActivityId());
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }
        
        Date displayDate = activityBase.getDisplayTime();
        Date endDate = activityBase.getEndTime();
        boolean open =false;
        if(TimeHelper.getCurrentDate().after(endDate)&&TimeHelper.getCurrentDate().before(displayDate)) {
        	open= true;
        }
        
        int allGold = 0;
        int partyId = 0;
        Member member = partyDataManager.getMemberById(player.roleId);
        PartyData partyData = member != null ? partyDataManager.getParty(member.getPartyId()) : null;
        if(partyData==null || player.lord.getOldPartyId()>0) {
        	partyData = partyDataManager.getParty(player.lord.getOldPartyId());
        }
        
        Map<Integer, Integer> statusMap = activity.getStatusMap();
        GetPartyRechargeRs.Builder builder = GetPartyRechargeRs.newBuilder();
        List<StaticActAward> condList = staticActivityDataMgr.getActAwardById(activityBase.getPlan().getAwardId());
        for (StaticActAward e : condList) {
                int keyId = e.getKeyId();
                Integer status = statusMap.get(keyId);
                if (status == null|| !open) {
                    status = 2;
                }
                if(open&&partyData!=null&&partyData.getTeamRecharge()>e.getCond()&&status==2) {
                	status = 0;
                }
                if(open&&player.lord.getOldPartyId()==0) {
                	status=2;
                }
                builder.addActivityCond(PbHelper.createActivityCondPb(e, status));
        }
        
//        int allGold = 0;
//        int partyId = 0;
//        Member member = partyDataManager.getMemberById(player.roleId);
//        PartyData partyData = member != null ? partyDataManager.getParty(member.getPartyId()) : null;
//        if(partyData==null || player.lord.getOldPartyId()>0) {
//        	partyData = partyDataManager.getParty(player.lord.getOldPartyId());
//        }
        if (partyData != null) {
        	allGold=(int) partyData.getTeamRecharge();
        	partyId = partyData.getPartyId();
        }
        
        if(member!=null) {
        	if(player.lord.getOldPartyId()==0) {
        		if(TimeHelper.getDay(activityBase.getPlan().getEndTime())<member.getEnterTime()&&TimeHelper.getDay(activityBase.getPlan().getDisplayTime())>=member.getEnterTime()) {
        			allGold = 0;
        		}
        	}
        }
        
        if(player.lord.getOldPartyId()>0) {
        	partyId=player.lord.getOldPartyId();
        }
        if(allGold>0) {
        	builder.setPartyId(partyId);
        }
        builder.setTotalGold(allGold);
        //builder.setActivity(PbHelper.createActivityPb(activityBase, open, 0));
        handler.sendMsgToPlayer(GetPartyRechargeRs.ext, builder.build());
        
        
	}
	
	
	
	
}
