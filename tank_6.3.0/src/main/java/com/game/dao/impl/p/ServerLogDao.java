/**   
 * @Title: ServerLogDao.java    
 * @Package com.game.dao.impl.p    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年9月9日 下午3:18:52    
 * @version V1.0   
 */
package com.game.dao.impl.p;

import com.game.dao.BaseDao;
import com.game.domain.p.ArenaLog;
import com.game.domain.p.WarLog;
import com.game.domain.p.WorldLog;

/**
 * @ClassName: ServerLogDao
 * @Description: 服务器日志
 * @author ZhangJun
 * @date 2015年9月9日 下午3:18:52
 * 
 */
public class ServerLogDao extends BaseDao {
	public ArenaLog selectLastArenaLog() {
		return this.getSqlSession().selectOne("ServerLogDao.selectLastArenaLog");
	}

	public void insertArenaLog(ArenaLog arenaLog) {
		this.getSqlSession().insert("ServerLogDao.insertArenaLog", arenaLog);
	}

	public WarLog selectLastWarLog() {
		return this.getSqlSession().selectOne("ServerLogDao.selectLastWarLog");
	}

	public void insertWarLog(WarLog warLog) {
		this.getSqlSession().insert("ServerLogDao.insertWarLog", warLog);
	}

	public WorldLog selectLastWorldLog() {
		return this.getSqlSession().selectOne("ServerLogDao.selectLastWorldLog");
	}

	public void insertWorldLog(WorldLog worldLog) {
		this.getSqlSession().insert("ServerLogDao.insertWorldLog", worldLog);
	}
}
