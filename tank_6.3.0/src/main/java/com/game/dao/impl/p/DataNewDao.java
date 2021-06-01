package com.game.dao.impl.p;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import com.game.dao.BaseDao;
import com.game.domain.p.DataNew;

/**
* @ClassName: DataNewDao 
* @Description: 玩家数据表p_data
* @author
 */
public class DataNewDao extends BaseDao {
	public DataNew selectData(Long lordId) {
		return this.getSqlSession().selectOne("DataNewDao.selectData", lordId);
	}

	public void insertData(DataNew data) {
		this.getSqlSession().insert("DataNewDao.insertData", data);
	}
	
	public int insertFullData(DataNew data) {
		return this.getSqlSession().insert("DataNewDao.insertFullData", data);
	}

	public void updateData(DataNew data) {
		this.getSqlSession().update("DataNewDao.updateData", data);
	}

	public List<DataNew> loadData() {
		List<DataNew> list = new ArrayList<>();
		long curIndex = 0;
		int count = 2000;
		int pageSize = 0;
		while (true) {
			List<DataNew> page = loadData(curIndex, count);
			pageSize = page.size();
			if (pageSize > 0) {
				list.addAll(page);
				curIndex = page.get(pageSize - 1).getLordId();
			} else {
				break;
			}

			if (page.size() < count) {
				break;
			}
		}
		return list;
	}

	private List<DataNew> loadData(long curIndex, int count) {
		Map<String, Object> params = paramsMap();
		params.put("curIndex", curIndex);
		params.put("count", count);
		return this.getSqlSession().selectList("DataNewDao.loadData", params);
	}

}
