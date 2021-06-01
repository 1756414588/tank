package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6.GetHonourRankRq;
import com.game.service.HonourSurviveService;

/**
 * @author: LiFeng
 * @date: 2018年8月20日 下午12:03:53
 * @description:
 */
public class GetHonourRankHandler extends ClientHandler {

	@Override
	public void action() {
		GetHonourRankRq req = msg.getExtension(GetHonourRankRq.ext);
		if (req.getType() == 1) {
			getService(HonourSurviveService.class).getHonourPlayerRank(this);
		} else {
			getService(HonourSurviveService.class).getHonourPartyRank(this);
		}
	}

}
