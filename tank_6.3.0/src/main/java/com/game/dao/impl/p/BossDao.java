package com.game.dao.impl.p;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import com.game.dao.BaseDao;
import com.game.domain.p.BossFight;
/**
* @ClassName: BossDao 
* @Description:     世界BOSS挑战信息
* @author
 */
public class BossDao extends BaseDao {
	// public Data selectData(Long lordId) {
	// return this.getSqlSession().selectOne("BossDao.selectData", lordId);
	// }

	public void insertData(BossFight data) {
		this.getSqlSession().insert("BossDao.insertData", data);
	}

	public int updateData(BossFight data) {
		return this.getSqlSession().update("BossDao.updateData", data);
	}

	public List<BossFight> loadData() {
		List<BossFight> list = new ArrayList<>();
		long curIndex = 0;
		int count = 2000;
		int pageSize = 0;
		while (true) {
			List<BossFight> page = loadData(curIndex, count);
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

	private List<BossFight> loadData(long curIndex, int count) {
		Map<String, Object> params = paramsMap();
		params.put("curIndex", curIndex);
		params.put("count", count);
		return this.getSqlSession().selectList("BossDao.loadData", params);
	}
}
