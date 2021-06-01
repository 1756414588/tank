/**   
* @Title: PartyScoreAwardHandler.java    
* @Package com.game.message.handler.cs    
* @Description:   
* @author ZhangJun   
* @date 2016年3月19日 下午3:36:37    
* @version V1.0   
*/
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.SeniorMineService;

/**   
 * @ClassName: PartyScoreAwardHandler    
 * @Description:     
 * @author ZhangJun   
 * @date 2016年3月19日 下午3:36:37    
 *         
 */
public class PartyScoreAwardHandler extends ClientHandler{

	/** 
	* Overriding: action    
	* @see com.game.server.ICommand#action()    
	*/
	@Override
	public void action() {
		//Auto-generated method stub
		getService(SeniorMineService.class).partyScoreAward(this);
	}

}
