/**   
* @Title: UpRankHandler.java    
* @Package com.game.message.handler.cs    
* @Description:   
* @author ZhangJun   
* @date 2015年9月3日 下午4:40:42    
* @version V1.0   
*/
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.PlayerService;

/**   
 * @ClassName: UpRankHandler    
 * @Description:     
 * @author ZhangJun   
 * @date 2015年9月3日 下午4:40:42    
 *         
 */
public class UpRankHandler extends ClientHandler{

	/** 
	* Overriding: action    
	* @see com.game.server.ICommand#action()    
	*/
	@Override
	public void action() {
		//Auto-generated method stub
		getService(PlayerService.class).upRank(this);
	}

}
