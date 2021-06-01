package com.game.dao.impl.p;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.game.dao.BaseDao;
import com.game.domain.p.LordRelation;
/**
* @ClassName: LordRelationDao 
* @Description: 同一玩家角色关联
* @author
 */
public class LordRelationDao extends BaseDao {
	public LordRelation selectLordRelation(int oldServerId, long oldLordId) {
		Map<String, String> map = new HashMap<>();
		map.put("oldServerId", String.valueOf(oldServerId));
		map.put("oldLordId", String.valueOf(oldLordId));
		return this.getSqlSession().selectOne("LordRelationDao.selectLordRelation", map);
	}

	public int insertLordRelation(LordRelation relation) {
		return this.getSqlSession().insert("LordRelationDao.insertLordRelation", relation);
	}
	
	public List<LordRelation> selectAllLordRelation() {
		return this.getSqlSession().selectList("LordRelationDao.selectAllLordRelation");
	}
	
	public void createLordRelationTable() {
		this.getSqlSession().insert("LordRelationDao.createLordRelationTable");
	}
	
	public List<String> showDatabases() {
		return this.getSqlSession().selectList("LordRelationDao.showDatabases");
	}
	
	public List<String> showTables() {
		return this.getSqlSession().selectList("LordRelationDao.showTables");
	}
	
	public void createGameDb(String dbName) {
		Map<String, Object> map = new HashMap<>();
		map.put("dbName", dbName);
		this.getSqlSession().update("LordRelationDao.createGameDb",map);
	}
	
	public String showCreateTable(String tableName) {
		Map<String, Object> map = new HashMap<>();
		map.put("tableName", tableName);
		Map<String, String>  rs = this.getSqlSession().selectOne("LordRelationDao.showCreateTable",map);
		return rs.get("value");
	}
	
	public void createTable(String sql) {
		Map<String, Object> map = new HashMap<>();
		map.put("sql", sql);
		this.getSqlSession().insert("LordRelationDao.createTable",map);
	}
	
	public void tableToOtherDb(String dbName,String tableName) {
		Map<String, Object> map = new HashMap<>();
		map.put("dbName", dbName);
		map.put("tableName", tableName);
		this.getSqlSession().update("LordRelationDao.tableToOtherDb",map);
	}
	
	public void truncateTable(String tableName) {
		Map<String, Object> map = new HashMap<>();
		map.put("tableName", tableName);
		this.getSqlSession().update("LordRelationDao.truncateTable",map);
	}
	
	public List<Integer> selectMergeServerIds() {
		return this.getSqlSession().selectList("LordRelationDao.selectMergeServerIds");
	}
	
	public List<LordRelation> selectAllLordRelationByTab(String tableName) {
		Map<String, Object> map = new HashMap<>();
		map.put("tableName", tableName);
		return this.getSqlSession().selectList("LordRelationDao.selectAllLordRelationByTab",map);
	}
	
	public int insertLordRelationByTab(LordRelation relation,String tableName) {
		Map<String, Object> map = new HashMap<>();
		map.put("tableName", tableName);
		map.put("oldServerId", relation.getOldServerId());
		map.put("oldLordId", relation.getOldLordId());
		map.put("newServerId", relation.getNewServerId());
		map.put("newLordId", relation.getNewLordId());
		
		return this.getSqlSession().insert("LordRelationDao.insertLordRelationByTab", map);
	}
}
