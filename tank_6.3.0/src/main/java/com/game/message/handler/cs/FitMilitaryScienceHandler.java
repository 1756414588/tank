/**   
* @Title: FitMilitaryScienceHandler.java    
* @Package com.game.service    
* @Description:   
* @author WanYi  
* @date 2016年5月10日 下午3:37:35    
* @version V1.0   
*/
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb4.FitMilitaryScienceRq;
import com.game.service.MilitaryScienceService;

/**   
 * @ClassName: FitMilitaryScienceHandler    
 * @Description: 装配或卸下军工科技  
 * @author WanYi   
 * @date 2016年5月10日 下午3:37:35    
 *         
 */
public class FitMilitaryScienceHandler extends ClientHandler {

	/** 
	 * Overriding: action    
	 * @see com.game.server.ICommand#action()    
	 */
	@Override
	public void action() {
		getService(MilitaryScienceService.class).fitMilitaryScience(msg.getExtension(FitMilitaryScienceRq.ext), this);
	}

}
