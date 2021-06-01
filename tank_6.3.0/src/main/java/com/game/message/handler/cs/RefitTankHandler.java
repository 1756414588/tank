/**   
* @Title: RefitTankHandler.java    
* @Package com.game.message.handler.cs    
* @Description:   
* @author ZhangJun   
* @date 2015年8月17日 下午5:30:08    
* @version V1.0   
*/
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb1.RefitTankRq;
import com.game.service.ArmyService;

/**   
 * @ClassName: RefitTankHandler    
 * @Description:     
 * @author ZhangJun   
 * @date 2015年8月17日 下午5:30:08    
 *         
 */
public class RefitTankHandler extends ClientHandler{

	/** 
	* Overriding: action    
	* @see com.game.server.ICommand#action()    
	*/
	@Override
	public void action() {
		//Auto-generated method stub
		RefitTankRq req = msg.getExtension(RefitTankRq.ext);
		getService(ArmyService.class).refitTank(req, this);
	}

}
