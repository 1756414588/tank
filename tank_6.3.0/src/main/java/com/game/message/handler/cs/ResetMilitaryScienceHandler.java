/**   
* @Title: UpMilitaryScienceHandler.java    
* @Package com.game.message.handler.cs    
* @Description:   
* @author WanYi  
* @date 2016年5月10日 上午10:06:50    
* @version V1.0   
*/
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6;
import com.game.service.MilitaryScienceService;

/** 军工科技重置
 * @ClassName: UpMilitaryScienceHandler    
 * @Description:     
 * @author WanYi   
 * @date 2016年5月10日 上午10:06:50    
 *         
 */
public class ResetMilitaryScienceHandler extends ClientHandler {

	/** 
	 * Overriding: action    
	 * @see com.game.server.ICommand#action()    
	 */
	@Override
	public void action() {
		GamePb6.ResetMilitaryScienceRq req = msg.getExtension(GamePb6.ResetMilitaryScienceRq.ext);
		getService(MilitaryScienceService.class).resetMilitaryScience(req,this);
	}

}
