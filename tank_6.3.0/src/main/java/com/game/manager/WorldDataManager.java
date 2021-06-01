/**   
 * @Title: WorldDataManager.java    
 * @Package com.game.manager    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年9月11日 上午10:26:25    
 * @version V1.0   
 */
package com.game.manager;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.game.constant.ArmyState;
import com.game.constant.Constant;
import com.game.dataMgr.StaticWorldDataMgr;
import com.game.domain.Player;
import com.game.domain.p.ActRebelData;
import com.game.domain.p.Army;
import com.game.domain.p.Form;
import com.game.domain.p.Guard;
import com.game.domain.p.Lord;
import com.game.domain.p.March;
import com.game.domain.p.Mine;
import com.game.domain.p.airship.Airship;
import com.game.domain.s.StaticMine;
import com.game.domain.s.StaticMineForm;
import com.game.domain.s.StaticScout;
import com.game.rebel.domain.Rebel;
import com.game.util.ListHelper;
import com.game.util.LogUtil;
import com.game.util.RandomHelper;
import com.game.util.TimeHelper;
import com.game.util.Tuple;

/**
 * @ClassName: WorldDataManager
 * @Description: 世界地图相关数据
 * @author ZhangJun
 * @date 2015年9月11日 上午10:26:25
 * 
 */

@Component
public class WorldDataManager {
	@Autowired
	private StaticWorldDataMgr staticWorldDataMgr;

	@Autowired
	private GlobalDataManager globalDataManager;
	@Autowired
	private PlayerDataManager playerDataManager;
	@Autowired
	private ActivityDataManager activityDataManager;
	@Autowired
	private RebelDataManager rebelDataManager;

	// 世界地图上的玩家
	private Map<Integer, Player> posMap = new HashMap<Integer, Player>();

	// 世界地图分块上的玩家
	private Map<Integer, Map<Integer, Player>> areaMap = new HashMap<>();

	// 矿的防守阵型
	private Map<Integer, StaticMineForm> mineFormMap = new HashMap<>();

	public Map<Integer, StaticMineForm> getMineFormMap() {
		return mineFormMap;
	}

	// 叛军阵型
	private Map<Integer, Form> rebelFormMap = new HashMap<>();


	// 全地图驻军数据
	// private Map<Integer, Guard> guardMap = new HashMap<>();
	private Map<Integer, List<Guard>> guardMap = new HashMap<>();

	// 空余的位置信息
	private List<Integer> freePostList = new ArrayList<Integer>();

	// 全地图行军数据 MAP<POS>
	private Map<Integer, List<March>> marchMap = new HashMap<>();

	// 活动叛军阵型
	private Map<Integer, Form> actRebelFormMap = new HashMap<>();

	// 飞艇
	private Map<Integer, Airship> airshipMap = new HashMap<>();

	// 叛军礼盒 key:坐标 , value:剩余可领次数
	private Map<Integer, Integer> rebelBoxMap = new HashMap<>();

	// @PostConstruct
	public void init() {
		for (int i = 0; i < 1600; i++) {
			areaMap.put(i, new HashMap<Integer, Player>());
		}

	}

	static final int INVALID_POS_1 = 298 + 298 * 600;
	static final int INVALID_POS_2 = 299 + 298 * 600;
	static final int INVALID_POS_3 = 300 + 298 * 600;

	static final int INVALID_POS_4 = 298 + 299 * 600;
	static final int INVALID_POS_5 = 299 + 299 * 600;
	static final int INVALID_POS_6 = 300 + 299 * 600;

	static final int INVALID_POS_7 = 298 + 300 * 600;
	static final int INVALID_POS_8 = 299 + 300 * 600;
	static final int INVALID_POS_9 = 300 + 300 * 600;

	public boolean isValidPos(int pos) {
		if (pos == INVALID_POS_1 || pos == INVALID_POS_2 || pos == INVALID_POS_3 || pos == INVALID_POS_4 || pos == INVALID_POS_5
				|| pos == INVALID_POS_6 || pos == INVALID_POS_7 || pos == INVALID_POS_8 || pos == INVALID_POS_9) {
			return false;
		}
		if (pos >= 360000 || pos < 1) {
			return false;
		}
		return true;
	}

