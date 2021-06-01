/**
 * @Title: RankDataManager.java
 * @Package com.game.manager
 * @Description:
 * @author ZhangJun
 * @date 2015年9月28日 下午3:21:01
 * @version V1.0
 */
package com.game.manager;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.ListIterator;
import java.util.Map;
import java.util.Set;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.game.domain.PartyData;
import com.game.domain.Player;
import com.game.domain.l.MilitaryRankSort;
import com.game.domain.p.Equip;
import com.game.domain.p.Lord;
import com.game.domain.p.PartyLvRank;
import com.game.domain.p.PartyRank;
import com.game.domain.sort.FormSort;
import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb2.GetRankRs;
import com.game.pb.InnerPb.BackRankBaseRq;
import com.game.util.PbHelper;
import com.game.util.TimeHelper;
import com.game.util.UnsafeSortInfo;

/**
 * @author ZhangJun
 * @ClassName: RankDataManager
 * @Description:强化（攻击 暴击 闪避）排行domain
 * @date 2015年9月28日 下午3:21:01
 */

class EquipRank {
	private Lord lord;
	private Equip equip;

	public Lord getLord() {
		return lord;
	}

	public void setLord(Lord lord) {
		this.lord = lord;
	}

	public Equip getEquip() {
		return equip;
	}

	public void setEquip(Equip equip) {
		this.equip = equip;
	}

	/**
	 * @param lord
	 * @param equip
	 */
	public EquipRank(Lord lord, Equip equip) {
		super();
		this.lord = lord;
		this.equip = equip;
	}

}

/**
 * 排行榜列表domain
 */
class RankList {
	private LinkedList<Lord> list = new LinkedList<>();
	private int size = 0;

	public LinkedList<Lord> getList() {
		return list;
	}

	public void setList(LinkedList<Lord> list) {
		this.list = list;
	}

	public int getSize() {
		return size;
	}

	public void setSize(int size) {
		this.size = size;
	}

	public void add(Lord lord) {
		list.add(lord);
		++size;
	}

	public long removeLast() {
		Lord lord = list.removeLast();
		--size;
		return lord.getLordId();
	}
}

/**
 * 
 * @ClassName: EquipRankList
 * @Description: 攻击暴击闪避排行列表
 * @author
 */
class EquipRankList {
	private LinkedList<EquipRank> list = new LinkedList<>();
	private int size = 0;

	public LinkedList<EquipRank> getList() {
		return list;
	}

	public void setList(LinkedList<EquipRank> list) {
		this.list = list;
	}

	public int getSize() {
		return size;
	}

	public void setSize(int size) {
		this.size = size;
	}

	public void add(Lord lord, Equip equip) {
		EquipRank equipRank = new EquipRank(lord, equip);
		list.add(equipRank);
		++size;
	}

	public void removeLast() {
		list.removeLast();
		--size;
	}
}

/**
 * 战力排序器
 */
class ComparatorFight implements Comparator<Lord> {

	/**
	 * Overriding: compare
	 *
	 * @param o1
	 * @param o2
	 * @return
	 * @see java.util.Comparator#compare(java.lang.Object, java.lang.Object)
	 */
	@Override
	public int compare(Lord o1, Lord o2) {
		// Auto-generated method stub
		long d1 = o1.getFight();
		long d2 = o2.getFight();

		if (d1 < d2)
			return 1;
		else if (d1 > d2) {
			return -1;
		}

		return 0;
	}
}

/**
 * 总战力排序器
 */
class ComparatorMaxFight implements Comparator<Lord> {

	/**
	 * Overriding: compare
	 *
	 * @param o1
	 * @param o2
	 * @return
	 * @see java.util.Comparator#compare(java.lang.Object, java.lang.Object)
	 */
	@Override
	public int compare(Lord o1, Lord o2) {
		// Auto-generated method stub
		long d1 = o1.getMaxFight();
		long d2 = o2.getMaxFight();
		long d3 = o1.getMilitaryRank();
		long d4 = o2.getMilitaryRank();
		if (d3 < d4) {
			return 1;
		} else if (d3 > d4) {
			return -1;
		} else {
			if (d1 < d2) {
				return 1;
			} else if (d1 > d2) {
				return -1;
			} else {
				if (o1.getMilitaryRankUpTime() < o2.getMilitaryRankUpTime()) {
					return 1;
				} else if (o1.getMilitaryRankUpTime() > o2.getMilitaryRankUpTime()) {
					return -1;
				}
			}
		}

		return 0;
	}
}

/**
 * 震慑排序器
 */
class ComparatorFrighten implements Comparator<Lord> {

	@Override
	public int compare(Lord o1, Lord o2) {
		int d1 = o1.getFrighten();
		int d2 = o2.getFrighten();

		if (d1 < d2)
			return 1;
		else if (d1 > d2) {
			return -1;
		}

		return 0;
	}
}

/**
 * 刚毅排序器
 */
class ComparatorFortitude implements Comparator<Lord> {

	@Override
	public int compare(Lord o1, Lord o2) {
		int d1 = o1.getFortitude();
		int d2 = o2.getFortitude();

		if (d1 < d2)
			return 1;
		else if (d1 > d2) {
			return -1;
		}

		return 0;
	}
}

/**
 * 勋章价值排序器
 */
class ComparatorMedalPrice implements Comparator<Lord> {

	@Override
	public int compare(Lord o1, Lord o2) {
		int d1 = o1.getMedalPrice();
		int d2 = o2.getMedalPrice();

		if (d1 < d2)
			return 1;
		else if (d1 > d2) {
			return -1;
		}

		return 0;
	}
}

/**
 * 关卡排序器
 */
class ComparatorStars implements Comparator<Lord> {

	/**
	 * Overriding: compare
	 *
	 * @param o1
	 * @param o2
	 * @return
	 * @see java.util.Comparator#compare(java.lang.Object, java.lang.Object)
	 */
	@Override
	public int compare(Lord o1, Lord o2) {
		int d1 = o1.getStars();
		int d2 = o2.getStars();

		if (d1 < d2)
			return 1;
		else if (d1 > d2) {
			return -1;
		} else {
			if (o1.getStarRankTime() > o2.getStarRankTime()) {
				return 1;
			} else if (o1.getStarRankTime() < o2.getStarRankTime()) {
				return -1;
			}
		}

		return 0;
	}
}

