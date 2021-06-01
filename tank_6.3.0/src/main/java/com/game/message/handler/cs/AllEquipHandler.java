/**   
* @Title: AllEquipHandler.java    
* @Package com.game.message.handler.cs    
* @Description:   
* @author ZhangJun   
* @date 2015年8月19日 下午12:32:41    
* @version V1.0   
*/
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb1.AllEquipRq;
import com.game.service.EquipService;

/**   
 * @ClassName: AllEquipHandler    
 * @Description:     
 * @author ZhangJun   
 * @date 2015年8月19日 下午12:32:41    
 *         
 */
public class AllEquipHandler extends ClientHandler{

	/** 
	* Overriding: action    
	* @see com.game.server.ICommand#action()    
	*/
	@Override
	public void action() {
		//Auto-generated method stub
		AllEquipRq req = msg.getExtension(AllEquipRq.ext);
		getService(EquipService.class).allEquip(req, this);
	}

}
