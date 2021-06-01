package com.game.message.handler.cs.airship;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5.GetAirshipGuardRq;
import com.game.service.airship.AirshipService;

public class GetAirshipGuardHandler extends ClientHandler {
	
	@Override
	public void action() {
		GetAirshipGuardRq req = msg.getExtension(GetAirshipGuardRq.ext);
		getService(AirshipService.class).getAirshipGuard(req,this);
	}

}
