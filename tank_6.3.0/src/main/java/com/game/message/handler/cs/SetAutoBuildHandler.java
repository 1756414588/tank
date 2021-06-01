/**   
* @Title: SetAutoBuildHandler.java    
* @Package com.game.message.handler.cs    
* @Description:   
* @author ZhangJun   
* @date 2016年1月22日 下午6:30:23    
* @version V1.0   
*/
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb3.SetAutoBuildRq;
import com.game.service.BuildingService;

/**   
 * @ClassName: SetAutoBuildHandler    
 * @Description:     
 * @author ZhangJun   
 * @date 2016年1月22日 下午6:30:23    
 *         
 */
public class SetAutoBuildHandler extends ClientHandler{

	/** 
	* Overriding: action    
	* @see com.game.server.ICommand#action()    
	*/
	@Override
	public void action() {
		//Auto-generated method stub
		getService(BuildingService.class).setAutoBuild(msg.getExtension(SetAutoBuildRq.ext), this);
	}

}
