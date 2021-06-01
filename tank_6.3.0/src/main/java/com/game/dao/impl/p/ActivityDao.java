package com.game.dao.impl.p;

import java.util.List;

import com.game.dao.BaseDao;
import com.game.domain.p.UsualActivity;
/**
* @ClassName: ActivityDao 
* @Description: 活动表 p_usual_activity
* @author
 */
public class ActivityDao extends BaseDao {

	public List<UsualActivity> selectUsualActivity() {
		return this.getSqlSession().selectList("ActivityDao.selectUsualActivity");
	}

	public void updateActivity(UsualActivity usualActivity) {
		if (update(usualActivity) == 0) {
			insertUsualActivity(usualActivity);
		}
	}

	public void insertUsualActivity(UsualActivity usualActivity) {
		this.getSqlSession().insert("ActivityDao.insertUsualActivity", usualActivity);
	}

	public int update(UsualActivity usualActivity) {
		return this.getSqlSession().update("ActivityDao.updateUsualActivity", usualActivity);
	}

}
