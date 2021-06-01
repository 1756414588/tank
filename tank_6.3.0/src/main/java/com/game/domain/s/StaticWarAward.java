/**   
 * @Title: StaticWarAward.java    
 * @Package com.game.domain.s    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年12月18日 下午6:45:02    
 * @version V1.0   
 */
package com.game.domain.s;

import java.util.List;

/**
 * @ClassName: StaticWarAward
 * @Description: 战斗奖励配置
 * @author ZhangJun
 * @date 2015年12月18日 下午6:45:02
 * 
 */
public class StaticWarAward {
	private int rank;
	private List<List<Integer>> rankAwards;
	private List<List<Integer>> winAwards;
	private List<List<Integer>> hurtAwards;
	private List<List<Integer>> scoreAwards;
	private List<List<Integer>> scorePartyAwards;
	private List<List<Integer>> fortressRankAward;
	private List<List<Integer>> drillRankAward;// 军事演习（红蓝大战）排行奖励
	private List<List<Integer>> drillPartWinAward;// 军事演习（红蓝大战）胜利方参与奖励
	private List<List<Integer>> drillPartFailAward;// 军事演习（红蓝大战）失败方参与奖励
	private List<List<Integer>> rebelRankAward;// 叛军入侵周个人排行奖励
	private List<List<Integer>> rebelBuffAward;// 叛军全服buff奖励
	private List<List<Integer>> eliteServerRankAwards; // 跨服精英赛排名奖励
	private List<List<Integer>> eliteAllAwards; // 跨服精英赛全服奖励
	private List<List<Integer>> topServerRankAwards; // '跨服巅峰组排名奖
	private List<List<Integer>> topAllAwards; // 跨服巅峰组全服奖励
	private List<List<Integer>> serverPartyRankAward;// 跨服军团争霸军团排行
	private List<List<Integer>> serverPartyPersonAward;// 跨服军团争霸个人排行
	private List<List<Integer>> serverPartyWinAward;// 跨服军团争霸连胜排行
	private List<List<Integer>> serverPartyAllAward;// 跨服军团争霸全服奖励
	private List<List<Integer>> rebelPartyRankAward; // 叛军入侵周军团排行奖励
	private List<List<Integer>> honourLiveRankAward;//荣耀生存个人排行榜奖励
	private List<List<Integer>> honourLivePartyRankAward;//荣耀生存军团排行榜奖励

	private List<List<Integer>> serverMineRankAward;//跨服军矿个人奖励
	private List<List<Integer>> serverMinePartyRankAward;//跨服军矿服务器奖励


	public List<List<Integer>> getFortressRankAward() {
		return fortressRankAward;
	}

	public void setFortressRankAward(List<List<Integer>> fortressRankAward) {
		this.fortressRankAward = fortressRankAward;
	}

	public int getRank() {
		return rank;
	}

	public void setRank(int rank) {
		this.rank = rank;
	}

	public List<List<Integer>> getRankAwards() {
		return rankAwards;
	}

	public void setRankAwards(List<List<Integer>> rankAwards) {
		this.rankAwards = rankAwards;
	}

	public List<List<Integer>> getWinAwards() {
		return winAwards;
	}

	public void setWinAwards(List<List<Integer>> winAwards) {
		this.winAwards = winAwards;
	}

	public List<List<Integer>> getHurtAwards() {
		return hurtAwards;
	}

	public void setHurtAwards(List<List<Integer>> hurtAwards) {
		this.hurtAwards = hurtAwards;
	}

	public List<List<Integer>> getScoreAwards() {
		return scoreAwards;
	}

	public void setScoreAwards(List<List<Integer>> scoreAwards) {
		this.scoreAwards = scoreAwards;
	}

	public List<List<Integer>> getScorePartyAwards() {
		return scorePartyAwards;
	}

	public void setScorePartyAwards(List<List<Integer>> scorePartyAwards) {
		this.scorePartyAwards = scorePartyAwards;
	}

	public List<List<Integer>> getDrillRankAward() {
		return drillRankAward;
	}

	public void setDrillRankAward(List<List<Integer>> drillRankAward) {
		this.drillRankAward = drillRankAward;
	}

	public List<List<Integer>> getDrillPartWinAward() {
		return drillPartWinAward;
	}

