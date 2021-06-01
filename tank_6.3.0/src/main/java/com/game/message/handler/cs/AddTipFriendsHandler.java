package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb3.AddTipFriendsRq;
import com.game.service.FriendService;

public class AddTipFriendsHandler extends ClientHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.server.ICommand#action()
	 */
	@Override
	public void action() {
		//Auto-generated method stub
		AddTipFriendsRq req = msg.getExtension(AddTipFriendsRq.ext);
		getService(FriendService.class).addTipFriendsRq(req, this);
	}

}