	/**
	 * 计算空余位置list后并混乱
	 */
	public void caluFreePostList() {
		for (int pos = 1; pos < 360000; pos++) {
			if (posHasUsed(pos)) {
				continue;
			} else {
				freePostList.add(pos);
			}
		}

		Collections.shuffle(freePostList);
	}

	/**
	 * 
	 * 地图上增加新玩家
	 * 
	 * @param player void
	 */
	public void addNewPlayer(Player player) {
		int pos;
		int slot;
		int xBegin;
		int yBegin;

		int times = 0;
		while (true) {
			slot = staticWorldDataMgr.getSlot(posMap.size());
			xBegin = slot % 20 * 30;
			yBegin = slot / 20 * 30;
			pos = (RandomHelper.randomInSize(30) + xBegin) + (RandomHelper.randomInSize(30) + yBegin) * 600;
			if (posHasUsed(pos)) {
				times++;

				if (times >= 100) {
					pos = freePostList.get(0);

					if (freePostList.size() < 10000) {
						// LogHelper.ERROR_LOGGER.error("位置不够了,请注意, 剩余:" +
						// freePostList.size() + ", 已分配:" + posMap.size());
						LogUtil.warn("空闲位置不够了,请注意, 剩余:" + freePostList.size() + ", 已分配:" + posMap.size());
					}
					break;
				}
				continue;
			}
			break;
		}

		player.lord.setPos(pos);
		putPlayer(player);
	}

	/**
	 * 随机获取一个空闲坐标
	 * 
	 * @return
	 */
	public int randomEmptyPos() {
		int pos;
		int slot;
		int xBegin;
		int yBegin;
		int times = 0;
		while (true) {
			slot = RandomHelper.randomInSize(400);
			xBegin = slot % 20 * 30;
			yBegin = slot / 20 * 30;
			pos = (RandomHelper.randomInSize(30) + xBegin) + (RandomHelper.randomInSize(30) + yBegin) * 600;
			if (posHasUsed(pos)) {
				times++;

				if (times >= 100) {
					pos = freePostList.get(0);

					if (freePostList.size() < 10000) {
						// LogHelper.ERROR_LOGGER.error("位置不够了,请注意, 剩余:" +
						// freePostList.size() + ", 已分配:" + posMap.size());
						LogUtil.warn("位置不够了,请注意, 剩余:" + freePostList.size() + ", 已分配:" + posMap.size());
					}
					break;
				}
				continue;
			}
			break;
		}

		freePostList.remove(Integer.valueOf(pos));// 从空闲坐标中移除

		return pos;
	}

	/**
	 * 
	 * Method: slot
	 * 
	 * @Description: 15 x 15 的客户端拉区区域 @param pos @return @return int @throws
	 */
	public int area(int pos) {
		Tuple<Integer, Integer> xy = reducePos(pos);
		return xy.getA() / 15 + xy.getB() / 15 * 40;
	}

	/**
	 * 
	 * 区域的矿点驻军列表
	 * 
	 * @param area
	 * @return List<Guard>
	 */
	public List<Guard> getAreaMineGuard(int area) {
		int xBegin = area % 40 * 15;
		int xEnd = xBegin + 15;
		int yBegin = area / 40 * 15;
		int yEnd = yBegin + 15;
		int pos = 0;
		Guard guard;
		ArrayList<Guard> guards = new ArrayList<>();
		for (int i = xBegin; i < xEnd; i++) {
			for (int j = yBegin; j < yEnd; j++) {
				pos = i + j * 600;
				guard = getMineGuard(pos);
				if (guard != null && evaluatePos(pos) != null) {
					guards.add(guard);
				}
			}
		}

		return guards;
	}

	/**
	 * 
	 * 计算得到x,y的显示坐标
	 * 
	 * @param pos 数字坐标
	 * @return Turple<Integer,Integer>
	 */
	static public Tuple<Integer, Integer> reducePos(int pos) {
		Tuple<Integer, Integer> turple = new Tuple<Integer, Integer>(pos % 600, pos / 600);
		return turple;
	}

