package com.game.dataMgr;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.game.dao.impl.s.StaticDataDao;
import com.game.domain.p.Award;
import com.game.domain.s.StaticAwards;
import com.game.util.RandomHelper;

/**
 * @author ChenKui
 * @version 创建时间：2015-9-1 上午11:19:54
 * @Description: 物品奖励处理s_award
 */
@Component
public class StaticAwardsDataMgr extends BaseDataMgr {
	@Autowired
	private StaticDataDao staticDataDao;

	private Map<Integer, StaticAwards> awardsMap = new HashMap<Integer, StaticAwards>();

	@Override
	public void init() {
		Map<Integer, StaticAwards> awardsMap  = staticDataDao.selectAwardsMap();
		this.awardsMap = awardsMap;
	}

	public StaticAwards getAwardById(int awardId) {
		return awardsMap.get(awardId);
	}

	/**
	 * 描叙：该方法有可能会获取到空结果,取决于配置数据
	 * 
	 * @param awardId
	 * @return
	 */
	public List<List<Integer>> getAwards(int awardId) {
		List<List<Integer>> rs = new ArrayList<List<Integer>>();
		StaticAwards staticAwards = awardsMap.get(awardId);
		int weight = staticAwards.getWeight();
		int repeat = staticAwards.getRepeat();
		int count = staticAwards.getCount();
		List<List<Integer>> awardList = staticAwards.getAwardList();
		List<List<Integer>> dropList = new ArrayList<List<Integer>>();
		dropList.addAll(awardList);
		int[][] award = new int[count][3];
		switch(weight){
		    case 0:
				// 概率掉落
				for (int i = 0; i < count; i++) {
					dropList = regroupList(dropList, award, repeat);
					int index = RandomHelper.randomInSize(100);
					for (List<Integer> e : dropList) {
						if (index <= e.get(3)) {
							award[i][0] = e.get(0);
							award[i][1] = e.get(1);
							award[i][2] = e.get(2);
							break;
						}
					}
				}
		        break;
			case 1:
				for (int i = 0; i < count; i++) {
					dropList = regroupList(dropList, award, repeat);
					int total = getTotal(dropList);
					int index = RandomHelper.randomInSize(total);
					total = 0;
					for (List<Integer> e : dropList) {
						total += e.get(3);
						if (index <= total) {
							award[i][0] = e.get(0);
							award[i][1] = e.get(1);
							award[i][2] = e.get(2);
							break;
						}
					}
				}
				break;
		    default:
		        break;
		}
		for (int i = 0; i < count; i++) {
			if (award[i][0] == 0) {
				continue;
			}
			List<Integer> ee = new ArrayList<Integer>();
			ee.add(award[i][0]);
			ee.add(award[i][1]);
			ee.add(award[i][2]);
			rs.add(ee);
		}
		return rs;
	}

	public List<Award> getDisplay(int awardId) {
		List<Award> rs = new ArrayList<Award>();
		StaticAwards staticAwards = awardsMap.get(awardId);
		List<List<Integer>> displayList = staticAwards.getDisplayList();
		if (displayList.size() == 0) {
			return rs;
		}
		List<List<Integer>> dropList = new ArrayList<List<Integer>>();
		dropList.addAll(displayList);
		int displayCount = staticAwards.getDisplayCount();
		for (int i = 0; i < displayCount; i++) {
			int size = dropList.size();
			if (size > 0) {
				int index = RandomHelper.randomInSize(size);
				List<Integer> ll = dropList.remove(index);
				Award award = new Award();
				award.setType(ll.get(0));
				award.setId(ll.get(1));
				award.setCount(ll.get(2));
				rs.add(award);
			}
		}
		return rs;
	}

	public static int getTotal(List<List<Integer>> list) {
		int total = 0;
		for (int i = 0; i < list.size(); i++) {
			total += list.get(i).get(3);
		}
		return total;
	}

	/**
	 * 描叙：重组列表,去已掉落物件,或者重复同一物件
	 * 
	 * @param list
	 * @param award
	 * @param repeat
	 * @return
	 */
	public static List<List<Integer>> regroupList(List<List<Integer>> list, int[][] award, int repeat) {
		List<List<Integer>> rs = new ArrayList<List<Integer>>();
		for (int i = 0; i < list.size(); i++) {
			List<Integer> e = list.get(i);
			int type = e.get(0);
			int id = e.get(1);
			int count = e.get(2);
			boolean flag = false;
			for (int c = 0; c < award.length; c++) {
				if (award[c][0] == 0) {
					break;
				}
				if (repeat == 1 && type == award[c][0] && id == award[c][1]) {
					flag = true;
					break;
				} else if (repeat == 0 && type == award[c][0] && id == award[c][1] && count == award[c][2]) {
					flag = true;
					break;
				}
			}
			if (!flag) {
				rs.add(e);
			}
		}
		return rs;
	}
}
