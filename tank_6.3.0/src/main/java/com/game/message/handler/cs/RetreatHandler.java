/**   
* @Title: RetreatHandler.java    
* @Package com.game.message.handler.cs    
* @Description:   
* @author ZhangJun   
* @date 2015年9月18日 下午5:47:59    
* @version V1.0   
*/
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb2.RetreatRq;
import com.game.service.WorldService;

/**   
 * @ClassName: RetreatHandler    
 * @Description:     
 * @author ZhangJun   
 * @date 2015年9月18日 下午5:47:59    
 *         
 */
public class RetreatHandler extends ClientHandler{

	/** 
	* Overriding: action    
	* @see com.game.server.ICommand#action()    
	*/
	@Override
	public void action() {
		//Auto-generated method stub
		getService(WorldService.class).retreat(msg.getExtension(RetreatRq.ext).getKeyId(), this);
	}

}
