/**   
* @Title: WarRegHandler.java    
* @Package com.game.message.handler.cs    
* @Description:   
* @author ZhangJun   
* @date 2015年12月14日 下午5:08:42    
* @version V1.0   
*/
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb3.WarRegRq;
import com.game.service.WarService;

/**   
 * @ClassName: WarRegHandler    
 * @Description:     
 * @author ZhangJun   
 * @date 2015年12月14日 下午5:08:42    
 *         
 */
public class WarRegHandler extends ClientHandler{

	/** 
	* Overriding: action    
	* @see com.game.server.ICommand#action()    
	*/
	@Override
	public void action() {
		//Auto-generated method stub
		getService(WarService.class).warReg(msg.getExtension(WarRegRq.ext), this);
	}

}
