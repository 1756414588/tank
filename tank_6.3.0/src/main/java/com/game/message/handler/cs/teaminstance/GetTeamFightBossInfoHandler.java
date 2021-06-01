package com.game.message.handler.cs.teaminstance;

import com.game.message.handler.ClientHandler;
import com.game.service.teaminstance.TeamInstanceService;

public class GetTeamFightBossInfoHandler extends ClientHandler{

	@Override
	public void action() {
		getService(TeamInstanceService.class).getFightBossInfo(this);
	}

}
