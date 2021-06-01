package com.game.manager;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import org.apache.commons.lang3.RandomUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.game.constant.ArmyState;
import com.game.dataMgr.StaticHonourSurviveMgr;
import com.game.dataMgr.StaticWorldDataMgr;
import com.game.domain.Player;
import com.game.domain.p.Army;
import com.game.domain.s.StaticHonourBuff;
import com.game.domain.s.StaticMine;
import com.game.domain.s.StaticMineLv;
import com.game.honour.domain.HonourConstant;
import com.game.honour.domain.HonourPartyScore;
import com.game.honour.domain.HonourRoleScore;
import com.game.honour.domain.SafeArea;
import com.game.service.HonourSurviveService;
import com.game.util.CheckNull;
import com.game.util.LogUtil;
import com.game.util.TimeHelper;
import com.game.util.Tuple;

/**
 * @author: LiFeng
 * @date:
 * @description: 荣耀生存玩法
 */
@Component
public class HonourDataManager {

	@Autowired
	private GlobalDataManager globalDataManager;

	@Autowired
	private HonourSurviveService honourSurviveService;

	@Autowired
	private PartyDataManager partyDataManager;

	@Autowired
	private PlayerDataManager playerDataManager;

	@Autowired
	private StaticHonourSurviveMgr staticHonourSurviveMgr;

	@Autowired
	private StaticWorldDataMgr staticWorldDataMgr;

	@Autowired
	private SmallIdManager smallIdManager;

	@Autowired
	private WorldDataManager worldDataManager;

	@Autowired
	private StaffingDataManager staffingDataManager;

	/** 安全区中心点 */
	private List<Tuple<Integer, Integer>> points = new ArrayList<>();

	/** 每阶段的初始安全区，不存库 */
	private List<SafeArea> initSafeAreas = new ArrayList<>();

	/** 安全区，不存库 */
	private SafeArea safeArea;

	/** 毒圈开始时间， 精确到分 */
	private int openTime;

	/** 毒圈当前阶段 */
	private int phase;

	/** 军团积分信息 */
	private Map<Integer, HonourPartyScore> honourPartyScore = new HashMap<>();

	/** 个人排行榜， 根据play.honourScore计算，不存库 */
	private LinkedList<HonourRoleScore> honourPlayerRank = new LinkedList<>();

	/** 军团排行榜，根据honourPartyScore计算，不存库 */
	private LinkedList<HonourPartyScore> honourPartyRank = new LinkedList<>();

	/** 已领取个人排行榜奖励的玩家 */
	private List<Long> playerRankAward = new LinkedList<>();

	/** 已领取军团排行榜奖励的玩家 */
	private List<Long> partyRankAward = new LinkedList<>();

	/** 是否已通知活动结束的标记 */
	private boolean notifyClose = false;

	/**
	 * 玩法已开启多久时间，精确到分（按理论值，即使中间有停服）
	 */
	public int haveOpen() {
		if (!isOpen()) {
			return 0;
		}
		int haveOpen = TimeHelper.getCurrentMinute() - openTime;
		return haveOpen > 0 ? haveOpen : 0;
	}

	/**
	 * 是否在安全区内
	 * 
	 * @param pos
	 * @return 1 安全区； -1 在安全区外
	 */
	public int isInSafeArea(int pos) {
		if (safeArea != null) {
			return safeArea.isSafe(pos);
		}
		return -1;
	}

	/**
	 * 活动是否已开启
	 */
	public boolean isOpen() {
		return !CheckNull.isEmpty(points);
	}

	/**
	 * 生成安全区中心点
	 */
	public void generatePoints() {
		points.clear();
		List<Integer> halfLength = HonourConstant.halfLength;
		// 300是世界地图半边长
		Tuple<Integer, Integer> turple = new Tuple<>(300, 300);
		for (int i = 0; i < halfLength.size(); i++) {
			int length;
			if (i == 0) {
				length = 300 - halfLength.get(i);
			} else {
				length = halfLength.get(i - 1) - halfLength.get(i);
			}
			turple = generateOnePoint(i, turple.getA(), turple.getB(), length);
			points.add(turple);
		}
	}

