/**
 * @Title: BossDataManager.java
 * @Package com.game.manager
 * @Description:
 * @author ZhangJun
 * @date 2015年12月29日 下午3:24:49
 * @version V1.0
 */
package com.game.manager;

import com.game.bossFight.domain.Boss;
import com.game.constant.BossState;
import com.game.dao.impl.p.BossDao;
import com.game.dataMgr.StaticActionAltarBossDataMgr;
import com.game.dataMgr.StaticActivateNewMgr;
import com.game.dataMgr.StaticEnergyStoneDataMgr;
import com.game.domain.Member;
import com.game.domain.PartyData;
import com.game.domain.p.BossFight;
import com.game.domain.s.StaticAltarBoss;
import com.game.domain.s.StaticAltarBossStar;
import com.game.domain.s.StaticSeverBoss;
import com.game.util.CheckNull;
import com.game.util.DateHelper;
import com.game.util.LogUtil;
import com.game.util.TimeHelper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.*;

/**
* @ClassName: ComparatorHurtRank
* @Description: boss伤害排序器
* @author
 */
class ComparatorHurtRank implements Comparator<BossFight> {
	@Override
	public int compare(BossFight o1, BossFight o2) {
		//Auto-generated method stub
		long d1 = o1.getHurt();
		long d2 = o2.getHurt();

		if (d1 < d2)
			return 1;
		else if (d1 > d2) {
			return -1;
		} else {
			return 0;
		}
	}
}
/**
 * @ClassName: BossDataManager
 * @Description: 玩家打boss相关
 * @author ZhangJun
 * @date 2015年12月29日 下午3:24:49
 */
@Component
public class BossDataManager {

	@Autowired
	private BossDao bossDao;

	@Autowired
	private GlobalDataManager globalDataManager;

	@Autowired
	private PartyDataManager partyDataManager;

	@Autowired
	private SmallIdManager smallIdManager;

	@Autowired
	private StaticActivateNewMgr staticActivateNewMgr;

	@Autowired
	private StaticEnergyStoneDataMgr staticEnergyStoneDataMgr;

	public static final int BOSS_TYPE_WORLD = 1;// BOSS类型:1 世界BOSS

	public static final int BOOS_TYPE_ALTAR = 2;// BOSS类型:2 祭坛BOSS

	// 世界BOSS玩家伤害排行
	private LinkedList<BossFight> hurtRankList = new LinkedList<>();

	/** 世界BOSS进入伤害排行玩家id */
	private Set<Long> hurtRankSet = new HashSet<Long>();

	/** 世界BOSS玩家数据, key:lordId */
	private Map<Long, BossFight> playerMap = new HashMap<Long, BossFight>();

	/** 祭坛BOSS玩家伤害排行榜， key:军团id */
	private Map<Integer, LinkedList<BossFight>> altarHurtRankList = new HashMap<Integer, LinkedList<BossFight>>();

	/** 祭坛BOSS参与攻击的玩家lordId, key:partyId */
	private Map<Integer, Set<Long>> altarparticipateRoleMap = new HashMap<Integer, Set<Long>>();

	/** 祭坛BOSS玩家数据, key:lordId */
	private Map<Long, BossFight> altarPlayerMap = new HashMap<Long, BossFight>();

	/** 世界BOSS */
	private Boss boss;

	/** 祭坛BOSS, key:partyId */
	private Map<Integer, Boss> altarBossMap = new HashMap<Integer, Boss>();

	/** 记录已被召唤出来的，没有死完或逃跑的祭坛BOSS */
	private Set<Boss> startAltarBossSet = new HashSet<Boss>();

	@Autowired
	private StaticActionAltarBossDataMgr staticActionAltarBossDataMgr;

//	@PostConstruct
	public void init() {
		fillPlayer();
		initData();
		initBoss();
	}
	/**
	* @Title: fillPlayer
	* @Description:   初始化世界boss和祭坛boss的的玩家
	* void

	 */
	private void fillPlayer() {
		List<BossFight> list = bossDao.loadData();
		BossFight bossFight;
		for (int i = 0; i < list.size(); i++) {
			bossFight = list.get(i);
			if (!smallIdManager.isSmallId(bossFight.getLordId())) {
				if (bossFight.getBossType() == BOSS_TYPE_WORLD) {// 世界BOSS
					playerMap.put(bossFight.getLordId(), bossFight);
				} else if (bossFight.getBossType() == BOOS_TYPE_ALTAR) {// 祭坛BOSS
					altarPlayerMap.put(bossFight.getLordId(), bossFight);
				}
			}
		}
	}

