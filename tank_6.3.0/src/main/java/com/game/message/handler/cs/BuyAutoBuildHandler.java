/**   
* @Title: BuyAutoBuildHandler.java    
* @Package com.game.message.handler.cs    
* @Description:   
* @author ZhangJun   
* @date 2016年1月22日 下午6:28:59    
* @version V1.0   
*/
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.BuildingService;

/**   
 * @ClassName: BuyAutoBuildHandler    
 * @Description:     
 * @author ZhangJun   
 * @date 2016年1月22日 下午6:28:59    
 *         
 */
public class BuyAutoBuildHandler extends ClientHandler{

	/** 
	* Overriding: action    
	* @see com.game.server.ICommand#action()    
	*/
	@Override
	public void action() {
		//Auto-generated method stub
		getService(BuildingService.class).buyAutoBuild(this);
	}

}
