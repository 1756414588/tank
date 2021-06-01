/**   
* @Title: ClickFameHandler.java    
* @Package com.game.message.handler.cs    
* @Description:   
* @author ZhangJun   
* @date 2015年9月4日 上午11:12:15    
* @version V1.0   
*/
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.PlayerService;

/**   
 * @ClassName: ClickFameHandler    
 * @Description:     
 * @author ZhangJun   
 * @date 2015年9月4日 上午11:12:15    
 *         
 */
public class ClickFameHandler extends ClientHandler{

	/** 
	* Overriding: action    
	* @see com.game.server.ICommand#action()    
	*/
	@Override
	public void action() {
		//Auto-generated method stub
		getService(PlayerService.class).clickFame(this);
	}

}
