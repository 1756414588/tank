/**   
 * @Title: PartyScoreRank.java    
 * @Package com.game.domain    
 * @Description:   
 * @author ZhangJun   
 * @date 2016年3月18日 下午4:00:48    
 * @version V1.0   
 */
package com.game.domain;

import com.game.pb.CommonPb;

/**
 * @ClassName: PartyScoreRank
 * @Description: 
 * @author ZhangJun
 * @date 2016年3月18日 下午4:00:48
 * 
 */
public class SeniorPartyScoreRank {
	private int partyId;
	private long fight;
	private int score;

	public int getPartyId() {
		return partyId;
	}

	public void setPartyId(int partyId) {
		this.partyId = partyId;
	}

	public long getFight() {
		return fight;
	}

	public void setFight(long fight) {
		this.fight = fight;
	}

	public int getScore() {
		return score;
	}

	public void setScore(int score) {
		this.score = score;
	}

	public CommonPb.SeniorPartyScore ser() {
		CommonPb.SeniorPartyScore.Builder builder = CommonPb.SeniorPartyScore.newBuilder();
		builder.setPartyId(partyId);
		builder.setFight(fight);
		builder.setScore(score);
		return builder.build();
	}

	public SeniorPartyScoreRank(CommonPb.SeniorPartyScore seniorScore) {
		partyId = seniorScore.getPartyId();
		fight = seniorScore.getFight();
		score = seniorScore.getScore();
	}

	public SeniorPartyScoreRank(PartyData partyData) {
		partyId = partyData.getPartyId();
		fight = partyData.getFight();
		score = partyData.getScore();
	}
}
