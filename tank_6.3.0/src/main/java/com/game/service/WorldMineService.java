package com.game.service;

import com.game.common.ServerSetting;
import com.game.constant.MineConst;
import com.game.constant.SeniorState;
import com.game.dataMgr.StaticWorldDataMgr;
import com.game.domain.Player;
import com.game.domain.p.Army;
import com.game.domain.p.Guard;
import com.game.domain.p.Mine;
import com.game.domain.s.StaticMineQuality;
import com.game.manager.HonourDataManager;
import com.game.manager.SeniorMineDataManager;
import com.game.manager.WorldDataManager;
import com.game.pb.CommonPb;
import com.game.pb.GamePb2.GetMapRs;
import com.game.server.GameServer;
import com.game.util.PbHelper;
import com.game.util.TimeHelper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashSet;
import java.util.Iterator;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;

/**
 * @author zhangdh
 * @ClassName: WorldMineService
 * @Description: 世界地图矿点
 * @date 2017-3-24 下午12:24:57
 */
@Service
public class WorldMineService {

	@Autowired
	private WorldDataManager worldDataManager;

	@Autowired
	private StaticWorldDataMgr staticWorldDataMgr;

	@Autowired
	private HonourDataManager honourDataManager;
	@Autowired
	private SeniorMineDataManager mineDataManager;

	private int logicTime;

	/**
	 * 世界地图上矿点资源的处理
	 */
	public void wroldMineLogic() {
		if (!isFunctionOpenInThisServer())
			return;
		// 矿点品级经验下降
		Map<Integer, Mine> mineInfo = worldDataManager.getMineInfo();
		if (!mineInfo.isEmpty()) {
			int now = TimeHelper.getCurrentSecond();
			int gameStopTime = worldDataManager.getGameStopTime();
			Set<Integer> remove = new HashSet<>();
			for (Map.Entry<Integer, Mine> entry : mineInfo.entrySet()) {
				Mine mine = entry.getValue();
				Guard guard = worldDataManager.getMineGuard(entry.getKey());
				// 矿点正在采矿中不掉等级
				if (guard != null || mine.getMineId() > 0)
					continue;

				StaticMineQuality staticMineQua = staticWorldDataMgr.getStaticWorldMineQuality(mine.getMineLv(), mine.getQua());
				if (staticMineQua == null) {
					remove.add(entry.getKey());
					continue;// 矿点品质数据不存在
				}

				// 停服期间矿点经验不减少
				if (logicTime == 0 && gameStopTime > 0) {
					int subStopTime = now - gameStopTime;// 停服时间
					mine.setModTime(mine.getModTime() + subStopTime);
					continue;
				}

				if (mine.getModTime() == 0) {
					mine.setModTime(now);
				}

				// 经验保护时间
				int subTime = now - mine.getModTime() - staticMineQua.getPtTime();
				if (subTime <= 0)
					continue;

				int subExp = subTime * Math.max(1, staticMineQua.getUpTime() / staticMineQua.getDownTime());// 降级速度可能比升级速度快

				if (!honourDataManager.isOpen() && mineDataManager.getSeniorState() != SeniorState.START_STATE) {

//					LogUtil.error("扣除经验了"+honourDataManager.isOpen()+" "+mineDataManager.getSeniorState());
					subQualityExp(mine, subExp);// 扣除经验(有可能导致降级)
				}

				// 清除已经过期的侦查
				Iterator<Entry<Long, Integer>> scoutIter = mine.getScoutMap().entrySet().iterator();
				while (scoutIter.hasNext()) {
					Entry<Long, Integer> scoutEntry = scoutIter.next();
					if (now >= scoutEntry.getValue() + staticMineQua.getScoutTime()) {
						scoutIter.remove();
					}
				}

				if (mine.getQua() == MineConst.WHITE && mine.getQuaExp() == 0 && mine.getScoutMap().isEmpty()) {
					remove.add(entry.getKey());
				} else {
					staticMineQua = staticWorldDataMgr.getStaticWorldMineQuality(mine.getMineLv(), mine.getQua());
					mine.setModTime(mine.getModTime() + subTime);
				}
			}
			for (Integer pos : remove) {
				mineInfo.remove(pos);
			}
			logicTime = now;
		}
	}

