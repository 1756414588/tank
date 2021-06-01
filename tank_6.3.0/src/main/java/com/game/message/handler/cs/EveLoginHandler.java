package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb3.EveLoginRq;
import com.game.service.SignService;

public class EveLoginHandler extends ClientHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.server.ICommand#action()
	 */
	@Override
	public void action() {
		//Auto-generated method stub
		EveLoginRq req = msg.getExtension(EveLoginRq.ext);
		getService(SignService.class).eveLoginRq(req, this);
	}

}
