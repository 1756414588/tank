package com.game.message.handler.ss;

import com.game.message.handler.ServerHandler;
import com.game.pb.InnerPb.SendToMailRq;
import com.game.server.GameServer;
import com.game.service.GmToolService;

public class SendToMailRqHandler extends ServerHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.server.ICommand#action()
	 */
	@Override
	public void action() {
		//Auto-generated method stub
		SendToMailRq req = msg.getExtension(SendToMailRq.ext);

		GmToolService toolService = GameServer.ac.getBean(GmToolService.class);
		toolService.sendMail(req, this);

	}
}
