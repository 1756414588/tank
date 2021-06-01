package com.game.util;

import com.game.domain.p.PartyLvRank;

import java.util.Comparator;

/**
 * 
 * @author ChenKui
 * @version 创建时间：2015-9-12 上午11:28:18
 * @declare
 */

public class ComparePartyLv implements Comparator<PartyLvRank> {

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
