package com.game.manager;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.game.constant.AwardFrom;
import com.game.constant.DrillConstant;
import com.game.constant.EffectType;
import com.game.constant.FirstActType;
import com.game.constant.FormType;
import com.game.constant.MailType;
import com.game.constant.SysChatId;
import com.game.dataMgr.StaticDrillDataManager;
import com.game.dataMgr.StaticWarAwardDataMgr;
import com.game.domain.Player;
import com.game.domain.p.Form;
import com.game.domain.p.Lord;
import com.game.domain.p.Tank;
import com.game.domain.s.StaticDrillShop;
import com.game.drill.domain.DrillArmy;
import com.game.drill.domain.DrillFightData;
import com.game.drill.domain.DrillImproveInfo;
import com.game.drill.domain.DrillRank;
import com.game.drill.domain.DrillRecord;
import com.game.drill.domain.DrillResult;
import com.game.drill.domain.DrillShopBuy;
import com.game.fight.FightLogic;
import com.game.fight.domain.Fighter;
import com.game.pb.CommonPb;
import com.game.pb.CommonPb.RptAtkFortress;
import com.game.service.ChatService;
import com.game.service.FightService;
import com.game.util.CheckNull;
import com.game.util.LogLordHelper;
import com.game.util.LogUtil;
import com.game.util.PbHelper;
import com.game.util.RandomHelper;
import com.game.util.TimeHelper;

/**
 * @ClassName DrillDataManager.java
 * @Description 
 * @author TanDonghai
 * @date 创建时间：2016年8月9日 上午10:17:31
 *
 */
@Component
public class DrillDataManager {
	@Autowired
	private StaticDrillDataManager staticDrillDataManager;

	@Autowired
	private StaticWarAwardDataMgr staticWarAwardDataMgr;

	@Autowired
	private PlayerDataManager playerDataManager;

	@Autowired
	private GlobalDataManager globalDataManager;

	@Autowired
	private RankDataManager rankDataManager;

	@Autowired
	private SmallIdManager smallIdManager;

	@Autowired
	private FightService fightService;

	@Autowired
	private ChatService chatService;

	/** 红蓝大战的状态 */
	private static int drillStatus;

	/** 红蓝大战最近一次开启的日期，格式:20160809 */
	private int lastOpenDrillDate;

	/** 红蓝大战的红方玩家数据 */
	private Map<Long, DrillFightData> redRoleMap = new HashMap<>();

	/** 红蓝大战的蓝方玩家数据 */
	private Map<Long, DrillFightData> blueRoleMap = new HashMap<>();

	/** 红蓝大战玩家排行榜（用于显示的排行榜数据） */
	private Map<Integer, LinkedHashMap<Long, DrillRank>> drillShowRank;

	/** 红蓝大战玩家战况记录 */
	private Map<Integer, LinkedHashMap<Integer, DrillRecord>> drillRecords;

	/** 红蓝大战玩家的战报记录 */
	private Map<Integer, RptAtkFortress> drillFightRpts;

	/** 已报名玩家 */
	private Set<Long> enrolledRoleSet = new HashSet<>();

	/** 红蓝大战三路战斗结果 */
	private Map<Integer, DrillResult> drillResult;

	/** 红蓝大战最终胜利方 */
	private int drillWinner;// 活动最终胜利阵营，0 平局，1 红方胜，2 蓝方胜

	/** 红蓝大战红方的进修情况 */
	private Map<Integer, DrillImproveInfo> drillRedImprove;

	/** 红蓝大战蓝方的进修情况 */
	private Map<Integer, DrillImproveInfo> drillBlueImprove;

	/** 红蓝大战中，玩家的排行榜，用于活动中临时记录上榜玩家 */
	private LinkedList<DrillFightData> drillRank = new LinkedList<>();

	/** 红蓝大战军演商店珍宝商品购买情况 */
	private Map<Integer, DrillShopBuy> drillShop;

	private int refreshDrillShopDate;// 上次刷新军演商店的日期

	private int nextFightTime;// 记录下次匹配战斗的时间

	public int redExploit;// 红方阵营功勋

	public int blueExploit;// 蓝方阵营功勋

	private boolean lastWinCamp; // 记录活动中最后一个胜利的阵营，用于在平局中，双方阵营的功勋相同时，判断最终胜利方

	private int reportKey = 200001;// 战报key

	/** 记录红方在三路战场中设置了部队的玩家lordId */
	private Map<Integer, Set<Long>> redArmyMap = new HashMap<>();
	private Map<Integer, Set<Long>> blueArmyMap = new HashMap<>();

	public void init() {
		initDrillData();
		initPlayerData();
	}

	/**
	 * 初始化玩家在红蓝大战中的数据
	 */
	private void initPlayerData() {
		Iterator<Player> its = playerDataManager.getPlayers().values().iterator();
		Player player;
		DrillFightData data;
		while (its.hasNext()) {
			player = its.next();
			if (!smallIdManager.isSmallId(player.lord.getLordId())) {
				data = player.drillFightData;
				if (null == data) {
					continue;
				}
				if (data.getLastEnrollDate() == getLastOpenDrillDate()) {
					enrolledRoleSet.add(player.lord.getLordId());

					if (drillStatus != DrillConstant.STATUS_ENROLL) {
						if (data.isRed()) {
							redRoleMap.put(data.getLordId(), data);
						} else {
							blueRoleMap.put(data.getLordId(), data);
						}
					}
				}
			}
		}
	}

