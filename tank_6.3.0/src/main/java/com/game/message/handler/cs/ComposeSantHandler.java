/**   
* @Title: ComposeSantHandler.java    
* @Package com.game.message.handler.cs    
* @Description:   
* @author ZhangJun   
* @date 2016年1月5日 下午6:46:55    
* @version V1.0   
*/
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb3.ComposeSantRq;
import com.game.service.PropService;

/**   
 * @ClassName: ComposeSantHandler    
 * @Description:     
 * @author ZhangJun   
 * @date 2016年1月5日 下午6:46:55    
 *         
 */
public class ComposeSantHandler extends ClientHandler{

	/** 
	* Overriding: action    
	* @see com.game.server.ICommand#action()    
	*/
	@Override
	public void action() {
		//Auto-generated method stub
		getService(PropService.class).composeSant(msg.getExtension(ComposeSantRq.ext), this);
	}

}
