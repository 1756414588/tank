package com.game.message.handler.cs.airship;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5;
import com.game.service.airship.AirshipTeamService;

public class JoinAirshipTeamHandler extends ClientHandler {
	
	@Override
	public void action() {
		GamePb5.JoinAirshipTeamRq req = msg.getExtension(GamePb5.JoinAirshipTeamRq.ext);
		getService(AirshipTeamService.class).joinAirshipTeam(req,this);
	}

}