	/**
	 * 初始化红蓝大战活动数据
	 */
	private void initDrillData() {
		drillStatus = globalDataManager.gameGlobal.getDrillStatus();
		if (drillStatus != DrillConstant.STATUS_NOT_START && drillStatus != DrillConstant.STATUS_ENROLL
				&& drillStatus != DrillConstant.STATUS_END) {
			drillStatus = DrillConstant.STATUS_NOT_START;// 如果上次停服时活动为结束，置为未开始
			globalDataManager.gameGlobal.setDrillStatus(drillStatus);
		}

		redExploit = globalDataManager.gameGlobal.getRedExploit();
		blueExploit = globalDataManager.gameGlobal.getBlueExploit();
		drillWinner = globalDataManager.gameGlobal.getDrillWinner();
		lastOpenDrillDate = globalDataManager.gameGlobal.getLastOpenDrillDate();
		refreshDrillShopDate = globalDataManager.gameGlobal.getRefreshDrillShopDate();

		drillShop = globalDataManager.gameGlobal.getDrillShop();
		drillResult = globalDataManager.gameGlobal.getDrillResult();
		drillRecords = globalDataManager.gameGlobal.getDrillRecords();
		drillShowRank = globalDataManager.gameGlobal.getDrillRank();
		drillFightRpts = globalDataManager.gameGlobal.getDrillFightRpts();
		drillRedImprove = globalDataManager.gameGlobal.getDrillRedImprove();
		drillBlueImprove = globalDataManager.gameGlobal.getDrillBlueImprove();

		int today = TimeHelper.getCurrentDay();
		if (CheckNull.isEmpty(drillShop) || (today > refreshDrillShopDate && TimeHelper.getCurrentHour() >= 22)) {// 没有珍宝的购买记录，初始数据
			refreshShopTreasure();
		}
	}

	/**
	 * 刷新珍宝商品
	 */
	public void refreshShopTreasure() {
		drillShop.clear();// 清空购买记录

		int shopId;
		int randomIndex;
		DrillShopBuy buy;
		List<Integer> shopIdList = new ArrayList<>();
		for (StaticDrillShop shop : staticDrillDataManager.getDrillShopMap().values()) {
			if (shop.isTreasure()) {
				shopIdList.add(shop.getGoodID());
			}
		}
		for (int i = 0; i < 3; i++) {// 随机出3个珍宝商品，并将购买信息置为0
			randomIndex = RandomHelper.randomInSize(shopIdList.size());
			shopId = shopIdList.get(randomIndex);

			buy = new DrillShopBuy();
			buy.setShopId(shopId);
			buy.setBuyNum(0);
			buy.setRestNum(staticDrillDataManager.getDrillShopById(shopId).getTotalNumber());
			drillShop.put(shopId, buy);
			LogUtil.common("军演商店刷新商品, shop:" + buy);

			shopIdList.remove(randomIndex);// 已随即出来的从列表中删除
		}
		shopIdList.clear();

		setRefreshDrillShopDate(TimeHelper.getCurrentDay());// 记录最后更新时间
	}

	public Map<Integer, Set<Long>> getRedArmyMap() {
		return redArmyMap;
	}

	public Map<Integer, Set<Long>> getBlueArmyMap() {
		return blueArmyMap;
	}

	/**
	 * 获取某个阵营在某路战场中设置的部队数
	 * 
	 * @param camp
	 * @param which
	 * @return
	 */
	public int getCampArmyNum(boolean camp, int which) {
		Set<Long> set = getCampArmySet(camp, which);
		return set.size();
	}

	/**
	 * 获取某个阵营在某路战场中设置了部队的玩家lordId
	 * 
	 * @param camp
	 * @param which
	 * @return
	 */
	private Set<Long> getCampArmySet(boolean camp, int which) {
		Map<Integer, Set<Long>> map;
		if (camp) {
			map = redArmyMap;
		} else {
			map = blueArmyMap;
		}
		Set<Long> set = map.get(which);
		if (null == set) {
			set = new HashSet<>();
			map.put(which, set);
		}
		return set;
	}

	/**
	 * 
	* @Description: 阵营中删除部队
	* @param camp
	* @param which
	* @param lordId  
	* void
	 */
	public void removeCampArmy(boolean camp, int which, long lordId) {
		Set<Long> set = getCampArmySet(camp, which);
		set.remove(lordId);
	}

	   /**
     * 
    * @Description: 阵营中添加部队
    * @param camp
    * @param which
    * @param lordId  
    * void
     */
	public void addCampArmy(boolean camp, int which, long lordId) {
		Set<Long> set = getCampArmySet(camp, which);
		set.add(lordId);
	}

	/**
	* @Description: 上次刷新军演商店的日期
	* @return  
	* int
	 */
	public int getRefreshDrillShopDate() {
		return refreshDrillShopDate;
	}

	public void setRefreshDrillShopDate(int refreshDrillShopDate) {
		this.refreshDrillShopDate = refreshDrillShopDate;
		globalDataManager.gameGlobal.setRefreshDrillShopDate(refreshDrillShopDate);
	}

	public void resetKeys() {
		reportKey = 200001;
	}

	public int getLastOpenDrillDate() {
		return lastOpenDrillDate;
	}

	public void setLastOpenDrillData(int lastOpenDrillDate) {
		this.lastOpenDrillDate = lastOpenDrillDate;
		globalDataManager.gameGlobal.setLastOpenDrillDate(lastOpenDrillDate);
	}

	public int getNextFightTime() {
		return nextFightTime;
	}

