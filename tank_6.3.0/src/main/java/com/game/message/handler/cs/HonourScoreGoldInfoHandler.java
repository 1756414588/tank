package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.HonourSurviveService;

/**
* @author: LiFeng
* @date: 2018年8月24日 下午4:08:17
* @description:
*/
public class HonourScoreGoldInfoHandler extends ClientHandler {

	@Override
	public void action() {
		getService(HonourSurviveService.class).honourScoreGoldInfo(this);
	}

}
