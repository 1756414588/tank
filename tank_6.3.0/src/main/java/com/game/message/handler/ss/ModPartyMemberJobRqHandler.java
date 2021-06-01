package com.game.message.handler.ss;

import com.game.message.handler.ServerHandler;
import com.game.pb.InnerPb.ModPartyMemberJobRq;
import com.game.server.GameServer;
import com.game.service.GmToolService;

public class ModPartyMemberJobRqHandler extends ServerHandler{

	@Override
	public void action() {
		//Auto-generated method stub
		ModPartyMemberJobRq req = msg.getExtension(ModPartyMemberJobRq.ext);
		
		GmToolService toolService = GameServer.ac.getBean(GmToolService.class);
		toolService.modPartyMemberJob(req, this);
	}

}
