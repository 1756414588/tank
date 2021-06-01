package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5.GetActRebelRankRq;
import com.game.service.ActionCenterService;

public class GetActRebelRankHandler extends ClientHandler {

	@Override
	public void action() {
		GetActRebelRankRq req = msg.getExtension(GetActRebelRankRq.ext);
		getService(ActionCenterService.class).getActRebelRank(req.getPage(),this);
	}

}
