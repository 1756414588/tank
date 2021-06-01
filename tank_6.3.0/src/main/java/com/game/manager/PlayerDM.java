/**   
 * @Title: PlayerDM.java    
 * @Package com.game.manager    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年8月6日 下午1:46:30    
 * @version V1.0   
 */
package com.game.manager;

import com.game.domain.Player;
import com.game.domain.p.Account;

/**
 * @ClassName: PlayerDM
 * @Description: 加载玩家数据接口
 * @author ZhangJun
 * @date 2015年8月6日 下午1:46:30
 * 
 */
public interface PlayerDM {
	/**
	 * 
	 * Method: loadAllPlayer
	 * 
	 * @Description: 加载全部玩家数据
	 * @return void
	 * @throws
	 */
	void loadAllPlayer();

	/**
	 * 
	 * Method: getPlayer
	 * 
	 * @Description: 根据roleId获取Player数据
	 * @param roleId
	 * @return
	 * @return Player
	 * @throws
	 */
	Player getPlayer(Long roleId);

	/**
	 * 
	 * Method: createPlayer
	 * 
	 * @Description: 创建玩家数据
	 * @param account
	 * @return
	 * @return Player
	 * @throws
	 */
	Player createPlayer(Account account);
}
