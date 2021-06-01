package com.game.message.handler.cs.corss;

import com.game.domain.Player;
import com.game.message.handler.ClientHandler;
import com.game.pb.CrossGamePb.CCGetCrossServerListRq;
import com.game.service.CrossService;

public class GetCrossServerListHandler extends ClientHandler {


	@Override
	public void action() {
		Player player = getService(CrossService.class).getPlayer(getRoleId());

		CCGetCrossServerListRq.Builder builder = CCGetCrossServerListRq.newBuilder();
		builder.setRoleId(player.lord.getLordId());
		builder.setNick(player.lord.getNick());
		
		sendMsgToCrossServer(CCGetCrossServerListRq.EXT_FIELD_NUMBER, CCGetCrossServerListRq.ext, builder.build());
	}
	
}
