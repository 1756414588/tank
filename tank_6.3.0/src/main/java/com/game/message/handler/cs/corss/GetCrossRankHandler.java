package com.game.message.handler.cs.corss;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb4.GetCrossRankRq;
import com.game.service.CrossService;

public class GetCrossRankHandler extends ClientHandler {

	@Override
	public void action() {
		getService(CrossService.class).getCrossRank( msg.getExtension(GetCrossRankRq.ext),this);
	}

}
