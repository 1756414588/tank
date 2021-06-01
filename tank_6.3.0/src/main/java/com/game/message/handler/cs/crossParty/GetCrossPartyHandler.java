package com.game.message.handler.cs.crossParty;

import com.game.message.handler.ClientHandler;
import com.game.pb.CrossGamePb.CCGetCrossPartyRq;
import com.game.pb.GamePb6;

public class GetCrossPartyHandler extends ClientHandler {

	@Override
	public void action() {

		CCGetCrossPartyRq.Builder builder = CCGetCrossPartyRq.newBuilder();
		builder.setRoleId(getRoleId());
		builder.setGroup(msg.getExtension(GamePb6.GetCrossPartyRq.ext).getGroup());
		
		sendMsgToCrossServer(CCGetCrossPartyRq.EXT_FIELD_NUMBER, CCGetCrossPartyRq.ext, builder.build());
	}

}
