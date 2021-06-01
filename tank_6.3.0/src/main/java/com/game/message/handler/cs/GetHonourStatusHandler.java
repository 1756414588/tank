package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.HonourSurviveService;

/**
* @author: LiFeng
* @date: 2018年8月22日 上午6:26:50
* @description:
*/
public class GetHonourStatusHandler extends ClientHandler {

	@Override
	public void action() {
		getService(HonourSurviveService.class).GetHonourStatus(this);
	}

}
