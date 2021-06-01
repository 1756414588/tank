package com.game.message.handler.cs.corss;

import com.game.domain.Player;
import com.game.message.handler.ClientHandler;
import com.game.pb.CrossGamePb.CCReceiveBetRq;
import com.game.pb.GamePb4.ReceiveBetRq;
import com.game.service.CrossService;

public class ReceiveBetHandler extends ClientHandler {

	@Override
	public void action() {
		Player player = getService(CrossService.class).getPlayer(getRoleId());

		ReceiveBetRq rq = msg.getExtension(ReceiveBetRq.ext);
		
		CCReceiveBetRq.Builder builder = CCReceiveBetRq.newBuilder();
		builder.setRoleId(player.lord.getLordId());
		builder.setMyGroup(rq.getMyGroup());
		builder.setStage(rq.getStage());
		builder.setGroupType(rq.getGroupType());
		builder.setCompetGroupId(rq.getCompetGroupId());
		
		sendMsgToCrossServer(CCReceiveBetRq.EXT_FIELD_NUMBER, CCReceiveBetRq.ext, builder.build());
	}

}
