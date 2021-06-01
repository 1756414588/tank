package com.game.message.handler.cs.crossParty;

import com.game.message.handler.ClientHandler;
import com.game.pb.CrossGamePb.CCExchangeCPShopRq;
import com.game.pb.GamePb6;

public class ExchangeCPShopHandler extends ClientHandler {

	@Override
	public void action() {
		GamePb6.ExchangeCPShopRq req = msg.getExtension(GamePb6.ExchangeCPShopRq.ext);

		CCExchangeCPShopRq.Builder builder = CCExchangeCPShopRq.newBuilder();
		builder.setRoleId(getRoleId());
		builder.setShopId(req.getShopId());
		builder.setCount(req.getCount());

		sendMsgToCrossServer(CCExchangeCPShopRq.EXT_FIELD_NUMBER, CCExchangeCPShopRq.ext, builder.build());
	}

}