	public void setNextFightTime(int nextFightTime) {
		this.nextFightTime = nextFightTime;
	}

	public static int getDrillStatus() {
		return drillStatus;
	}

	public void setDrillStatus(int status) {
		drillStatus = status;
		globalDataManager.gameGlobal.setDrillStatus(drillStatus);
	}

	/**
	 * 获取玩家爱的排行
	 * 
	 * @param rankType
	 * @param lordId
	 * @return
	 */
	public int getPlayerRank(int rankType, long lordId) {
		Map<Long, DrillRank> map = getDrillShowRank(rankType);
		DrillRank rank = map.get(lordId);
		if (null != rank) {
			return rank.getRank();
		}
		return 0;
	}

	/**
	 * 获取红蓝大战的某个排行榜信息
	 * 
	 * @param rankType
	 * @return
	 */
	public LinkedHashMap<Long, DrillRank> getDrillShowRank(int rankType) {
		LinkedHashMap<Long, DrillRank> map = drillShowRank.get(rankType);
		if (null == map) {
			map = new LinkedHashMap<>();
			drillShowRank.put(rankType, map);
		}
		return map;
	}

	public Map<Integer, LinkedHashMap<Long, DrillRank>> getDrillShowRank() {
		return drillShowRank;
	}

	public Map<Integer, LinkedHashMap<Integer, DrillRecord>> getDrillRecords() {
		return drillRecords;
	}

	public Map<Integer, RptAtkFortress> getDrillFightRpts() {
		return drillFightRpts;
	}

	public Set<Long> getEnrolledRoleSet() {
		return enrolledRoleSet;
	}

	public int getDrillWinner() {
		return drillWinner;
	}

	public Map<Integer, DrillResult> getDrillResult() {
		return drillResult;
	}

	public SmallIdManager getSmallIdManager() {
		return smallIdManager;
	}

	public Map<Integer, DrillImproveInfo> getDrillRedImprove() {
		return drillRedImprove;
	}

	public Map<Integer, DrillImproveInfo> getDrillBlueImprove() {
		return drillBlueImprove;
	}

	public Map<Integer, DrillShopBuy> getDrillShop() {
		return drillShop;
	}

	public void addDrillRank(DrillFightData data) {
		if (!drillRank.contains(data)) {
			drillRank.add(data);
		}
	}

	/**
	 * 计算并设置最终胜利方
	 */
	public void setDrillWinner() {
		int redWinNum = 0;// 记录红方胜利数
		int drawNum = 0;// 记录平局数
		for (DrillResult result : drillResult.values()) {
			if (result.getStatus() == DrillConstant.RESULT_DRAW) {
				drawNum++;
			} else if (result.getStatus() == DrillConstant.RESULT_RED) {
				redWinNum++;
			}
		}

		if (drawNum == 3) {// 三场战斗都是平局，最终结果无效
			drillWinner = DrillConstant.RESULT_DRAW;
			LogUtil.common("红蓝大战三路战斗平局，最终结果无效");
		} else {
			int blueWin = 3 - redWinNum - drawNum;
			if (redWinNum == blueWin) {// 一胜一负一平局，判断双方的阵营功勋
				if (redExploit == blueExploit) {// 如果阵营功勋值相同，先达到该功勋值的胜利
					drillWinner = lastWinCamp ? DrillConstant.RESULT_BLUE : DrillConstant.RESULT_RED;
				} else {// 功勋值高的胜利
					drillWinner = redExploit > blueExploit ? DrillConstant.RESULT_RED : DrillConstant.RESULT_BLUE;
				}
			} else {// 胜利场次多的胜利
				drillWinner = redWinNum > blueWin ? DrillConstant.RESULT_RED : DrillConstant.RESULT_BLUE;
			}
		}
	}

	/**
	 * 将所有参与红蓝大战的玩家爱数据更新后，放入临时排行队列中，等待处理
	 */
	public void addTotalDrillRank() {
		drillRank.clear();
		Player player = null;
		DrillFightData data = null;
		for (Long lordId : enrolledRoleSet) {
			player = playerDataManager.getPlayer(lordId);
			data = player.drillFightData;
			data.updateData();// 更新相关数据
			drillRank.add(data);
		}
	}

	/**
	 * 将临时排行数据填充到排行榜中
	 * 
	 * @param which
	 */
	public void fillShowRankList(int which) {
		LinkedHashMap<Long, DrillRank> map = drillShowRank.get(which);
		if (null == map) {
			map = new LinkedHashMap<>();
			drillShowRank.put(which, map);
		}
		LogUtil.common("红蓝大战填充排行榜数据, which:" + which + ", size:" + drillRank.size());
		// 排序
		if (which == DrillConstant.RANK_TYPE_TOTAL) {
			Collections.sort(drillRank, new DrillTotalRankCompator());
		} else {
			Collections.sort(drillRank, new DrillRankDescCompator());
		}

		Player player;
		int index = 1;
		DrillRank rank;
		for (DrillFightData data : drillRank) {
			try {
				rank = new DrillRank();
				rank.setCamp(data.isRed());
				rank.setFailNum(data.getFailNum(which));
				player = playerDataManager.getPlayer(data.getLordId());
				if (which == DrillConstant.RANK_TYPE_TOTAL) {// 总榜需要显示玩家的战力
					rank.setFightNum(player.lord.getFight());
				}
				rank.setLordId(data.getLordId());
				rank.setName(player.lord.getNick());
				rank.setRank(index++);
				rank.setReward(data.isCampRewad());
				rank.setSuccessNum(data.getSuccessNum(which));
				map.put(rank.getLordId(), rank);

				LogUtil.common("红蓝大战添加一条排行榜数据, which:" + which + ", rank:" + rank);
				if (which == DrillConstant.RANK_TYPE_TOTAL && index > 10) {
					break;// 总榜只记录前十名
				}
			} catch (Exception e) {
				LogUtil.error("红蓝大战整理排行榜数据出错, drillFightData:" + data + ", rankIndex:" + index, e);
				LogUtil.common("红蓝大战整理排行榜数据出错, drillFightData:" + data + ", rankIndex:" + index + ", exception:"
						+ e.getMessage());
			}
		}

		drillRank.clear();// 清空临时排行数据
	}

