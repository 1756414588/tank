package com.game.message.handler.ss;

import com.game.message.handler.ServerHandler;
import com.game.pb.InnerPb.GetPartyMembersRq;
import com.game.server.GameServer;
import com.game.service.GmToolService;

public class GetPartyMembersRqHandler extends ServerHandler{

	@Override
	public void action() {
		//Auto-generated method stub
		GetPartyMembersRq req = msg.getExtension(GetPartyMembersRq.ext);
		GmToolService toolService = GameServer.ac.getBean(GmToolService.class);
		toolService.getPartyMembers(req, this);
	}

}
