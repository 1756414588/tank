package com.game.message.handler.cs.crossParty;

import com.game.message.handler.ClientHandler;
import com.game.pb.CrossGamePb.CCGetCPTrendRq;

public class GetCPTrendHandler extends ClientHandler {

	@Override
	public void action() {
		CCGetCPTrendRq.Builder builder = CCGetCPTrendRq.newBuilder();
		builder.setRoleId(getRoleId());
		sendMsgToCrossServer(CCGetCPTrendRq.EXT_FIELD_NUMBER, CCGetCPTrendRq.ext, builder.build());
	}

}
