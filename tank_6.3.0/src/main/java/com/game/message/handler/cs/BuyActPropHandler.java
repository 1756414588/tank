package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5.BuyActPropRq;
import com.game.service.ActionCenterService;

public class BuyActPropHandler extends ClientHandler {
	
	@Override
	public void action() {
		BuyActPropRq req = msg.getExtension(BuyActPropRq.ext);
		getService(ActionCenterService.class).buyActProp(req, this);
	}

}