	/**
	 * 安全区中心点生成规则
	 * 
	 * @param index 第几个安全区中心点
	 * @param x 上一个中心点坐标
	 * @param y 上一个中心点坐标
	 * @param length 区间
	 * @return Tuple 安全区中心点
	 */
	private Tuple<Integer, Integer> generateOnePoint(int index, int x, int y, int length) {
		int A = RandomUtils.nextInt(x - length, x + length);
		int B = RandomUtils.nextInt(y - length, y + length);
		Tuple<Integer, Integer> turple = new Tuple<>(A, B);
		LogUtil.common("HonourSurvive generateOnePoint index: " + index + " x: " + A + " y:" + B);
		return turple;
	}

	/**
	 * 实时更新安全区
	 */
	public void updateSafeArea() {
		int phase = honourSurviveService.inWhichPhase();
		setPhase(phase);
		if (phase == 0) {
			// 毒圈未出现，整个地图都属于安全区
			this.safeArea = initSafeAreas.get(0);
			return;
		}
		int index = Math.abs(phase) - 1;
		// 当不缩圈时，避免无意义的刷新安全区
		if (phase > 0 && (safeArea == null || safeArea.getPhase() != phase)) {
			this.safeArea = initSafeAreas.get(index + 1);
		} else if (phase < 0 && index < HonourConstant.refreshTime.size()) {
			Integer[] refreshTime = HonourConstant.refreshTime.get(index);
			int interval = TimeHelper.getCurrentMinute() - openTime;
			// 当前缩圈进度
			float rate = (interval - refreshTime[0]) * 1F / (refreshTime[1] - refreshTime[0]);
			SafeArea lastSafeArea = initSafeAreas.get(index);
			SafeArea nextSafeArea = initSafeAreas.get(index + 1);
			if (safeArea == null) {
				this.safeArea = new SafeArea();
			}
			safeArea.refresh(lastSafeArea, nextSafeArea, rate, phase);
		}
	}

	/**
	 * 起服加载数据
	 */
	public void init() {
		points = globalDataManager.gameGlobal.getPoints();
		openTime = globalDataManager.gameGlobal.getHonourOpenTime();
		phase = globalDataManager.gameGlobal.getHonourPhase();
		playerRankAward = globalDataManager.gameGlobal.getPlayerRankAward();
		partyRankAward = globalDataManager.gameGlobal.getPartyRankAward();
		honourPartyScore = globalDataManager.gameGlobal.getPartyScore();
		initSafeArea();
	}

	/**
	 * 数据加载完成后进行某些初始化操作
	 */
	public void initData() {

		// 起服数据加载完成后马上主动调一次定时任务，刷新安全区
		Calendar calendar = Calendar.getInstance();
		int dayOfMonth = calendar.get(Calendar.DAY_OF_MONTH);
		int hourOfDay = calendar.get(Calendar.HOUR_OF_DAY);
		int minute = calendar.get(Calendar.MINUTE);
		honourSurviveService.honourLogic(dayOfMonth, hourOfDay, minute);

		// 初始化个人排行榜
		LinkedList<HonourRoleScore> roleScorelList = new LinkedList<>();
		Iterator<Player> its = playerDataManager.getPlayers().values().iterator();
		while (its.hasNext()) {
			Player player = its.next();
			HonourRoleScore honourScore = player.honourScore;
			if (!smallIdManager.isSmallId(player.lord.getLordId())) {
				if (honourScore != null && honourScore.getScore() >= HonourConstant.roleRankLimit) {
					roleScorelList.add(honourScore);
				}
			}
		}
		Collections.sort(roleScorelList);
		int maxIndex = roleScorelList.size() > 10 ? 10 : roleScorelList.size();
		honourPlayerRank.addAll(roleScorelList.subList(0, maxIndex));

		// 初始化军团排行榜
		LinkedList<HonourPartyScore> partyScorelList = new LinkedList<>();
		for (HonourPartyScore partyScore : honourPartyScore.values()) {
			if (partyScore.getScore() >= HonourConstant.partyRankLimit) {
				partyScorelList.add(partyScore);
			}
		}
		Collections.sort(partyScorelList);
		int maxIndex2 = partyScorelList.size() > 10 ? 10 : partyScorelList.size();
		honourPartyRank.addAll(partyScorelList.subList(0, maxIndex2));
	}

