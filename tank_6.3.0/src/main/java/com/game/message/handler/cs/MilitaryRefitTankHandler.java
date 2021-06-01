/**   
* @Title: MilitaryRefitTankHandler.java    
* @Package com.game.message.handler.cs    
* @Description:   
* @author WanYi  
* @date 2016年5月11日 上午11:39:23    
* @version V1.0   
*/
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb4.MilitaryRefitTankRq;
import com.game.service.MilitaryScienceService;

/**   
 * @ClassName: MilitaryRefitTankHandler    
 * @Description: 军工科技改造  
 * @author WanYi   
 * @date 2016年5月11日 上午11:39:23    
 *         
 */
public class MilitaryRefitTankHandler extends ClientHandler {

	/** 
	 * Overriding: action    
	 * @see com.game.server.ICommand#action()    
	 */
	@Override
	public void action() {
		getService(MilitaryScienceService.class).militaryRefitTankRq(msg.getExtension(MilitaryRefitTankRq.ext),this);
	}

}
