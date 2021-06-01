package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6;
import com.game.pb.GamePb6.HonourCollectInfoRq;
import com.game.service.HonourSurviveService;
import com.game.service.WorldService;

/**
 * 获取新英雄采集的金币
 */
public class GetNewHeroInfoRqHandler extends ClientHandler {

	@Override
	public void action() {
		getService(WorldService.class).getNewHoeoGold(this, msg.getExtension(GamePb6.GetNewHeroInfoRq.ext));
	}

}