	/**
	 * 初始化每阶段默认最终安全区
	 */
	public void initSafeArea() {
		initSafeAreas.clear();
		// 初始化每个阶段的初始安全区大小，第一个默认安全区为整个世界地图
		SafeArea firstArea = new SafeArea(new Tuple<Integer, Integer>(300, 300), 300, 0);
		this.safeArea = firstArea;
		initSafeAreas.add(firstArea);
		for (int i = 0; i < points.size(); i++) {
			Tuple<Integer, Integer> pos = points.get(i);
			Integer halfLength = HonourConstant.halfLength.get(i);
			SafeArea area = new SafeArea(pos, halfLength, i + 1);
			initSafeAreas.add(area);
		}

	}

	/**
	 * 是否在活动开启时间
	 * 
	 * @return -1 未到开启时间， 0 正好位于玩法开启时间点，1 已过开启时间
	 */
	public int isOpenTime(int hourOfDay, int minute) {
		if (hourOfDay > HonourConstant.openTime[0]) {
			return 1;
		} else if (hourOfDay == HonourConstant.openTime[0]) {
			if (minute == HonourConstant.openTime[1]) {
				return 0;
			} else if (minute > HonourConstant.openTime[1]) {
				return 1;
			}
		}
		return -1;
	}

	/**
	 * 获取此时指定坐标的buff信息
	 */
	public StaticHonourBuff getHonourBuff(int pos) {
		if (!isOpen()) {
			return null;
		}
		int type = isInSafeArea(pos);
		return staticHonourSurviveMgr.getHonourBuff(Math.abs(phase), type);
	}

	/**
	 * 活动结束，清除数据
	 */
	public void endClear() {
		for (Player player : playerDataManager.getPlayers().values()) {
			player.setHonourPartyId(partyDataManager.getPartyId(player.lord.getLordId()));
		}
		setPhase(0);
		initSafeAreas.clear();
		points.clear();
	}

	/**
	 * 开启玩法
	 * 
	 * @param day 玩法配置的开启日期（每月第几天）
	 */
	public void openHonourSurvive(int day) {
		Calendar cal = Calendar.getInstance();

		// 记录当前玩法实际开启时间
		LogUtil.common("honourSurvive opentime | Day:" + cal.get(Calendar.DAY_OF_MONTH) + " Month:" + (cal.get(Calendar.MONTH) + 1));

		cal.set(Calendar.DAY_OF_MONTH, day);
		cal.set(Calendar.HOUR_OF_DAY, HonourConstant.openTime[0]);
		cal.set(Calendar.MINUTE, HonourConstant.openTime[1]);
		setOpenTime(((int) (cal.getTimeInMillis() / 60000)));

		generatePoints();
		initSafeArea();
		setNotifyClose(false);

		// 清除上次玩法军团积分数据
		honourPartyScore.clear();

		// 清除个人数据
		for (Player player : playerDataManager.getPlayers().values()) {
			player.honourScore = null;
			player.honourNotify = false;
			player.setHonourPartyId(0);
			player.setHonourGrabGold(0);
			player.setHonourScoreGoldStatus(0);
		}

		honourPlayerRank.clear();
		honourPartyRank.clear();
		playerRankAward.clear();
		partyRankAward.clear();

		int phase = honourSurviveService.inWhichPhase();

		/**
		 * 这里是为了特殊处理0阶段（未开启活动和开启一小时之内都是0，定时器里的synUpdateSafeArea不会被调用，所以需要特殊处理），这里同步过去的一定是一个全图安全区，
		 * 但是当开服时间是玩法的其他阶段时间段时，这个同步的安全区就是错误的。这个错误只是一瞬，后续定时器立刻会再同步一个正确的安全区
		 */
		honourSurviveService.synUpdateSafeArea(null);

		honourSurviveService.synNextSafeArea(phase, null);

		for (Player player : playerDataManager.getAllOnlinePlayer().values()) {
			honourSurviveService.notifyOpenOrClose(player, 1);
		}
	}

