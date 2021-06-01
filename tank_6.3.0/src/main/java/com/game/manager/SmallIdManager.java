/**   
* @Title: SmallIdManager.java    
* @Package com.game.manager    
* @Description:   
* @author WanYi  
* @date 2016年4月21日 上午10:40:12    
* @version V1.0   
*/
package com.game.manager;

import com.game.dao.impl.p.SmallIdDao;
import com.game.domain.p.SmallId;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**   剁小号管理
 * @ClassName: SmallIdManager    
 * @Description:     
 * @author WanYi   
 * @date 2016年4月21日 上午10:40:12    
 *         
 */
@Component
public class SmallIdManager {
	@Autowired
	private SmallIdDao smallDao;
	
	private Map<Long,SmallId> smallIdCache = new HashMap<>();
	
//	@PostConstruct
	public void init() {
		List<SmallId> list = smallDao.load();
		for (SmallId smallId : list) {
			smallIdCache.put(smallId.getLordId(), smallId);
		}
	}
	
	/**
	 * 判断是否小号
	* Method: isSmallId    
	* @Description:     
	* @param lordId
	* @return    
	* @return boolean    
	* @throws
	 */
	public boolean isSmallId(long lordId) {
		return lordId ==0 || smallIdCache.containsKey(lordId);
	}
}