	/**
	* @Title: initData
	* @Description:
	* void

	 */
	private void initData() {
		// 初始化世界BOSS玩家伤害排行数据
		List<Long> list = globalDataManager.gameGlobal.getHurtRank();
		for (Long roleId : list) {
			BossFight bossFight = playerMap.get(roleId);
			if (bossFight != null) {
				hurtRankList.add(bossFight);
				hurtRankSet.add(roleId);
			}
		}

		// 初始化祭坛BOSS玩家伤害排行数据
		for (PartyData party : partyDataManager.getPartyMap().values()) {// 遍历所有的军团
			if (!CheckNull.isEmpty(party.getBossHurtRankList())) {
				LinkedList<BossFight> rankList = altarHurtRankList.get(party.getPartyId());
				if (null == rankList) {
					rankList = new LinkedList<BossFight>();
					altarHurtRankList.put(party.getPartyId(), rankList);
				}
				for (Long roleId : party.getBossHurtRankList()) {
					BossFight bossFight = altarPlayerMap.get(roleId);
					if (null != bossFight) {
						rankList.add(bossFight);
					}
				}
			}
		}
	}

	/**
	 * 初始化BOSS
	 */
	private void initBoss() {
		// 初始化世界BOSS
		boss = new Boss();
		boss.setBossType(BOSS_TYPE_WORLD);
		boss.setBossCreateTime(globalDataManager.gameGlobal.getBossTime());
		boss.setBossLv(globalDataManager.gameGlobal.getBossLv());
		boss.setBossHp(globalDataManager.gameGlobal.getBossHp());
		boss.setBossWhich(globalDataManager.gameGlobal.getBossWhich());
		boss.setBossState(globalDataManager.gameGlobal.getBossState());

		// 初始化已开启的祭坛BOSS
		for (PartyData party : partyDataManager.getPartyMap().values()) {// 遍历所有的军团
			if (party.getBossState() == BossState.PREPAIR_STATE || party.getBossState() == BossState.FIGHT_STATE) {
				// 如果上次关闭服务器时，祭坛BOSS战还没有结束，本次召唤不算，可重新召唤
				party.setBossState(BossState.INIT_STATE);
				party.setNextCallBossSec(0);
				party.setBossHp(0);
				party.setBossWhich(0);
				party.getBossAwardList().clear();
				party.getBossHurtRankList().clear();

				// 返还上次召唤消耗的资源
				StaticAltarBoss sab = staticEnergyStoneDataMgr.getAltarBossDataByLv(party.getAltarLv());
				if (null == sab) {
					continue;
				}
				party.setBuild(party.getBuild() + sab.getCallBossCost());
			}
		}
	}

	/******************* 祭坛BOSS逻辑开始 *******************/

	/**
	 * 根据军团id获取与其相关的祭坛BOSS对象
	 *
	 * @param partyId
	 * @return
	 */
	public Boss getAltarBoss(int partyId) {
		return altarBossMap.get(partyId);
	}

	/**
	 * 创建军团的祭坛BOSS实例
	 *
	 * @param partyId
	 * @return
	 */
	public Boss createAltarBoss(int partyId) {
		Boss boss = new Boss();
		boss.setPartyId(partyId);
		boss.setBossType(BOOS_TYPE_ALTAR);
		altarBossMap.put(partyId, boss);
		return boss;
	}

