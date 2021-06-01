package com.game.message.handler.cs.corss;

import com.game.domain.Player;
import com.game.message.handler.ClientHandler;
import com.game.pb.CrossGamePb.CCGetCrossReportRq;
import com.game.pb.GamePb4.GetCrossReportRq;
import com.game.service.CrossService;

public class GetCrossReportHandler extends ClientHandler {


	@Override
	public void action() {
		Player player = getService(CrossService.class).getPlayer(getRoleId());

		GetCrossReportRq rq = msg.getExtension(GetCrossReportRq.ext);
		CCGetCrossReportRq.Builder builder = CCGetCrossReportRq.newBuilder();

		builder.setRoleId(player.lord.getLordId());
		builder.setReportKey(rq.getReportKey());

		sendMsgToCrossServer(CCGetCrossReportRq.EXT_FIELD_NUMBER, CCGetCrossReportRq.ext, builder.build());
	}

}
