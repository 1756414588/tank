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
import com.game.domain.p.SmallId;

/**
 * SmallIdDao
* @ClassName: SmallIdDao    
* @Description:     小号
* @author WanYi   
* @date 2016年4月21日 上午10:26:12    
*
 */
public class SmallIdDao extends BaseDao {

	public SmallId selectSmallId(long lordId) {
		return this.getSqlSession().selectOne("SmallIdDao.selectSmallId", lordId);
	}

	public void insertSmallId(SmallId smallId) {
		this.getSqlSession().insert("SmallIdDao.insertSmallId", smallId);
	}

	public List<SmallId> load() {
		List<SmallId> list = new ArrayList<>();
		long curIndex = 0L;
		int count = 1000;
		int pageSize = 0;
		while (true) {
			List<SmallId> page = load(curIndex, count);
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

	private List<SmallId> load(long curIndex, int count) {
		Map<String, Object> params = paramsMap();
		params.put("curIndex", curIndex);
		params.put("count", count);
		return this.getSqlSession().selectList("SmallIdDao.load", params);
	}
	
	public void insertAllNewSmallId(Integer smallLordLv) {
		this.getSqlSession().insert("SmallIdDao.insertAllNewSmallId",smallLordLv);
	}


    public void clearNotFountInAccountTablePlayer(){
        this.getSqlSession().insert("SmallIdDao.clearNotFoundInAccountTablePlayer");
    }

    public void truncateSmallIdTable(){
        this.getSqlSession().update("SmallIdDao.truncateSmallId");
    }
}
