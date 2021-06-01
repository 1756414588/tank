/**   
* @Title: AttackPosHandler.java    
* @Package com.game.message.handler.cs    
* @Description:   
* @author ZhangJun   
* @date 2015年9月18日 下午5:00:43    
* @version V1.0   
*/
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb2.AttackPosRq;
import com.game.service.WorldService;

/**   
 * @ClassName: AttackPosHandler    
 * @Description:     
 * @author ZhangJun   
 * @date 2015年9月18日 下午5:00:43    
 *         
 */
public class AttackPosHandler extends ClientHandler{

	/** 
	* Overriding: action    
	* @see com.game.server.ICommand#action()    
	*/
	@Override
	public void action() {
		//Auto-generated method stub
		getService(WorldService.class).attackPos(msg.getExtension(AttackPosRq.ext), this);
	}

}
