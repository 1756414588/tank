/**   
 * @Title: ExtremeDao.java    
 * @Package com.game.dao.impl.p    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年9月26日 上午10:29:15    
 * @version V1.0   
 */
package com.game.dao.impl.p;

import java.util.List;

import com.game.dao.BaseDao;
import com.game.domain.p.DbExtreme;

/**
 * @ClassName: ExtremeDao
 * @Description:    极限探险记录
 * @author ZhangJun
 * @date 2015年9月26日 上午10:29:15
 * 
 */
public class ExtremeDao extends BaseDao {
	public List<DbExtreme> selectExtreme() {
		return getSqlSession().selectList("ExtremeDao.selectExtreme");
	}

	public void updateExtreme(DbExtreme dbExtreme) {
		getSqlSession().update("ExtremeDao.updateExtreme", dbExtreme);
	}

	public void insertExtreme(DbExtreme dbExtreme) {
		getSqlSession().insert("ExtremeDao.insertExtreme", dbExtreme);
	}
}
