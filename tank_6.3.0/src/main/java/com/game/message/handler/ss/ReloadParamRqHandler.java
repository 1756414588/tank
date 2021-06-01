package com.game.message.handler.ss;

import com.game.message.handler.ServerHandler;
import com.game.pb.InnerPb.ReloadParamRq;
import com.game.server.GameServer;
import com.game.service.GmToolService;

public class ReloadParamRqHandler extends ServerHandler {

	@Override
	public void action() {
		ReloadParamRq req = msg.getExtension(ReloadParamRq.ext);

		GmToolService toolService = GameServer.ac.getBean(GmToolService.class);
		toolService.reloadParam(req.getType());
	}
}
