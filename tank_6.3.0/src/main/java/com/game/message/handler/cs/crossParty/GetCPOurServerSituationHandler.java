package com.game.message.handler.cs.crossParty;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6;
import com.game.service.CrossPartyService;

public class GetCPOurServerSituationHandler extends ClientHandler {

	@Override
	public void action() {
		getService(CrossPartyService.class).getCPOurServerSituation(msg.getExtension(GamePb6.GetCPOurServerSituationRq.ext),
				this);
	}

}