/**
 * 极限副本排序器
 */
class ComparatorExtreme implements Comparator<Player> {

	/**
	 * Overriding: compare
	 *
	 * @param o1
	 * @param o2
	 * @return
	 * @see java.util.Comparator#compare(java.lang.Object, java.lang.Object)
	 */
	@Override
	public int compare(Player o1, Player o2) {
		// Auto-generated method stub
		if (o1.extrMark < o2.extrMark)
			return 1;
		else if (o1.extrMark > o2.extrMark) {
			return -1;
		} else {
			long v1 = o1.lord.getFight();
			long v2 = o2.lord.getFight();
			if (v1 < v2) {
				return 1;
			} else if (v1 > v2) {
				return -1;
			}

			return 0;
		}
	}
}

/**
 * 勋章展示数量排序器
 */
class ComparatorMedalBounsNum implements Comparator<Player> {

	@Override
	public int compare(Player o1, Player o2) {
		int d1 = o1.medalBounss.get(1).size();
		int d2 = o2.medalBounss.get(1).size();

		if (d1 < d2)
			return 1;
		else if (d1 > d2) {
			return -1;
		}

		return 0;
	}
}

/**
 * 荣誉排序器
 */
class ComparatorHonour implements Comparator<Lord> {

	/**
	 * Overriding: compare
	 *
	 * @param o1
	 * @param o2
	 * @return
	 * @see java.util.Comparator#compare(java.lang.Object, java.lang.Object)
	 */
	@Override
	public int compare(Lord o1, Lord o2) {
		int d1 = o1.getHonour();
		int d2 = o2.getHonour();

		if (d1 < d2)
			return 1;
		else if (d1 > d2) {
			return -1;
		}

		return 0;
	}
}

/**
 * 编制排序器
 * 
 * @ClassName: ComparatorStaffing
 * @author
 */
class ComparatorStaffing implements Comparator<Lord> {

	/**
	 * Overriding: compare
	 *
	 * @param o1
	 * @param o2
	 * @return
	 * @see java.util.Comparator#compare(java.lang.Object, java.lang.Object)
	 */
	@Override
	public int compare(Lord o1, Lord o2) {
		if (o1.getStaffingLv() < o2.getStaffingLv())
			return 1;
		else if (o1.getStaffingLv() > o2.getStaffingLv()) {
			return -1;
		} else {
			long v1 = o1.getStaffingExp();
			long v2 = o2.getStaffingExp();
			if (v1 < v2) {
				return 1;
			} else if (v1 > v2) {
				return -1;
			}

			return 0;
		}
	}
}

/**
 * 攻击闪避暴击强化排序器
 */
class ComparatorEquip implements Comparator<EquipRank> {

	public static final int[] FACTOR = { 15, 1, 3, 5, 10 };
	public static final int[] FACTOR2 = { 0, 8, 18, 30, 45, 65 };

	/**
	 * Overriding: compare
	 *
	 * @param o1
	 * @param o2
	 * @return
	 * @see java.util.Comparator#compare(java.lang.Object, java.lang.Object)
	 */
	@Override
	public int compare(EquipRank o1, EquipRank o2) {
		// Auto-generated method stub
		// 这个地方的装备加成比较，为了提高性能，暂时写死
		int d1 = (o1.getEquip().getLv() + 9 + FACTOR2[o1.getEquip().getStarlv()]) * FACTOR[o1.getEquip().getEquipId() % 5];
		int d2 = (o2.getEquip().getLv() + 9 + FACTOR2[o2.getEquip().getStarlv()]) * FACTOR[o2.getEquip().getEquipId() % 5];

		if (d1 < d2)
			return 1;
		else if (d1 > d2) {
			return -1;
		}

		return 0;
	}
}

/**
 * 军团战力排序器
 */
class ComparatorPartyFight implements Comparator<PartyRank> {

	/**
	 * Overriding: compare
	 *
	 * @param o1
	 * @param o2
	 * @return
	 * @see java.util.Comparator#compare(java.lang.Object, java.lang.Object)
	 */
	@Override
	public int compare(PartyRank o1, PartyRank o2) {
		// Auto-generated method stub
		long d1 = o1.getFight();
		long d2 = o2.getFight();

		if (d1 < d2)
			return 1;
		else if (d1 > d2) {
			return -1;
		}

		return 0;
	}
}

/**
 * 军团等级排序器
 */
class ComparatorPartyLv implements Comparator<PartyLvRank> {

	@Override
	public int compare(PartyLvRank o1, PartyLvRank o2) {
		if (o1.getPartyLv() < o2.getPartyLv()) {
			return 1;
		} else if (o1.getPartyLv() > o2.getPartyLv()) {
			return -1;
		} else {// 等级相同则已科技馆等级进行倒叙排序
			if (o1.getScienceLv() < o2.getScienceLv()) {
				return 1;
			} else if (o1.getScienceLv() > o2.getScienceLv()) {
				return -1;
			} else {// 科技馆等级相同则以福利院进行倒叙排序
				if (o1.getWealLv() < o2.getWealLv()) {
					return 1;
				} else if (o1.getWealLv() > o2.getWealLv()) {
					return -1;
				} else {// 福利院等级相同则已贡献度进行排名
					if (o1.getBuild() < o2.getBuild()) {
						return 1;
					} else if (o1.getBuild() > o2.getBuild()) {
						return -1;
					}
				}
			}
		}
		return 0;
	}
}

/**
 * 军团等级排行列表
 */
class PartyLvRankList {
	public int status = 0;// 活动开启时间
	private LinkedList<PartyLvRank> list = new LinkedList<PartyLvRank>();

	public LinkedList<PartyLvRank> getList() {
		return list;
	}

	public void addPartylvRank(PartyLvRank partyLvRank) {
		list.add(partyLvRank);
	}
}

/**
 * 排行榜数据处理
 */
@Component
public class RankDataManager {

	@Autowired
	private PlayerDataManager playerDataManager;

	public RankList fightRankList = new RankList();		
	public Set<Long> fightRankSet = new HashSet<>();

	public RankList starsRankList = new RankList();
	public Set<Long> starsRankSet = new HashSet<>();

	public RankList honourRankList = new RankList();
	public Set<Long> honourRankSet = new HashSet<>();

	public EquipRankList attackRankList = new EquipRankList();
	public EquipRankList critRankList = new EquipRankList();
	public EquipRankList dodgeRankList = new EquipRankList();

