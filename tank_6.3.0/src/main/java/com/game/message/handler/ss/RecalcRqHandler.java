package com.game.message.handler.ss;

import com.game.message.handler.ServerHandler;
import com.game.server.GameServer;
import com.game.service.GmService;

public class RecalcRqHandler extends ServerHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.server.ICommand#action()
	 */
	@Override
	public void action() {
		//Auto-generated method stub		
		GmService service = GameServer.ac.getBean(GmService.class);
		service.recalcResource();
	}
}
