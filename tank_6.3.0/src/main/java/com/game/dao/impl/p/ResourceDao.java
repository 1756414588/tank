/**   
 * @Title: ResourceDao.java    
 * @Package com.game.dao.impl    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年7月17日 下午4:43:12    
 * @version V1.0   
 */
package com.game.dao.impl.p;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import com.game.dao.BaseDao;
import com.game.domain.p.Resource;

/**
 * @ClassName: ResourceDao
 * @Description: 资源相关
 * @author ZhangJun
 * @date 2015年7月17日 下午4:43:12
 * 
 */
public class ResourceDao extends BaseDao {
	public Resource selectResource(long lordId) {
		return this.getSqlSession().selectOne("ResourceDao.selectResource", lordId);
	}

	public void updateResource(Resource resource) {
		this.getSqlSession().update("ResourceDao.updateResource", resource);
	}
	
//	public void updateOut(Resource resource) {
//		this.getSqlSession().update("ResourceDao.updateOut", resource);
//	}
//	
//	public void updateMax(Resource resource) {
//		this.getSqlSession().update("ResourceDao.updateMax", resource);
//	}
//	
//	public void updateMaxAndOut(Resource resource) {
//		this.getSqlSession().update("ResourceDao.updateMaxAndOut", resource);
//	}
//	
//	public void updateTime(Resource resource) {
//		this.getSqlSession().update("ResourceDao.updateTime", resource);
//	}

	public void insertResource(Resource resource) {
		this.getSqlSession().insert("ResourceDao.insertResource", resource);
	}
	
	public int insertFullResource(Resource resource) {
		return this.getSqlSession().insert("ResourceDao.insertFullResource", resource);
	}
	
	public List<Resource> load() {
		List<Resource> list = new ArrayList<>();
		long curIndex = 0L;
		int count = 1000;
		int pageSize = 0;
		while (true) {
			List<Resource> page = load(curIndex, count);
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

	private List<Resource> load(long curIndex, int count) {
		Map<String, Object> params = paramsMap();
		params.put("curIndex", curIndex);
		params.put("count", count);
		return this.getSqlSession().selectList("ResourceDao.load", params);
	}

}
