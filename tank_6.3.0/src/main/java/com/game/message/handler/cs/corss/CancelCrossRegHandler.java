package com.game.message.handler.cs.corss;

import com.game.domain.Player;
import com.game.message.handler.ClientHandler;
import com.game.pb.CrossGamePb.CCCancelCrossRegRq;
import com.game.service.CrossService;

public class CancelCrossRegHandler extends ClientHandler {

	
	@Override
	public void action() {
		Player player = getService(CrossService.class).getPlayer(getRoleId());
		
		CCCancelCrossRegRq.Builder builder = CCCancelCrossRegRq.newBuilder();
		builder.setRoleId(player.lord.getLordId());
		
		sendMsgToCrossServer(CCCancelCrossRegRq.EXT_FIELD_NUMBER, CCCancelCrossRegRq.ext, builder.build());
	}

}
