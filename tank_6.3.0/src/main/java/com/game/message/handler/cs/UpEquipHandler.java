/**   
* @Title: UpEquipHandler.java    
* @Package com.game.message.handler.cs    
* @Description:   
* @author ZhangJun   
* @date 2015年8月18日 下午3:53:45    
* @version V1.0   
*/
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb1.UpEquipRq;
import com.game.service.EquipService;

/**   
 * @ClassName: UpEquipHandler    
 * @Description:     
 * @author ZhangJun   
 * @date 2015年8月18日 下午3:53:45    
 *         
 */
public class UpEquipHandler extends ClientHandler{

	/** 
	* Overriding: action    
	* @see com.game.server.ICommand#action()    
	*/
	@Override
	public void action() {
		//Auto-generated method stub
		UpEquipRq req = msg.getExtension(UpEquipRq.ext);
		getService(EquipService.class).upEquip(req, this);
	}
}