	public PartyLvRankList partyLvRankList = new PartyLvRankList();

	public LinkedList<Player> extremeRankList = new LinkedList<>();
	public Set<Long> extremeRankSet = new HashSet<>();

	public RankList staffingRankList = new RankList();
	public Set<Long> staffingRankSet = new HashSet<>();

	public RankList frightenRankList = new RankList();
	public Set<Long> frightenRankSet = new HashSet<>();

	public RankList fortitudeRankList = new RankList();
	public Set<Long> fortitudeRankSet = new HashSet<>();

	public RankList medalPriceRankList = new RankList();
	public Set<Long> medalPriceRankSet = new HashSet<>();

	public LinkedList<Player> medalBounsNumRankList = new LinkedList<>();
	public Set<Long> medalBounsNumRankSet = new HashSet<>();

	// 军衔排名
	public UnsafeSortInfo militaryRankSortInfo = new UnsafeSortInfo(200);
	// 最大实力排名
	public UnsafeSortInfo strongestFormRankSortInfo = new UnsafeSortInfo(200);

	/**
	 * 判断是否战力前5 Method: isFightRankTop5
	 *
	 * @param lordId
	 * @return boolean
	 * @throws @Description:
	 */
	public boolean isFightRankTop5(long lordId) {
		if (fightRankList.getList().size() > 5) {
			return (fightRankList.getList().get(0).getLordId() == lordId) || (fightRankList.getList().get(1).getLordId() == lordId)
					|| (fightRankList.getList().get(2).getLordId() == lordId) || (fightRankList.getList().get(3).getLordId() == lordId)
					|| (fightRankList.getList().get(4).getLordId() == lordId);
		}
		return true;
	}

	/**
	 * 
	 * 加载某玩家进排行
	 * 
	 * @param player void
	 */
	public void load(Player player) {
		Lord lord = player.lord;
		fightRankList.add(lord);
		if (lord.getStars() > 0) {
			starsRankList.add(lord);
		}

		honourRankList.add(lord);

		// if (TimeHelper.isStaffingOpen())
		staffingRankList.add(lord);

		if (player.extrMark > 0) {
			extremeRankList.add(player);
		}

		loadEquip(lord, player.equips);

		if (lord.getFrighten() > 0) {
			frightenRankList.add(lord);
		}

		if (lord.getFortitude() > 0) {
			fortitudeRankList.add(lord);
		}

		if (lord.getMedalPrice() > 0) {
			medalPriceRankList.add(lord);
		}

		if (player.medalBounss.get(1).size() > 0) {
			medalBounsNumRankList.add(player);
		}

		// 军衔排名
		if (lord.getMilitaryRank() > 0) {
			militaryRankSortInfo.upsert(new MilitaryRankSort(lord));
		}

		if (lord.getMaxFight() > 0) {
			strongestFormRankSortInfo.upsert(new FormSort(lord));
		}
	}

	/**
	 * 更新玩家最强战力排名
	 *
	 * @param lord
	 */
	public void upStrongestFormRankSortInfo(Lord lord) {
		strongestFormRankSortInfo.upsert(new FormSort(lord));
	}

	/**
	 * 更新玩家军衔排名
	 *
	 * @param lord
	 */
	public void upMilitaryRankSort(Lord lord) {
		militaryRankSortInfo.upsert(new MilitaryRankSort(lord));
	}

	/**
	 * 获取玩家军衔排名 -1:未上榜
	 *
	 * @param lord
	 * @return
	 */
	public int getMilitaryRankSort(Lord lord) {
		return militaryRankSortInfo.getRanking(String.valueOf(lord.getLordId()));
	}

	/**
	 * 
	 * 加载玩家装备更新排行榜
	 * 
	 * @param lord
	 * @param equips void
	 */
	private void loadEquip(Lord lord, Map<Integer, Map<Integer, Equip>> equips) {
		for (int i = 0; i < 7; i++) {
			Map<Integer, Equip> map = equips.get(i);
			Iterator<Equip> it = map.values().iterator();
			int index;
			while (it.hasNext()) {
				Equip equip = (Equip) it.next();
				index = equip.getEquipId() / 100;
				if (index == 1) {
					attackRankList.add(lord, equip);
				} else if (index == 4) {
					dodgeRankList.add(lord, equip);
				} else if (index == 5) {
					critRankList.add(lord, equip);
				}
			}
		}
	}

	/**
	 * 
	 * 排序所有 void
	 */
	public void sort() {
		Collections.sort(fightRankList.getList(), new ComparatorFight());
		while (fightRankList.getSize() > 100) {
			fightRankList.removeLast();
		}

		Collections.sort(starsRankList.getList(), new ComparatorStars());
		while (starsRankList.getSize() > 100) {
			starsRankList.removeLast();
		}

		Collections.sort(honourRankList.getList(), new ComparatorHonour());
		while (honourRankList.getSize() > 100) {
			honourRankList.removeLast();
		}

		Collections.sort(staffingRankList.getList(), new ComparatorStaffing());
		while (staffingRankList.getSize() > 100) {
			staffingRankList.removeLast();
		}

		Collections.sort(extremeRankList, new ComparatorExtreme());
		while (extremeRankList.size() > 100) {
			extremeRankList.removeLast();
		}

		Collections.sort(attackRankList.getList(), new ComparatorEquip());
		while (attackRankList.getSize() > 100) {
			attackRankList.removeLast();
		}

		Collections.sort(critRankList.getList(), new ComparatorEquip());
		while (critRankList.getSize() > 100) {
			critRankList.removeLast();
		}

		Collections.sort(dodgeRankList.getList(), new ComparatorEquip());
		while (dodgeRankList.getSize() > 100) {
			dodgeRankList.removeLast();
		}

		Collections.sort(frightenRankList.getList(), new ComparatorFrighten());
		while (frightenRankList.getSize() > 100) {
			frightenRankList.removeLast();
		}

		Collections.sort(fortitudeRankList.getList(), new ComparatorFortitude());
		while (fortitudeRankList.getSize() > 100) {
			fortitudeRankList.removeLast();
		}

		Collections.sort(medalPriceRankList.getList(), new ComparatorMedalPrice());
		while (medalPriceRankList.getSize() > 100) {
			medalPriceRankList.removeLast();
		}

		Collections.sort(medalBounsNumRankList, new ComparatorMedalBounsNum());
		while (medalBounsNumRankList.size() > 100) {
			medalBounsNumRankList.removeLast();
		}

		for (Lord lord : fightRankList.getList()) {
			fightRankSet.add(lord.getLordId());
		}

		int add = 0;
		int now = TimeHelper.getCurrentSecond();
		for (Lord lord : starsRankList.getList()) {
			starsRankSet.add(lord.getLordId());
			if (lord.getStarRankTime() == 0) {// 处理历史遗留问题，已经上榜没有记录上榜时间的，以当前时间为上榜时间
				lord.setStarRankTime(now + add);
				add++;
			}
		}

		for (Lord lord : honourRankList.getList()) {
			honourRankSet.add(lord.getLordId());
		}

		for (Lord lord : staffingRankList.getList()) {
			staffingRankSet.add(lord.getLordId());
		}

		for (Player player : extremeRankList) {
			extremeRankSet.add(player.roleId);
		}

		for (Lord lord : frightenRankList.getList()) {
			frightenRankSet.add(lord.getLordId());
		}

		for (Lord lord : fortitudeRankList.getList()) {
			fortitudeRankSet.add(lord.getLordId());
		}

		for (Lord lord : medalPriceRankList.getList()) {
			medalPriceRankSet.add(lord.getLordId());
		}

		for (Player player : medalBounsNumRankList) {
			medalBounsNumRankSet.add(player.roleId);
		}

		// for (Lord lord : fightRankList.getList()) {
		// // LogHelper.ERROR_LOGGER.error(lord.getNick() + "|" + lord.getFight());
		// LogUtil.start("战力排行榜|" + lord.getNick() + "|" + lord.getFight());
		// }
	}

