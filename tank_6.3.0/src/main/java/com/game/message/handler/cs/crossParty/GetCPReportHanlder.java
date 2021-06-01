package com.game.message.handler.cs.crossParty;

import com.game.message.handler.ClientHandler;
import com.game.pb.CrossGamePb.CCGetCPReportRq;
import com.game.pb.GamePb6;

public class GetCPReportHanlder extends ClientHandler {

	@Override
	public void action() {
		CCGetCPReportRq.Builder builder = CCGetCPReportRq.newBuilder();
		builder.setRoleId(getRoleId());
		builder.setReportKey(msg.getExtension(GamePb6.GetCPReportRq.ext).getReportKey());

		sendMsgToCrossServer(CCGetCPReportRq.EXT_FIELD_NUMBER, CCGetCPReportRq.ext, builder.build());
	}

}
