/**   
* @Title: GetFortressBattleParty.java    
* @Package com.game.message.handler.cs    
* @Description:   
* @author WanYi  
* @date 2016年5月30日 下午4:24:30    
* @version V1.0   
*/
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.FortressWarService;

/**   
 * @ClassName: GetFortressBattleParty    
 * @Description: 获取参加要塞战的军团 
 * @author WanYi   
 * @date 2016年5月30日 下午4:24:30    
 *         
 */
public class GetFortressBattlePartyHandler extends ClientHandler {

	/** 
	 * Overriding: action    
	 * @see com.game.server.ICommand#action()    
	 */
	@Override
	public void action() {
		getService(FortressWarService.class).getFortressBattleParty(this);
	}

}