	/**
	 * 
	 * 处于该坐标的矿点
	 * 
	 * @param pos
	 * @return StaticMine
	 */
	public StaticMine evaluatePos(int pos) {
		Tuple<Integer, Integer> xy = reducePos(pos);
		int x = xy.getA();
		int y = xy.getB();
		int index = x / 40 + y / 40 * 15;
		int reflection = (x % 40 + y % 40 * 40 + 13 * index) % 1600;
		StaticMine staticMine = staticWorldDataMgr.getMine(reflection);
		return staticMine;
	}

	private Set<Player> errorLordPos = new HashSet<>();

	/**
	 * 
	 * 搬迁到随机坐标 void
	 */
	public void randomNewPos() {
		for (Player player : errorLordPos) {
			addNewPlayer(player);
			LogUtil.error("lordId= " + player.lord.getLordId() + " 已搬迁 to " + player.lord.getPos());
		}
		errorLordPos = null;
	}

	/**
	 * 
	 * 将玩家放到地图
	 * 
	 * @param player void
	 */
	public void putPlayer(Player player) {
		int pos = player.lord.getPos();
		if (pos != -1) {
			if (!isValidPos(pos)) {// isValidPos以前未判断边缘值1-600*600
				LogUtil.error("错误 pos " + pos + "  lordId= " + player.lord.getLordId() + " 已搬迁 ");
				errorLordPos.add(player);
				return;
			}
			posMap.put(pos, player);
			areaMap.get(area(pos)).put(pos, player);
			freePostList.remove(Integer.valueOf(pos));
		}
	}

	/**
	 * 
	 * 移除某坐标 变为空闲坐标
	 * 
	 * @param pos void
	 */
	public void removePos(int pos) {
		posMap.remove(pos);
		areaMap.get(area(pos)).remove(pos);
		freePostList.add(pos);
	}

	/**
	 * 
	 * 得到区域中的玩家列表
	 * 
	 * @param area
	 * @return List<Player>
	 */
	public List<Player> getMap(int area) {
		List<Player> list = new ArrayList<>();
		Map<Integer, Player> slot = areaMap.get(area);
		if (slot == null) {
			return null;
		}
		Iterator<Player> it = slot.values().iterator();
		while (it.hasNext()) {
			list.add(it.next());
		}
		return list;
	}

	/**
	 * 
	 * 取坐标中的玩家
	 * 
	 * @param pos
	 * @return Player
	 */
	public Player getPosData(int pos) {
		return posMap.get(pos);
	}

	/**
	 * 
	 * 取坐标中的矿点驻军 如果 如果没有 放入指定等级的矿点驻军
	 * 
	 * @param pos
	 * @param lv
	 * @return StaticMineForm
	 */
	public StaticMineForm getMineForm(int pos, int lv) {
		StaticMineForm form = mineFormMap.get(pos);
		if (form == null) {
			form = staticWorldDataMgr.randomForm(lv);
			mineFormMap.put(pos, form);
		}
		return form;
	}

	/**
	 * 
	 * 充值坐标上的矿点驻军
	 * 
	 * @param pos
	 * @param lv void
	 */
	public void resetMineForm(int pos, int lv) {
		mineFormMap.put(pos, staticWorldDataMgr.randomForm(lv));
	}

	/**
	 * 
	 * 坐标中加入叛军驻军
	 * 
	 * @param pos
	 * @param form void
	 */
	public void setRebelForm(int pos, Form form) {
		rebelFormMap.put(pos, form);
	}

	public void setRebelBox(int pos, int count) {
		rebelBoxMap.put(pos, count);
	}

	public Form getRebelForm(int pos) {
		return rebelFormMap.get(pos);
	}

	public boolean isRebel(int pos) {
		return rebelFormMap.containsKey(pos);
	}

	public Map<Integer, Form> getRebelFormMap() {
		return rebelFormMap;
	}

	public Map<Integer, Integer> getRebelBoxMap() {
		return rebelBoxMap;
	}

	public boolean isRebelBox(int pos) {
		return rebelBoxMap.containsKey(pos);
	}

