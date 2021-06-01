package com.game.message.handler.cs.corss;

import com.game.message.handler.ClientHandler;
import com.game.pb.CrossGamePb.CCExchangeCrossShopRq;
import com.game.pb.GamePb4.ExchangeCrossShopRq;

public class ExchangeCrossShopHandler extends ClientHandler {

	@Override
	public void action() {
		ExchangeCrossShopRq req = msg.getExtension(ExchangeCrossShopRq.ext);
		
		
		CCExchangeCrossShopRq.Builder builder = CCExchangeCrossShopRq.newBuilder();
		builder.setRoleId(getRoleId());
		builder.setShopId(req.getShopId());
		builder.setCount(req.getCount());

		sendMsgToCrossServer(CCExchangeCrossShopRq.EXT_FIELD_NUMBER, CCExchangeCrossShopRq.ext, builder.build());
	}

}
