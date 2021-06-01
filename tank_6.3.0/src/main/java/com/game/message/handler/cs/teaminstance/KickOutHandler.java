package com.game.message.handler.cs.teaminstance;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6.KickOutRq;
import com.game.service.teaminstance.TeamService;

/**
* @author : LiFeng
* @date :
* @description :
*/
public class KickOutHandler extends ClientHandler{

	@Override
	public void action() {
		getService(TeamService.class).kickout(this, msg.getExtension(KickOutRq.ext));
	}

}