	/**
	 * 三场战斗都打完后，更新活动最终胜利方，更新排行榜数据
	 */
	private void updateDrillRank() {
		setDrillWinner();// 计算最终胜利放并设置

		LogUtil.common("红蓝大战三路战斗全部结束，最终胜利方:" + drillWinner + ", 开始总榜排行");

		if (drillWinner != DrillConstant.RESULT_DRAW) {
			// 排行总榜
			addTotalDrillRank();
			fillShowRankList(DrillConstant.RANK_TYPE_TOTAL);
		}

		// 更新全局数据
		globalDataManager.gameGlobal.setRedExploit(redExploit);
		globalDataManager.gameGlobal.setBlueExploit(blueExploit);
		globalDataManager.gameGlobal.setDrillWinner(drillWinner);
	}

	/**
	 * 在进入下一路战斗前，检查上一路的战斗是否结束，如果没有结束，一次运算完其所有战斗
	 */
	public void checkLastFightStatus() {
		int which = drillStatus - DrillConstant.STATUS_PREHEAT;// 计算当前是第几路的战斗
		DrillResult result = drillResult.get(which);
		if (null == result) {
			// 不应该存在这种情况
			return;
		}

		if (!result.isOver()) {// 该路战斗还没有结束，一次性运算完所有战斗
			int limitNum = 1;
			while (limitNum != 0) {
				limitNum = beginNextFight();
			}
		}
	}

	/**
	 * 开始匹配玩家并计算战斗结果
	 * 
	 * @return 返回玩家多的一方比少的一方的比例，用于判断极限运算次数。该比例的由来：由于红蓝大战是分阵营匹配战斗，所以每轮都只会执行人数少的一方的人数的战斗，在极限情况下（即人少的一方不损），而比例足够大，比如500:1
	 *         ，则战斗的轮数可能达到500轮开能结束本路的战斗
	 */
	public int beginNextFight() {
		// 对玩家按连胜次数、军力排序
		LinkedList<DrillFightData> redList = sortRoleFightMap(redRoleMap);
		LinkedList<DrillFightData> blueList = sortRoleFightMap(blueRoleMap);

		int which = drillStatus - DrillConstant.STATUS_PREHEAT;// 计算当前是第几路的战斗
		DrillResult result = drillResult.get(which);
		if (null == result) {// 初始化新阶段大战的结果
			result = new DrillResult();
			result.setDrillRedTotal(redList.size());
			result.setDrillBlueTotal(blueList.size());
			drillResult.put(which, result);

			if (CheckNull.isEmpty(redList) && CheckNull.isEmpty(blueList)) {
				result.setStatus(DrillConstant.RESULT_DRAW);// 如果双方在本路战斗中都没有设置部队，平局
				LogUtil.common("红蓝大战本路战斗平局, which:" + which);
				if (drillStatus == DrillConstant.STATUS_THIRD_BATTLE) {
					updateDrillRank();// 如果三路战斗都已结束，相关处理
				}
				setNextFightTime(0);// 一路战斗结束后，重置下一次战斗的时间
				return 0;// 本路战斗结束，返回比例0
			}
		}

		boolean redShort = false;// 记录人数少的一方是否是红方
		List<DrillFightData> shortList;// 人数少的一方
		List<DrillFightData> longList;// 人数多的一方的数据
		if (redList.size() <= blueList.size()) {
			shortList = redList;
			longList = blueList;
			redShort = true;
		} else {
			shortList = blueList;
			longList = redList;
		}
		int shortNum = shortList.size();// 记录剩余玩家人数
		int longNum = longList.size();

		DrillFightData nextData = null;
		DrillFightData matchData = null;
		List<DrillFightData> randomList = new ArrayList<DrillFightData>();
		for (DrillFightData data : shortList) {// 人数少的一方主动匹配
			if (longList.size() <= 3) {// 如果被匹配队列已经不多于3个玩家，随机匹配
				matchData = randomMatch(longList);
			} else {// 如果有超过3个可匹配对象，找出3个与玩家相近的连胜次数的玩家，随机匹配
				for (int i = 0; i < longList.size(); i++) {// 按连胜次数，战力寻找一个合适的玩家匹配
					// 如果一直到匹配队列的最后都没有找到相匹配的，直接在最后3个玩家中随机
					if (i == longList.size() - 1) {
						randomList.addAll(longList.subList(longList.size() - 3, longList.size()));
					} else {
						nextData = longList.get(i + 1);
						if (data.getSuccessNum() > nextData.getSuccessNum()) {
							continue;// 连胜次数不匹配，跳过，继续向后查找
						}

						// 找到连胜次数相匹配的玩家，扩大随机范围
						if (i == 0) {
							// 如果当前为匹配队列的第一个，直接在前4个玩家中随机
							randomList.addAll(longList.subList(0, 4));
						} else {
							// 将前1个和后面2-5个玩家加入随机列表中，即可用于随机的玩家数量为3-6个
							randomList.add(longList.get(i - 1));
							int add = 0;
							while (add < 5 && i + add < longList.size()) {
								randomList.add(longList.get(i + add++));
							}
						}
						break;
					}
				}
				matchData = randomMatch(randomList);
				randomList.clear();
			}

			longList.remove(matchData);// 已经被匹配的，移除出匹配队列

			// 匹配对战,随机判定一方为攻击方
			boolean shortWin;
			try {
				if (randomCamp(0)) {// 主动匹配方为攻击方
					shortWin = fightLogic(data, matchData);
				} else {
					shortWin = !fightLogic(matchData, data);
				}

				addDrillRank(data);// 记录玩家，用于战斗结束后排行
				addDrillRank(matchData);

				if (shortWin) {// 失败的一方，人数减1
					longNum--;
				} else {
					shortNum--;
				}
			} catch (Exception e) {
				LogUtil.error("红蓝大战本路战斗逻辑出现异常, data:" + data + ", matchData:" + matchData, e);
				LogUtil.common("红蓝大战本路战斗逻辑出现异常, data:" + data + ", matchData:" + matchData);
			}
		}

		if (shortNum == 0 || longNum == 0) {// 其中一方全部失败，本阶段战斗结束
			if (redShort) {
				result.setDrillRedRest(shortNum);
				result.setDrillBlueRest(longNum);
			} else {
				result.setDrillRedRest(longNum);
				result.setDrillBlueRest(shortNum);
			}
			lastWinCamp = result.getDrillRedRest() > result.getDrillBlueRest();
			result.setStatus(lastWinCamp ? DrillConstant.RESULT_RED : DrillConstant.RESULT_BLUE);
			LogUtil.common("红蓝大战本路战斗结束, which:" + which + ", result:" + result);
			fillShowRankList(which);// 填充排行榜数据，并清空临时排行榜
			if (drillStatus == DrillConstant.STATUS_THIRD_BATTLE) {
				updateDrillRank();// 如果三路战斗都已结束，相关处理
			}
			setNextFightTime(0);// 一路战斗结束后，重置下一次战斗的时间
			return 0;// 本路战斗结束，返回比例0
		} else {// 双方都还有部队，设置下次战斗时间
			setNextFightTime(TimeHelper.getCurrentSecond() + 15);// 15s执行一次
			return shortNum > longNum ? shortNum / longNum : longNum / shortNum;
		}
	}

