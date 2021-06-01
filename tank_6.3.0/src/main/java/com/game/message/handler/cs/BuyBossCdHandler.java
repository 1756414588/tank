/**   
* @Title: BuyBossCdHandler.java    
* @Package com.game.message.handler.cs    
* @Description:   
* @author ZhangJun   
* @date 2016年1月5日 下午6:44:11    
* @version V1.0   
*/
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb3.BuyBossCdRq;
import com.game.service.BossService;

/**   
 * @ClassName: BuyBossCdHandler    
 * @Description:     
 * @author ZhangJun   
 * @date 2016年1月5日 下午6:44:11    
 *         
 */
public class BuyBossCdHandler extends ClientHandler{

	/** 
	* Overriding: action    
	* @see com.game.server.ICommand#action()    
	*/
	@Override
	public void action() {
		//Auto-generated method stub
		getService(BossService.class).buyBossCd(msg.getExtension(BuyBossCdRq.ext), this);
	}

}