	/**
	 * 召唤祭坛BOSS
	 *
	 * @param partyId 军团id
	 * @return
	 */
	public Boss callAltarBoss(int partyId) {
		List<Member> mList = partyDataManager.getMemberList(partyId);
		if (CheckNull.isEmpty(mList)) {
			return null;
		}

		// 设置玩家战斗相关数据
		int now = TimeHelper.getCurrentSecond();
		for (Member m : mList) {
			BossFight bossFight = altarPlayerMap.get(m.getLordId());
			if (null != bossFight) {
				bossFight.setHurt(0);
				bossFight.setBless1(0);
				bossFight.setBless2(0);
				bossFight.setBless3(0);
				bossFight.setAttackTime(now);
			}
		}

		Boss boss = getAltarBoss(partyId);
		if (null == boss) {
			boss = createAltarBoss(partyId);
		}

		// 设置BOSS等级，死亡+1级，逃跑-1级
		PartyData party = partyDataManager.getParty(partyId);
		boss.setBossLv(party.getBossLv());
		if (party.getBossState() == BossState.BOSS_DIE) {
			if (party.getBossLv() < 6) {
				boss.setBossLv(party.getBossLv() + 1);
			}
		} else if (party.getBossState() == BossState.BOSS_END) {
			if (party.getBossLv() > 1) {
				boss.setBossLv(party.getBossLv() - 1);
			}
		} else if (party.getBossState() == BossState.INIT_STATE) {
			if(party.getBossLv() < 1) {
				boss.setBossLv(1);
			} else {
				boss.setBossLv(party.getBossLv());
			}
		}


		PartyData partydata = partyDataManager.getParty(partyId);
		StaticAltarBossStar staticAltarBossStar = staticActionAltarBossDataMgr.getAltarStarMaps(partydata.getAltarBossExp());
		if (staticAltarBossStar == null) {
			boss.setBossHp(10000);
		} else {
			boss.setBossHp(staticAltarBossStar.getAmount());
		}

		// 重置BOSS数据
		boss.setHurt(0);
		boss.setBossWhich(0);

		boss.setBossCreateTime(now);
		boss.setBossState(BossState.PREPAIR_STATE);

		// 清空上次伤害排行记录
		List<BossFight> list = altarHurtRankList.get(party.getPartyId());
		if (!CheckNull.isEmpty(list)) {
			list.clear();
		}
		// 清空上次参与人员信息
		Set<Long> set = altarparticipateRoleMap.get(partyId);
		if (!CheckNull.isEmpty(set)) {
			set.clear();
		}

		startAltarBossSet.add(boss);// 添加已召唤的BOSS记录

//		LogHelper.BOSS_LOGGER.error("call altar boss, partyId:" + partyId + ", boss:" + boss);
		LogUtil.boss("call altar boss, partyId:" + partyId + ", boss:" + boss);

		return boss;
	}

	/**
	 * 增加祭坛BOSS的伤害记录
	 *
	 * @param partyId
	 * @param bossFight
	 * @param hurt
	 */
	public void addAltarBossHurt(int partyId, BossFight bossFight, long hurt) {
		bossFight.setHurt(bossFight.getHurt() + hurt);
		updateAltarBossHurtRank(partyId, bossFight);
		Boss boss = getAltarBoss(partyId);
		boss.setHurt(boss.getHurt() + hurt);
	}

	/**
	 * 更新祭坛BOSS的伤害排行
	 *
	 * @param partyId
	 * @param bossFight
	 */
	public void updateAltarBossHurtRank(int partyId, BossFight bossFight) {
		Set<Long> set = altarparticipateRoleMap.get(partyId);
		if (null == set) {
			set = new HashSet<Long>();
			altarparticipateRoleMap.put(partyId, set);
		}
		set.add(bossFight.getLordId());// 记录玩家参与战斗

		LinkedList<BossFight> list = altarHurtRankList.get(partyId);
		if (null == list) {
			list = new LinkedList<BossFight>();
			altarHurtRankList.put(partyId, list);
		}

		if (list.isEmpty()) {
			list.add(bossFight);
			return;
		}

		if (list.contains(bossFight)) {
			Collections.sort(list, new ComparatorHurtRank());
			return;
		}

		int index = 0;
		for (BossFight b : list) {
			if (b.getHurt() < bossFight.getHurt()) {
				break;
			}
			index++;
		}

		if (index < 10) {// 排行榜只记录前十名
			list.add(index, bossFight);

			if (list.size() > 10) {
				list.removeLast();
			}
		}
	}


	public Set<Boss> getStartAltarBossSet() {
		return startAltarBossSet;
	}

	/**
	* @Title: resetAltarBossAutoFight
	* @Description: 清除玩家的 VIP自动战斗设置（祭坛boss)
	* @param partyId
	* void

	 */
	public void resetAltarBossAutoFight(int partyId) {
		List<Member> mList = partyDataManager.getMemberList(partyId);
		if (CheckNull.isEmpty(mList)) {
			return;
		}
		for (Member member : mList) {
			BossFight bossFight = altarPlayerMap.get(member.getLordId());
			if (null != bossFight) {
				bossFight.setAutoFight(0);
			}
		}
	}

