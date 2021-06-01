package com.game.dao.impl.p;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import com.game.dao.BaseDao;
import com.game.domain.p.Lord;

/**
 * 
* @ClassName: LordDao 
* @Description: 角色基本信息
* @author
 */
public class LordDao extends BaseDao {
	public Lord selectLordById(Long lordId) {
		return this.getSqlSession().selectOne("LordDao.selectLordById", lordId);
	}
	
    public Lord selectLordByNick(String nick) {
        return this.getSqlSession().selectOne("LordDao.selectLordByNick", nick);
    }
	
	public List<Long> selectLordNotSmallIds(){
		return getSqlSession().selectList("LordDao.selectLordNotSmallIds");
	}

//	public Map<Long, Lord> getLordListInId(List<Long> lordIds) {
//		return this.getSqlSession().selectMap("LordDao.getLordListInId", lordIds, "lordId");
//	}

//	public Lord selectLordByNick(String nick) {
//		return this.getSqlSession().selectOne("LordDao.selectLordByNick", nick);
//	}

//	public int sameNameCount(String nick) {
//		return this.getSqlSession().selectOne("LordDao.sameNameCount", nick);
//	}

	public void updateNickPortrait(Lord lord) {
		this.getSqlSession().update("LordDao.updateNickPortrait", lord);
	}


	public void updateLord(Lord lord) {
		this.getSqlSession().update("LordDao.updateLord", lord);
	}
	

	public void insertLord(Lord lord) {
		this.getSqlSession().insert("LordDao.insertLord", lord);
	}
	
	public int insertFullLord(Lord lord) {
		return this.getSqlSession().insert("LordDao.insertFullLord", lord);
	}

	public List<Lord> load() {
		List<Lord> list = new ArrayList<>();
		long curIndex = 0L;
		int count = 1000;
		int pageSize = 0;
		while (true) {
			List<Lord> page = load(curIndex, count);
			pageSize = page.size();
			if (pageSize > 0) {
				list.addAll(page);
				curIndex =  page.get(pageSize - 1).getLordId();
			} else {
				break;
			}

			if (pageSize < count) {
				break;
			}
		}
		return list;
	}

	private List<Lord> load(long curIndex, int count) {
		Map<String, Object> params = paramsMap();
		params.put("curIndex", curIndex);
		params.put("count", count);
		return this.getSqlSession().selectList("LordDao.load", params);
	}
	
	public Integer selectLordCount() {
		return this.getSqlSession().selectOne("LordDao.selectLordCount");
	}

	public List<Lord> selectLordByIds(List<Long> lordIds) {
		return this.getSqlSession().selectList("LordDao.selectLordByIds",lordIds);
	}
}
