/**   
* @Title: BuyBuildHandler.java    
* @Package com.game.message.handler.cs    
* @Description:   
* @author ZhangJun   
* @date 2015年10月21日 下午4:45:12    
* @version V1.0   
*/
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.PlayerService;

/**   
 * @ClassName: BuyBuildHandler    
 * @Description:     
 * @author ZhangJun   
 * @date 2015年10月21日 下午4:45:12    
 *         
 */
public class BuyBuildHandler extends ClientHandler{

	/** 
	* Overriding: action    
	* @see com.game.server.ICommand#action()    
	*/
	@Override
	public void action() {
		//Auto-generated method stub
		getService(PlayerService.class).buyBuild(this);
	}

}