	/**
	 * 从传入列表中随机一个对象返回
	 * 
	 * @param randomList
	 * @return
	 */
	private DrillFightData randomMatch(List<DrillFightData> randomList) {
		if (CheckNull.isEmpty(randomList)) {
			return null;
		}
		int randomIndex = RandomHelper.randomInSize(randomList.size());
		return randomList.get(randomIndex);
	}

	/**
	 * 战斗逻辑，返回进攻方是否胜利
	 * 
	 * @param attackerData
	 * @param defencerData
	 * @return
	 */
	private boolean fightLogic(DrillFightData attackerData, DrillFightData defencerData) {
		Player attackPlayer = playerDataManager.getPlayer(attackerData.getLordId());
		Player defencePlayer = playerDataManager.getPlayer(defencerData.getLordId());

		int which = drillStatus - DrillConstant.STATUS_PREHEAT;// 计算当前是第几路的战斗
		Fighter attacker = fightService.createDrillFighter(attackPlayer, attackerData.getForm(which), 3,
				attackerData.isRed() ? drillRedImprove : drillBlueImprove);
		attacker.fightNum = attackerData.getArmyMap().get(which).fightNum;
		Fighter defencer = fightService.createDrillFighter(defencePlayer, defencerData.getForm(which), 3,
				defencerData.isRed() ? drillRedImprove : drillBlueImprove);
		defencer.fightNum = defencerData.getArmyMap().get(which).fightNum;

		FightLogic fightLogic = new FightLogic(attacker, defencer, FirstActType.FISRT_VALUE_DRILL, true);


		fightLogic.packForm(attackerData.getForm(which), defencerData.getForm(which));
		fightLogic.fight();

		// 计算攻方损失并扣除坦克，并增加防守方的功勋值
		int exploit = calDestroyTank(attackerData.getForm(which), attacker, attackPlayer, defencePlayer);
		if (exploit > 0) {
			playerDataManager.updateExploit(defencePlayer, exploit, AwardFrom.DRILL_FIGHT);// 增加玩家的功勋值
			defencerData.setExploit(defencerData.getExploit() + exploit);// 记录玩家在本次活动中获得的功勋值
			addCampExploit(defencerData.isRed(), exploit);// 记录阵营功勋
		}

		// 计算守方损失并扣除坦克，并增加进攻方的功勋值
		exploit = calDestroyTank(defencerData.getForm(which), defencer, defencePlayer, attackPlayer);
		if (exploit > 0) {
			playerDataManager.updateExploit(attackPlayer, exploit, AwardFrom.DRILL_FIGHT);
			attackerData.setExploit(attackerData.getExploit() + exploit);// 记录玩家在本次活动中获得的功勋值
			addCampExploit(attackerData.isRed(), exploit);// 记录阵营功勋
		}

		CommonPb.Record record = fightLogic.generateRecord();
		attackerData.addReportKey(which, reportKey);// 记录玩家个人战报
		defencerData.addReportKey(which, reportKey);

		boolean attackWin = fightLogic.getWinState() == 1;
		RptAtkFortress report = PbHelper.createRptAtkFortressPb(reportKey++, attackWin, fightLogic.attackerIsFirst(),
				createRptMan(attackPlayer, attackerData.getForm(which).getAwakenHero() != null ? attackerData.getForm(which).getAwakenHero().getHeroId() : attackerData.getForm(which).getCommander(), attacker.firstValue),
				createRptMan(defencePlayer, defencerData.getForm(which).getAwakenHero() != null ? defencerData.getForm(which).getAwakenHero().getHeroId() : defencerData.getForm(which).getCommander(), defencer.firstValue), record);
		drillFightRpts.put(report.getReportKey(), report);
		// 记录战报
		DrillRecord dr = new DrillRecord();
		dr.setReportKey(report.getReportKey());
		dr.setAttacker(attackPlayer.lord.getNick());
		dr.setAttackNum((int) (attacker.fightNum * 100 / attackerData.getArmyMap().get(which).totalFight));
		dr.setAttackCamp(attackerData.isRed());
		dr.setDefender(defencePlayer.lord.getNick());
		dr.setDefendNum((int) (defencer.fightNum * 100 / defencerData.getArmyMap().get(which).totalFight));
		dr.setDefendCamp(defencerData.isRed());
		dr.setResult(attackWin);
		dr.setTime(TimeHelper.getCurrentSecond());
		addFightRecord(which, dr);// 加入全服战报

		// 删除失败方的部队，防止后面该路战斗结束前该玩家还会被匹配到
		if (attackWin) {
			defencerData.getArmyMap().remove(which);
			defencerData.addFailNum(which);
			// attackerData.addSuccessNum(which);
			addPlayerWinNum(which, attackerData, attackPlayer.lord.getNick());// 记录玩家连胜次数，如果达到广播要求，全服广播
		} else {
			attackerData.getArmyMap().remove(which);
			attackerData.addFailNum(which);
			// defencerData.addSuccessNum(which);
			addPlayerWinNum(which, defencerData, defencePlayer.lord.getNick());// 记录玩家连胜次数，如果达到广播要求，全服广播
		}
		return attackWin;
	}

