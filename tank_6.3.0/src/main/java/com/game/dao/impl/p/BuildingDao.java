/**   
 * @Title: BuildingDao.java    
 * @Package com.game.dao.impl    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年7月21日 下午2:26:47    
 * @version V1.0   
 */
package com.game.dao.impl.p;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import com.game.dao.BaseDao;
import com.game.domain.p.Building;

/**
 * @ClassName: BuildingDao
 * @Description: 建筑信息
 * @author ZhangJun
 * @date 2015年7月21日 下午2:26:47
 * 
 */
public class BuildingDao extends BaseDao {
	public Building selectBuilding(long lordId) {
		return this.getSqlSession().selectOne("BuildingDao.selectBuilding", lordId);
	}

	public int insertBuilding(Building building) {
		return this.getSqlSession().insert("BuildingDao.insertBuilding", building);
	}

	public void updateBuilding(Building building) {
		this.getSqlSession().update("BuildingDao.updateBuilding", building);
	}

	public List<Building> load() {
		List<Building> list = new ArrayList<>();
		long curIndex = 0L;
		int count = 1000;
		int pageSize = 0;
		while (true) {
			List<Building> page = load(curIndex, count);
			pageSize = page.size();
			if (pageSize > 0) {
				list.addAll(page);
				curIndex = page.get(pageSize - 1).getLordId();
			} else {
				break;
			}

			if (pageSize < count) {
				break;
			}
		}
		return list;
	}

	private List<Building> load(long curIndex, int count) {
		Map<String, Object> params = paramsMap();
		params.put("curIndex", curIndex);
		params.put("count", count);
		return this.getSqlSession().selectList("BuildingDao.load", params);
	}

}
