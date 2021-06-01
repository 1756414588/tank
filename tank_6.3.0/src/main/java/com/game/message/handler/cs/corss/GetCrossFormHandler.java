package com.game.message.handler.cs.corss;

import com.game.domain.Player;
import com.game.message.handler.ClientHandler;
import com.game.pb.CrossGamePb.CCGetCrossFormRq;
import com.game.service.CrossService;

public class GetCrossFormHandler extends ClientHandler {
	
	@Override
	public void action() {
		Player player = getService(CrossService.class).getPlayer(getRoleId());
		
		CCGetCrossFormRq.Builder builder = CCGetCrossFormRq.newBuilder();
		builder.setRoleId(player.lord.getLordId());
		
		sendMsgToCrossServer(CCGetCrossFormRq.EXT_FIELD_NUMBER, CCGetCrossFormRq.ext, builder.build());
	}
}
