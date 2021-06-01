package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6.GetHonourRankAwardRq;
import com.game.service.HonourSurviveService;

/**
 * @author: LiFeng
 * @date: 2018年8月6日 下午12:25:54
 * @description:
 */
public class GetHonourRankAwardHandler extends ClientHandler {

	@Override
	public void action() {
		GetHonourRankAwardRq req = msg.getExtension(GetHonourRankAwardRq.ext);
		if (req.getAwardType() == 1) {
			getService(HonourSurviveService.class).getPlayerRankAward(this);
		} else {
			getService(HonourSurviveService.class).getPartyRankAward(this);
		}
	}

}
