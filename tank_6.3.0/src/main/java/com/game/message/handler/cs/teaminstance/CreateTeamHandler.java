package com.game.message.handler.cs.teaminstance;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6.CreateTeamRq;
import com.game.service.teaminstance.TeamService;

/**
 * @author : LiFeng
 * @date :
 * @description :
 */
public class CreateTeamHandler extends ClientHandler {
	@Override
	public void action() {
		getService(TeamService.class).createTeam(this, msg.getExtension(CreateTeamRq.ext));
	}
}