	/**
	 * 获取军团中所有参加祭坛BOSS战斗的玩家lordId
	 *
	 * @param partyId
	 * @return
	 */
	public Set<Long> getAltarparticipateRoles(int partyId) {
		return altarparticipateRoleMap.get(partyId);
	}

	/**
	 * 获取玩家在祭坛BOSS战斗中的伤害排行
	 *
	 * @param partyId
	 * @param lordId
	 * @return
	 */
	public int getAltarHurtRank(int partyId, long lordId) {
		List<BossFight> list = altarHurtRankList.get(partyId);
		if (!CheckNull.isEmpty(list)) {
			int rank = 0;
			for (BossFight bossFight : list) {
				rank++;
				if (bossFight.getLordId() == lordId) {
					return rank;
				}
			}
		}
		return 0;
	}

	/**
	 * 获取祭坛BOSS伤害排行
	 *
	 * @param partyId
	 * @return
	 */
	public List<BossFight> getAltarBossHurtRank(int partyId) {
		return altarHurtRankList.get(partyId);
	}

	/**
	 * 玩家是否已领取祭坛BOSS排行奖励
	 *
	 * @param partyId
	 * @param lordId
	 * @return
	 */
	public boolean hadGetAltarAward(int partyId, long lordId) {
		PartyData party = partyDataManager.getParty(partyId);
		if (null != party) {
			return party.getBossAwardList().contains(lordId);
		}
		return true;
	}

	/**
	 * 设置玩家已领取祭坛BOSS排行奖励
	 *
	 * @param partyId
	 * @param lordId
	 */
	public void setAltarAward(int partyId, long lordId) {
		PartyData party = partyDataManager.getParty(partyId);
		if (null != party) {
			party.getBossAwardList().add(lordId);
		}
	}

	/**
	 * 获取玩家关于祭坛BOSS的战斗数据
	 *
	 * @param lordId
	 * @return
	 */
	public BossFight getAltarBossFight(long lordId) {
		BossFight bossFight = altarPlayerMap.get(lordId);
		if (null == bossFight) {
			return createAltarBossFight(lordId);
		}
		return bossFight;
	}

	/**
	 * 创建玩家关于祭坛BOSS的战斗数据
	 *
	 * @param lordId
	 * @return
	 */
	private BossFight createAltarBossFight(long lordId) {
		BossFight bossFight = new BossFight();
		bossFight.setBossType(BOOS_TYPE_ALTAR);
		bossFight.setLordId(lordId);
		altarPlayerMap.put(lordId, bossFight);
		return bossFight;
	}

	/******************* 祭坛BOSS逻辑结束 *******************/

	/******************* 以下为世界BOSS相关逻辑 *******************/

	public Map<Long, BossFight> getPlayerMap() {
		return playerMap;
	}

	public void setPlayerMap(Map<Long, BossFight> playerMap) {
		this.playerMap = playerMap;
	}

	/**
	 * 世界BOSS刷新
	 */
	public void refreshBoss() {
		Iterator<BossFight> it = playerMap.values().iterator();
		while (it.hasNext()) {
			BossFight bossFight = (BossFight) it.next();
			bossFight.setBless1(0);
			bossFight.setBless2(0);
			bossFight.setBless3(0);
			bossFight.setHurt(0);
		}

		setBossTime(TimeHelper.getCurrentDay());
		if (boss.getBossState() == BossState.BOSS_DIE) {
			if (boss.getBossLv() < 55) {
				setBossLv(boss.getBossLv() + 1);
			}
		} else if (boss.getBossState() == BossState.INIT_STATE) {
			setBossLv(45);
			StaticSeverBoss config = staticActivateNewMgr.getSeverBoss(DateHelper.getServerOpenDay());
			if( config != null ){
				setBossLv(config.getBossLv());
			}
		}


		boss.setHurt(0);
		setBossHp(10000);
		setBossWhich(0);
		setBossState(BossState.PREPAIR_STATE);
		setKiller("");
		globalDataManager.gameGlobal.getHurtRank().clear();
		globalDataManager.gameGlobal.getGetHurtRank().clear();
		hurtRankList.clear();
		hurtRankSet.clear();

//		LogHelper.BOSS_LOGGER.error("refresh boss:" + boss.getBossLv());
		LogUtil.boss("refresh world boss:" + boss.getBossLv());
	}

	/**
	* @Title: setBossState
	* @Description: 设置boss状态
	* @param state
	* void

	 */
	public void setBossState(int state) {
		boss.setBossState(state);
		globalDataManager.gameGlobal.setBossState(state);
//		LogHelper.BOSS_LOGGER.error("boss state:" + state);
		LogUtil.boss("set boss state:" + boss);
	}

