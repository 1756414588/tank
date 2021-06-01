package com.game.message.handler.cs.airship;

import com.game.message.handler.ClientHandler;
import com.game.service.airship.AirshipTeamService;

public class StartAirshipTeamMarchHandler extends ClientHandler {
	
	@Override
	public void action() {
		getService(AirshipTeamService.class).startAirshipTeamMarch(this);
	}

}
