/**   
* @Title: ExplodeChipHandler.java    
* @Package com.game.message.handler.cs    
* @Description:   
* @author ZhangJun   
* @date 2015年8月20日 下午12:26:55    
* @version V1.0   
*/
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb1.ExplodeChipRq;
import com.game.service.PartService;

/**   
 * @ClassName: ExplodeChipHandler    
 * @Description:     
 * @author ZhangJun   
 * @date 2015年8月20日 下午12:26:55    
 *         
 */
public class ExplodeChipHandler extends ClientHandler{

	/** 
	* Overriding: action    
	* @see com.game.server.ICommand#action()    
	*/
	@Override
	public void action() {
		//Auto-generated method stub
		ExplodeChipRq req = msg.getExtension(ExplodeChipRq.ext);
		getService(PartService.class).explodeChip(req, this);
	}

}
