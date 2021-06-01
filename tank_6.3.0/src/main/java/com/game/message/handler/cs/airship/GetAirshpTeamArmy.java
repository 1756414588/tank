package com.game.message.handler.cs.airship;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5.GetAirshpTeamArmyRq;
import com.game.service.airship.AirshipTeamService;

public class GetAirshpTeamArmy extends ClientHandler {
	
	@Override
	public void action() {
		GetAirshpTeamArmyRq req = msg.getExtension(GetAirshpTeamArmyRq.ext);
		getService(AirshipTeamService.class).getAirshpTeamArmy(req,this);
	}

}
