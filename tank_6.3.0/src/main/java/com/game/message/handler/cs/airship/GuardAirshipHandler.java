package com.game.message.handler.cs.airship;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5.GuardAirshipRq;
import com.game.service.airship.AirshipService;

public class GuardAirshipHandler extends ClientHandler {
	
	@Override
	public void action() {
		GuardAirshipRq req = msg.getExtension(GuardAirshipRq.ext);
		getService(AirshipService.class).guardAirship(req,this);
	}

}
