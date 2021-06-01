package com.game.message.handler.cs.crossParty;

import com.game.message.handler.ClientHandler;
import com.game.pb.CrossGamePb.CCGetCrossPartyServerListRq;

public class GetCrossPartyServerListHanlder extends ClientHandler {

	@Override
	public void action() {
		CCGetCrossPartyServerListRq.Builder builder = CCGetCrossPartyServerListRq.newBuilder();
		builder.setRoleId(getRoleId());
		
		sendMsgToCrossServer(CCGetCrossPartyServerListRq.EXT_FIELD_NUMBER, CCGetCrossPartyServerListRq.ext, builder.build());
		
	}

}
