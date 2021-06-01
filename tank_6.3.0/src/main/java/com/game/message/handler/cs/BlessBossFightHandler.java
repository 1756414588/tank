/**   
* @Title: BlessBossFightHandler.java    
* @Package com.game.message.handler.cs    
* @Description:   
* @author ZhangJun   
* @date 2016年1月5日 下午6:40:03    
* @version V1.0   
*/
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb3.BlessBossFightRq;
import com.game.service.BossService;

/**   
 * @ClassName: BlessBossFightHandler    
 * @Description:     
 * @author ZhangJun   
 * @date 2016年1月5日 下午6:40:03    
 *         
 */
public class BlessBossFightHandler extends ClientHandler{

	/** 
	* Overriding: action    
	* @see com.game.server.ICommand#action()    
	*/
	@Override
	public void action() {
		//Auto-generated method stub
		getService(BossService.class).blessBossFight(msg.getExtension(BlessBossFightRq.ext), this);
	}

}
