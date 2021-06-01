/**   
* @Title: BuyFameHandler.java    
* @Package com.game.message.handler.cs    
* @Description:   
* @author ZhangJun   
* @date 2015年9月3日 下午4:41:26    
* @version V1.0   
*/
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb1.BuyFameRq;
import com.game.service.PlayerService;

/**   
 * @ClassName: BuyFameHandler    
 * @Description:     
 * @author ZhangJun   
 * @date 2015年9月3日 下午4:41:26    
 *         
 */
public class BuyFameHandler extends ClientHandler{

	/** 
	* Overriding: action    
	* @see com.game.server.ICommand#action()    
	*/
	@Override
	public void action() {
		//Auto-generated method stub
		BuyFameRq req = msg.getExtension(BuyFameRq.ext);
		getService(PlayerService.class).buyFame(req.getType(), this);
	}

}
