package com.game.message.handler.cs.tactics;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6;
import com.game.service.TacticsService;
import com.game.service.teaminstance.TeamService;

public class GetTacticsRqHandler extends ClientHandler{

	@Override
	public void action() {
		getService(TacticsService.class).getTacticsRq(msg.getExtension(GamePb6.GetTacticsRq.ext),this);
	}

}