	/**
	 * 将礼盒信息初始化至地图中
	 */
	public void setRebelBoxInMap(Map<Integer, Integer> rebelBoxMap) {
		this.rebelBoxMap = new HashMap<>(rebelBoxMap);
		freePostList.removeAll(rebelBoxMap.keySet());
	}

	/**
	 * 清楚指定位置的礼盒并置空坐标
	 */
	public void removeReblBoxFromMap(int pos) {
		rebelBoxMap.remove(pos);
		if (!freePostList.contains(Integer.valueOf(pos))) {
			freePostList.add(pos);
		}
	}

	/**
	 * 
	 * 指定坐标设为空余坐标
	 * 
	 * @param pos void
	 */
	public void returnRebelPos(int pos) {
		if (!freePostList.contains(Integer.valueOf(pos))) {
			freePostList.add(pos);
		}
	}

	/**
	 * 
	 * 清理地图上叛军 void
	 */
	public void clearRebelForm() {
		for (Integer pos : rebelFormMap.keySet()) {
			if (!freePostList.contains(pos)) {
				freePostList.add(pos);
			}
		}
		rebelFormMap.clear();
	}

	/**
	 * 
	 * Method: getGuard
	 * 
	 * @Description: 获取驻军 @param pos @return void @throws
	 */
	public List<Guard> getGuard(int pos) {
		return guardMap.get(pos);
	}

	/**
	 * 
	 * 获取矿点驻军
	 * 
	 * @param pos
	 * @return Guard
	 */
	public Guard getMineGuard(int pos) {
		List<Guard> list = guardMap.get(pos);
		if (list != null && !list.isEmpty()) {
			return list.get(0);
		}
		return null;
	}

	/**
	 * 
	 * 获取玩家基地驻军
	 * 
	 * @param pos
	 * @return Guard
	 */
	public Guard getHomeGuard(int pos) {
		List<Guard> list = guardMap.get(pos);
		if (list != null && !list.isEmpty()) {
			for (Guard guard : list) {
				if (guard.getArmy().getState() == ArmyState.GUARD) {
					return guard;
				}
			}
		}
		return null;
	}

	/**
	 * 
	 * 将行军的部队设置在目标坐标驻军
	 * 
	 * @param guard void
	 */
	public void setGuard(Guard guard) {
		int pos = guard.getArmy().getTarget();
		List<Guard> list = guardMap.get(pos);
		if (list == null) {
			list = new ArrayList<>();
			guardMap.put(pos, list);
		}
		list.add(guard);
	}

	/**
	 * 
	 * 移除目标驻军
	 * 
	 * @param guard void
	 */
	public void removeGuard(Guard guard) {
		int pos = guard.getArmy().getTarget();
		guardMap.get(pos).remove(guard);
	}

	/**
	 * 
	 * 移除目标坐标的所有驻军
	 * 
	 * @param pos void
	 */
	public void removeGuard(int pos) {
		guardMap.remove(pos);
	}

	/**
	 * 
	 * 移除指定玩家的指定部队驻军
	 * 
	 * @param player
	 * @param army void
	 */
	public void removeGuard(Player player, Army army) {
		int pos = army.getTarget();
		List<Guard> list = guardMap.get(pos);
		Guard e;
		if (list != null) {
			for (int i = 0; i < list.size(); i++) {
				e = list.get(i);
				if (e.getPlayer() == player && e.getArmy().getKeyId() == army.getKeyId()) {
					list.remove(i);
					break;
				}
			}
		}
	}

	/**
	 * 
	 * 获得目标为该坐标的行军数据
	 * 
	 * @param pos
	 * @return List<March>
	 */
	public List<March> getMarch(int pos) {
		return marchMap.get(pos);
	}

	/**
	 * 
	 * 增加地图行军
	 * 
	 * @param march void
	 */
	public void addMarch(March march) {
		int pos = march.getArmy().getTarget();
		List<March> list = marchMap.get(pos);
		if (list == null) {
			list = new ArrayList<>();
			marchMap.put(pos, list);
		}
		list.add(march);
	}

