package com.game.message.handler.cs.crossParty;

import com.game.message.handler.ClientHandler;
import com.game.pb.CrossGamePb.CCGetCPRankRq;
import com.game.pb.GamePb6;

public class GetCPRankHandler extends ClientHandler {

	@Override
	public void action() {
		GamePb6.GetCPRankRq rq = msg.getExtension(GamePb6.GetCPRankRq.ext);

		CCGetCPRankRq.Builder builder = CCGetCPRankRq.newBuilder();
		builder.setRoleId(getRoleId());
		builder.setPage(rq.getPage());
		builder.setType(rq.getType());

		sendMsgToCrossServer(CCGetCPRankRq.EXT_FIELD_NUMBER, CCGetCPRankRq.ext, builder.build());
	}

}
