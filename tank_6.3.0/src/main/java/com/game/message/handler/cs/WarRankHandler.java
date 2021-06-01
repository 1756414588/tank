/**   
* @Title: WarRankHandler.java    
* @Package com.game.message.handler.cs    
* @Description:   
* @author ZhangJun   
* @date 2015年12月21日 下午6:09:29    
* @version V1.0   
*/
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb3.WarRankRq;
import com.game.service.WarService;

/**   
 * @ClassName: WarRankHandler    
 * @Description:     
 * @author ZhangJun   
 * @date 2015年12月21日 下午6:09:29    
 *         
 */
public class WarRankHandler extends ClientHandler{

	/** 
	* Overriding: action    
	* @see com.game.server.ICommand#action()    
	*/
	@Override
	public void action() {
		//Auto-generated method stub
		getService(WarService.class).warRank(msg.getExtension(WarRankRq.ext), this);
	}

}