	/**
	 * 记录玩家连胜次数，如果玩家连胜次数达到要求，发送公告
	 * 
	 * @param which
	 * @param drillData
	 * @param nick
	 */
	private void addPlayerWinNum(int which, DrillFightData drillData, String nick) {
		int winNum = drillData.addSuccessNum(which);
		String camp = drillData.isRed() ? DrillConstant.RED : DrillConstant.BLUE;
		String name = DrillConstant.getName(which);
		if (winNum == 3) {
			chatService.sendWorldChat(chatService.createSysChat(SysChatId.Drill_Win3, camp, nick, name));
		} else if (winNum == 7) {
			chatService.sendWorldChat(chatService.createSysChat(SysChatId.Drill_Win7, camp, nick, name));
		} else if (winNum == 10) {
			chatService.sendWorldChat(chatService.createSysChat(SysChatId.Drill_Win10, camp, nick, name));
		}
	}

	/**
	 * 记录阵营功勋值
	 * 
	 * @param camp
	 * @param exploit
	 */
	private void addCampExploit(boolean camp, int exploit) {
		if (camp) {
			redExploit += exploit;
		} else {
			blueExploit += exploit;
		}
	}

	/**
	* @Description: 增加战斗记录
	* @param which
	* @param record  
	* void
	 */
	private void addFightRecord(int which, DrillRecord record) {
		LinkedHashMap<Integer, DrillRecord> map = drillRecords.get(which);
		if (null == map) {
			map = new LinkedHashMap<>();
			drillRecords.put(which, map);
		}
		map.put(record.getReportKey(), record);
	}

	private CommonPb.RptMan createRptMan(Player player, int hero, int firstValue) {
		CommonPb.RptMan.Builder builder = CommonPb.RptMan.newBuilder();
		Lord lord = player.lord;
		builder.setName(lord.getNick());
		builder.setHero(hero);
		builder.setFirstValue(firstValue);
		return builder.build();
	}

	/**
	 * 计算并扣除损失的坦克，并返回对应的功勋值
	 * 
	 * @param form
	 * @param fighter
	 * @param player
	 * @param enemyLordId
	 */
	private int calDestroyTank(Form form, Fighter fighter, Player player, Player enemy) {
		// 临时记录损失的坦克
		Map<Integer, Integer> destroyTank = new HashMap<Integer, Integer>();

		int length = form.p.length;
		for (int i = 0; i < length; i++) {
			int tankId = form.p[i];
			if (tankId == 0) {
				continue;
			}
			int killCount = fighter.forces[i] == null ? 0 : fighter.forces[i].killed;
			form.c[i] = form.c[i] - killCount;// 更新战后的阵型

			Integer count = destroyTank.get(tankId);
			if (count == null) {
				destroyTank.put(tankId, killCount);
			} else {
				destroyTank.put(tankId, count + killCount);
			}
		}

		double exploit = 0;// 记录机会坦克对应的功勋值
		Set<Integer> keySet = destroyTank.keySet();
		for (Integer tankId : keySet) {
			int count = destroyTank.get(tankId);

			Tank drillTank = player.drillTanks.get(tankId);
			if (null == drillTank) {
				drillTank = new Tank(tankId, 0, 0);
				player.drillTanks.put(tankId, drillTank);
			} else {
				if (drillTank.getCount() < count) {
					count = drillTank.getCount();
				}
				if (count > 0) {
					drillTank.setCount(drillTank.getCount() - count);
					LogLordHelper.tank(AwardFrom.DRILL_FIGHT, player.account, player.lord, tankId, drillTank.getCount(),
							-count, -count, enemy.lord.getLordId());// 记录玩家坦克消耗

					// 记录玩家击毁坦克数
					Integer killNum = enemy.drillKillTank.get(tankId);
					if (null == killNum) {
						enemy.drillKillTank.put(tankId, count);
					} else {
						enemy.drillKillTank.put(tankId, killNum + count);
					}

					exploit += count * staticDrillDataManager.getExploitByTankId(tankId);
				}
			}
		}

		return (int) Math.ceil(exploit);// 向上取整
	}