	/**
	 * 扣除矿点品质经验
	 *
	 * @param mine 矿点信息
	 * @param subTime 扣除时间
	 */
	private void subQualityExp(Mine mine, int subExp) {
		int remainExp = mine.getQuaExp() - subExp;
		while (true) {
			if (remainExp >= 0) {
				StaticMineQuality data = staticWorldDataMgr.getStaticWorldMineQuality(mine.getMineLv(), mine.getQua());
				int maxQuaExp = data != null ? data.getUpTime() : remainExp;
				mine.setQuaExp(Math.min(maxQuaExp, remainExp));
				break;
			} else {
				if (staticWorldDataMgr.isMinQulity(mine.getMineLv(), mine.getQua())) {
					mine.setQuaExp(0);
					break;
				} else {
					// 降级处理
					StaticMineQuality sdata = staticWorldDataMgr.getStaticWorldMineQuality(mine.getMineLv(), mine.getQua() - 1);
					mine.setQua(mine.getQua() - 1);
					mine.setQuaExp(remainExp = sdata.getUpTime() + remainExp);
				}
			}
		}
		// LogUtil.common(String.format("mine id :%d, sub exp :%d, before qua :%d exp :%d ----> after qua :%d exp :%d ",
		// mine.getPos(), subExp, qua0, exp0, mine.getQua(), mine.getQuaExp()));
	}

	/**
	 * 
	 * 开始采集
	 * 
	 * @param player
	 * @param army
	 * @param lv void
	 */
	public void startCollectMine(Player player, Army army, int lv) {
		if (!isFunctionOpenInThisServer())
			return;
		Mine mine = getAndCreateIfAbsent(army.getTarget(), lv);
		mine.setMineId(player.account.getAccountKey());
		army.setTarQua(mine.getQua());
	}

	/**
	 * 增加矿点品质经验 矿点品质一次最多只能提升一级
	 *
	 * @param pos
	 * @param ctime 1秒=1点品质经验
	 */
	public void addMineQualityExp(Player player, int pos, int lv, int ctime) {
		if (!isFunctionOpenInThisServer())
			return;
		Mine mine = getAndCreateIfAbsent(pos, lv);
		int remain = mine.getQuaExp() + ctime;
		StaticMineQuality data = staticWorldDataMgr.getStaticWorldMineQuality(mine.getMineLv(), mine.getQua());
		if (remain < data.getUpTime()) {
			mine.setQuaExp(remain);
		} else {
			if (!staticWorldDataMgr.isMaxQuality(mine.getMineLv(), mine.getQua())) {
				mine.setQua(mine.getQua() + 1);
				mine.setQuaExp(0);
			} else {
				mine.setQuaExp(Math.min(remain, data.getUpTime()));
			}
		}
		mine.setMineId(0);// 设置为没有被占领的矿点
		mine.setModTime(TimeHelper.getCurrentSecond());
		scoutMine(player, pos, lv);// 收矿时默认增加一次侦查时间
		// LogUtil.common(String.format("---------------> mine pos :%d, qua :%d, exp :%d world mine size :%d",
		// pos, mine.getQua(), mine.getQuaExp(), worldDataManager.getMineInfo().size()));
	}

	/**
	 * 
	 * 在某个坐标如果不存在矿 就加一个
	 * 
	 * @param pos
	 * @param lv
	 * @return Mine
	 */
	private Mine getAndCreateIfAbsent(int pos, int lv) {
		Mine mine = worldDataManager.getMineInfo().get(pos);
		if (mine == null) {
			mine = new Mine(pos, MineConst.WHITE);
			mine.setMineLv(lv);
			worldDataManager.getMineInfo().put(pos, mine);
		}
		return mine;
	}

	/**
	 * builder 区域内矿点信息
	 *
	 * @param builder
	 * @param area
	 */
	public void buildMineInfo(GetMapRs.Builder builder, Player player, int area) {
		if (!isFunctionOpenInThisServer())
			return;
		Map<Integer, Mine> mineInfo = worldDataManager.getMineInfo();
		if (!mineInfo.isEmpty()) {
			int curTime = TimeHelper.getCurrentSecond();
			CommonPb.WorldMineInfo.Builder wmb = CommonPb.WorldMineInfo.newBuilder();
			for (Entry<Integer, Mine> entry : mineInfo.entrySet()) {
				Mine mine = entry.getValue();
				if (canSee(mine, player, area, curTime)) {
					Integer scoutTime = mine.getScoutMap().get(player.lord.getLordId());

					Guard guard = worldDataManager.getMineGuard(mine.getPos());
					wmb.addMine(PbHelper.createMinePb2(mine, scoutTime == null ? 0 : scoutTime, guard));
				}
			}
			builder.setMineInfo(wmb);
		}
	}

