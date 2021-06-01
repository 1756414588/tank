package com.game.util;

import java.util.*;

/**
 * @author GuiJie
 * @description 描述
 * @created 2018/02/28 13:28
 */
public class LotteryUtil {

	/**
	 * 随即获取Map中一个key(0-和值)
	 *
	 * @param items (key: value:权重值)
	 * @return
	 */
	public static <T> T getRandomKey(Map<T, Float> items) {
		if (items == null || items.size() == 0) {
			return null;
		}
		// 求和(选取随机数范围)
		float total = 0;
		for (Map.Entry<T, Float> entry : items.entrySet()) {
			total += entry.getValue();
		}
		// 如果几率之和为0，随机一个key
		if (total == 0) {
			return null;
		}
		float sum = 0f;
		// 随机取值
		int maxNumber = (int) (total * 10000);
		int ran = new Random().nextInt(maxNumber);
		for (Map.Entry<T, Float> entry : items.entrySet()) {
			float tmp = sum + entry.getValue();
			if (ran >= (sum * 10000) && ran < (tmp * 10000)) {
				return entry.getKey();
			}
			sum = tmp;
		}
		return null;
	}

	/**
	 * 随即获取Map中一个key(0-10000) 会随机出空的
	 *
	 * @param items (key: value:比例值/权重值)
	 * @return
	 */
	public static <T> T getRandomItem(Map<T, Float> items) {

		float sum = 0f;
		float ran = new Random().nextInt(10000);
		for (Map.Entry<T, Float> entry : items.entrySet()) {
			if (ran >= sum && ran < sum + entry.getValue()) {
				return entry.getKey();
			}
			sum += entry.getValue();
		}
		return null;
	}

	/**
	 * @param num
	 * @return
	 */
	public static Integer[] lotteryInt(int num, int count) {
		if (num < count) {
			return null;
		}

		List<Integer> result = new ArrayList<>();
		while (result.size() < count) {
			int nextInt = new Random().nextInt(num);
			if (!result.contains(nextInt)) {
				result.add(nextInt);
			}
		}
		return result.toArray(new Integer[count]);
	}

	public static Map<List<Integer>, Float> listToMap(List<List<Integer>> list) {
		Map<List<Integer>, Float> map = new HashMap<>();
		for (List<Integer> award : list) {
			map.put(award.subList(0, 3), award.get(3) * 1.0F);
		}
		return map;
	}

}