	/**
	* @Title: setBossHp
	* @Description: 设置boss生命
	* @param hp
	* void

	 */
	public void setBossHp(int hp) {
		boss.setBossHp(hp);
		globalDataManager.gameGlobal.setBossHp(hp);
	}

	/**
	* @Title: setBossWhich
	* @Description: 设置boss是第几管血
	* @param which
	* void

	 */
	public void setBossWhich(int which) {
		boss.setBossWhich(which);
		globalDataManager.gameGlobal.setBossWhich(which);
	}

	/**
	* @Title: setBossTime
	* @Description: 设置boss创建时间
	* @param time
	* void

	 */
	public void setBossTime(int time) {
		boss.setBossCreateTime(time);
		globalDataManager.gameGlobal.setBossTime(time);
	}

	/**boss等级*/
	public void setBossLv(int lv) {
		boss.setBossLv(lv);
		globalDataManager.gameGlobal.setBossLv(lv);
	}
	/**boss击杀者*/
	public void setKiller(String name) {
		globalDataManager.gameGlobal.setBossKiller(name);
	}

	public BossFight getBossFight(long lordId) {
		return playerMap.get(lordId);
	}

	/**
	 * 获取玩家世界BOSS的伤害排行
	 *
	 * @param lordId
	 * @return
	 */
	public int getHurtRank(long lordId) {
		int rank = 0;
		for (BossFight bossFight : hurtRankList) {
			rank++;
			if (bossFight.getLordId() == lordId) {
				return rank;
			}
		}

		return 0;
	}

	/**
	 * 创建玩家关于世界BOSS的战斗数据
	 *
	 * @param lordId
	 * @return
	 */
	public BossFight createBossFight(long lordId) {
		BossFight bossFight = new BossFight();
		bossFight.setBossType(BOSS_TYPE_WORLD);
		bossFight.setLordId(lordId);
		playerMap.put(lordId, bossFight);
		return bossFight;
	}

	public Boss getBoss() {
		return boss;
	}

	public void setBoss(Boss boss) {
		this.boss = boss;
	}

	public String getKiller() {
		return globalDataManager.gameGlobal.getBossKiller();
	}

	public LinkedList<BossFight> getHurtRankList() {
		return hurtRankList;
	}

	public void setHurtRankList(LinkedList<BossFight> hurtRankList) {
		this.hurtRankList = hurtRankList;
	}

	/**
	 * 增加世界BOSS的伤害记录
	 *
	 * @param b
	 * @param hurt
	 */
	public void addHurt(BossFight b, long hurt) {
		b.setHurt(b.getHurt() + hurt);
		setHurtRank(b);
		boss.setHurt(boss.getHurt() + hurt);
	}

	/**
	* @Title: setHurtRank
	* @Description: 更新伤害排名
	* @param b
	* void

	 */
	private void setHurtRank(BossFight b) {

		if (hurtRankSet.contains(b.getLordId())) {
			Collections.sort(hurtRankList, new ComparatorHurtRank());
		} else {
			if (hurtRankList.isEmpty()) {
				hurtRankList.add(b);
			} else {
				boolean added = false;
				ListIterator<BossFight> rankIt = hurtRankList.listIterator(hurtRankList.size());
				while (rankIt.hasPrevious()) {
					BossFight e = rankIt.previous();
					if (b.getHurt() <= e.getHurt()) {
						rankIt.next();
						rankIt.add(b);
						added = true;
						break;
					}
				}

				if (!added) {
					hurtRankList.addFirst(b);
				}
			}

			hurtRankSet.add(b.getLordId());
			if (hurtRankList.size() > 10) {
				hurtRankSet.remove(hurtRankList.removeLast().getLordId());
			}
		}
	}

	/**
	 * 获取玩家是否已领取过世界BOSS的伤害排行奖励
	 *
	 * @param roleId
	 * @return
	 */
	public boolean hadGetHurtRankAward(long roleId) {
		return globalDataManager.gameGlobal.getGetHurtRank().contains(roleId);
	}

	/**
	 * 记录玩家已领取世界BOSS排行奖励
	 *
	 * @param roleId
	 */
	public void setHurtRankAward(long roleId) {
		globalDataManager.gameGlobal.getGetHurtRank().add(roleId);
	}
}
