package com.game.message.handler.cs.crossParty;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6;
import com.game.service.CrossPartyService;

public class GetCPMyRegInfoHandler extends ClientHandler {

	@Override
	public void action() {
		getService(CrossPartyService.class).getCPMyRegInfo(msg.getExtension(GamePb6.GetCPMyRegInfoRq.ext), this);
	}

}
