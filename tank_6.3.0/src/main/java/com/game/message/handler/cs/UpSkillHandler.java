/**   
* @Title: UpSkillHandler.java    
* @Package com.game.message.handler.cs    
* @Description:   
* @author ZhangJun   
* @date 2015年9月4日 下午2:36:07    
* @version V1.0   
*/
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb1.UpSkillRq;
import com.game.service.PlayerService;

/**   
 * @ClassName: UpSkillHandler    
 * @Description:     
 * @author ZhangJun   
 * @date 2015年9月4日 下午2:36:07    
 *         
 */
public class UpSkillHandler extends ClientHandler{

	/** 
	* Overriding: action    
	* @see com.game.server.ICommand#action()    
	*/
	@Override
	public void action() {
		//Auto-generated method stub
		UpSkillRq req = msg.getExtension(UpSkillRq.ext);
		getService(PlayerService.class).upSkill(req.getId(), this);
	}

}
