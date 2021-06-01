package com.game.message.handler.cs.airship;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5.ScoutAirshipRq;
import com.game.service.airship.AirshipService;

public class ScoutAirshipHandler extends ClientHandler {
	
	@Override
	public void action() {
		ScoutAirshipRq req = msg.getExtension(ScoutAirshipRq.ext);
		getService(AirshipService.class).scoutAirship(req.getId(),this);
	}

}
