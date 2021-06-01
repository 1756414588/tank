package com.game.message.handler.cs.corss;

import com.game.domain.Player;
import com.game.message.handler.ClientHandler;
import com.game.pb.CrossGamePb.CCGetCrossFightStateRq;
import com.game.service.CrossService;

public class GetCrossFightStateHandler extends ClientHandler {
	
	@Override
	public void action() {
		Player player = getService(CrossService.class).getPlayer(getRoleId());
		
		CCGetCrossFightStateRq.Builder builder = CCGetCrossFightStateRq.newBuilder();
		builder.setRoleId(player.lord.getLordId());
		
		sendMsgToCrossServer(CCGetCrossFightStateRq.EXT_FIELD_NUMBER, CCGetCrossFightStateRq.ext, builder.build());
	}

}