	/**
	 * 增加荣耀积分
	 */
	public void addHonourScore(Player player, int add) {
		if (!isOpen()) {
			return;
		}
		HonourRoleScore roleScore = player.honourScore;
		long lordId = player.lord.getLordId();
		int partyId = partyDataManager.getPartyId(lordId);
		if (roleScore == null || roleScore.getOpenTime() != openTime) {
			roleScore = new HonourRoleScore(lordId, openTime);
			player.honourScore = roleScore;
		}
		int score = roleScore.getScore() + add;
		roleScore.setScore(score);
		roleScore.setPartyId(partyId);

		if (score >= HonourConstant.roleRankLimit) {
			updatePlayerRank(roleScore);
		}

		if (partyId != 0) {
			HonourPartyScore partyScore = getPartyScoreByPartyId(partyId);
			if (partyScore == null) {
				partyScore = new HonourPartyScore(partyId, openTime);
				honourPartyScore.put(partyId, partyScore);
			}
			int score2 = partyScore.getScore() + add;
			partyScore.setScore(score2);

			if (score2 >= HonourConstant.partyRankLimit) {
				updatePartyRank(partyScore);
			}
		}
		// 记录一下积分获取情况
		LogUtil.common("addHonourScore | nick : " + player.lord.getNick() + "| partyId : " + partyId + "| add : " + add);
	}

	/**
	 * 更新个人排行榜
	 * 
	 */
	private void updatePlayerRank(HonourRoleScore roleScore) {
		boolean flag = honourPlayerRank.contains(roleScore);
		if (!flag) {
			// 写死排行榜只存前10条
			if (honourPlayerRank.size() == 10) {
				if (roleScore.compareTo(honourPlayerRank.getLast()) < 0) {
					honourPlayerRank.set(9, roleScore);
				}
			} else {
				honourPlayerRank.add(roleScore);
			}
		}
		roleScore.setRankTime(TimeHelper.getCurrentSecond());
		Collections.sort(honourPlayerRank);

	}

	/**
	 * 更新军团排行榜
	 * 
	 */
	private void updatePartyRank(HonourPartyScore partyScore) {
		boolean flag = honourPartyRank.contains(partyScore);
		if (!flag) {
			if (honourPartyRank.size() == 10) {
				if (partyScore.compareTo(honourPartyRank.getLast()) < 0) {
					honourPartyRank.set(9, partyScore);
				}
			} else {
				honourPartyRank.add(partyScore);
			}
		}
		partyScore.setRankTime(TimeHelper.getCurrentSecond());
		Collections.sort(honourPartyRank);
	}

	/**
	 * 根据军团ID获取指定军团的积分信息
	 */
	public HonourPartyScore getPartyScoreByPartyId(int partyId) {
		return honourPartyScore.get(partyId);
	}

	/**
	 * 获取玩家的个人积分排行
	 */
	public int getPlayerRank(long roleId) {
		Player player = playerDataManager.getPlayer(roleId);
		int index = honourPlayerRank.indexOf(player.honourScore);
		if (index < 0) {
			return 0;
		}
		return index + 1;
	}

	/**
	 * 获取军团的积分排行
	 */
	public int getPartyRank(int partyId) {
		HonourPartyScore honourPartyScore = getPartyScoreByPartyId(partyId);
		int index = honourPartyRank.indexOf(honourPartyScore);
		if (index < 0) {
			return 0;
		}
		return index + 1;
	}

