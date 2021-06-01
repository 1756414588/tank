package com.game.message.handler.cs.teaminstance;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6.TeamChatRq;
import com.game.service.teaminstance.TeamService;

/**
* @author: LiFeng
* @date:
* @description:
*/
public class TeamChatHandler extends ClientHandler {

	@Override
	public void action() {
		getService(TeamService.class).teamChat(this, msg.getExtension(TeamChatRq.ext));
	}

}
