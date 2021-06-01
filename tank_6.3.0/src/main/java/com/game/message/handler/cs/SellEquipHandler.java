/**   
* @Title: SellEquipHandler.java    
* @Package com.game.message.handler.cs    
* @Description:   
* @author ZhangJun   
* @date 2015年8月18日 下午3:33:19    
* @version V1.0   
*/
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb1.SellEquipRq;
import com.game.service.EquipService;

/**   
 * @ClassName: SellEquipHandler    
 * @Description:     
 * @author ZhangJun   
 * @date 2015年8月18日 下午3:33:19    
 *         
 */
public class SellEquipHandler extends ClientHandler{

	/** 
	* Overriding: action    
	* @see com.game.server.ICommand#action()    
	*/
	@Override
	public void action() {
		//Auto-generated method stub
		SellEquipRq req = msg.getExtension(SellEquipRq.ext);
		getService(EquipService.class).sellEquip(req, this);
	}

}
