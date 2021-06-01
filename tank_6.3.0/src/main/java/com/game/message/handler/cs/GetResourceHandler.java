/**   
* @Title: GetResourceHandler.java    
* @Package com.game.message.handler.cs    
* @Description:   
* @author ZhangJun   
* @date 2015年8月10日 下午2:17:20    
* @version V1.0   
*/
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.PlayerService;

/**   
 * @ClassName: GetResourceHandler    
 * @Description:     
 * @author ZhangJun   
 * @date 2015年8月10日 下午2:17:20    
 *         
 */
public class GetResourceHandler extends ClientHandler{

	/** 
	* Overriding: action    
	* @see com.game.message.handler.Handler#action()    
	*/
	@Override
	public void action() {
		//Auto-generated method stub
		PlayerService playerService = getService(PlayerService.class);
		playerService.getResource(this);
	}

}
