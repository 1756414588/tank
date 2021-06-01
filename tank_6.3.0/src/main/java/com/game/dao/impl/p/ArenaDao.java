/**   
 * @Title: ArenaDao.java    
 * @Package com.game.dao.impl.p    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年9月7日 上午11:07:14    
 * @version V1.0   
 */
package com.game.dao.impl.p;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import com.game.dao.BaseDao;
import com.game.domain.p.Arena;

/**
 * @ClassName: ArenaDao
 * @Description: 竞技场信息
 * @author ZhangJun
 * @date 2015年9月7日 上午11:07:14
 * 
 */
public class ArenaDao extends BaseDao {
	public Arena selectArena(Long lordId) {
		return this.getSqlSession().selectOne("ArenaDao.selectArena", lordId);
	}

	public int updateArena(Arena arena) {
		return this.getSqlSession().update("ArenaDao.updateArena", arena);
	}

	public void insertArena(Arena arena) {
		this.getSqlSession().insert("ArenaDao.insertArena", arena);
	}

	public List<Arena> load() {
		List<Arena> list = new ArrayList<>();
		long curIndex = 0L;
		int count = 1000;
		int pageSize = 0;
		while (true) {
			List<Arena> page = load(curIndex, count);
			pageSize = page.size();
			if (pageSize > 0) {
				list.addAll(page);
				curIndex = page.get(pageSize - 1).getRank();
			} else {
				break;
			}

			if (pageSize < count) {
				break;
			}
		}
		return list;
	}

//	private Map<Integer, Arena> load(long curIndex, int count) {
//		Map<String, Object> params = paramsMap();
//		params.put("curIndex", curIndex);
//		params.put("count", count);
//		return this.getSqlSession().selectMap("ArenaDao.load", params, "rank");
//	}
	
	private List<Arena> load(long curIndex, int count) {
		Map<String, Object> params = paramsMap();
		params.put("curIndex", curIndex);
		params.put("count", count);
		return this.getSqlSession().selectList("ArenaDao.load", params);
	}

    public List<Arena> loadArenaNotInSmallIds(){
        return this.getSqlSession().selectList("ArenaDao.loadNotInSmallIds");
    }
}
