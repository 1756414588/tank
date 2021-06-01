package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb1.SendMailRq;
import com.game.service.MailService;

public class SendMailHandler extends ClientHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.server.ICommand#action()
	 */
	@Override
	public void action() {
		//Auto-generated method stub
		SendMailRq req = msg.getExtension(SendMailRq.ext);
		getService(MailService.class).sendMailRq(req, this);
	}

}
