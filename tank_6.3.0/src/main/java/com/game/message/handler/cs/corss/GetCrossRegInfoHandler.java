package com.game.message.handler.cs.corss;

import com.game.domain.Player;
import com.game.message.handler.ClientHandler;
import com.game.pb.CrossGamePb.CCGetCrossRegInfoRq;
import com.game.service.CrossService;

public class GetCrossRegInfoHandler extends ClientHandler {

	
	@Override
	public void action() {
		Player player = getService(CrossService.class).getPlayer(getRoleId());
		
		CCGetCrossRegInfoRq.Builder builder = CCGetCrossRegInfoRq.newBuilder();
		builder.setRoleId(player.lord.getLordId());
		
		sendMsgToCrossServer(CCGetCrossRegInfoRq.EXT_FIELD_NUMBER, CCGetCrossRegInfoRq.ext, builder.build());
	}

}
