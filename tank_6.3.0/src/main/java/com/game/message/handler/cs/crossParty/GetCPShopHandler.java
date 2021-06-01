package com.game.message.handler.cs.crossParty;

import com.game.message.handler.ClientHandler;
import com.game.pb.CrossGamePb.CCGetCPShopRq;

public class GetCPShopHandler extends ClientHandler {

	@Override
	public void action() {
		CCGetCPShopRq.Builder builder = CCGetCPShopRq.newBuilder();
		builder.setRoleId(getRoleId());

		sendMsgToCrossServer(CCGetCPShopRq.EXT_FIELD_NUMBER, CCGetCPShopRq.ext, builder.build());
	}
}