	/**
	 * 
	 * 设置玩家关卡排行
	 * 
	 * @param lord void
	 */
	public void setStars(Lord lord) {
		if (starsRankSet.contains(lord.getLordId())) {
			lord.setStarRankTime(TimeHelper.getCurrentSecond());
			Collections.sort(starsRankList.getList(), new ComparatorStars());
		} else {
			int size = starsRankList.getSize();
			if (size == 0) {
				starsRankList.add(lord);
				starsRankSet.add(lord.getLordId());
				lord.setStarRankTime(TimeHelper.getCurrentSecond());
			} else {
				boolean added = false;
				ListIterator<Lord> it = starsRankList.getList().listIterator(size);
				while (it.hasPrevious()) {
					if (lord.getStars() <= it.previous().getStars()) {
						it.next();
						it.add(lord);
						added = true;
						break;
					}
				}

				if (!added) {
					starsRankList.getList().addFirst(lord);
				}

				starsRankList.setSize(size + 1);
				starsRankSet.add(lord.getLordId());
				lord.setStarRankTime(TimeHelper.getCurrentSecond());

				if (starsRankList.getSize() > 100) {
					starsRankSet.remove(starsRankList.removeLast());
				}
			}

		}
	}

	/**
	 * 
	 * 设置玩家荣誉排行
	 * 
	 * @param lord void
	 */
	public void setHonour(Lord lord) {
		if (honourRankSet.contains(lord.getLordId())) {
			Collections.sort(honourRankList.getList(), new ComparatorHonour());
		} else {
			int size = honourRankList.getSize();
			if (size == 0) {
				honourRankList.add(lord);
				honourRankSet.add(lord.getLordId());
			} else {
				boolean added = false;
				ListIterator<Lord> it = honourRankList.getList().listIterator(size);
				Lord e = null;
				while (it.hasPrevious()) {
					e = it.previous();
					// LogHelper.ERROR_LOGGER.error("setHonour " +
					// lord.getNick() + ":" + lord.getHonour() + "|" +
					// e.getNick() + ":" + e.getHonour());
					if (lord.getHonour() <= e.getHonour()) {	
						it.next();
						it.add(lord);
						added = true;
						// LogHelper.ERROR_LOGGER.error("setHonour added");
						break;
					}
				}

				if (!added) {
					honourRankList.getList().addFirst(lord);
				}

				honourRankList.setSize(size + 1);
				honourRankSet.add(lord.getLordId());

				if (honourRankList.getSize() > 100) {
					honourRankSet.remove(honourRankList.removeLast());
				}
			}
		}
	}

	/**
	 * 
	 * 设置玩家关卡排行
	 * 
	 * @param lord void
	 */
	public void setStaffing(Lord lord) {
		if (staffingRankSet.contains(lord.getLordId())) {
			Collections.sort(staffingRankList.getList(), new ComparatorStaffing());
		} else {
			int size = staffingRankList.getSize();
			if (size == 0) {
				staffingRankList.add(lord);
				staffingRankSet.add(lord.getLordId());
			} else {
				boolean added = false;
				ListIterator<Lord> it = staffingRankList.getList().listIterator(size);
				Lord e = null;
				while (it.hasPrevious()) {
					e = it.previous();
					if (lord.getStaffingLv() < e.getStaffingLv()) {
						it.next();
						it.add(lord);
						added = true;
						break;
					} else if (lord.getStaffingLv() == e.getStaffingLv()) {
						if (lord.getStaffingExp() <= e.getStaffingExp()) {
							it.next();
							it.add(lord);
							added = true;
							break;
						}
					}
				}

				if (!added) {
					staffingRankList.getList().addFirst(lord);
				}

				staffingRankList.setSize(size + 1);
				staffingRankSet.add(lord.getLordId());

				if (staffingRankList.getSize() > 100) {
					staffingRankSet.remove(staffingRankList.removeLast());
				}
			}
		}
	}

	/**
	 * 
	 * 设置玩家勋章展示排行
	 * 
	 * @param player void
	 */
	public void setMedalBounsNum(Player player) {
		if (medalBounsNumRankSet.contains(player.roleId)) {
			Collections.sort(medalBounsNumRankList, new ComparatorMedalBounsNum());
		} else {
			int size = medalBounsNumRankList.size();
			if (size == 0) {
				medalBounsNumRankList.add(player);
				medalBounsNumRankSet.add(player.roleId);
			} else {
				boolean added = false;
				ListIterator<Player> it = medalBounsNumRankList.listIterator(size);
				Player e = null;
				while (it.hasPrevious()) {
					e = it.previous();
					if (player.medalBounss.get(1).size() < e.medalBounss.get(1).size()) {
						it.next();
						it.add(player);
						added = true;
						break;
					}
				}

				if (!added) {
					medalBounsNumRankList.addFirst(player);
				}

				medalBounsNumRankSet.add(player.roleId);

				if (medalBounsNumRankList.size() > 100) {
					medalBounsNumRankSet.remove(medalBounsNumRankList.removeLast().roleId);
				}
			}
		}
	}

