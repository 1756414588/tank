package com.game.message.handler.cs.corss;

import com.game.message.handler.ClientHandler;
import com.game.pb.CrossGamePb.CCGetCrossTrendRq;

public class GetCrossTrendHandler extends ClientHandler {

	@Override
	public void action() {

		CCGetCrossTrendRq.Builder builder = CCGetCrossTrendRq.newBuilder();
		builder.setRoleId(getRoleId());

		sendMsgToCrossServer(CCGetCrossTrendRq.EXT_FIELD_NUMBER, CCGetCrossTrendRq.ext, builder.build());
	}

}
