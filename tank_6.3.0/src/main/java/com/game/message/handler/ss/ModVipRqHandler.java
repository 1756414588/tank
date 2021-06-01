package com.game.message.handler.ss;

import com.game.message.handler.ServerHandler;
import com.game.pb.InnerPb.ModVipRq;
import com.game.server.GameServer;
import com.game.service.GmToolService;

public class ModVipRqHandler extends ServerHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.server.ICommand#action()
	 */
	@Override
	public void action() {
		//Auto-generated method stub
		ModVipRq req = msg.getExtension(ModVipRq.ext);
		
		GmToolService toolService = GameServer.ac.getBean(GmToolService.class);
		toolService.modVip(req, this);
	}
}
