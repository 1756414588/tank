package com.game.util;

import java.util.List;

public class ListHelper {
	/**
	 * 
	*  [[临界值,取值],[临界值,取值],[临界值,取值],[临界值,取值]]  根据startVal达到的临界值计算取值
	* @param list
	* @param startVal
	* @return  
	* int
	 */
	public static int getListNearVal(List<List<Integer>> list,int startVal){
		for (List<Integer> l : list) {
			if(startVal <= l.get(0)){
				return l.get(1);
			}
		}
		return Integer.MAX_VALUE;
	}
	
	/**
	 * 
	* 根据权重随机出一个奖励
	* @param awardList  格式 [[type，id，count,权重]......]
	* @return  
	* List<Integer>
	 */
	public static List<Integer> getRandomAward(List<List<Integer>> awardList){
		if (awardList.size() == 1) {
			return awardList.get(0);
		}
		int[] seeds = { 0, 0 };
		for (List<Integer> e : awardList) {
			if (e.size() < 4) {
				continue;
			}
			seeds[0] += e.get(3);
		}
		seeds[0] = RandomHelper.randomInSize(seeds[0]);
		for (List<Integer> e : awardList) {
			seeds[1] += e.get(3);
			if (seeds[0] <= seeds[1]) {
				return e;
			}
		}
		return null;
	}

}
