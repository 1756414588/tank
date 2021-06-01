package com.game.message.handler.ss;

import com.game.message.handler.ServerHandler;
import com.game.pb.InnerPb.ForbiddenRq;
import com.game.server.GameServer;
import com.game.service.GmToolService;

public class ForbiddenRqHandler extends ServerHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.server.ICommand#action()
	 */
	@Override
	public void action() {
		//Auto-generated method stub
		ForbiddenRq req = msg.getExtension(ForbiddenRq.ext);
		
		GmToolService toolService = GameServer.ac.getBean(GmToolService.class);
		toolService.forbidden(req, this);
	}
}