	/**
	 * 
	 * 设置玩家极限副本排行
	 * 
	 * @param player void
	 */
	public void setExtreme(Player player) {
		if (extremeRankSet.contains(player.roleId)) {
			Collections.sort(extremeRankList, new ComparatorExtreme());
		} else {
			int size = extremeRankList.size();
			if (size == 0) {
				extremeRankList.add(player);
				extremeRankSet.add(player.roleId);
			} else {
				boolean added = false;
				ListIterator<Player> it = extremeRankList.listIterator(size);
				Player e = null;
				while (it.hasPrevious()) {
					e = it.previous();
					if (player.extrMark < e.extrMark) {
						it.next();
						it.add(player);
						added = true;
						break;
					} else if (player.extrMark == e.extrMark) {
						if (player.lord.getFight() <= e.lord.getFight()) {
							it.next();
							it.add(player);
							added = true;
							break;
						}
					}
				}

				if (!added) {
					extremeRankList.addFirst(player);
				}

				extremeRankSet.add(player.roleId);

				if (extremeRankList.size() > 100) {
					extremeRankSet.remove(extremeRankList.removeLast().roleId);
				}
			}
		}
	}

	/**
	 * 
	 * 设置勋章价值排行
	 * 
	 * @param lord void
	 */
	public void setMedalPrice(Lord lord) {
		if (medalPriceRankSet.contains(lord.getLordId())) {
			Collections.sort(medalPriceRankList.getList(), new ComparatorMedalPrice());
		} else {
			int size = medalPriceRankList.getSize();
			if (size == 0) {
				medalPriceRankList.add(lord);
				medalPriceRankSet.add(lord.getLordId());
			} else {
				boolean added = false;
				ListIterator<Lord> it = medalPriceRankList.getList().listIterator(size);
				while (it.hasPrevious()) {
					if (lord.getMedalPrice() <= it.previous().getMedalPrice()) {
						it.next();
						it.add(lord);
						added = true;
						break;
					}
				}

				if (!added) {
					medalPriceRankList.getList().addFirst(lord);
				}

				medalPriceRankList.setSize(size + 1);
				medalPriceRankSet.add(lord.getLordId());

				if (medalPriceRankList.getSize() > 100) {
					medalPriceRankSet.remove(medalPriceRankList.removeLast());
				}
			}
		}
	}

	/**
	 * 设置玩家刚毅排行
	 */
	public void setFortitude(Lord lord) {
		if (fortitudeRankSet.contains(lord.getLordId())) {
			Collections.sort(fortitudeRankList.getList(), new ComparatorFortitude());
		} else {
			int size = fortitudeRankList.getSize();
			if (size == 0) {
				fortitudeRankList.add(lord);
				fortitudeRankSet.add(lord.getLordId());
			} else {
				boolean added = false;
				ListIterator<Lord> it = fortitudeRankList.getList().listIterator(size);
				while (it.hasPrevious()) {
					if (lord.getFortitude() <= it.previous().getFortitude()) {
						it.next();
						it.add(lord);
						added = true;
						break;
					}
				}

				if (!added) {
					fortitudeRankList.getList().addFirst(lord);
				}

				fortitudeRankList.setSize(size + 1);
				fortitudeRankSet.add(lord.getLordId());

				if (fortitudeRankList.getSize() > 100) {
					fortitudeRankSet.remove(fortitudeRankList.removeLast());
				}
			}
		}
	}

	/**
	 * 
	 * 设置玩家威慑排行
	 * 
	 * @param lord void
	 */
	public void setFrighten(Lord lord) {
		if (frightenRankSet.contains(lord.getLordId())) {
			Collections.sort(frightenRankList.getList(), new ComparatorFrighten());
		} else {
			int size = frightenRankList.getSize();
			if (size == 0) {
				frightenRankList.add(lord);
				frightenRankSet.add(lord.getLordId());
			} else {
				boolean added = false;
				ListIterator<Lord> it = frightenRankList.getList().listIterator(size);
				while (it.hasPrevious()) {
					if (lord.getFrighten() <= it.previous().getFrighten()) {
						it.next();
						it.add(lord);
						added = true;
						break;
					}
				}

				if (!added) {
					frightenRankList.getList().addFirst(lord);
				}

				frightenRankList.setSize(size + 1);
				frightenRankSet.add(lord.getLordId());

				if (frightenRankList.getSize() > 100) {
					frightenRankSet.remove(frightenRankList.removeLast());
				}
			}
		}
	}

	/**
	 * 
	 * 设置战力排行
	 * 
	 * @param lord void
	 */
	public void setFight(Lord lord) {
		if (fightRankSet.contains(lord.getLordId())) {
			Collections.sort(fightRankList.getList(), new ComparatorFight());
		} else {
			int size = fightRankList.getSize();
			if (size == 0) {
				fightRankList.add(lord);
				fightRankSet.add(lord.getLordId());
			} else {
				boolean added = false;
				ListIterator<Lord> it = fightRankList.getList().listIterator(size);
				while (it.hasPrevious()) {
					if (lord.getFight() <= it.previous().getFight()) {
						it.next();
						it.add(lord);
						added = true;
						break;
					}
				}

				if (!added) {
					fightRankList.getList().addFirst(lord);
				}

				fightRankList.setSize(size + 1);
				fightRankSet.add(lord.getLordId());

				if (fightRankList.getSize() > 100) {
					fightRankSet.remove(fightRankList.removeLast());
				}
			}
		}
	}

