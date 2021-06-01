/**   
* @Title: BuyArenaCdHandler.java    
* @Package com.game.message.handler.cs    
* @Description:   
* @author ZhangJun   
* @date 2016年1月19日 上午11:01:33    
* @version V1.0   
*/
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb3.BuyArenaCdRq;
import com.game.service.ArenaService;

/**   
 * @ClassName: BuyArenaCdHandler    
 * @Description:     
 * @author ZhangJun   
 * @date 2016年1月19日 上午11:01:33    
 *         
 */
public class BuyArenaCdHandler extends ClientHandler{

	/** 
	* Overriding: action    
	* @see com.game.server.ICommand#action()    
	*/
	@Override
	public void action() {
		//Auto-generated method stub
		getService(ArenaService.class).buyArenaCd(msg.getExtension(BuyArenaCdRq.ext), this);
	}

}
