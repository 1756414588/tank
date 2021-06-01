/**   
* @Title: OnEquipHandler.java    
* @Package com.game.message.handler.cs    
* @Description:   
* @author ZhangJun   
* @date 2015年8月18日 下午5:19:58    
* @version V1.0   
*/
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb1.OnEquipRq;
import com.game.service.EquipService;

/**   
 * @ClassName: OnEquipHandler    
 * @Description:     
 * @author ZhangJun   
 * @date 2015年8月18日 下午5:19:58    
 *         
 */
public class OnEquipHandler extends ClientHandler{

	/** 
	* Overriding: action    
	* @see com.game.server.ICommand#action()    
	*/
	@Override
	public void action() {
		//Auto-generated method stub
		OnEquipRq req = msg.getExtension(OnEquipRq.ext);
		getService(EquipService.class).onEquip(req, this);
	}

}