	/**
	 * 
	 * 设置军备排行
	 * 
	 * @param lord
	 * @param equip
	 * @param list void
	 */
	public void setEquip(Lord lord, Equip equip, EquipRankList list) {
		boolean find = false;
		for (EquipRank e : list.getList()) {
			if (e.getLord().getLordId() == lord.getLordId() && e.getEquip().getKeyId() == equip.getKeyId()) {
				find = true;
				break;
			}
		}

		if (find) {
			Collections.sort(list.getList(), new ComparatorEquip());
		} else {
			int size = list.getSize();
			if (size == 0) {
				list.add(lord, equip);
			} else {
				boolean added = false;
				Equip in = null;
				ListIterator<EquipRank> it = list.getList().listIterator(size);
				while (it.hasPrevious()) {
					in = it.previous().getEquip();
					int d1 = (equip.getLv() + 9 + ComparatorEquip.FACTOR2[equip.getStarlv()]) * ComparatorEquip.FACTOR[equip.getEquipId() % 5];
					int d2 = (in.getLv() + 9 + ComparatorEquip.FACTOR2[in.getStarlv()]) * ComparatorEquip.FACTOR[in.getEquipId() % 5];

					if (d1 <= d2) {
						it.next();
						it.add(new EquipRank(lord, equip));
						added = true;
						break;
					}
				}

				if (!added) {
					list.getList().addFirst(new EquipRank(lord, equip));
				}

				list.setSize(size + 1);

				if (list.getSize() > 100) {
					list.removeLast();
				}
			}
		}
	}

	/**
	 * 
	 * 设置军团等级排行
	 * 
	 * @param partyData void
	 */
	public void updatePartyLv(PartyData partyData) {
		int partyId = partyData.getPartyId();
		Iterator<PartyLvRank> it = partyLvRankList.getList().iterator();
		while (it.hasNext()) {
			PartyLvRank e = it.next();
			if (e.getPartyId() == partyId) {
				e.setPartyLv(partyData.getPartyLv());
				e.setScienceLv(partyData.getScienceLv());
				e.setWealLv(partyData.getWealLv());
				e.setBuild(partyData.getBuild());
				break;
			}
		}
		Collections.sort(partyLvRankList.getList(), new ComparatorPartyLv());
	}

	public LinkedList<PartyLvRank> getPartyLvRankList() {
		return partyLvRankList.getList();
	}

	/**
	 * 
	 * 新增军团的时候加入军团等级排行
	 * 
	 * @param partyId
	 * @param partyName
	 * @param partyLv
	 * @param scienceLv
	 * @param wealLv
	 * @param build void
	 */
	public void LoadPartyLv(int partyId, String partyName, int partyLv, int scienceLv, int wealLv, int build) {
		PartyLvRank partyLvRank = new PartyLvRank(partyId, partyName, partyLv, scienceLv, wealLv, build);
		getPartyLvRankList().add(partyLvRank);
	}

	/**
	 * 
	 * 设置玩家攻击强化排行
	 * 
	 * @param lord
	 * @param equip void
	 */
	public void setAttack(Lord lord, Equip equip) {
		setEquip(lord, equip, attackRankList);
	}

	/**
	 * 
	 * 设置玩家暴击强化排行
	 * 
	 * @param lord
	 * @param equip void
	 */
	public void setCrit(Lord lord, Equip equip) {
		setEquip(lord, equip, critRankList);
	}

	/**
	 * 
	 * 设置玩家闪避排行
	 * 
	 * @param lord
	 * @param equip void
	 */
	public void setDodge(Lord lord, Equip equip) {
		setEquip(lord, equip, dodgeRankList);
	}

	/**
	 * 
	 * 获得玩家排名
	 * 
	 * @param type 排名类型
	 * @param lordId
	 * @return int
	 */
	public int getPlayerRank(int type, long lordId) {
		int rank = 0;
		switch (type) {
		case 1: {// 战力榜
			Iterator<Lord> it = fightRankList.getList().iterator();
			while (it.hasNext()) {
				rank++;
				if (it.next().getLordId() == lordId) {
					return rank;
				}
			}
			break;
		}
		case 2: {// 关卡榜
			Iterator<Lord> it = starsRankList.getList().iterator();
			while (it.hasNext()) {
				rank++;
				if (it.next().getLordId() == lordId) {
					return rank;
				}
			}
			break;
		}
		case 3: {// 荣誉榜
			Iterator<Lord> it = honourRankList.getList().iterator();
			while (it.hasNext()) {
				rank++;
				if (it.next().getLordId() == lordId) {
					return rank;
				}
			}
			break;
		}
		case 4: {// 攻击强化
			Iterator<EquipRank> it = attackRankList.getList().iterator();
			while (it.hasNext()) {
				rank++;
				if (it.next().getLord().getLordId() == lordId) {
					return rank;
				}
			}
			break;
		}
		case 5: {// 暴击强化
			Iterator<EquipRank> it = critRankList.getList().iterator();
			while (it.hasNext()) {
				rank++;
				if (it.next().getLord().getLordId() == lordId) {
					return rank;
				}
			}
			break;
		}
		case 6: {// 闪避强化
			Iterator<EquipRank> it = dodgeRankList.getList().iterator();
			while (it.hasNext()) {
				rank++;
				if (it.next().getLord().getLordId() == lordId) {
					return rank;
				}
			}
			break;
		}
		case 8: {// 极限副本
			Iterator<Player> it = extremeRankList.iterator();
			while (it.hasNext()) {
				rank++;
				if (it.next().roleId == lordId) {
					return rank;
				}
			}
			break;
		}
		case 9: {// 编制榜
			Iterator<Lord> it = staffingRankList.getList().iterator();
			while (it.hasNext()) {
				rank++;
				if (it.next().getLordId() == lordId) {
					return rank;
				}
			}
			break;
		}
		case 10: {// 震慑
			Iterator<Lord> it = frightenRankList.getList().iterator();
			while (it.hasNext()) {
				rank++;
				if (it.next().getLordId() == lordId) {
					return rank;
				}
			}
			break;
		}
		case 11: {// 刚毅
			Iterator<Lord> it = fortitudeRankList.getList().iterator();
			while (it.hasNext()) {
				rank++;
				if (it.next().getLordId() == lordId) {
					return rank;
				}
			}
			break;
		}
		case 12: {// 勋章价值
			Iterator<Lord> it = medalPriceRankList.getList().iterator();
			while (it.hasNext()) {
				rank++;
				if (it.next().getLordId() == lordId) {
					return rank;
				}
			}
			break;
		}
		case 13: {// 勋章展示数量
			Iterator<Player> it = medalBounsNumRankList.iterator();
			while (it.hasNext()) {
				rank++;
				if (it.next().roleId == lordId) {
					return rank;
				}
			}
			break;
		}
		case 14: {
			return militaryRankSortInfo.getRanking(String.valueOf(lordId)) + 1;
		}
		case 15: {// 总战力榜
			return strongestFormRankSortInfo.getRanking(String.valueOf(lordId)) + 1;
		}
		}

		return 0;
	}

