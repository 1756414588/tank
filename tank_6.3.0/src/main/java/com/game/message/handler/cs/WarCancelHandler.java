/**   
* @Title: WarCancelHandler.java    
* @Package com.game.message.handler.cs    
* @Description:   
* @author ZhangJun   
* @date 2015年12月21日 下午5:54:49    
* @version V1.0   
*/
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.WarService;

/**   
 * @ClassName: WarCancelHandler    
 * @Description:     
 * @author ZhangJun   
 * @date 2015年12月21日 下午5:54:49    
 *         
 */
public class WarCancelHandler extends ClientHandler{

	/** 
	* Overriding: action    
	* @see com.game.server.ICommand#action()    
	*/
	@Override
	public void action() {
		//Auto-generated method stub
		getService(WarService.class).warCancel(this);
	}

}
