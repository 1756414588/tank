package com.game.service;

import com.game.actor.role.PlayerEventService;
import com.game.constant.*;
import com.game.dataMgr.StaticDrillDataManager;
import com.game.dataMgr.StaticTankDataMgr;
import com.game.dataMgr.StaticWarAwardDataMgr;
import com.game.domain.Player;
import com.game.domain.p.Lord;
import com.game.domain.p.Resource;
import com.game.domain.p.Tank;
import com.game.domain.s.StaticDrillBuff;
import com.game.domain.s.StaticDrillShop;
import com.game.drill.domain.*;
import com.game.manager.DrillDataManager;
import com.game.manager.PlayerDataManager;
import com.game.manager.StaffingDataManager;
import com.game.message.handler.ClientHandler;
import com.game.pb.CommonPb;
import com.game.pb.CommonPb.RptAtkFortress;
import com.game.pb.GamePb4.*;
import com.game.util.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.Map.Entry;

/**
 * @ClassName DrillService.java
 * @Description 红蓝大战
 * @author TanDonghai
 * @date 创建时间：2016年8月8日 下午5:59:58
 *
 */
@Service
public class DrillService {
	@Autowired
	private StaticDrillDataManager staticDrillDataManager;

	@Autowired
	private StaticWarAwardDataMgr staticWarAwardDataMgr;

	@Autowired
	private StaticTankDataMgr staticTankDataMgr;

	@Autowired
	private StaffingDataManager staffingDataManager;

	@Autowired
	private PlayerDataManager playerDataManager;

	@Autowired
	private DrillDataManager drillDataManager;

	@Autowired
	private ChatService chatService;

	@Autowired
	private PlayerEventService playerEventService;

	/**
	 * 获取红蓝大战的状态信息等数据
	 * 
	 * @param handler
	 */
	public void getDrillData(ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());

		if (staffingDataManager.getWorldLv() < 1) {
			handler.sendErrorMsgToPlayer(GameError.DRILL_WORLD_LV_LIMIT);
			return;
		}

		DrillFightData data = player.drillFightData;
		int camp = 0;// 玩家所在的阵营，0 未分配，1 红方，2 蓝方
		int status = DrillDataManager.getDrillStatus();

		if (null != data && data.getLastEnrollDate() != drillDataManager.getLastOpenDrillDate()) {
			data.clearSuccessNum();
			data.getRecordKeyMap().clear();
			player.drillKillTank.clear();
		}