	public void setDrillPartWinAward(List<List<Integer>> drillPartWinAward) {
		this.drillPartWinAward = drillPartWinAward;
	}

	public List<List<Integer>> getDrillPartFailAward() {
		return drillPartFailAward;
	}

	public void setDrillPartFailAward(List<List<Integer>> drillPartFailAward) {
		this.drillPartFailAward = drillPartFailAward;
	}

	public List<List<Integer>> getRebelRankAward() {
		return rebelRankAward;
	}

	public void setRebelRankAward(List<List<Integer>> rebelRankAward) {
		this.rebelRankAward = rebelRankAward;
	}

	public List<List<Integer>> getRebelBuffAward() {
		return rebelBuffAward;
	}

	public void setRebelBuffAward(List<List<Integer>> rebelBuffAward) {
		this.rebelBuffAward = rebelBuffAward;
	}

	public List<List<Integer>> getEliteServerRankAwards() {
		return eliteServerRankAwards;
	}

	public void setEliteServerRankAwards(List<List<Integer>> eliteServerRankAwards) {
		this.eliteServerRankAwards = eliteServerRankAwards;
	}

	public List<List<Integer>> getEliteAllAwards() {
		return eliteAllAwards;
	}

	public void setEliteAllAwards(List<List<Integer>> eliteAllAwards) {
		this.eliteAllAwards = eliteAllAwards;
	}

	public List<List<Integer>> getTopServerRankAwards() {
		return topServerRankAwards;
	}

	public void setTopServerRankAwards(List<List<Integer>> topServerRankAwards) {
		this.topServerRankAwards = topServerRankAwards;
	}

	public List<List<Integer>> getTopAllAwards() {
		return topAllAwards;
	}

	public void setTopAllAwards(List<List<Integer>> topAllAwards) {
		this.topAllAwards = topAllAwards;
	}

	public List<List<Integer>> getServerPartyRankAward() {
		return serverPartyRankAward;
	}

	public void setServerPartyRankAward(List<List<Integer>> serverPartyRankAward) {
		this.serverPartyRankAward = serverPartyRankAward;
	}

	public List<List<Integer>> getServerPartyPersonAward() {
		return serverPartyPersonAward;
	}

	public void setServerPartyPersonAward(List<List<Integer>> serverPartyPersonAward) {
		this.serverPartyPersonAward = serverPartyPersonAward;
	}

	public List<List<Integer>> getServerPartyWinAward() {
		return serverPartyWinAward;
	}

	public void setServerPartyWinAward(List<List<Integer>> serverPartyWinAward) {
		this.serverPartyWinAward = serverPartyWinAward;
	}

	public List<List<Integer>> getServerPartyAllAward() {
		return serverPartyAllAward;
	}

	public void setServerPartyAllAward(List<List<Integer>> serverPartyAllAward) {
		this.serverPartyAllAward = serverPartyAllAward;
	}

	public List<List<Integer>> getRebelPartyRankAward() {
		return rebelPartyRankAward;
	}
	
	public void setRebelPartyRankAward(List<List<Integer>> rebelPartyRankAward) {
		this.rebelPartyRankAward = rebelPartyRankAward;
	}

	public List<List<Integer>> getHonourLiveRankAward() {
		return honourLiveRankAward;
	}

	public void setHonourLiveRankAward(List<List<Integer>> honourLiveRankAward) {
		this.honourLiveRankAward = honourLiveRankAward;
	}

	public List<List<Integer>> getHonourLivePartyRankAward() {
		return honourLivePartyRankAward;
	}

	public void setHonourLivePartyRankAward(List<List<Integer>> honourLivePartyRankAward) {
		this.honourLivePartyRankAward = honourLivePartyRankAward;
	}

	public List<List<Integer>> getServerMineRankAward() {
		return serverMineRankAward;
	}

	public void setServerMineRankAward(List<List<Integer>> serverMineRankAward) {
		this.serverMineRankAward = serverMineRankAward;
	}

	public List<List<Integer>> getServerMinePartyRankAward() {
		return serverMinePartyRankAward;
	}

	public void setServerMinePartyRankAward(List<List<Integer>> serverMinePartyRankAward) {
		this.serverMinePartyRankAward = serverMinePartyRankAward;
	}
}
