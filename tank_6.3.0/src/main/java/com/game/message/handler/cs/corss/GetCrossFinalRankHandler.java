package com.game.message.handler.cs.corss;

import com.game.message.handler.ClientHandler;
import com.game.pb.CrossGamePb.CCGetCrossFinalRankRq;
import com.game.pb.GamePb4.GetCrossFinalRankRq;

public class GetCrossFinalRankHandler extends ClientHandler {

	@Override
	public void action() {
		
		GetCrossFinalRankRq req = msg.getExtension(GetCrossFinalRankRq.ext);
		CCGetCrossFinalRankRq.Builder builder = CCGetCrossFinalRankRq.newBuilder();
		
		builder.setRoleId(getRoleId());
		builder.setGroup(req.getGroup());
		sendMsgToCrossServer(CCGetCrossFinalRankRq.EXT_FIELD_NUMBER, CCGetCrossFinalRankRq.ext, builder.build());
	}

}
