package com.game.message.handler.cs.airship;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5.CreateAirshipTeamRq;
import com.game.service.airship.AirshipTeamService;

public class CreateAirshipTeamHandler extends ClientHandler {
	
	@Override
	public void action() {
		CreateAirshipTeamRq req = msg.getExtension(CreateAirshipTeamRq.ext);
		getService(AirshipTeamService.class).createAirshipTeam(req,this);
	}

}
