/**   
* @Title: UpPartHandler.java    
* @Package com.game.message.handler.cs    
* @Description:   
* @author ZhangJun   
* @date 2015年8月20日 下午12:29:54    
* @version V1.0   
*/
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb1.UpPartRq;
import com.game.service.PartService;

/**   
 * @ClassName: UpPartHandler    
 * @Description:     
 * @author ZhangJun   
 * @date 2015年8月20日 下午12:29:54    
 *         
 */
public class UpPartHandler extends ClientHandler{

	/** 
	* Overriding: action    
	* @see com.game.server.ICommand#action()    
	*/
	@Override
	public void action() {
		//Auto-generated method stub
		UpPartRq req = msg.getExtension(UpPartRq.ext);
		getService(PartService.class).upPart(req, this);
	}

}
