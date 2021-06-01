/**   
* @Title: ScoreAwardHandler.java    
* @Package com.game.message.handler.cs    
* @Description:   
* @author ZhangJun   
* @date 2016年3月19日 下午3:35:53    
* @version V1.0   
*/
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.SeniorMineService;

/**   
 * @ClassName: ScoreAwardHandler    
 * @Description:     
 * @author ZhangJun   
 * @date 2016年3月19日 下午3:35:53    
 *         
 */
public class ScoreAwardHandler extends ClientHandler{

	/** 
	* Overriding: action    
	* @see com.game.server.ICommand#action()    
	*/
	@Override
	public void action() {
		//Auto-generated method stub
		getService(SeniorMineService.class).scoreAward(this);
	}

}
