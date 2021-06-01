package com.game.message.handler.ss;

import com.game.message.handler.ServerHandler;
import com.game.pb.InnerPb.ModPropRq;
import com.game.server.GameServer;
import com.game.service.GmToolService;

public class ModPropRqHandler extends ServerHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.server.ICommand#action()
	 */
	@Override
	public void action() {
		//Auto-generated method stub
		ModPropRq req = msg.getExtension(ModPropRq.ext);
		
		GmToolService toolService = GameServer.ac.getBean(GmToolService.class);
		toolService.modProp(req, this);
	}
}
