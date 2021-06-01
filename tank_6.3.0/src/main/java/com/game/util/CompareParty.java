package com.game.util;

import com.game.domain.p.PartyRank;

import java.util.Comparator;

/**
 * 军战力比较器
 * @author ChenKui
 * @version 创建时间：2015-9-12 上午11:28:18
 * @declare
 */

public class CompareParty implements Comparator<PartyRank> {

	@Override
	public int compare(PartyRank o1, PartyRank o2) {
		if (o1.getFight() > o2.getFight()) {
			return -1;
		} else if (o1.getFight() < o2.getFight()) {
			return 1;
		}
		return 0;
	}

}

