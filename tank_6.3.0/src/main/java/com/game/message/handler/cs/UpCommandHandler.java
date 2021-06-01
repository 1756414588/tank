/**   
* @Title: UpCommandHandler.java    
* @Package com.game.message.handler.cs    
* @Description:   
* @author ZhangJun   
* @date 2015年9月3日 下午4:41:01    
* @version V1.0   
*/
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb1.UpCommandRq;
import com.game.service.PlayerService;

/**   
 * @ClassName: UpCommandHandler    
 * @Description:     
 * @author ZhangJun   
 * @date 2015年9月3日 下午4:41:01    
 *         
 */
public class UpCommandHandler extends ClientHandler{

	/** 
	* Overriding: action    
	* @see com.game.server.ICommand#action()    
	*/
	@Override
	public void action() {
		//Auto-generated method stub
		UpCommandRq req = msg.getExtension(UpCommandRq.ext);
		getService(PlayerService.class).upCommand(req.getUseGold(), this);
	}

}