	/**
	 * 判断是否已领取排行榜奖励
	 * 
	 * @param player
	 * @param type 排行榜类型,1 表示个人榜，2表示军团榜
	 * @return
	 */
	public boolean isReceiveAward(Player player, int type) {
		long lordId = player.lord.getLordId();
		if (type == 1) {
			return playerRankAward.contains(lordId);
		}
		if (type == 2) {
			return partyRankAward.contains(lordId);
		}
		return true;
	}

	/**
	 * 获取安全区内的所有坐标点
	 * 
	 * @param area 区域
	 * @return 坐标点集合
	 */
	public List<Integer> getPosInArea(SafeArea area) {
		List<Integer> list = new LinkedList<>();
		if (area == null) {
			return list;
		}
		for (int i = area.getBeginx(); i <= area.getEndx(); i++) {
			for (int j = area.getBeginy(); j <= area.getEndy(); j++) {
				int pos = i + j * 600;
				list.add(pos);
			}
		}
		return list;
	}

	/**
	 * 计算本次玩法中，每个阶段的开始时间
	 * 
	 * @param phase
	 * @return 返回值0表示不合法参数或活动未开启
	 */
	public int calcPhaseOpenTime(int phase) {
		if (!isOpen()) {
			return 0;
		}
		List<Integer[]> refreshTime = HonourConstant.refreshTime;
		if (Math.abs(phase) > refreshTime.size()) {
			return 0;
		}
		if (phase == 0) {
			return openTime;
		}
		int index = phase < 0 ? 0 : 1;
		return openTime + refreshTime.get(Math.abs(phase) - 1)[index];
	}

	/**
	 * 计算预期的活动结束时间点，精确到分
	 * 
	 * @param day 每月的第几天
	 * @return
	 */
	public int calcExpectedEndTime(int day) {
		if (!HonourConstant.openDayInMonth.contains(day)) {
			return 0;
		}
		Calendar cal = Calendar.getInstance();
		cal.set(Calendar.DAY_OF_MONTH, day);
		cal.set(Calendar.HOUR_OF_DAY, HonourConstant.openTime[0]);
		cal.set(Calendar.MINUTE, HonourConstant.openTime[1]);
		int endTime = (int) (cal.getTimeInMillis() / 60000) + HonourConstant.duration;
		return endTime;

	}

	/**
	 * 采集金币
	 * 
	 * @param army
	 * @param now
	 * @return
	 */
	public int calcHonourCollectGold(Army army, int now) {
		if (!isOpen()) {
			return army.getHonourGold();
		}

		if(army.getSenior() || army.isCrossMine()){
			return 0;
		}

		if (army.getState() != ArmyState.COLLECT) {
			return 0;
		}

		List<Integer> posList = getPosInArea(this.initSafeAreas.get(4));
		if (!posList.contains(army.getTarget())) {
			return 0;
		}
		StaticMine staticMine = worldDataManager.evaluatePos(army.getTarget());
		if (staticMine == null) {
			return 0;
		}
		StaticMineLv staticMineLv = staticWorldDataMgr.getStaticMineLvWolrd(staticMine.getLv(),staffingDataManager.getWorldMineLevel() );
		if (staticMineLv == null) {
			return 0;
		}

		// 4阶段才开始产生金币
		int phaseOpen = calcPhaseOpenTime(4);
		int armyEnd = army.getEndTime() / 60;
		// armyEnd < openTime条件用于当采集结束后一直未撤回，到了第二次活动重新开始，金币会清零
		if (now < phaseOpen || armyEnd < openTime) {
			return 0;
		}

		// 金币采集生效开始时间
		int goldBegin = army.getCollectBeginTime() / 60;
		goldBegin = goldBegin < phaseOpen ? phaseOpen : goldBegin;

		if (now > openTime + HonourConstant.duration) {
			now = openTime + HonourConstant.duration;
		}
		// 金币采集实际结算时间
		int goldEnd = armyEnd > now ? now : armyEnd;
		if (goldEnd <= goldBegin) {
			return army.getHonourGold();
		}
		int hasCollect = goldEnd - goldBegin;
		// 仅一次采集跨两个玩法时可能出现这种情况
		if (hasCollect > HonourConstant.duration - HonourConstant.refreshTime.getLast()[1]) {
			hasCollect = HonourConstant.duration - HonourConstant.refreshTime.getLast()[1];
		}
		int gold = hasCollect / HonourConstant.goldTime * staticMineLv.getHonourLiveGold();
		return army.getHonourGold() + gold;
	}

