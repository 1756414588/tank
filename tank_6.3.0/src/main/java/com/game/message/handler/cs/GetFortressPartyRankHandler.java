package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.FortressWarService;

/**
 * 获取要塞战军团排名
 * @author wanyi
 *
 */
public class GetFortressPartyRankHandler extends ClientHandler {

	@Override
	public void action() {
		getService(FortressWarService.class).getFortressPartyRank(this);
	}

}
