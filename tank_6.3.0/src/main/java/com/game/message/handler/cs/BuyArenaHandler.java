/**   
* @Title: BuyArenaHandler.java    
* @Package com.game.message.handler.cs    
* @Description:   
* @author ZhangJun   
* @date 2015年9月9日 下午1:57:25    
* @version V1.0   
*/
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.ArenaService;

/**   
 * @ClassName: BuyArenaHandler    
 * @Description:     
 * @author ZhangJun   
 * @date 2015年9月9日 下午1:57:25    
 *         
 */
public class BuyArenaHandler extends ClientHandler{

	/** 
	* Overriding: action    
	* @see com.game.server.ICommand#action()    
	*/
	@Override
	public void action() {
		//Auto-generated method stub
		getService(ArenaService.class).buyArena(this);
	}

}
