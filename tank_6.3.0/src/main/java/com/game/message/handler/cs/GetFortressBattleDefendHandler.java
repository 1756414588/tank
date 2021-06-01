/**   
* @Title: GetFortressBattleDefendHandler.java    
* @Package com.game.service    
* @Description:   
* @author WanYi  
* @date 2016年6月7日 上午11:37:43    
* @version V1.0   
*/
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.FortressWarService;

/**   
 * @ClassName: GetFortressBattleDefendHandler    
 * @Description:     
 * @author WanYi   
 * @date 2016年6月7日 上午11:37:43    
 *         
 */
public class GetFortressBattleDefendHandler extends ClientHandler {

	/** 
	 * Overriding: action    
	 * @see com.game.server.ICommand#action()    
	 */
	@Override
	public void action() {
		getService(FortressWarService.class).getFortressBattleDefend(this);
	}

}