	/**
	 * 删除指定玩家的指定部队行军
	 * 
	 * @param player
	 * @param army void
	 */
	public void removeMarch(Player player, Army army) {
		int pos = army.getTarget();
		List<March> list = marchMap.get(pos);
		March e;
		if (list != null) {
			for (int i = 0; i < list.size(); i++) {
				e = list.get(i);
				if (e.getPlayer() == player && e.getArmy().getKeyId() == army.getKeyId()) {
					list.remove(i);
					break;
				}
			}
		}
	}

	public Map<Integer, List<Guard>> getGuardMap() {
		return guardMap;
	}

	/**
	 * 
	 * 在坐标上设置叛军
	 * 
	 * @param pos
	 * @param form void
	 */
	public void setActRebelForm(int pos, Form form) {
		actRebelFormMap.put(pos, form);
		freePostList.remove(Integer.valueOf(pos));
	}

	/**
	 * 
	 * 获得坐标上的驻军部队
	 * 
	 * @param pos
	 * @return Form
	 */
	public Form getActRebelForm(int pos) {
		return actRebelFormMap.get(pos);
	}

	/**
	 * 
	 * 指定坐标是否是叛军
	 * 
	 * @param pos
	 * @return boolean
	 */
	public boolean isActRebel(int pos) {
		return actRebelFormMap.containsKey(pos);
	}

	public Map<Integer, Form> getActRebelFormMap() {
		return actRebelFormMap;
	}

	/**
	 * 
	 * 设置指定坐标为空余坐标
	 * 
	 * @param pos void
	 */
	public void returnActRebelPos(int pos) {
		if (!freePostList.contains(Integer.valueOf(pos))) {
			freePostList.add(pos);
		}
	}

	/**
	 * 
	 * 清理所有叛军 void
	 */
	public void clearActRebelForm() {
		for (Integer pos : actRebelFormMap.keySet()) {
			if (!freePostList.contains(pos)) {
				freePostList.add(pos);
			}
		}
		actRebelFormMap.clear();
	}

	/**
	 * 
	 * X,Y转成数字坐标
	 * 
	 * @param x
	 * @param y
	 * @return int
	 */
	public static int pos(int x, int y) {
		return x + 600 * y;
	}

	public List<Integer> getFreePostList() {
		return freePostList;
	}

	public Map<Integer, Mine> getMineInfo() {
		return globalDataManager.gameGlobal.getWorldMineInfo();
	}

	public int getGameStopTime() {
		return globalDataManager.gameGlobal.getGameStopTime();
	}

	/**
	 * 
	 * 指定等级的目标侦查需要的水晶
	 * 
	 * @param lord
	 * @param enemyLv 等级
	 * @param multiple 第几次侦查
	 * @return long
	 */
	public long getScoutNeedStone(Lord lord, int enemyLv, int multiple) {
		StaticScout staticScout = staticWorldDataMgr.getScout(enemyLv);
		int lvDiff = enemyLv - lord.getLevel();
		if (staticScout == null) {
			LogUtil.error("NO CONFIG | table s_scout miss config | targetLv : " + enemyLv);
			lvDiff = 0;
		}
		long scountCost = staticScout.getScoutCost() * multiple;

		if (lord.getScountDate() != TimeHelper.getCurrentDay()) {// 隔天后重置侦查次数
			lord.setScountDate(TimeHelper.getCurrentDay());
			lord.setScount(0);
		}

		int scount = lord.getScount() + 1;
		if (lvDiff < 0) {
			lvDiff = 0;
		}

		scountCost = (long) Math.ceil(scountCost * (1 + lvDiff * Constant.SCOUT_lV_DIFF_RATIO / 10000f) * ListHelper.getListNearVal(Constant.SCOUT_COUNT_RATIO, scount) / 10000f);
		return scountCost;
	}

	/**
	 * 
	 * 坐标上是否有内容
	 * 
	 * @param pos
	 * @return boolean
	 */
	public boolean posHasUsed(int pos) {
		if (posMap.containsKey(pos) || evaluatePos(pos) != null || !isValidPos(pos) || isRebel(pos) || isActRebel(pos) || isAirship(pos)
				|| isRebelBox(pos)) {
			return true;
		}
		return false;
	}

