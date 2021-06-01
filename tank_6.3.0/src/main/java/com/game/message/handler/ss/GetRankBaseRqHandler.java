package com.game.message.handler.ss;

import com.game.message.handler.ServerHandler;
import com.game.pb.InnerPb.GetRankBaseRq;
import com.game.server.GameServer;
import com.game.service.GmToolService;

public class GetRankBaseRqHandler extends ServerHandler{

	@Override
	public void action() {
		//Auto-generated method stub
		GetRankBaseRq req = msg.getExtension(GetRankBaseRq.ext);
		GmToolService toolService = GameServer.ac.getBean(GmToolService.class);
		toolService.getRankBase(req, this);
	}

}
