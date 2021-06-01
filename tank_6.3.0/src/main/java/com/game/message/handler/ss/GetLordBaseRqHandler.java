package com.game.message.handler.ss;

import com.game.message.handler.ServerHandler;
import com.game.pb.InnerPb.GetLordBaseRq;
import com.game.server.GameServer;
import com.game.service.GmToolService;

public class GetLordBaseRqHandler extends ServerHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.server.ICommand#action()
	 */
	@Override
	public void action() {
		//Auto-generated method stub
		GetLordBaseRq req = msg.getExtension(GetLordBaseRq.ext);

		GmToolService toolService = GameServer.ac.getBean(GmToolService.class);
		toolService.getLordBase(req, this);
	}
}
