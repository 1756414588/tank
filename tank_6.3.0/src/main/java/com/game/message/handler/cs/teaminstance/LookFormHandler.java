package com.game.message.handler.cs.teaminstance;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6.LookMemberInfoRq;
import com.game.service.teaminstance.TeamService;

/**
 * @author: LiFeng
 * @date:
 * @description:
 */
public class LookFormHandler extends ClientHandler {

	@Override
	public void action() {
		getService(TeamService.class).lookForm(this, msg.getExtension(LookMemberInfoRq.ext));
	}

}