	/**
	 * 计算部队当前采集及掠夺获得的荣耀积分总数
	 * 
	 * @param army
	 * @param now
	 * @param collect 对应等级矿点每小时积分产出
	 * @param pos 矿点坐标
	 * @return
	 */
	public int calcHonourScore(Army army, int now, int collect, int pos) {
		if (!isOpen() || army.getState() != ArmyState.COLLECT) {
			return 0;
		}

		if(army.getSenior()){
			return 0;
		}

		int openTime = getOpenTime() * 60;
		if (army.getEndTime() < openTime) {
			return 0;
		}
		// 如果撤回部队结算积分时，活动已结束，则不给积分
		if (now > openTime + HonourConstant.duration * 60) {
			return 0;
		}
		int realCollect = 0;
		// 实际有效的积分采集开始时间
		int begin = army.getEndTime() - army.getPeriod();
		if (begin <= openTime) {
			begin = openTime;
		}
		if (now > army.getEndTime()) {
			now = army.getEndTime();
		}
		if (begin > now) {
			return 0;
		}
		realCollect = now - begin;
		int score = army.getHonourScore();
		score += (int) (realCollect / ((double) TimeHelper.HOUR_S) * collect);
		return score;
	}

	public List<Tuple<Integer, Integer>> getPoints() {
		return points;
	}

	public void setPoints(List<Tuple<Integer, Integer>> points) {
		this.points = points;
	}

	public void setOpenTime(int openTime) {
		this.openTime = openTime;
		globalDataManager.gameGlobal.setHonourOpenTime(openTime);

	}

	public int getOpenTime() {
		return openTime;
	}

	public int getPhase() {
		return phase;
	}

	public void setPhase(int phase) {
		this.phase = phase;
		globalDataManager.gameGlobal.setHonourPhase(phase);
	}

	public SafeArea getSafeArea() {
		return safeArea;
	}

	public boolean isNotifyClose() {
		return notifyClose;
	}

	public void setNotifyClose(boolean notifyClose) {
		this.notifyClose = notifyClose;
	}

	public void setSafeArea(SafeArea safeArea) {
		this.safeArea = safeArea;
	}

	public LinkedList<HonourRoleScore> getHonourPlayerRank() {
		return honourPlayerRank;
	}

	public void setHonourPlayerRank(LinkedList<HonourRoleScore> honourPlayerRank) {
		this.honourPlayerRank = honourPlayerRank;
	}

	public LinkedList<HonourPartyScore> getHonourPartyRank() {
		return honourPartyRank;
	}

	public void setHonourPartyRank(LinkedList<HonourPartyScore> honourPartyRank) {
		this.honourPartyRank = honourPartyRank;
	}

	public List<Long> getPlayerRankAward() {
		return playerRankAward;
	}

	public void setPlayerRankAward(List<Long> playerRankAward) {
		this.playerRankAward = playerRankAward;
	}

	public List<Long> getPartyRankAward() {
		return partyRankAward;
	}

	public void setPartyRankAward(List<Long> partyRankAward) {
		this.partyRankAward = partyRankAward;
	}

	public List<SafeArea> getInitSafeAreas() {
		return initSafeAreas;
	}

	public void setInitSafeAreas(List<SafeArea> initSafeAreas) {
		this.initSafeAreas = initSafeAreas;
	}

}