		GetDrillDataRs.Builder builder = GetDrillDataRs.newBuilder();
		builder.setStatus(status);
		builder.setEnrollNum(drillDataManager.getEnrolledRoleSet().size());
		builder.setExploit(player.lord.getExploit());
		int armyNum = 0;
		for (int i = FormType.DRILL_1; i <= FormType.DRILL_3; i++) {
			if (null != player.forms.get(i)) {
				armyNum++;
			}
		}
		builder.setMyArmy(armyNum);
		if (drillDataManager.getEnrolledRoleSet().contains(player.lord.getLordId())) {
			builder.setIsEnrolled(true);
			if (null != data && status != DrillConstant.STATUS_ENROLL) {
				camp = data.isRed() ? 1 : 2;
			}
		} else {
			builder.setIsEnrolled(false);
		}
		builder.setCamp(camp);
		if (status != DrillConstant.STATUS_NOT_START) {
			builder.setRedExploit(drillDataManager.redExploit);
			builder.setBlueExploit(drillDataManager.blueExploit);
		}
		for (DrillResult result : drillDataManager.getDrillResult().values()) {
			builder.addRedWin(result.getStatus());
		}
		handler.sendMsgToPlayer(GetDrillDataRs.ext, builder.build());
	}

	/**
	 * 玩家报名参加红蓝大战
	 * 
	 * @param handler
	 */
	public void drillEnroll(ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());

		if (staffingDataManager.getWorldLv() < 1) {
			handler.sendErrorMsgToPlayer(GameError.DRILL_WORLD_LV_LIMIT);
			return;
		}

		// 判断红蓝大战的活动状态
		if (DrillDataManager.getDrillStatus() != DrillConstant.STATUS_ENROLL) {
			handler.sendErrorMsgToPlayer(GameError.DRILL_STATUS_EROOR);
			return;
		}

		// 判断玩家是否已报名
		Set<Long> enrollSet = drillDataManager.getEnrolledRoleSet();
		if (enrollSet.contains(player.lord.getLordId())) {
			handler.sendErrorMsgToPlayer(GameError.DRILL_HAS_ENROLLED);
			return;
		}

		// 报名逻辑
		enrollSet.add(player.lord.getLordId());
		DrillFightData data = player.drillFightData;
		if (null == data) {
			data = new DrillFightData();
			data.setLordId(player.lord.getLordId());
			player.drillFightData = data;
		}
		data.setLastEnrollDate(drillDataManager.getLastOpenDrillDate());

		// 返回消息
		DrillEnrollRs.Builder builder = DrillEnrollRs.newBuilder();
		playerDataManager.updTask(player, TaskType.COND_DRILL_FIGHT, 1);//军事演习报名任务进度刷新
		handler.sendMsgToPlayer(DrillEnrollRs.ext, builder.build());
	}

	/**
	 * 兑换演习军力
	 * 
	 * @param tankId
	 * @param count
	 * @param handler
	 */
	public void exchangeDrillTank(int tankId, int count, ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());

		if (staffingDataManager.getWorldLv() < 1) {
			handler.sendErrorMsgToPlayer(GameError.DRILL_WORLD_LV_LIMIT);
			return;
		}

		// 判断玩家基地中的坦克是否足够
		Tank tank = player.tanks.get(tankId);
		if (null == tank || tank.getCount() < count) {
			handler.sendErrorMsgToPlayer(GameError.TANK_COUNT);
			return;
		}

		// 判断玩家活动中的坦克是否会越界
		Tank drillTank = player.drillTanks.get(tankId);
		int add = count * 500;
		if (add <= 0 || (null != drillTank && drillTank.getCount() + add > Integer.MAX_VALUE)) {
			handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
			return;
		}

		// 扣除基地中的坦克
		tank.setCount(tank.getCount() - count);
		LogLordHelper.tank(AwardFrom.DRILL_EXCHANGE_TANk, player.account, player.lord, tankId, tank.getCount(), -count,
				-count, 0);

		// 增加红蓝大战活动中的坦克数量
		if (null == drillTank) {
			drillTank = new Tank(tankId, 0, 0);
			player.drillTanks.put(tankId, drillTank);
		}
		drillTank.setCount(drillTank.getCount() + add);
		LogLordHelper.tank(AwardFrom.DRILL_EXCHANGE_TANk, player.account, player.lord, tankId, tank.getCount(), add,
				0, 0);

		// 返回消息
		ExchangeDrillTankRs.Builder builder = ExchangeDrillTankRs.newBuilder();
		builder.setTankId(tankId);
		builder.setCount(drillTank.getCount());
		handler.sendMsgToPlayer(ExchangeDrillTankRs.ext, builder.build());

		//如果被消耗的是金币坦克，重新计算最强实力
		if (staticTankDataMgr.isGoldTank(tankId)){
            playerEventService.calcStrongestFormAndFight(player);
        }

	}

	/**
	 * 获取红蓝大战的战况
	 * 
	 * @param type
	 * @param which
	 * @param pageNum
	 * @param handler
	 */
	public void getDrillRecord(int type, int which, int pageNum, ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		if (which < 1 || which > 3) {
			handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
			return;
		}

		DrillResult result = drillDataManager.getDrillResult().get(which);

		// 返回消息
		GetDrillRecordRs.Builder builder = GetDrillRecordRs.newBuilder();
		if (null != result && result.isOver()) {// 结果已出的情况下，返回结果
			builder.setResult(PbHelper.createDrillResultPb(result));
		} else {
			if (DrillDataManager.getDrillStatus() != DrillConstant.STATUS_NOT_START) {// 结果未出时，返回该路已设置部队的玩家数
				com.game.pb.CommonPb.DrillResult.Builder dr = com.game.pb.CommonPb.DrillResult.newBuilder();
				dr.setRedRest(drillDataManager.getCampArmyNum(true, which));
				dr.setRedTotal(drillDataManager.getCampArmyNum(true, which));
				dr.setBlueRest(drillDataManager.getCampArmyNum(false, which));
				dr.setBlueTotal(drillDataManager.getCampArmyNum(false, which));
				builder.setResult(dr.build());
			}
		}

		Map<Integer, DrillRecord> map = drillDataManager.getDrillRecords().get(which);
		if (!CheckNull.isEmpty(map)) {
			if (type == DrillConstant.RECORD_TYPE_ONE) {// 个人战报
				DrillFightData data = player.drillFightData;
				if (null != data) {
					List<Integer> list = data.getRecordKeyMap().get(which);
					if (!CheckNull.isEmpty(list)) {
						DrillRecord record;
						for (Integer recordKey : list) {
							record = map.get(recordKey);
							if (null != record) {
								builder.addRecord(PbHelper.createDrillRecordPb(record));
							}
						}
					}
				}
			} else {// 全服战报，需要分页显示
				int begin = pageNum * 20;
				int end = begin + 20;
				int index = 0;
				for (DrillRecord record : map.values()) {
					if (index++ < begin) {
						continue;
					}
					if (index > end) {
						break;
					}
					builder.addRecord(PbHelper.createDrillRecordPb(record));
				}
			}
		}

		handler.sendMsgToPlayer(GetDrillRecordRs.ext, builder.build());
	}

	/**
	 * 获取红蓝大战的具体战报
	 * 
	 * @param reportKey
	 * @param handler
	 */
	public void getDrillFightReport(int reportKey, ClientHandler handler) {
		RptAtkFortress r = drillDataManager.getDrillFightRpts().get(reportKey);
		if (null == r) {// 没有该战报
			handler.sendErrorMsgToPlayer(GameError.Fortress_Error_ReportKey);
			return;
		}
		GetDrillFightReportRs.Builder builder = GetDrillFightReportRs.newBuilder();
		builder.setRptAtkFortress(PbHelper.createRptAtkFortressPb(r));
		handler.sendMsgToPlayer(GetDrillFightReportRs.ext, builder.build());
	}

	/**
	 * 获取红蓝大战排行榜
	 * 
	 * @param rankType
	 * @param handler
	 */
	public void getDrillRank(int rankType, ClientHandler handler) {
		if (rankType < DrillConstant.RANK_TYPE_FIRST || rankType > DrillConstant.RANK_TYPE_TOTAL) {
			handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
			return;
		}

		Player player = playerDataManager.getPlayer(handler.getRoleId());

		DrillFightData data = player.drillFightData;

		// 返回消息
		GetDrillRankRs.Builder builder = GetDrillRankRs.newBuilder();
		builder.setSuccessCamp(drillDataManager.getDrillWinner());
		if (null != data) {
			builder.setSuccessNum(data.getSuccessNum(rankType));
			builder.setFailNum(data.getFailNum(rankType));
			builder.setMyCamp(data.isRed());
		} else {
			builder.setMyCamp(true);
			builder.setSuccessNum(0);
			builder.setFailNum(0);
		}
		builder.setCanGetPart(false);// 参与奖励会在活动结束时发放
		int myRank = drillDataManager.getPlayerRank(rankType, player.lord.getLordId());
		builder.setMyRank(myRank);
		if (DrillConstant.RANK_TYPE_TOTAL == rankType && myRank > 0 && myRank <= 10) {
			DrillRank drillRank = drillDataManager.getDrillShowRank(DrillConstant.RANK_TYPE_TOTAL)
					.get(player.lord.getLordId());
			builder.setCanGetRank(!drillRank.isReward());
		} else {
			builder.setCanGetRank(false);
		}
		for (DrillRank rank : drillDataManager.getDrillShowRank(rankType).values()) {
			Player rankPlayer = playerDataManager.getPlayer(rank.getLordId());
			if(rankPlayer != null){
				rank.setName(rankPlayer.lord.getNick());
			}
			builder.addRanks(PbHelper.createDrillRankPb(rank));
		}
		if (DrillConstant.RANK_TYPE_TOTAL == rankType) {// 如果是获取总榜数据，返回玩家击毁坦克种类，数量，获取分榜数据时不返回
			for (Entry<Integer, Integer> entry : player.drillKillTank.entrySet()) {
				builder.addKillTank(PbHelper.createTwoIntPb(entry.getKey(), entry.getValue()));
			}
			if (null != data) {// 玩家在本次红蓝大战中获得的总功勋值
				builder.setGetExploit(data.getExploit());
			}
		}
		handler.sendMsgToPlayer(GetDrillRankRs.ext, builder.build());
	}

	/**
	 * 领取红蓝大战的奖励
	 * 
	 * @param rewardType
	 * @param drillRewardHandler
	 */
	public void drillReward(int rewardType, ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		if (staffingDataManager.getWorldLv() < 1) {
			handler.sendErrorMsgToPlayer(GameError.DRILL_WORLD_LV_LIMIT);
			return;
		}

		// 判断红蓝大战的活动状态
		if (DrillDataManager.getDrillStatus() != DrillConstant.STATUS_END) {
			handler.sendErrorMsgToPlayer(GameError.DRILL_STATUS_EROOR);
			return;
		}

		// 判断玩家是否已报名
		Set<Long> enrollSet = drillDataManager.getEnrolledRoleSet();
		if (!enrollSet.contains(player.lord.getLordId())) {
			handler.sendErrorMsgToPlayer(GameError.DRILL_NOT_ENROLLED);
			return;
		}

		// 判断玩家是否可以领取奖励，判断玩家是否已经领取了奖励，记录玩家领奖
		AwardFrom from;
		List<List<Integer>> awardList;
		if (rewardType == DrillConstant.REWARD_TYPE_RANK) {
			int rank = drillDataManager.getPlayerRank(DrillConstant.RANK_TYPE_TOTAL, player.lord.getLordId());
			if (rank < 1 || rank > 10) {
				handler.sendErrorMsgToPlayer(GameError.DRILL_NOT_IN_RANK);
				return;
			}

			DrillRank drillRank = drillDataManager.getDrillShowRank(DrillConstant.RANK_TYPE_TOTAL)
					.get(player.lord.getLordId());
			if (drillRank.isReward()) {
				handler.sendErrorMsgToPlayer(GameError.DRILL_GET_REWARD);
				return;
			}

			drillRank.setReward(true);

			from = AwardFrom.DRILL_RANK_AWARD;
			// 排行奖励
			awardList = staticWarAwardDataMgr.getDrillRankAward(rank);
		} else {
			// 参与奖励已在活动结束时通过邮件发送，不能再领取
			handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
			return;
		}

		// 发送奖励
		List<CommonPb.Award> award = playerDataManager.addAwardsBackPb(player, awardList, from);

		// 返回消息
		DrillRewardRs.Builder builder = DrillRewardRs.newBuilder();
		builder.addAllAward(award);
		handler.sendMsgToPlayer(DrillRewardRs.ext, builder.build());
	}

	/**
	 * 获取军演商店数据
	 * 
	 * @param handler
	 */
	public void getDrillShop(ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());

		// 如果玩家上次清空的时间与系统商店的刷新时间不同，重置购买信息
		int refreshDrillShopDate = drillDataManager.getRefreshDrillShopDate();
		if (refreshDrillShopDate > 0 && player.lord.getResetDrillShopTime() != refreshDrillShopDate) {
			player.drillShopBuy.clear();
			player.lord.setResetDrillShopTime(refreshDrillShopDate);
		}

		GetDrillShopRs.Builder builder = GetDrillShopRs.newBuilder();
		StaticDrillShop shop;
		DrillShopBuy totalBuy;
		Map<Integer, DrillShopBuy> map = new HashMap<>(drillDataManager.getDrillShop());
		for (DrillShopBuy buy : player.drillShopBuy.values()) {
			shop = staticDrillDataManager.getDrillShopById(buy.getShopId());
			if (null != shop) {
				if (shop.isTreasure()) {// 珍宝为全服限购，有总数限制
					totalBuy = map.get(buy.getShopId());
					if (null == totalBuy) {
						builder.addBuy(PbHelper.createDrillShopBuyPb(buy, shop.getTotalNumber()));
						LogUtil.common("totalBuy为空, shopId:" + buy.getShopId() + ", treasureId:"
								+ drillDataManager.getDrillShop().keySet());
					} else {
						builder.addBuy(PbHelper.createDrillShopBuyPb(buy, totalBuy.getRestNum()));
					}
					map.remove(buy.getShopId());
				} else {
					builder.addBuy(PbHelper.createDrillShopBuyPb(buy, shop.getPersonNumber()));
				}
			}
		}
		for (DrillShopBuy total : map.values()) {// 玩家没有购买过的全服限购商品的数据
			builder.addBuy(PbHelper.createDrillShopBuyPb(total.getShopId(), 0, total.getRestNum()));
		}
		builder.addAllTreasureShopId(drillDataManager.getDrillShop().keySet());
		handler.sendMsgToPlayer(GetDrillShopRs.ext, builder.build());
	}

	/**
	 * 兑换军演商店的物品
	 * 
	 * @param shopId
	 * @param count
	 * @param handler
	 */
	public void exchangeDrillShop(int shopId, int count, ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());

		if (shopId <= 0 || count <= 0 || count >= Integer.MAX_VALUE) {
			handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
			return;
		}
		StaticDrillShop shop = staticDrillDataManager.getDrillShopById(shopId);
		if (null == shop) {
			handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
			return;
		}

		// 如果是珍宝，判断是否还有剩余
		DrillShopBuy totalBuy = drillDataManager.getDrillShop().get(shopId);
		if (shop.isTreasure()) {
			if (null == totalBuy) {
				handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
				return;
			}

			if (totalBuy.getBuyNum() + count > shop.getTotalNumber()) {
				handler.sendErrorMsgToPlayer(GameError.DRILL_SHOP_NOT_ENOUGH);
				return;
			}
		}

		// 如果玩家上次清空的时间与系统商店的刷新时间不同，重置购买信息
		int refreshDrillShopDate = drillDataManager.getRefreshDrillShopDate();
		if (refreshDrillShopDate > 0 && player.lord.getResetDrillShopTime() != refreshDrillShopDate) {
			player.drillShopBuy.clear();
			player.lord.setResetDrillShopTime(drillDataManager.getRefreshDrillShopDate());
		}

		// 判断是否还有足够购买次数
		DrillShopBuy buy = player.drillShopBuy.get(shopId);
		if (null == buy) {
			buy = new DrillShopBuy();
			buy.setShopId(shopId);
			buy.setBuyNum(0);
			buy.setRestNum(0);
			player.drillShopBuy.put(shopId, buy);
		}
		if (buy.getBuyNum() + count > shop.getPersonNumber()) {
			handler.sendErrorMsgToPlayer(GameError.DRILL_SHOP_BUY_LIMIT);
			return;
		}

		// 判断是否有足够的功勋值
		if (player.lord.getExploit() < shop.getCost()) {
			handler.sendErrorMsgToPlayer(GameError.DRILL_EXPLOIT_NOT_ENOUGH);
			return;
		}

		// 扣除功勋值
		playerDataManager.updateExploit(player, -shop.getCost(), AwardFrom.DRILL_SHOP_EXCHANGE);

		// 增加购买次数
		buy.setBuyNum(buy.getBuyNum() + count);
		// 如果是珍宝，减少剩余数量
		if (shop.isTreasure()) {
			totalBuy.setBuyNum(totalBuy.getBuyNum() + count);
			totalBuy.setRestNum(totalBuy.getRestNum() - count);
		}

		// 发送物品
		if (!CheckNull.isEmpty(shop.getRewardList()) && shop.getRewardList().size() == 3) {
			playerDataManager.addAward(player, shop.getRewardList().get(0), shop.getRewardList().get(1),
					shop.getRewardList().get(2), AwardFrom.DRILL_SHOP_EXCHANGE);
		}

		// 返回消息
		ExchangeDrillShopRs.Builder builder = ExchangeDrillShopRs.newBuilder();
		builder.setExploit(player.lord.getExploit());
		builder.setShopId(shopId);
		if (shop.isTreasure()) {
			builder.setCount(totalBuy.getRestNum());
		}
		handler.sendMsgToPlayer(ExchangeDrillShopRs.ext, builder.build());
	}

	/**
	 * 获取玩家的演习进修信息
	 * 
	 * @param handler
	 */
	public void getDrillImprove(ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		if (staffingDataManager.getWorldLv() < 1) {
			handler.sendErrorMsgToPlayer(GameError.DRILL_WORLD_LV_LIMIT);
			return;
		}

		GetDrillImproveRs.Builder builder = GetDrillImproveRs.newBuilder();
		DrillFightData data = player.drillFightData;
		if (null != data) {
			Map<Integer, DrillImproveInfo> redMap = drillDataManager.getDrillRedImprove();
			Map<Integer, DrillImproveInfo> blueMap = drillDataManager.getDrillBlueImprove();
			Map<Integer, DrillImproveInfo> map;
			if (!drillDataManager.getEnrolledRoleSet().contains(player.lord.getLordId())) {
				map = new HashMap<Integer, DrillImproveInfo>();// 玩家未报名，没有阵营，返回buff进修信息为0
			} else {
				if (data.isRed()) {
					map = redMap;
				} else {
					map = blueMap;
				}
			}

			int buffLv;// 记录玩家所在阵营buff等级
			int exper;// buff该等级的经验
			int ratio;// 红蓝双方的进修等级比例，该值记录红方等级战红蓝双方总等级的百分比
			int redLv;// 红方等级
			int blueLv;// 蓝方等级
			DrillImproveInfo info;
			for (Integer buffId : staticDrillDataManager.getDrillBuffIdSet()) {
				info = map.get(buffId);
				if (null == info) {
					buffLv = 0;
					exper = 0;
				} else {
					buffLv = info.getBuffLv();
					exper = info.getExper();
				}
				if (redMap.containsKey(buffId)) {
					redLv = redMap.get(buffId).getBuffLv();
				} else {
					redLv = 0;
				}
				if (blueMap.containsKey(buffId)) {
					blueLv = blueMap.get(buffId).getBuffLv();
				} else {
					blueLv = 0;
				}
				if (redLv + blueLv == 0) {
					ratio = 50;// 红蓝方都为0级的时候，50%
				} else {
					ratio = redLv * 100 / (redLv + blueLv);
				}
				builder.addImprove(PbHelper.createDrillImproveInfoPb(buffId, buffLv, exper, ratio));
			}
		}

		handler.sendMsgToPlayer(GetDrillImproveRs.ext, builder.build());
	}

	/**
	 * 演习进修
	 * 
	 * @param buffId
	 * @param handler
	 */
	public void drillImprove(int buffId, ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());
		if (staffingDataManager.getWorldLv() < 1) {
			handler.sendErrorMsgToPlayer(GameError.DRILL_WORLD_LV_LIMIT);
			return;
		}

		// 判断红蓝大战的活动状态
		if (DrillDataManager.getDrillStatus() != DrillConstant.STATUS_PREPARE) {
			handler.sendErrorMsgToPlayer(GameError.DRILL_STATUS_EROOR);
			return;
		}

		// 判断玩家是否已报名
		Set<Long> enrollSet = drillDataManager.getEnrolledRoleSet();
		if (!enrollSet.contains(player.lord.getLordId())) {
			handler.sendErrorMsgToPlayer(GameError.DRILL_NOT_ENROLLED);
			return;
		}

		// 获取进修情况
		DrillFightData data = player.drillFightData;
		Map<Integer, DrillImproveInfo> map;
		if (data.isRed()) {
			map = drillDataManager.getDrillRedImprove();
		} else {
			map = drillDataManager.getDrillBlueImprove();
		}

		// 判断是否可以进修
		DrillImproveInfo info = map.get(buffId);
		if (null == info) {
			info = new DrillImproveInfo();
			info.setBuffId(buffId);
			info.setBuffLv(0);
			info.setExper(0);
			map.put(buffId, info);
		}

		StaticDrillBuff curBuff = staticDrillDataManager.getDrillBuffByIdAndLv(buffId, info.getBuffLv());
		if (null == curBuff) {
			handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
			return;
		}

		if (info.getBuffLv() >= staticDrillDataManager.getDrillBuffMaxLv(buffId)) {
			handler.sendErrorMsgToPlayer(GameError.DRILL_BUFF_MAX_LV);
			return;
		}

		// 判断材料是否足够
		if (!CheckNull.isEmpty(curBuff.getCostList()) && curBuff.getCostList().size() == 3) {
			if (!checkCostIsEnough(player, curBuff.getCostList().get(0), curBuff.getCostList().get(1),
					curBuff.getCostList().get(2))) {
				handler.sendErrorMsgToPlayer(GameError.DRILL_BUFF_COST);
				return;
			}

			// 扣除材料，因为进修只会消耗金币或资源，所有可以使用发负数的奖励的方式扣除材料
			if (curBuff.getCostList().get(0) == AwardType.GOLD) {
				playerDataManager.subGold(player, curBuff.getCostList().get(2), AwardFrom.DRILL_IMPROVE);
			} else {
				playerDataManager.addAward(player, curBuff.getCostList().get(0), curBuff.getCostList().get(1),
						-curBuff.getCostList().get(2), AwardFrom.DRILL_IMPROVE);
			}
		}

		// 增加进修经验值，如果经验值满，升级
		if (info.getExper() + 1 >= curBuff.getExp()) {
			info.setBuffLv(info.getBuffLv() + 1);
			info.setExper(0);
		} else {
			info.setExper(info.getExper() + 1);
		}

		// 返回消息
		DrillImproveRs.Builder builder = DrillImproveRs.newBuilder();
		int redLv;
		int blueLv;
		if (drillDataManager.getDrillRedImprove().containsKey(buffId)) {
			redLv = drillDataManager.getDrillRedImprove().get(buffId).getBuffLv();
		} else {
			redLv = 0;
		}
		if (drillDataManager.getDrillBlueImprove().containsKey(buffId)) {
			blueLv = drillDataManager.getDrillBlueImprove().get(buffId).getBuffLv();
		} else {
			blueLv = 0;
		}
		int ratio;
		if (redLv + blueLv == 0) {
			ratio = 50;// 红蓝方都为0级的时候，50%
		} else {
			ratio = redLv * 100 / (redLv + blueLv);
		}
		builder.setImprove(PbHelper.createDrillImproveInfoPb(buffId, info.getBuffLv(), info.getExper(), ratio));
		handler.sendMsgToPlayer(DrillImproveRs.ext, builder.build());
	}

	/**
	 * 检查演习进修需要消耗的资源，玩家是否足够，由于策划说消耗材料这会有金币或资源，所以值检查中两种
	 * 
	 * @param player
	 * @param awardType
	 * @param id
	 * @param cost
	 * @return
	 */
	private boolean checkCostIsEnough(Player player, int awardType, int id, int cost) {
		Lord lord = player.lord;
		switch (awardType) {
		case AwardType.GOLD:// 金币
			return lord.getGold() >= cost;
		case AwardType.RESOURCE:// 资源
			Resource resource = player.resource;
			switch (id) {
			case 1:
				return resource.getIron() >= cost;
			case 2:
				return resource.getOil() >= cost;
			case 3:
				return resource.getCopper() >= cost;
			case 4:
				return resource.getSilicon() >= cost;
			case 5:
				return resource.getStone() >= cost;
			}
		}
		return false;
	}

	/**
	 * 获取演习军力
	 * 
	 * @param handler
	 */
	public void getDrillTank(ClientHandler handler) {
		Player player = playerDataManager.getPlayer(handler.getRoleId());

		GetDrillTankRs.Builder builder = GetDrillTankRs.newBuilder();
		for (Tank tank : player.drillTanks.values()) {
			if (null != tank && tank.getCount() > 0) {
				builder.addDrillTank(PbHelper.createTankPb(tank));
			}
		}
		handler.sendMsgToPlayer(GetDrillTankRs.ext, builder.build());
	}

	/**
	 * 红蓝大战懂事任务逻辑
	 */
	public void drillTimerLogic() {
		int today = TimeHelper.getCurrentDay();
		try {
			if (staffingDataManager.getWorldLv() >= 1 && isDrillDay()) {// 红蓝大战每周二开启
				int time = TimeHelper.getCurrentSecond();
				int status = DrillDataManager.getDrillStatus();
				if (nextChatTime == 0 && status == DrillConstant.STATUS_ENROLL) {
					// 活动中重启服务器，重新设置公告时间
					nextChatTime = TimeHelper.getNextHourTime();// 整点发送
				}

				if (status == DrillConstant.STATUS_NOT_START || status == DrillConstant.STATUS_END) {
					// 如果活动未开始，并且当前时间小于报名结束时间，开启今天的报名
					if (today != drillDataManager.getLastOpenDrillDate() && time < TimeHelper.getSecond(20, 30, 0)) {
						drillDataManager.setDrillStatus(DrillConstant.STATUS_ENROLL);
						// 清空上次大战的数据
						drillDataManager.clearDrillData();

						drillDataManager.setLastOpenDrillData(today);
						LogUtil.common("红蓝大战开始报名, today:" + today);

						// 聊天通知
						nextChatTime = TimeHelper.getNearlyHourTime();// 整点发送
					}
				} else {
					if (status == DrillConstant.STATUS_ENROLL && TimeHelper.isTime(20, 30)) {// 进入准备状态
						drillDataManager.setDrillStatus(DrillConstant.STATUS_PREPARE);

						// 分配红蓝队成员
						drillDataManager.refreshCamp();
						LogUtil.common("红蓝大战备战，分配红蓝队");

						// 聊天通知
						nextChatTime = time;
					} else if (status == DrillConstant.STATUS_PREPARE && TimeHelper.isTime(20, 55)) {// 进入预热阶段
						drillDataManager.setDrillStatus(DrillConstant.STATUS_PREHEAT);

						LogUtil.common("红蓝大战预热");
					} else if (status == DrillConstant.STATUS_PREHEAT && TimeHelper.isTime(21, 0)) {// 上路战斗开始
						drillDataManager.setDrillStatus(DrillConstant.STATUS_FIRST_BATTLE);

						drillDataManager.setNextFightTime(time);
						// 更新战斗数据
						drillDataManager.refreshDrillArmy();
						LogUtil.common("红蓝大战上路战斗开始，刷新玩家部队数据");
					} else if (status == DrillConstant.STATUS_FIRST_BATTLE && TimeHelper.isTime(21, 10)) {// 中路战斗开始
						// 改变状态前检查上一路的战斗是否结束，如果没有，一次运行完
						drillDataManager.checkLastFightStatus();

						drillDataManager.setDrillStatus(DrillConstant.STATUS_SECOND_BATTLE);
						drillDataManager.setNextFightTime(time);
						LogUtil.common("红蓝大战中路战斗开始");
					} else if (status == DrillConstant.STATUS_SECOND_BATTLE && TimeHelper.isTime(21, 20)) {// 下路战斗开始
						// 改变状态前检查上一路的战斗是否结束，如果没有，一次运行完
						drillDataManager.checkLastFightStatus();

						drillDataManager.setDrillStatus(DrillConstant.STATUS_THIRD_BATTLE);
						drillDataManager.setNextFightTime(time);
						LogUtil.common("红蓝大战下路战斗开始");
					} else if (TimeHelper.isTime(21, 30)) {
						// 改变状态前检查上一路的战斗是否结束，如果没有，一次运行完
						drillDataManager.checkLastFightStatus();
						drillDataManager.setDrillStatus(DrillConstant.STATUS_END);
						drillDataManager.setNextFightTime(0);

						LogUtil.common("红蓝大战活动结束，清空玩家部队数据，发放参与奖励，胜利方:" + drillDataManager.getDrillWinner());

						// 活动结束清空玩家的演习部队
						drillDataManager.clearRoleDrillArmy();

						// 发送玩家的参与奖励
						drillDataManager.sendPartReward();

						// 活动结束公告
						nextChatTime = time;
					}

					// 判断是否到了战斗开启的时间，是则匹配对战
					int nextFightTime = drillDataManager.getNextFightTime();
					if (nextFightTime > 0 && nextFightTime <= time) {
						LogUtil.common("-----开始执行红蓝大战战斗逻辑-----");
						int limitNum = 10;// 理论上的极限执行次数（某一路战场的战斗轮数）
						int executeNum = 0;// 本次已执行次数
						while ((limitNum >= 10) && (executeNum <= (limitNum / 10))) {
							// 如果极限次数>=10，则一次性执行多轮战斗
							limitNum = drillDataManager.beginNextFight();
							executeNum++;
							LogUtil.common("已执行战斗次数:" + executeNum + ", 当前极限比:" + limitNum + ", nextFightTime:"
									+ drillDataManager.getNextFightTime() + ", currTime:" + time);
						}

						LogUtil.common("-----执行红蓝大战战斗逻辑结束-----");
					}
				}

				// 公告相关逻辑
				sendWorldChat(time, DrillDataManager.getDrillStatus());
			}
		} catch (Throwable t) {
			LogUtil.error("红蓝大战逻辑异常, status:" + DrillDataManager.getDrillStatus() + ", nextChatTime:" + nextChatTime
					+ ", nextFightTime:" + drillDataManager.getNextFightTime(), t);
			LogUtil.common("红蓝大战逻辑异常, status:" + DrillDataManager.getDrillStatus() + ", nextChatTime:" + nextChatTime
					+ ", nextFightTime:" + drillDataManager.getNextFightTime());
		}

		// 每天晚上10点刷新军演商店
		if (TimeHelper.isTime(22, 0) && today > drillDataManager.getRefreshDrillShopDate()) {
			drillDataManager.refreshShopTreasure();
			LogUtil.common("军演商店商品刷新完成");
		}
	}

	private int nextChatTime;// 记录下次全服公告红蓝大战状态的时间

	/**
	 * 
	* 红蓝大战世界公共
	* @param now
	* @param status  
	* void
	 */
	private void sendWorldChat(int now, int status) {
		if (status == DrillConstant.STATUS_ENROLL && TimeHelper.isTimeSecond(20, 25, 0)) {// 20:25通知玩家报名即将结束
			chatService.sendHornChat(chatService.createSysChat(SysChatId.Drill_Enroll_Near_End), 1);
			nextChatTime = 1;// 发送报名即将结束的公告后不再发报名的公告，这里是为了防止再发通知玩家报名的公告
		} else if (status == DrillConstant.STATUS_PREPARE && TimeHelper.isTimeSecond(20, 50, 0)) {// 20:50通知玩家备战即将结束
			chatService.sendHornChat(chatService.createSysChat(SysChatId.Drill_Prepare_Near_End), 1);
			nextChatTime = 1;// 不再发备战通知
		}

		// 判断是否需要发送公告
		if (nextChatTime == now) {
			if (status == DrillConstant.STATUS_ENROLL) {
				chatService.sendHornChat(chatService.createSysChat(SysChatId.Drill_Start), 1);
				nextChatTime = now + 3600; // 1小时发一次红蓝大战报名公告
			} else if (status == DrillConstant.STATUS_PREPARE) {
				chatService.sendHornChat(chatService.createSysChat(SysChatId.Drill_Prepare), 1);
				nextChatTime = now + 300; // 5分钟发一次红蓝大战开始准备的公告
			} else if (status == DrillConstant.STATUS_END) {// 活动结束公告
				int winner = drillDataManager.getDrillWinner();
				if (winner == DrillConstant.RESULT_DRAW) {// 活动无效公告
					chatService.sendWorldChat(chatService.createSysChat(SysChatId.Drill_Invalid));
				} else {// 活动结束，通知胜利方的公告
					String camp = winner == DrillConstant.RESULT_RED ? DrillConstant.RED : DrillConstant.BLUE;
					chatService.sendWorldChat(chatService.createSysChat(SysChatId.Drill_End, camp));
				}
			}
		}
	}

	/**
	 * 
	* 今天是否开启红蓝大战
	* @return  
	* boolean
	 */
	public boolean isDrillDay() {
		return TimeHelper.isDayOfWeek(Calendar.TUESDAY);
	}
}
