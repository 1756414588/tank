/**   
* @Title: RetreatAidHandler.java    
* @Package com.game.message.handler.cs    
* @Description:   
* @author ZhangJun   
* @date 2015年9月25日 下午3:07:00    
* @version V1.0   
*/
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb2.RetreatAidRq;
import com.game.service.WorldService;

/**   
 * @ClassName: RetreatAidHandler    
 * @Description:     
 * @author ZhangJun   
 * @date 2015年9月25日 下午3:07:00    
 *         
 */
public class RetreatAidHandler extends ClientHandler{

	/** 
	* Overriding: action    
	* @see com.game.server.ICommand#action()    
	*/
	@Override
	public void action() {
		//Auto-generated method stub
		getService(WorldService.class).retreatAid(msg.getExtension(RetreatAidRq.ext), this);
	}

}