	/**
	 * 玩家是否能看见指定矿点品质信息
	 *
	 * @param mine
	 * @param player
	 * @param area
	 * @param curTime
	 * @return true-能看见
	 */
	private boolean canSee(Mine mine, Player player, int area, int curTime) {
		if (mine.getQua() < MineConst.WHITE)
			return false;
		if (worldDataManager.area(mine.getPos()) != area)
			return false;// 不在指定区域
		StaticMineQuality staticMineQua = staticWorldDataMgr.getStaticWorldMineQuality(mine.getMineLv(), mine.getQua());
		if (staticMineQua == null)
			return false;
		// 被自己占领的矿一直显示品质
		Guard guard = worldDataManager.getMineGuard(mine.getPos());
		if (guard != null && guard.getPlayer().lord.getLordId() == player.lord.getLordId()) {
			return true;
		}
		Integer scoutTime = mine.getScoutMap().get(player.lord.getLordId());
		// 最近一个小时内侦查过该矿点
		return scoutTime != null && scoutTime + staticMineQua.getScoutTime() >= curTime;
	}

	/**
	 * 获得世界地图上矿点的产量
	 *
	 * @param pos
	 * @param baseProdunction
	 * @return
	 */
	public int getMineProdunction(int pos, int baseProdunction) {
		if (!isFunctionOpenInThisServer())
			return baseProdunction;
		Mine mine = worldDataManager.getMineInfo().get(pos);
		if (mine != null) {// 矿点品质对产量基数加成
			StaticMineQuality staticQuaMine = staticWorldDataMgr.getStaticWorldMineQuality(mine.getMineLv(), mine.getQua());
			if (staticQuaMine != null) {
				return (int) (baseProdunction * (staticQuaMine.getYield() / 1000.0));
			}
		}
		return baseProdunction;
	}

	/**
	 * 侦查一个矿点, 如果此矿点有品质信息则记录侦查时间
	 *
	 * @param player
	 * @param pos
	 */
	public void scoutMine(Player player, int pos, int lv) {
		Mine mine = getAndCreateIfAbsent(pos, lv);
		int nowSec = TimeHelper.getCurrentSecond();
		mine.getScoutMap().put(player.lord.getLordId(), nowSec);
		if (mine.getModTime() == 0) {
			mine.setModTime(nowSec);
		}
	}

	/**
	 * 判断本服是否开启矿点升级功能
	 *
	 * @return
	 */
	public boolean isFunctionOpenInThisServer() {
		return MineConst.openServerList.isEmpty()
				|| MineConst.openServerList.contains(GameServer.ac.getBean(ServerSetting.class).getServerID());
	}

	/**
	 * 
	 * 某个点的矿点品质
	 * 
	 * @param pos
	 * @return int
	 */
	public int getMineQuality(int pos) {
		Mine mine = worldDataManager.getMineInfo().get(pos);
		return mine != null ? mine.getQua() : MineConst.WHITE;
	}

	/**
	 * 
	 * 获得矿点品质 （玩家必须侦查过此点并且没过期 才能获得这个点的品质）
	 * 
	 * @param player
	 * @param pos
	 * @return int
	 */
	public int getMineQualityWithScout(Player player, int pos) {
		Mine mine = worldDataManager.getMineInfo().get(pos);
		if (mine == null) {// 如果目标不是矿 就返回白色
			return MineConst.WHITE;
		} else {
			Integer scoutTime = mine.getScoutMap().get(player.lord.getLordId());
			if (scoutTime == null)
				return MineConst.WHITE;// 如果没有侦查过 返回白色
			StaticMineQuality staticMineQua = staticWorldDataMgr.getStaticWorldMineQuality(mine.getMineLv(), mine.getQua());
			if (staticMineQua == null)
				return MineConst.WHITE;// 如果没有此矿点品质配置 返回白色
			return scoutTime + staticMineQua.getScoutTime() >= TimeHelper.getCurrentSecond() ? mine.getQua() : MineConst.WHITE;// 过侦查信息已过期
																																// 返回白色
		}
	}
}
