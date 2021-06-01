package com.game.message.handler.cs.teaminstance;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6.InviteMemberRq;
import com.game.service.teaminstance.TeamService;

/**
 * @author: LiFeng
 * @date:
 * @description:
 */
public class InviteMemberHandler extends ClientHandler {

	@Override
	public void action() {
		getService(TeamService.class).teamInvite(this, msg.getExtension(InviteMemberRq.ext));
	}

}
