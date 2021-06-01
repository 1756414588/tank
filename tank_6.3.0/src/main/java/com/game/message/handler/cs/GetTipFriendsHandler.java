package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.FriendService;

public class GetTipFriendsHandler extends ClientHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.server.ICommand#action()
	 */
	@Override
	public void action() {
		//Auto-generated method stub
		getService(FriendService.class).getTipFriendsRq(this);
	}

}
