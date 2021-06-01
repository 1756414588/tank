package com.game.message.handler.cs.corss;

import com.game.domain.Player;
import com.game.message.handler.ClientHandler;
import com.game.pb.CrossGamePb.CCGetCrossFinalCompetInfoRq;
import com.game.pb.GamePb4.GetCrossFinalCompetInfoRq;
import com.game.service.CrossService;

public class GetCrossFinalCompetInfoHandler extends ClientHandler {



	@Override
	public void action() {
		Player player = getService(CrossService.class).getPlayer(getRoleId());
		
		GetCrossFinalCompetInfoRq req = msg.getExtension(GetCrossFinalCompetInfoRq.ext);
		
		CCGetCrossFinalCompetInfoRq.Builder builder = CCGetCrossFinalCompetInfoRq.newBuilder();
		builder.setRoleId(player.lord.getLordId());	
		builder.setGroupId(req.getGroupId());
		
		sendMsgToCrossServer(CCGetCrossFinalCompetInfoRq.EXT_FIELD_NUMBER, CCGetCrossFinalCompetInfoRq.ext, builder.build());
	}

}
