package com.game.util;

import com.game.domain.p.Lord;

import java.util.Comparator;

/**
 * 战力比较器
 * @author ChenKui
 * @version 创建时间：2015-12-8 上午9:50:56
 * @declare
 */

public class CompareLordFight implements Comparator<Lord> {

	@Override
	public int compare(Lord o1, Lord o2) {
		if (o1.getFight() < o2.getFight()) {
			return 1;
		} else if (o1.getFight() > o2.getFight()) {
			return -1;
		} else {
			if (o1.getLordId() < o2.getLordId()) {
				return -1;
			}
		}
		return 0;
	}

}
