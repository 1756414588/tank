package com.game.message.handler.cs.crossParty;

import com.game.message.handler.ClientHandler;
import com.game.pb.CrossGamePb.CCGetCPFormRq;

public class GetCPFormHandler extends ClientHandler {

	@Override
	public void action() {
		CCGetCPFormRq.Builder builder = CCGetCPFormRq.newBuilder();
		builder.setRoleId(getRoleId());
		
		sendMsgToCrossServer(CCGetCPFormRq.EXT_FIELD_NUMBER, CCGetCPFormRq.ext, builder.build());
	}

}
