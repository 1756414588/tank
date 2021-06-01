package com.game.message.handler.ss;

import com.game.message.handler.ServerHandler;
import com.game.pb.InnerPb.ModNameRq;
import com.game.server.GameServer;
import com.game.service.GmToolService;

public class ModNameRqHandler extends ServerHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.server.ICommand#action()
	 */
	@Override
	public void action() {
		//Auto-generated method stub
		ModNameRq req = msg.getExtension(ModNameRq.ext);
		
		GmToolService toolService = GameServer.ac.getBean(GmToolService.class);
		toolService.modName(req, this);
	}
}
