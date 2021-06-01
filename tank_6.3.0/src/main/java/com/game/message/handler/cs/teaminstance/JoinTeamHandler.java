package com.game.message.handler.cs.teaminstance;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6.JoinTeamRq;
import com.game.service.teaminstance.TeamService;

/**
* @author : LiFeng
* @date :
* @description :
*/
public class JoinTeamHandler extends ClientHandler{

	@Override
	public void action() {
		getService(TeamService.class).joinTeam(this, msg.getExtension(JoinTeamRq.ext));
	}

}
