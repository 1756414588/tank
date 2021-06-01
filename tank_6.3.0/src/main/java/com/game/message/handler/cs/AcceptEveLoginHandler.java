package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.SignService;

public class AcceptEveLoginHandler extends ClientHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.server.ICommand#action()
	 */
	@Override
	public void action() {
		getService(SignService.class).acceptEveLoginRq(this);
	}

}