	/**
	 * Function:活动时获取军团等级排名
	 *
	 * @param type 1等级 ，2战斗力
	 * @param partyId
	 * @return
	 */
	public PartyLvRank getPartyRank(int partyId) {
		int rank = 0;
		Iterator<PartyLvRank> it = partyLvRankList.getList().iterator();
		while (it.hasNext()) {
			rank++;
			PartyLvRank partyLvRank = it.next();
			if (partyLvRank.getPartyId() == partyId) {
				if (partyLvRank.getRank() == 0) {
					partyLvRank.setRank(rank);
				}
				return partyLvRank;
			}
		}
		return null;
	}

	/**
	 * 
	 * 获取军团等级排行榜
	 * 
	 * @param page
	 * @return List<PartyLvRank>
	 */
	public List<PartyLvRank> getPartyLvRank(int page) {
		List<PartyLvRank> rs = new ArrayList<PartyLvRank>();
		int count = 0;
		int[] pages = { page * 20, (page + 1) * 20 };
		Iterator<PartyLvRank> it = partyLvRankList.getList().iterator();
		while (it.hasNext()) {
			PartyLvRank next = it.next();
			if (count >= pages[0]) {
				rs.add(next);
			}
			if (++count >= pages[1]) {
				break;
			}
		}

		return rs;
	}

	/**
	 * 
	 * 获取排行榜信息并发送协议到客户端
	 * 
	 * @param type
	 * @param page
	 * @param handler void
	 */
	public void getRank(int type, int page, ClientHandler handler) {
		Player play = playerDataManager.getPlayer(handler.getRoleId());
		GetRankRs.Builder builder = GetRankRs.newBuilder();
		int begin = (page - 1) * 20;
		int end = page * 20;
		int index = 0;
		switch (type) {
		case 1: {// 战力榜
			Iterator<Lord> it = fightRankList.getList().iterator();
			while (it.hasNext()) {
				if (index >= end) {
					break;
				}

				Lord lord = (Lord) it.next();
				if (index >= begin) {
					builder.addRankData(PbHelper.createRankData(lord.getNick(), lord.getLevel(), lord.getFight(), 0));
				}

				++index;
			}

			break;
		}
		case 2: {// 关卡榜
			Iterator<Lord> it = starsRankList.getList().iterator();
			while (it.hasNext()) {
				if (index >= end) {
					break;
				}

				Lord lord = (Lord) it.next();
				if (index >= begin) {
					builder.addRankData(PbHelper.createRankData(lord.getNick(), lord.getLevel(), lord.getStars(), 0));
				}

				++index;
			}
			break;
		}
		case 3: {// 荣誉榜
			Iterator<Lord> it = honourRankList.getList().iterator();
			while (it.hasNext()) {
				if (index >= end) {
					break;
				}

				Lord lord = (Lord) it.next();
				if (index >= begin) {
					builder.addRankData(PbHelper.createRankData(lord.getNick(), lord.getLevel(), lord.getHonour(), 0));
				}
				++index;
			}
			break;
		}
		case 4: {// 攻击强化
			Iterator<EquipRank> it = attackRankList.getList().iterator();
			while (it.hasNext()) {
				if (index >= end) {
					break;
				}

				EquipRank e = (EquipRank) it.next();
				if (index >= begin) {
					builder.addRankData(PbHelper.createRankData(e.getLord().getNick(), e.getEquip().getLv(), e.getEquip().getEquipId(),
							e.getEquip().getStarlv()));
				}
				++index;
			}
			break;
		}
		case 5: {// 暴击强化
			Iterator<EquipRank> it = critRankList.getList().iterator();
			while (it.hasNext()) {
				if (index >= end) {
					break;
				}

				EquipRank e = (EquipRank) it.next();
				if (index >= begin) {
					builder.addRankData(PbHelper.createRankData(e.getLord().getNick(), e.getEquip().getLv(), e.getEquip().getEquipId(),
							e.getEquip().getStarlv()));
				}
				++index;
			}
			break;
		}
		case 6: {// 闪避强化
			Iterator<EquipRank> it = dodgeRankList.getList().iterator();
			while (it.hasNext()) {
				if (index >= end) {
					break;
				}

				EquipRank e = (EquipRank) it.next();
				if (index >= begin) {
					builder.addRankData(PbHelper.createRankData(e.getLord().getNick(), e.getEquip().getLv(), e.getEquip().getEquipId(),
							e.getEquip().getStarlv()));
				}
				++index;
			}
			break;
		}
		case 8: {// 极限副本
			Iterator<Player> it = extremeRankList.iterator();
			while (it.hasNext()) {
				if (index >= end) {
					break;
				}

				Player player = (Player) it.next();
				if (index >= begin) {
					builder.addRankData(PbHelper.createRankData(player.lord.getNick(), player.extrMark, player.lord.getFight(), 0));
				}
				++index;
			}
			break;
		}
		case 9: {// 编制
			Iterator<Lord> it = staffingRankList.getList().iterator();
			while (it.hasNext()) {
				if (index >= end) {
					break;
				}

				Lord lord = (Lord) it.next();
				if (index >= begin) {
					builder.addRankData(PbHelper.createRankData(lord.getNick(), lord.getStaffing(), lord.getStaffingLv(), 0));
				}
				++index;
			}
			break;
		}
		case 10: {// 震慑
			Iterator<Lord> it = frightenRankList.getList().iterator();
			while (it.hasNext()) {
				if (index >= end) {
					break;
				}

				Lord lord = (Lord) it.next();
				if (index >= begin) {
					builder.addRankData(PbHelper.createRankData(lord.getNick(), lord.getLevel(), lord.getFrighten(), 0));
				}

				++index;
			}
			break;
		}
		case 11: {// 刚毅
			Iterator<Lord> it = fortitudeRankList.getList().iterator();
			while (it.hasNext()) {
				if (index >= end) {
					break;
				}

				Lord lord = (Lord) it.next();
				if (index >= begin) {
					builder.addRankData(PbHelper.createRankData(lord.getNick(), lord.getLevel(), lord.getFortitude(), 0));
				}

				++index;
			}
			break;
		}
		case 12: {// 勋章价值
			Iterator<Lord> it = medalPriceRankList.getList().iterator();
			while (it.hasNext()) {
				if (index >= end) {
					break;
				}

				Lord lord = (Lord) it.next();
				if (index >= begin) {
					builder.addRankData(PbHelper.createRankData(lord.getNick(), lord.getLevel(), lord.getMedalPrice(), 0));
				}

				++index;
			}
			break;
		}
		case 13: {// 展示数量
			Iterator<Player> it = medalBounsNumRankList.iterator();
			while (it.hasNext()) {
				if (index >= end) {
					break;
				}

				Player player = (Player) it.next();
				if (index >= begin) {
					builder.addRankData(
							PbHelper.createRankData(player.lord.getNick(), player.lord.getLevel(), player.medalBounss.get(1).size(), 0));
				}
				++index;
			}
			break;
		}
		case 14: {
			UnsafeSortInfo.ISortVO[] ranks = militaryRankSortInfo.getSubs(begin, end);
			if (ranks != null) {
				for (UnsafeSortInfo.ISortVO rank : ranks) {
					MilitaryRankSort sort = (MilitaryRankSort) rank;
					Player player = playerDataManager.getPlayer(sort.getLordId());
					Lord lord = player != null ? player.lord : null;
					if (lord != null) {
						builder.addRankData(PbHelper.createRankData(lord.getNick(), lord.getLevel(), lord.getMilitaryRank(), 0));
					}
				}
			}
			break;
		}
		case 15: {// 总战力榜
			UnsafeSortInfo.ISortVO[] ranks = strongestFormRankSortInfo.getSubs(begin, end);
			if (ranks != null) {
				for (UnsafeSortInfo.ISortVO rank : ranks) {
					Player player = playerDataManager.getPlayer(Long.valueOf(rank.getKey()));
					Lord lord = player != null ? player.lord : null;
					if (lord != null) {
						FormSort sort = (FormSort) rank;
						builder.addRankData(PbHelper.createRankData(lord.getNick(), sort.getMlr(), sort.getFight(), 0));
					}
				}
			}
			break;
		}
		default:
			break;
		}

		if (page == 1) {
			builder.setRank(getPlayerRank(type, handler.getRoleId()));
			if (type == 15) {
				builder.setMaxFight(play.lord.getMaxFight());
			}
		}

		handler.sendMsgToPlayer(GetRankRs.ext, builder.build());
	}

