package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.WarService;

public class GetThisWeekMyWarJiFenRankHandler extends ClientHandler {

	@Override
	public void action() {
		this.getService(WarService.class).getThisWeekMyWarJiFenRank(this);
	}

}
