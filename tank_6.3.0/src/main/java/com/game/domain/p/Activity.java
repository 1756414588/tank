package com.game.domain.p;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.game.constant.ActivityConst;
import com.game.domain.ActivityBase;
import com.game.domain.s.StaticActivity;
import com.game.util.TimeHelper;

/**
 * @author ChenKui
 * @version 创建时间：2015-10-26 上午9:53:33
* @Description:  玩家的活动数据
 */

public class Activity {
	private int activityId;
	private List<Long> statusList;
	private Map<Integer, Integer> statusMap;
	private Map<Integer, Integer> propMap = new HashMap<>();
	/** 设置每日重置  该集合不会重置 */
	private Map<Integer, Integer> saveMap = new HashMap<>();  
	/** 活动开始时间 ,格式yyyyMMdd*/
	private int beginTime;
	/** 记录清理数据的时间精确到天，避免重复清理数据 */
	private int endTime;
	/** 1可领奖,0不可领奖,-1活动未开启*/
	private int open;	

	public int getActivityId() {
		return activityId;
	}

	public void setActivityId(int activityId) {
		this.activityId = activityId;
	}

	public List<Long> getStatusList() {
		return statusList;
	}

	public void setStatusList(List<Long> statusList) {
		this.statusList = statusList;
	}

	public Map<Integer, Integer> getStatusMap() {
		return statusMap;
	}

	public void setStatusMap(Map<Integer, Integer> statusMap) {
		this.statusMap = statusMap;
	}

	public Map<Integer, Integer> getPropMap() {
		return propMap;
	}

	public void setPropMap(Map<Integer, Integer> propMap) {
		this.propMap = propMap;
	}
	
	public Map<Integer, Integer> getSaveMap() {
		return saveMap;
	}

	public void setSaveMap(Map<Integer, Integer> saveMap) {
		this.saveMap = saveMap;
	}

	public int getBeginTime() {
		return beginTime;
	}

	public void setBeginTime(int beginTime) {
		this.beginTime = beginTime;
	}

	public int getEndTime() {
		return endTime;
	}

	public void setEndTime(int endTime) {
		this.endTime = endTime;
	}

	public int getOpen() {
		return open;
	}

	public void setOpen(int open) {
		this.open = open;
	}

	public Activity() {
	}

	public Activity(ActivityBase activityBase, int begin) {
		this.activityId = activityBase.getStaticActivity().getActivityId();
		this.beginTime = begin;
		this.statusMap = new HashMap<>();
		this.propMap = new HashMap<>();
		this.saveMap = new HashMap<>();
	}

	/**
	 * 开启时间不同,则为两次开启活动,重置活动数据
	 * 
	 * @param begin
	 */
	public boolean isReset(int begin) {
		if (this.beginTime == begin) {
			return false;
		}
		this.beginTime = begin;
		this.endTime = begin;
		this.cleanActivity(false);
		this.propMap.clear();
		this.saveMap.clear();
		return true;
	}

	/**
	 * 自动清理活动数据
	 * 
	 * @param staticActivity
	 * @param theDay
	 */
	public void autoDayClean(ActivityBase activityBase) {
		StaticActivity sa = activityBase.getStaticActivity();
		if (sa.getClean() == ActivityConst.CLEAN_DAY) {
			int nowDay = TimeHelper.getCurrentDay();
			if (this.endTime != nowDay) {
				cleanActivity(true);
				this.endTime = nowDay;
			}
		}
	}

	/**
	 * 清理活动中记录的数据（分每日重置以及活动开启重置）
	 * @param isDayClean 是否是每日重置
	 */
	private void cleanActivity(boolean isDayClean) {
		cleanStatusMap(isDayClean);
		
		if (activityId == ActivityConst.ACT_PAY_EVERYDAY_NEW_1) {
		    statusList = new ArrayList<>();
		    statusList.add(2L);
		    statusList.add(0L);
		    return;
		}
		
		if (activityId == ActivityConst.ACT_PAY_PARTY) {
			statusList.add(0L);
			return;
		}
		
		if (this.statusList != null && this.statusList.size() > 0) {
			for (int i = 0; i < this.statusList.size(); i++) {
				this.statusList.set(i, 0L);
			}
		}
	}
	
	/**
	 * 清除数据特别处理
	 * @param isDayClean
	 */
	private void cleanStatusMap(boolean isDayClean) {
        if (!isDayClean) {
            this.statusMap.clear();
        } else {  //  有些活动 设置了每日重置 但又含有排行榜领奖的   需要保留排行榜领奖状态
            switch (activityId) {
                case ActivityConst.ACT_PIRATE:
                    Integer receive = this.statusMap.get(0);
                    this.statusMap.clear();
                    if (receive != null) {
                        this.statusMap.put(0, receive);
                    }
                    break;
                case ActivityConst.ACT_WORSHIP_ID:
                    break;
                case ActivityConst.ACT_PAY_EVERYDAY_NEW_1:
    			case ActivityConst.ACT_PAY_EVERYDAY_NEW_2:
    			case ActivityConst.ACT_PAY_PARTY:
                case ActivityConst.ACT_MEDAL_OF_HONOR: {//活动期间不刷新statusMap数据
                    break;
                }
                default:
                    this.statusMap.clear();
                    break;
            }
        }
    }


}
