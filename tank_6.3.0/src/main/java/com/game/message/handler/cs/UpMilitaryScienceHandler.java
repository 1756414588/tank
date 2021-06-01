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
import com.game.pb.GamePb4.UpMilitaryScienceRq;
import com.game.service.MilitaryScienceService;

/** 升级军工科技
 * @ClassName: UpMilitaryScienceHandler    
 * @Description:     
 * @author WanYi   
 * @date 2016年5月10日 上午10:06:50    
 *         
 */
public class UpMilitaryScienceHandler extends ClientHandler {

	/** 
	 * Overriding: action    
	 * @see com.game.server.ICommand#action()    
	 */
	@Override
	public void action() {
		UpMilitaryScienceRq req = msg.getExtension(UpMilitaryScienceRq.ext);
		getService(MilitaryScienceService.class).upMilitaryScience(req,this);
	}

}
