package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb3.GetActGeneralRankRq;
import com.game.service.ActionCenterService;

public class GetActGeneralRankHandler extends ClientHandler {

	@Override
	public void action() {
		GetActGeneralRankRq req = msg.getExtension(GetActGeneralRankRq.ext);
		getService(ActionCenterService.class).getActGeneralRankRq(req,this);
	}

}
