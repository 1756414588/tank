/**   
* @Title: GetWarFightHandler.java    
* @Package com.game.message.handler.cs    
* @Description:   
* @author ZhangJun   
* @date 2015年12月21日 下午7:01:24    
* @version V1.0   
*/
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb3.GetWarFightRq;
import com.game.service.WarService;

/**   
 * @ClassName: GetWarFightHandler    
 * @Description:     
 * @author ZhangJun   
 * @date 2015年12月21日 下午7:01:24    
 *         
 */
public class GetWarFightHandler extends ClientHandler{

	/** 
	* Overriding: action    
	* @see com.game.server.ICommand#action()    
	*/
	@Override
	public void action() {
		//Auto-generated method stub
		getService(WarService.class).getWarFight(msg.getExtension(GetWarFightRq.ext), this);
	}

}
