package com.game.message.handler.cs.corss;

import com.game.message.handler.ClientHandler;
import com.game.pb.CrossGamePb.CCGetCrossShopRq;

public class GetCrossShopHandler extends ClientHandler {

	@Override
	public void action() {
		CCGetCrossShopRq.Builder builder = CCGetCrossShopRq.newBuilder();
		builder.setRoleId(getRoleId());
		
		sendMsgToCrossServer(CCGetCrossShopRq.EXT_FIELD_NUMBER, CCGetCrossShopRq.ext, builder.build());
	}

}
