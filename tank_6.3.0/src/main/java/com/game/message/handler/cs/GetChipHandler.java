/**   
* @Title: GetChipHandler.java    
* @Package com.game.message.handler.cs    
* @Description:   
* @author ZhangJun   
* @date 2015年8月20日 上午10:27:33    
* @version V1.0   
*/
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.PartService;

/**   
 * @ClassName: GetChipHandler    
 * @Description:     
 * @author ZhangJun   
 * @date 2015年8月20日 上午10:27:33    
 *         
 */
public class GetChipHandler extends ClientHandler{

	/** 
	* Overriding: action    
	* @see com.game.server.ICommand#action()    
	*/
	@Override
	public void action() {
		//Auto-generated method stub
		getService(PartService.class).getChip(this);
	}

}
