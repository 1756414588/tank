package com.game.message.handler.cs.crossParty;

import com.game.message.handler.ClientHandler;
import com.game.pb.CrossGamePb.CCGetCPSituationRq;
import com.game.pb.GamePb6;

public class GetCPSituationHandler extends ClientHandler {

	@Override
	public void action() {
		GamePb6.GetCPSituationRq rq = msg.getExtension(GamePb6.GetCPSituationRq.ext);

		CCGetCPSituationRq.Builder builder = CCGetCPSituationRq.newBuilder();
		builder.setRoleId(getRoleId());

		builder.setGroup(rq.getGroup());
		builder.setPage(rq.getPage());

		sendMsgToCrossServer(CCGetCPSituationRq.EXT_FIELD_NUMBER, CCGetCPSituationRq.ext, builder.build());
	}

}
