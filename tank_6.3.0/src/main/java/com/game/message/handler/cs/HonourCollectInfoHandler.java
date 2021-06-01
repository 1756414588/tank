package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6.HonourCollectInfoRq;
import com.game.service.HonourSurviveService;

/**
* @author: LiFeng
* @date: 2018年8月20日 上午1:11:21
* @description:
*/
public class HonourCollectInfoHandler extends ClientHandler {

	@Override
	public void action() {
		getService(HonourSurviveService.class).honourCollectInfo(this, msg.getExtension(HonourCollectInfoRq.ext));
	}

}
