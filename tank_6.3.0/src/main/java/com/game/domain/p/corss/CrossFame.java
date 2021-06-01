package com.game.domain.p.corss;

import java.util.ArrayList;
import java.util.List;

/**
 * 
* @ClassName: CrossFame 
* @Description: 跨服战名人堂战斗明细
* @author
 */
public class CrossFame {
	private int groupId;
	public List<FamePojo> famePojos = new ArrayList<FamePojo>();
	public List<FameBattleReview> fameBattleReviews = new ArrayList<FameBattleReview>();

	public List<FameBattleReview> getFameBattleReviews() {
		return fameBattleReviews;
	}

	public void setFameBattleReviews(List<FameBattleReview> fameBattleReviews) {
		this.fameBattleReviews = fameBattleReviews;
	}

	public int getGroupId() {
		return groupId;
	}

	public void setGroupId(int groupId) {
		this.groupId = groupId;
	}

	public List<FamePojo> getFamePojos() {
		return famePojos;
	}

	public void setFamePojos(List<FamePojo> famePojos) {
		this.famePojos = famePojos;
	}

}
