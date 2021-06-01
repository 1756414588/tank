package com.game.message.handler.ss;

import com.game.message.handler.ServerHandler;
import com.game.pb.InnerPb.NoticeRq;
import com.game.server.GameServer;
import com.game.service.GmToolService;

public class NoticeRqHandler extends ServerHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.server.ICommand#action()
	 */
	@Override
	public void action() {
		//Auto-generated method stub
		NoticeRq req = msg.getExtension(NoticeRq.ext);

		GmToolService toolService = GameServer.ac.getBean(GmToolService.class);
		toolService.sendNotice(req, this);
	}
}
