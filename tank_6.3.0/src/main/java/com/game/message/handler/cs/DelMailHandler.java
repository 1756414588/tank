package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb1.DelMailRq;
import com.game.service.MailService;

public class DelMailHandler extends ClientHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.server.ICommand#action()
	 */
	@Override
	public void action() {
		//Auto-generated method stub
		DelMailRq req = msg.getExtension(DelMailRq.ext);
		getService(MailService.class).delMailRq(req, this);
	}

}
