package com.game.message.handler.cs.corss;

import com.game.domain.Player;
import com.game.message.handler.ClientHandler;
import com.game.pb.CrossGamePb.CCGetCrossKnockCompetInfoRq;
import com.game.pb.GamePb4.GetCrossKnockCompetInfoRq;
import com.game.service.CrossService;

public class GetCrossKnockCompetInfoHandler extends ClientHandler {


	@Override
	public void action() {
		Player player = getService(CrossService.class).getPlayer(getRoleId());
		
		GetCrossKnockCompetInfoRq req = msg.getExtension(GetCrossKnockCompetInfoRq.ext);
		
		CCGetCrossKnockCompetInfoRq.Builder builder = CCGetCrossKnockCompetInfoRq.newBuilder();
		builder.setRoleId(player.lord.getLordId());
		builder.setGroupId(req.getGroupId());
		builder.setGroupType(req.getGroupType());
		
		sendMsgToCrossServer(CCGetCrossKnockCompetInfoRq.EXT_FIELD_NUMBER, CCGetCrossKnockCompetInfoRq.ext, builder.build());
	}
}
