/**   
* @Title: UpCapacityHandler.java    
* @Package com.game.message.handler.cs    
* @Description:   
* @author ZhangJun   
* @date 2015年8月19日 下午2:05:36    
* @version V1.0   
*/
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.EquipService;

/**   
 * @ClassName: UpCapacityHandler    
 * @Description:     
 * @author ZhangJun   
 * @date 2015年8月19日 下午2:05:36    
 *         
 */
public class UpCapacityHandler extends ClientHandler{

	/** 
	* Overriding: action    
	* @see com.game.server.ICommand#action()    
	*/
	@Override
	public void action() {
		//Auto-generated method stub
		getService(EquipService.class).upCapacity(this);
	}

}
