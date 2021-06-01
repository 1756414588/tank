/**   
* @Title: ScoreRankHandler.java    
* @Package com.game.message.handler.cs    
* @Description:   
* @author ZhangJun   
* @date 2016年3月18日 下午3:31:36    
* @version V1.0   
*/
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.SeniorMineService;

/**   
 * @ClassName: ScoreRankHandler    
 * @Description:     
 * @author ZhangJun   
 * @date 2016年3月18日 下午3:31:36    
 *         
 */
public class ScoreRankHandler extends ClientHandler{

	/** 
	* Overriding: action    
	* @see com.game.server.ICommand#action()    
	*/
	@Override
	public void action() {
		//Auto-generated method stub
		getService(SeniorMineService.class).scoreRank(this);
	}

}
