package com.game.message.handler.ss;

import com.game.message.handler.ServerHandler;
import com.game.pb.InnerPb.CensusBaseRq;
import com.game.server.GameServer;
import com.game.service.GmToolService;

public class CensusBaseRqHandler extends ServerHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.server.ICommand#action()
	 */
	@Override
	public void action() {
		//Auto-generated method stub
		CensusBaseRq req = msg.getExtension(CensusBaseRq.ext);

		GmToolService toolService = GameServer.ac.getBean(GmToolService.class);
		toolService.censusBase(req, this);
	}
}
