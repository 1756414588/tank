/**   
* @Title: GetBossHurtRankHandler.java    
* @Package com.game.message.handler.cs    
* @Description:   
* @author ZhangJun   
* @date 2016年1月5日 下午6:35:37    
* @version V1.0   
*/
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.BossService;

/**   
 * @ClassName: GetBossHurtRankHandler    
 * @Description:     
 * @author ZhangJun   
 * @date 2016年1月5日 下午6:35:37    
 *         
 */
public class GetBossHurtRankHandler extends ClientHandler{

	/** 
	* Overriding: action    
	* @see com.game.server.ICommand#action()    
	*/
	@Override
	public void action() {
		//Auto-generated method stub
		getService(BossService.class).getBossHurtRank(this);
	}

}