	/**
	 * 剔除本轮战斗中不能参加的成员，并排序
	 * 
	 * @param map
	 * @return
	 */
	public LinkedList<DrillFightData> sortRoleFightMap(Map<Long, DrillFightData> map) {
		LinkedList<DrillFightData> list = new LinkedList<>();
		if (CheckNull.isEmpty(map)) {
			return list;
		}

		int add = drillStatus - DrillConstant.STATUS_FIRST_BATTLE;
		int formType = FormType.DRILL_1 + add;// 本轮战斗对应的红蓝大战的阵型类型
		int which = add + 1;// 当前是第几轮战斗

		Player player;
		DrillArmy army;
		DrillFightData data;
		for (Long lordId : map.keySet()) {
			player = playerDataManager.getPlayer(lordId);
			if (null != player && player.forms.containsKey(formType)) {
				data = player.drillFightData;
				if (null != data && !CheckNull.isEmpty(data.getArmyMap())) {
					army = data.getArmyMap().get(which);// 剔除在该路没有设置阵型（或者已经战败，阵型被移除）的玩家
					if (null != army) {// 更新战力
						army.fightNum = fightService.calcFormFight(player, army.form);
						list.add(data);
					}
				}
			}
		}

		Collections.sort(list, new DrillRankAscCompator());

		return list;
	}

	/**
	 * 上路进入战斗状态的时候，更新玩家的部队等属性
	 */
	public void refreshDrillArmy() {
		Player player = null;
		DrillFightData data = null;
		for (Long lordId : enrolledRoleSet) {
			player = playerDataManager.getPlayer(lordId);
			data = player.drillFightData;
			data.clearData();
			data.refreshData(player);
			for (DrillArmy army : data.getArmyMap().values()) {
				army.totalFight = fightService.calcFormFight(player, army.form);
			}
		}
	}

	/**
	 * 红蓝大战开始报名时，清空上次大战的数据
	 */
	public void clearDrillData() {
		redArmyMap.clear();
		blueArmyMap.clear();
		redRoleMap.clear();
		blueRoleMap.clear();
		drillShowRank.clear();
		drillResult.clear();
		drillRecords.clear();
		drillFightRpts.clear();
		enrolledRoleSet.clear();
		drillRedImprove.clear();
		drillBlueImprove.clear();
		resetKeys();

		// 重置下次战斗时间
		nextFightTime = 0;
		// 重置双方阵营功勋值
		redExploit = 0;
		blueExploit = 0;
		drillWinner = DrillConstant.RESULT_DRAW;
		globalDataManager.gameGlobal.setRedExploit(redExploit);
		globalDataManager.gameGlobal.setBlueExploit(blueExploit);
		globalDataManager.gameGlobal.setDrillWinner(drillWinner);
	}

	/**
	 * 红蓝大战进入备战阶段，分配玩家阵营
	 */
	public void refreshCamp() {
		long lordId;
		int offset = 0;
		boolean camp = false;
		Player player = null;
		DrillFightData data = null;
		Set<Long> enrollSet = new HashSet<>(enrolledRoleSet);
		Iterator<Lord> it = rankDataManager.getRankList(1).iterator();
		while (it.hasNext()) {// 先分配战力排行榜上的玩家，排行榜玩家分配原则：如果前一名的玩家分配了到了红方，则后一名分配到蓝方的比例增加，反之亦然
			lordId = it.next().getLordId();
			if (enrollSet.contains(lordId)) {// 玩家有报名参加活动，分配
				player = playerDataManager.getPlayer(lordId);
				camp = randomCamp(offset);

				data = player.drillFightData;
				data.setRed(camp);
				if (camp) {
					redRoleMap.put(lordId, data);
					offset -= 20;
				} else {
					blueRoleMap.put(lordId, data);
					offset += 20;
				}
				enrollSet.remove(lordId);// 移除已分配玩家
			}
		}

		for (Long lordId2 : enrollSet) {// 未出现在战力排行榜上的玩家
			player = playerDataManager.getPlayer(lordId2);
			camp = !camp;

			data = player.drillFightData;
			data.setRed(camp);
			if (camp) {
				redRoleMap.put(lordId2, data);
			} else {
				blueRoleMap.put(lordId2, data);
			}
		}

		// int index = 0;
		// for (Long lordId2 : enrolledRoleSet) {
		// player = playerDataManager.getPlayer(lordId2);
		// if (index == 0) {// 测试用，只分1个到蓝军，其他都分到红军
		// camp = false;
		// index++;
		// } else {
		// camp = true;
		// }
		//
		// data = player.drillFightData;
		// data.setRed(camp);
		// if (camp) {
		// redRoleMap.put(lordId2, data);
		// } else {
		// blueRoleMap.put(lordId2, data);
		// }
		// }
	}

