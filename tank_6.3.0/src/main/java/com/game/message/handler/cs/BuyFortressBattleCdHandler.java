/**   
* @Title: BuyFortressCDHandler.java    
* @Package com.game.message.handler.cs    
* @Description:   
* @author WanYi  
* @date 2016年6月12日 下午5:39:47    
* @version V1.0   
*/
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.FortressWarService;

/**   
 * @ClassName: BuyFortressCDHandler    
 * @author WanYi   
 * @date 2016年6月12日 下午5:39:47    
 *         
 */
public class BuyFortressBattleCdHandler extends ClientHandler {

	/** 
	 * Overriding: action    
	 * @see com.game.server.ICommand#action()    
	 */
	@Override
	public void action() {
		getService(FortressWarService.class).buyFortressCD(this);
	}

}