	public Map<Integer, Airship> getAirshipMap() {
		return airshipMap;
	}

	public boolean isAirship(int pos) {
		return airshipMap.containsKey(pos);
	}

	/**
	 * 
	 * 设置飞艇到地图
	 * 
	 * @param nearPos
	 * @param airship void
	 */
	public void setAirship(List<Integer> nearPos, Airship airship) {
		for (Integer pos : nearPos) {
			airshipMap.put(pos, airship);
			freePostList.remove(Integer.valueOf(pos));
		}
	}

	/**
	 * 
	 * 删除地图中驻军
	 * 
	 * @param pos void
	 */
	public void removePosPlayer(int pos) {
		posMap.remove(pos);
		areaMap.get(area(pos)).remove(pos);
		marchMap.remove(pos);
	}

	/**
	 * 修复玩家基地坐标和玩家重复问题
	 */
	public void updatePlayerPos() {
		try {
			LogUtil.error("开始修改玩家重复坐标问题....");

			// 坐标对应的玩家loadid
			Map<Integer, Long> posMap = new HashMap<>();// pos-->loadId

			// 重复坐标的玩家loadid
			List<Long> loadIds = new ArrayList<>();

			// 重复的坐标
			List<Integer> posList = new ArrayList<>();

			Map<Long, Player> players = playerDataManager.getPlayers();
			for (Map.Entry<Long, Player> entry : players.entrySet()) {
				Player player = entry.getValue();

				if (player.lord.getNick() == null || player.lord.getPos() == -1) {
					continue;
				}

				if (!posMap.containsKey(player.lord.getPos())) {
					posMap.put(player.lord.getPos(), player.lord.getLordId());
				} else {

					long rid = posMap.get(player.lord.getPos());

					if (!loadIds.contains(rid)) {
						loadIds.add(rid);
					}

					if (!loadIds.contains(player.lord.getLordId())) {
						loadIds.add(player.lord.getLordId());
					}

					if (!posList.contains(player.lord.getPos())) {
						posList.add(player.lord.getPos());
					}

				}
			}

			LogUtil.error("update player pos 0 重复坐标的玩家有 " + loadIds.size() + " 个 ");

			for (long roleId : loadIds) {
				Player player = playerDataManager.getPlayer(roleId);

				LogUtil.error("update player pos 1 玩家 " + player.lord.getNick() + " 原坐标 " + player.lord.getPos());

				int count = 0;

				while (count < 1000) {

					count++;

					int pos = RandomHelper.randomInSize(600 * 600);

					// 如果随机的坐标是已经重复过的就过掉
					if (posList.contains(pos)) {
						continue;
					}

					Player target = getPosData(pos);
					if (target != null) {
						continue;
					}

					StaticMine staticMine = evaluatePos(pos);
					if (staticMine != null) {
						continue;
					}

					if (!isValidPos(pos)) {
						continue;
					}

					if (rebelDataManager.isRebelStart()) {// 叛军活动结束前，叛军所在坐标（即使叛军已经死亡）不允许迁入
						Rebel rebel = rebelDataManager.getRebelByPos(pos);
						if (null != rebel) {
							continue;
						}
					}

					// 活动叛军
					ActRebelData actRebelData = activityDataManager.getActRebelByPos(pos);
					if (actRebelData != null) {
						continue;
					}

					if (isAirship(pos)) {
						continue;
					}

					int oldPos = player.lord.getPos();
					List<Guard> list = getGuard(oldPos);
					if (list != null) {
						for (int i = 0; i < list.size(); i++) {
							Guard guard = list.get(i);
							guard.getArmy().setTarget(pos);
							setGuard(guard);
						}
					}

					removeGuard(oldPos);
					removePos(oldPos);

					player.lord.setPos(pos);
					putPlayer(player);

					LogUtil.error("update player pos 2 玩家 " + player.lord.getNick() + " 坐标修改为 " + player.lord.getPos());
					break;

				}
			}
			LogUtil.error("结束修改玩家重复坐标问题....");
		} catch (Exception e) {
			LogUtil.error("", e);
		}
	}

}
