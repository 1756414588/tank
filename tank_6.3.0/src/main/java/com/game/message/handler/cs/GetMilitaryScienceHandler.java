/**   
* @Title: GetMilitaryScienceHandler.java    
* @Package com.game.message.handler.cs    
* @Description:   
* @author WanYi  
* @date 2016年5月9日 下午5:50:02    
* @version V1.0   
*/
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.MilitaryScienceService;

/**   
 * @ClassName: GetMilitaryScienceHandler    
 * @Description:     
 * @author WanYi   
 * @date 2016年5月9日 下午5:50:02    
 *         
 */
public class GetMilitaryScienceHandler extends ClientHandler {

	/** 
	 * Overriding: action    
	 * @see com.game.server.ICommand#action()    
	 */
	@Override
	public void action() {
		getService(MilitaryScienceService.class).getMilitaryScience(this);
	}

}