	/**
	 * 随机阵营，true为红方，否则为蓝方
	 * 
	 * @param offset 偏移量，取值范围(-50,50)，传入负数，蓝方比例会增加，传入正数则红方比例增加
	 * @return
	 */
	public boolean randomCamp(int offset) {
		int baseProb = 50;// 基础概率50%，根据需要按偏移量增减随机概率
		return RandomHelper.isHitRangeIn100(baseProb + offset);
	}

	/**
	 * 活动结束后清空玩家的部队数据
	 */
	public void clearRoleDrillArmy() {
		Player player = null;
		for (Long lordId : enrolledRoleSet) {
			player = playerDataManager.getPlayer(lordId);
			if (null != player) {
				player.forms.remove(FormType.DRILL_1);
				player.forms.remove(FormType.DRILL_2);
				player.forms.remove(FormType.DRILL_3);
			}
		}

	}
	
	/**
	 * 邮件发送玩家的参与奖励，胜利方的玩家发送编制加速BUFF
	 */
	public void sendPartReward() {
		if (drillWinner == DrillConstant.RESULT_DRAW) {// 三路都没有玩家设置部队，本次活动无效
			return;
		}
		Set<Long> winnerSet;
		Set<Long> loserSet;
		if (drillWinner == DrillConstant.RESULT_RED) {
			winnerSet = redRoleMap.keySet();
			loserSet = blueRoleMap.keySet();
		} else {
			loserSet = redRoleMap.keySet();
			winnerSet = blueRoleMap.keySet();
		}

		List<List<Integer>> awardList = staticWarAwardDataMgr.getDrillPartWinAward();
		List<CommonPb.Award> awards = PbHelper.createAwardsPb(awardList);
		int now = TimeHelper.getCurrentSecond();
		Player player;
		for (Long lordId : winnerSet) {// 胜利方的奖励
			player = playerDataManager.getPlayer(lordId);
			if (null != player) {
				// 发送编制加速BUFF
				playerDataManager.addEffect(player, EffectType.ADD_STAFFING_ALL, 24 * 3600);

				// 通过邮件附件形式发送参与奖励
				playerDataManager.sendAttachMail(AwardFrom.DRILL_PART_WIN_AWARD, player, awards,
						MailType.MOLD_DRILL_PART_REWARD, now);
			}
		}

		awardList = staticWarAwardDataMgr.getDrillPartFailAward();
		awards = PbHelper.createAwardsPb(awardList);
		for (Long lordId : loserSet) {// 失败方的参与奖励
			player = playerDataManager.getPlayer(lordId);
			if (null != player) {
				// 通过邮件附件形式发送参与奖励
				playerDataManager.sendAttachMail(AwardFrom.DRILL_PART_FAIL_AWARD, player, awards,
						MailType.MOLD_DRILL_PART_REWARD, now);
			}
		}
	}
}

/**
 * 红蓝大战排行榜总榜排序
 *
 */
class DrillTotalRankCompator implements Comparator<DrillFightData> {

	@Override
	public int compare(DrillFightData o1, DrillFightData o2) {
		int s1 = o1.getSuccessNum();
		int s2 = o2.getSuccessNum();
		if (s1 > s2) {// 胜利次数多的排前面
			return -1;
		} else if (s1 < s2) {
			return 1;
		} else {
			int f1 = o1.getFailNum();
			int f2 = o2.getFailNum();
			if (f1 < f2) {// 失败次数少的排前面
				return -1;
			} else if (f1 > f2) {
				return 1;
			} else {
				long fight1 = o1.getFight();
				long fight2 = o2.getFight();
				if (fight1 > fight2) {// 战力高的排前面
					return -1;
				} else if (fight1 < fight2) {
					return 1;
				}
			}
		}

		return 0;
	}
}

/**
 * 红蓝大战的匹配排序比较逻辑，首先比较双方的胜利次数，其次比较战力
 *
 */
class DrillRankAscCompator implements Comparator<DrillFightData> {

	@Override
	public int compare(DrillFightData o1, DrillFightData o2) {
		int which = DrillDataManager.getDrillStatus() - DrillConstant.STATUS_PREHEAT;
		int s1 = o1.getSuccessNum(which);
		int s2 = o2.getSuccessNum(which);
		if (s1 > s2) {// 连胜次数高的排前面
			return 1;
		} else if (s1 < s2) {
			return -1;
		} else {
			if (which >= 1 && which <= 3) {// 如果是排总榜的时候，不应该进入这里，这里是三路战斗的匹配排序，战力高的排前面
				long v1 = o1.getArmyMap().get(which).totalFight;
				long v2 = o2.getArmyMap().get(which).totalFight;
				if (v1 > v2) {
					return -1;
				} else if (v1 < v2) {
					return 1;
				}
			}
		}

		return 0;
	}
}

/**
 * 红蓝大战分榜排序逻辑
 *
 */
class DrillRankDescCompator implements Comparator<DrillFightData> {

	@Override
	public int compare(DrillFightData o1, DrillFightData o2) {
		int which = DrillDataManager.getDrillStatus() - DrillConstant.STATUS_PREHEAT;
		int s1 = o1.getSuccessNum(which);
		int s2 = o2.getSuccessNum(which);
		if (s1 > s2) {
			return -1;
		} else if (s1 < s2) {
			return 1;
		} else {
			int f1 = o1.getFailNum(which);
			int f2 = o2.getFailNum(which);
			if (f1 < f2) {
				return -1;
			} else if (f1 > f2) {
				return 1;
			}
		}

		return 0;
	}
}
