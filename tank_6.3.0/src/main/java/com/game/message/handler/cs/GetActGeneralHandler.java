package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb3.GetActGeneralRq;
import com.game.service.ActionCenterService;

public class GetActGeneralHandler extends ClientHandler {

	@Override
	public void action() {
		GetActGeneralRq req = msg.getExtension(GetActGeneralRq.ext);
		getService(ActionCenterService.class).getActGeneralRq(req,this);
	}

}
