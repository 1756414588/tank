/**   
 * @Title: GetEquipHandler.java    
 * @Package com.game.message.handler.cs    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年8月18日 下午2:41:51    
 * @version V1.0   
 */
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb1.AddFriendRq;
import com.game.service.FriendService;

/**
 * @ClassName: GetEquipHandler
 * @Description: 
 * @author ZhangJun
 * @date 2015年8月18日 下午2:41:51
 * 
 */
public class AddFriendHandler extends ClientHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.server.ICommand#action()
	 */
	@Override
	public void action() {
		//Auto-generated method stub
		AddFriendRq req = msg.getExtension(AddFriendRq.ext);
		getService(FriendService.class).addFriend(req, this);
	}

}
