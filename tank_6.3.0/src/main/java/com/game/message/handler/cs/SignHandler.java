package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb2.SignRq;
import com.game.service.SignService;

public class SignHandler extends ClientHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.server.ICommand#action()
	 */
	@Override
	public void action() {
		SignRq req = msg.getExtension(SignRq.ext);
		getService(SignService.class).signRq(req, this);
	}

}
