package com.game.message.handler.cs.teaminstance;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6.FindTeamRq;
import com.game.service.teaminstance.TeamService;

/**
* @author : LiFeng
* @date :
* @description :
*/
public class FindTeamHandler extends ClientHandler{

	@Override
	public void action() {
		getService(TeamService.class).findTeam(this, msg.getExtension(FindTeamRq.ext));
	}

}
