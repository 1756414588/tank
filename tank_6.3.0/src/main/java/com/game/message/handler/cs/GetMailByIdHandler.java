package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb2.GetMailByIdRq;
import com.game.service.MailService;

public class GetMailByIdHandler extends ClientHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.server.ICommand#action()
	 */
	@Override
	public void action() {
		//Auto-generated method stub
		GetMailByIdRq req = msg.getExtension(GetMailByIdRq.ext);
		getService(MailService.class).getMailById(req, this);
	}

}
