package com.game.domain.s;

import java.util.List;

/**
 * @ClassName:StaticActChooseGift
 * @author zc
 * @Description:对应tank_ini.s_act_choosegift
 * @date 2017年8月25日
 */
public class StaticActChooseGift {
	private int id;
	private int activityid;			//活动编号
	private int awardid;
	private int qualification;		//领取资格（需要充多少金币）
	private int limitnumber;		//每天可参与的次数
	private List<List<Integer>> awardlist;//单个宝箱内含什么奖励 
	
	public int getId() {
		return id;
	}
	public void setId(int id) {
		this.id = id;
	}
	public int getActivityid() {
		return activityid;
	}
	public void setActivityid(int activityid) {
		this.activityid = activityid;
	}
	public int getAwardid() {
		return awardid;
	}
	public void setAwardid(int awardid) {
		this.awardid = awardid;
	}
	public int getQualification() {
		return qualification;
	}
	public void setQualification(int qualification) {
		this.qualification = qualification;
	}
	public int getLimitnumber() {
		return limitnumber;
	}
	public void setLimitnumber(int limitnumber) {
		this.limitnumber = limitnumber;
	}
	public List<List<Integer>> getAwardlist() {
		return awardlist;
	}
	public void setAwardlist(List<List<Integer>> awardlist) {
		this.awardlist = awardlist;
	}
		
}
