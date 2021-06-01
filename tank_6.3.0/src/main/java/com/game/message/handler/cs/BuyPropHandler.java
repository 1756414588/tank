/**   
* @Title: BuyPropHandler.java    
* @Package com.game.message.handler.cs    
* @Description:   
* @author ZhangJun   
* @date 2015年8月14日 下午2:50:08    
* @version V1.0   
*/
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb1.BuyPropRq;
import com.game.service.PropService;

/**   
 * @ClassName: BuyPropHandler    
 * @Description:     
 * @author ZhangJun   
 * @date 2015年8月14日 下午2:50:08    
 *         
 */
public class BuyPropHandler extends ClientHandler{

	/** 
	* Overriding: action    
	* @see com.game.server.ICommand#action()    
	*/
	@Override
	public void action() {
		//Auto-generated method stub
		BuyPropRq req = msg.getExtension(BuyPropRq.ext);
		getService(PropService.class).buyProp(req, this);
	}

}