	/**
	 * 
	 * 获取排行列表 type为1,2,3,9以外 用的时候得修改这个方法
	 * 
	 * @param type
	 * @return LinkedList<Lord>
	 */
	public LinkedList<Lord> getRankList(int type) {
		if (type == 1) {
			return fightRankList.getList();
		} else if (type == 2) {
			return starsRankList.getList();
		} else if (type == 3) {
			return honourRankList.getList();
		} else if (type == 9) {
			return staffingRankList.getList();
		}
		return null;
	}

	/**
	 * 
	 * 获取排行信息 账号服会调用他 给后台显示用
	 * 
	 * @param type
	 * @param num
	 * @param builder void
	 */
	public void getRank(int type, int num, BackRankBaseRq.Builder builder) {
		int index = 0;
		switch (type) {
		case 1: {
			Iterator<Lord> it = fightRankList.getList().iterator();
			while (it.hasNext()) {
				Lord lord = (Lord) it.next();
				builder.addRankData(PbHelper.createRankData(lord.getNick(), lord.getLevel(), lord.getFight(), 0));
				index++;
				if (index >= num) {
					break;
				}
			}
			break;
		}
		case 2: {
			Iterator<Lord> it = starsRankList.getList().iterator();
			while (it.hasNext()) {
				Lord lord = (Lord) it.next();
				builder.addRankData(PbHelper.createRankData(lord.getNick(), lord.getLevel(), lord.getStars(), 0));
				index++;
				if (index >= num) {
					break;
				}
			}
			break;
		}
		case 3: {
			Iterator<Lord> it = this.honourRankList.getList().iterator();
			while (it.hasNext()) {
				Lord lord = (Lord) it.next();
				builder.addRankData(PbHelper.createRankData(lord.getNick(), lord.getLevel(), lord.getHonour(), 0));
				index++;
				if (index >= num) {
					break;
				}
			}
			break;
		}
		case 4: {
			Iterator<EquipRank> it = attackRankList.getList().iterator();
			while (it.hasNext()) {
				EquipRank e = (EquipRank) it.next();
				builder.addRankData(PbHelper.createRankData(e.getLord().getNick(), e.getEquip().getLv(), e.getEquip().getEquipId(),
						e.getEquip().getStarlv()));
				index++;
				if (index >= num) {
					break;
				}
			}
			break;
		}
		case 5: {
			Iterator<EquipRank> it = critRankList.getList().iterator();
			while (it.hasNext()) {
				EquipRank e = (EquipRank) it.next();
				builder.addRankData(PbHelper.createRankData(e.getLord().getNick(), e.getEquip().getLv(), e.getEquip().getEquipId(),
						e.getEquip().getStarlv()));
				index++;
				if (index >= num) {
					break;
				}
			}
			break;
		}
		case 6: {
			Iterator<EquipRank> it = dodgeRankList.getList().iterator();
			while (it.hasNext()) {
				EquipRank e = (EquipRank) it.next();
				builder.addRankData(PbHelper.createRankData(e.getLord().getNick(), e.getEquip().getLv(), e.getEquip().getEquipId(),
						e.getEquip().getStarlv()));
				index++;
				if (index >= num) {
					break;
				}
			}
			break;
		}
		case 8: {
			Iterator<Player> it = extremeRankList.iterator();
			while (it.hasNext()) {
				Player player = (Player) it.next();
				builder.addRankData(PbHelper.createRankData(player.lord.getNick(), player.extrMark, player.lord.getFight(), 0));
				index++;
				if (index >= num) {
					break;
				}
			}
			break;
		}
		case 9: {
			Iterator<Lord> it = this.staffingRankList.getList().iterator();
			while (it.hasNext()) {
				Lord lord = (Lord) it.next();
				builder.addRankData(PbHelper.createRankData(lord.getNick(), lord.getStaffing(), lord.getStaffingLv(), 0));
				index++;
				if (index < num) {
					if (!it.hasNext()) {
						break;
					}
				}
			}
			break;
		}
		default:
			break;
		}
	}
}
