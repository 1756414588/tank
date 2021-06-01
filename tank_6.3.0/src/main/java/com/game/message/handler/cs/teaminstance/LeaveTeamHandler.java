package com.game.message.handler.cs.teaminstance;

import com.game.message.handler.ClientHandler;
import com.game.service.teaminstance.TeamService;

/**
* @author : LiFeng
* @date :
* @description :
*/
public class LeaveTeamHandler extends ClientHandler{

	@Override
	public void action() {
		getService(TeamService.class).leaveTeam(this);
	}

}
