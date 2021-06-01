package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.SignService;

public class GetSignHandler extends ClientHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.server.ICommand#action()
	 */
	@Override
	public void action() {
		//Auto-generated method stub
		getService(SignService.class).getSignRq(this);
	}

}
