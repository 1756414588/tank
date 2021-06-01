package com.game.dataMgr;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.commons.lang3.RandomUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.game.dao.impl.s.StaticDataDao;
import com.game.domain.s.StaticScoutPic;
import com.game.util.LogUtil;
import com.game.util.RandomHelper;

/**
 * @author: LiFeng
 * @date: 2018年9月17日 下午6:54:22
 * @description:
 */
@Component
public class StaticScoutDataMgr extends BaseDataMgr {

	@Autowired
	private StaticDataDao staticDataDao;

	// key : keyId
	private Map<Integer, StaticScoutPic> scoutPicMap = new HashMap<>();
	private List<StaticScoutPic> scoutPicList = new ArrayList<>();
	// 所有大类
	private Set<Integer> allGenus = new HashSet<>();
	// 所有小类
	private Set<Integer> allSpecies = new HashSet<>();
	// key : genus
	private Map<Integer, List<StaticScoutPic>> genusMap = new HashMap<>();
	// key : species
	private Map<Integer, List<StaticScoutPic>> speciesMap = new HashMap<>();

	@Override
	public void init() {
		scoutPicMap.clear();
		genusMap.clear();
		speciesMap.clear();
		Set<Integer> tempGenus = new HashSet<>();
		Set<Integer> tempSpecies = new HashSet<>();
		try {
			List<StaticScoutPic> scoutPicList = staticDataDao.selectScoutPicList();
			this.scoutPicList = scoutPicList;
			for (StaticScoutPic s : scoutPicList) {
				scoutPicMap.put(s.getKeyId(), s);
				tempGenus.add(s.getGenus());
				tempSpecies.add(s.getSpecies());

				List<StaticScoutPic> genus = genusMap.get(s.getGenus());
				if (genus == null) {
					genus = new LinkedList<>();
					genusMap.put(s.getGenus(), genus);
				}
				genus.add(s);

				List<StaticScoutPic> species = speciesMap.get(s.getSpecies());
				if (species == null) {
					species = new LinkedList<>();
					speciesMap.put(s.getSpecies(), species);
				}
				species.add(s);
			}
		} catch (Exception e) {
			LogUtil.error("初始化扫矿验证图片信息配置报错");
			e.printStackTrace();
		}
		this.allGenus = tempGenus;
		this.allSpecies = tempSpecies;
	}

	public StaticScoutPic getScoutPic(int keyId) {
		return scoutPicMap.get(keyId);
	}

	public List<Integer> getAllGenus() {
		return new ArrayList<Integer>(allGenus);
	}

	public List<Integer> getAllSpecies() {
		return new ArrayList<Integer>(allSpecies);
	}

	/**
	 * 从大类及小类中随机出一个类别编号
	 * 
	 * @return int[]
	 */
	public int[] generateFromGenusAndSpecies() {
		int[] ret = new int[2];
		// 先随机出一个小类
		int indexOne = RandomUtils.nextInt(0, scoutPicList.size());
		StaticScoutPic sp = scoutPicList.get(indexOne);
		int targetOne = sp.getSpecies();
		// 有些图片没有小类
		while (targetOne == 0) {
			indexOne = RandomUtils.nextInt(0, scoutPicList.size());
			sp = scoutPicList.get(indexOne);
			targetOne = sp.getSpecies();
		}
		ret[1] = targetOne;
		// 再随机出一个大类或一个小类
		List<Integer> list = new ArrayList<>();
		list.addAll(allSpecies);
		list.addAll(allGenus);
		Iterator<Integer> iterator = list.iterator();
		while (iterator.hasNext()) {
			int next = iterator.next();
			// 下一个大类不得包含上一个小类，下一个小类与上一个小类也不同属于一个大类
			if (next == sp.getGenus() || next / 100 == sp.getGenus() || next == 0) {
				iterator.remove();
			}
		}
		int indexTwo = RandomUtils.nextInt(0, list.size());
		int targetTwo = list.get(indexTwo);
		ret[0] = targetTwo;
		return ret;
	}

	/**
	 * 根据大类或小类编号选择正确图片
	 * 
	 * @param kind1
	 * @param kind2
	 * @param num 图片总数
	 * @return 若kind1 与kind2 在分类上有重叠，可能返回重复的图片id 规则， 每类图片至少一张
	 */
	public List<Integer> selectCorrectImg(int kind1, int kind2, int num) {
		List<Integer> ret = new LinkedList<>();
		if ((kind1 < 100 && kind2 < 100) || num < 5) {
			LogUtil.error("图片验证生成的分类参数有误 | kind1 : " + kind1 + " | kind2 : " + kind2);
			return null;
		}
		List<StaticScoutPic> kindList1 = genusMap.get(kind1);
		if (kindList1 == null) {
			kindList1 = speciesMap.get(kind1);
		}
		List<StaticScoutPic> kindList2 = speciesMap.get(kind2);
		if (kindList2 == null) {
			kindList2 = genusMap.get(kind2);
		}

		List<StaticScoutPic> piclist = new LinkedList<>();
		// 先从两个分类中分别取出一个
		StaticScoutPic pic1 = kindList1.get(RandomUtils.nextInt(0, kindList1.size()));
		StaticScoutPic pic2 = kindList2.get(RandomUtils.nextInt(0, kindList2.size()));
		piclist.add(pic1);
		piclist.add(pic2);

		List<StaticScoutPic> list = new LinkedList<>();
		list.addAll(kindList1);
		list.addAll(kindList2);
		list.remove(pic1);
		list.remove(pic2);

		// 正确图片的数量从这个数组中随机
		int[] correct = new int[] { (num + 1) / 2, (num + 1) / 2 - 1, (num + 1) / 2 - 2 };
		int count = RandomHelper.getRandomArray(correct, 1)[0];
		if (count >= list.size() + 2) {
			count = list.size() + 2;
		}

		List<StaticScoutPic> randomList = RandomHelper.getRandomList(list, count - 2);
		piclist.addAll(randomList);
		for (StaticScoutPic pic : piclist) {
			ret.add(pic.getKeyId());
		}
		return ret;

	}

	/**
	 * 选择干扰图片
	 * 
	 * @param kind1
	 * @param kind2
	 * @param num 错误图片的数量d'sa'd
	 * @return
	 */
	public List<Integer> selectErrorImg(int kind1, int kind2, int num) {
		List<Integer> ret = new ArrayList<>();
		List<StaticScoutPic> list = new LinkedList<>(scoutPicList);
		Iterator<StaticScoutPic> iterator = list.iterator();
		while (iterator.hasNext()) {
			StaticScoutPic next = iterator.next();
			if (next.getGenus() == kind1 || next.getGenus() == kind2 || next.getSpecies() == kind1
					|| next.getSpecies() == kind2) {
				iterator.remove();
			}
		}
		List<Integer> index = RandomHelper.getRandomValues(0, list.size() - 1, num);
		for (int i : index) {
			ret.add(list.get(i).getKeyId());
		}
		return ret;
	}

}
