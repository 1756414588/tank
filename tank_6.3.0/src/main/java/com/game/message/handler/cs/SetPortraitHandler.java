/**   
* @Title: SetPortraitHandler.java    
* @Package com.game.message.handler.cs    
* @Description:   
* @author ZhangJun   
* @date 2015年10月14日 下午2:49:39    
* @version V1.0   
*/
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb2.SetPortraitRq;
import com.game.service.PlayerService;

/**   
 * @ClassName: SetPortraitHandler    
 * @Description:     
 * @author ZhangJun   
 * @date 2015年10月14日 下午2:49:39    
 *         
 */
public class SetPortraitHandler extends ClientHandler{

	/** 
	* Overriding: action    
	* @see com.game.server.ICommand#action()    
	*/
	@Override
	public void action() {
		//Auto-generated method stub
		getService(PlayerService.class).setPortrait(msg.getExtension(SetPortraitRq.ext).getPortrait(), this);
	}

}
