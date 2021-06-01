/**   
 * @Title: ArenaDao.java    
 * @Package com.game.dao.impl.p    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年9月7日 上午11:07:14    
 * @version V1.0   
 */
package com.game.dao.impl.p;

import java.util.List;

import com.game.dao.BaseDao;
import com.game.domain.p.corss.DbCrossFameInfo;
import com.game.domain.p.corssParty.DbCPFame;

/**
* @ClassName: CrossFameDao 
* @Description: 跨服军团战记录
* @author
 */
public class CrossFameDao extends BaseDao {
	public List<DbCrossFameInfo> selectCrossFameInfo() {
		return this.getSqlSession().selectList("CrossFameDao.selectCrossFameInfo");
	}

	public void insertCrossFameInfo(DbCrossFameInfo fameInfo) {
		this.getSqlSession().insert("CrossFameDao.insertCrossFameInfo", fameInfo);
	}
	
	public List<DbCPFame> selectCPFameInfo() {
		return this.getSqlSession().selectList("CrossFameDao.selectCPFameInfo");
	}

	public void insertCPFameInfo(DbCPFame fameInfo) {
		this.getSqlSession().insert("CrossFameDao.insertCPFameInfo", fameInfo);
	}
}
