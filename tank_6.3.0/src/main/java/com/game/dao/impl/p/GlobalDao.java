/**   
 * @Title: ArenaDao.java    
 * @Package com.game.dao.impl.p    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年9月7日 上午11:07:14    
 * @version V1.0   
 */
package com.game.dao.impl.p;

import com.game.dao.BaseDao;
import com.game.domain.p.DbGlobal;

/**
 * @ClassName: GlobalDao
 * @Description:    全局信息
 * @author ZhangJun
 * @date 2015年9月7日 上午11:07:14
 * 
 */
public class GlobalDao extends BaseDao {
	public DbGlobal selectGlobal() {
		return this.getSqlSession().selectOne("GlobalDao.selectGlobal");
	}

	public int updateGlobal(DbGlobal dbGlobal) {
		return this.getSqlSession().update("GlobalDao.updateGlobal", dbGlobal);
	}

	public void insertGlobal(DbGlobal dbGlobal) {
		this.getSqlSession().insert("GlobalDao.insertGlobal", dbGlobal);
	}
}
