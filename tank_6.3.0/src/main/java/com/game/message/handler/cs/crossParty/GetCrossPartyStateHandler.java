package com.game.message.handler.cs.crossParty;

import com.game.message.handler.ClientHandler;
import com.game.pb.CrossGamePb.CCGetCrossPartyStateRq;

public class GetCrossPartyStateHandler extends ClientHandler {

	@Override
	public void action() {

		CCGetCrossPartyStateRq.Builder builder = CCGetCrossPartyStateRq.newBuilder();
		builder.setRoleId(getRoleId());

		sendMsgToCrossServer(CCGetCrossPartyStateRq.EXT_FIELD_NUMBER, CCGetCrossPartyStateRq.ext, builder.build());
	}
}
