/**   
* @Title: HeartHandler.java    
* @Package com.game.message.handler.cs    
* @Description:   
* @author ZhangJun   
* @date 2015年8月12日 下午7:30:48    
* @version V1.0   
*/
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb1.HeartRs;

/**   
 * @ClassName: HeartHandler    
 * @Description:     
 * @author ZhangJun   
 * @date 2015年8月12日 下午7:30:48    
 *         
 */
public class HeartHandler extends ClientHandler{

	/** 
	* Overriding: action    
	* @see com.game.server.ICommand#action()    
	*/
	@Override
	public void action() {
		sendMsgToPlayer(HeartRs.ext, HeartRs.newBuilder().build());
	}

}
