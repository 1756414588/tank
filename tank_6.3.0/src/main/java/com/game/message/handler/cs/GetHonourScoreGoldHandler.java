package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6.GetHonourScoreGoldRq;
import com.game.service.HonourSurviveService;

/**
* @author: LiFeng
* @date: 2018年8月24日 下午4:05:19
* @description:
*/
public class GetHonourScoreGoldHandler extends ClientHandler{

	@Override
	public void action() {
		getService(HonourSurviveService.class).getHonourScoreGold(this, msg.getExtension(GetHonourScoreGoldRq.ext));
	}

}
