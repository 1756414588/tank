package com.game.domain;

import com.game.constant.ActivityConst;
import com.game.domain.s.StaticActivity;
import com.game.domain.s.StaticActivityPlan;
import com.game.util.DateHelper;

import java.util.Calendar;
import java.util.Date;

/**
 * s_activity_plan中每条记录将生成一个ActivityBase对象
 * @author ChenKui
 * @version 创建时间：2015-12-18 下午2:52:10
 * @declare
 */

public class ActivityBase {
	private Date openTime;// 开服时间

	private StaticActivityPlan plan;// 活动计划

	private StaticActivity staticActivity;// 活动模板

	private Date beginTime;
	private Date endTime;
	private Date displayTime;

	public StaticActivity getStaticActivity() {
		return staticActivity;
	}

	public void setStaticActivity(StaticActivity staticActivity) {
		this.staticActivity = staticActivity;
	}

	public StaticActivityPlan getPlan() {
		return plan;
	}

	public void setPlan(StaticActivityPlan plan) {
		this.plan = plan;
	}

	public Date getOpenTime() {
		return openTime;
	}

	public void setOpenTime(Date openTime) {
		this.openTime = openTime;
	}

	public Date getBeginTime() {
		return beginTime;
	}

	public void setBeginTime(Date beginTime) {
		this.beginTime = beginTime;
	}

	public Date getEndTime() {
		return endTime;
	}

	public void setEndTime(Date endTime) {
		this.endTime = endTime;
	}

	public Date getDisplayTime() {
		return displayTime;
	}

	public void setDisplayTime(Date displayTime) {
		this.displayTime = displayTime;
	}

	public int getActivityId() {
		return this.plan.getActivityId();
	}

	public int getKeyId() {
		return this.plan.getAwardId();
	}

	public int getDayiy() {
		return DateHelper.dayiy(openTime, new Date());
	}

	public boolean initData() {
		int beginDate = plan.getOpenBegin();
		if (beginDate != 0) {
			int openDuration = plan.getOpenDuration();
			if (openDuration == 0) {
				return false;
			}
			int displayDuration = plan.getDisplayDuration();
			Calendar open = Calendar.getInstance();
			open.setTime(openTime);
			open.set(Calendar.HOUR_OF_DAY, 0);
			open.set(Calendar.MINUTE, 0);
			open.set(Calendar.SECOND, 0);
			open.set(Calendar.MILLISECOND, 0);
			long openMillis = open.getTimeInMillis();

			long beginMillis = (beginDate - 1) * 24 * 3600 * 1000L + openMillis;
			this.beginTime = new Date(beginMillis);

			// 等级活动和投资计划时间必须按之前设定的做处理
			int activityId = this.staticActivity.getActivityId();
			if (activityId == 1
                    || activityId == 15
                    || activityId == 18
                    || activityId == ActivityConst.ACT_INVEST_NEW) {
				this.beginTime = DateHelper.parseDate("2015-11-17 00:00:00");
			}

			//VIP礼包在V4.10.1(2018/02/08)版本中全服重置一次 2018-2-8 00:00:00
			if (activityId == ActivityConst.ACT_VIP_GIFT){
                this.beginTime = DateHelper.parseDate("2018-2-8 00:00:00");
            }

			long endMillis = beginMillis + openDuration * 24 * 3600 * 1000L - 1;
			this.endTime = new Date(endMillis);

			if (displayDuration != 0) {
				long displayMillis = endMillis + displayDuration * 24 * 3600 * 1000L;
				this.displayTime = new Date(displayMillis);
			}
			return true;

		} else {
			if (plan.getBeginTime() == null || plan.getEndTime() == null) {
				return false;
			}

			this.beginTime = plan.getBeginTime();
			this.endTime = plan.getEndTime();
			this.displayTime = plan.getDisplayTime();
			return true;
		}
	}

	/**
	 * 活动
	 * 
	 * @param openTime
	 * @return {-1 活动未开启， 0活动进行中， 1活动结束但未关闭显示}
	 */
	public int getStep() {
		int whole = staticActivity.getWhole();// 0开服,常规,促销。1全服

		int openBegin = plan.getOpenBegin();
		int openDuration = plan.getOpenDuration();
		int displayDuration = plan.getDisplayDuration();

		Date now = new Date();// 当前时间
		int wholeDayiy = DateHelper.dayiy(openTime, now);// 开服多少天

		if (whole == 2 && wholeDayiy < 30) {// 新服小于30天的都不可开启
			return -1;
		}

		if (openBegin > 0) {// 开服计划类活动跟着顺序走
			int dayiy = DateHelper.dayiy(openTime, now);// 开服距当前天数

			int endDate = openBegin + openDuration;
			int displayDate = endDate + displayDuration;

			if (dayiy >= openBegin && dayiy < endDate) {
				return 0;
			}

			if (dayiy >= endDate && dayiy < displayDate) {
				return 1;
			}

		} else {// 常规,促销,全服性质活动
			Date beginTime = plan.getBeginTime();
			Date endTime = plan.getEndTime();
			Date displayTime = plan.getDisplayTime();

			if (beginTime == null || endTime == null) {
				return -1;
			}

			int beginLimit = plan.getServerBegin();// 活动开启限制
			int endLimit = plan.getServerEnd();// 活动结束限制

			int dayiy = DateHelper.dayiy(openTime, beginTime);// 开服时间距活动开启天数
			if (beginLimit != 0 && dayiy < beginLimit) {// 活动开启限制
				return -1;
			}

			if (endLimit != 0 && dayiy > endLimit) {// 活动结束限制
				return -1;
			}

			if (now.after(beginTime) && now.before(endTime)) {
				return 0;
			}

			if (displayTime != null && now.after(endTime) && now.before(displayTime)) {
				return 1;
			}
		}
		return -1;
	}

	/**
	 * 获取活动{1可领奖,0不可领奖,-1活动未开启}
	 * 
	 * @return
	 */
	public int getBaseOpen() {
		int step = getStep();
		if (step == -1) {// 活动未开启
			return step;
		}
		int podium = staticActivity.getPodium();
		if (podium == 0) {// 活动过程中可领奖
			if (step == 0) {
				return 1;
			}
			return step;
		} else if (podium == 1) {// 活动结束后才可领奖
			return step;
		} else if (podium == 2) {// 活动过程和结束后都可领奖
			return 1;
		}
		return 0;
	}
}
