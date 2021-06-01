package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.ActivityService;

/**
* @author: LiFeng
* @date: 2018年7月28日 下午2:07:15
* @description:
*/
public class ActBuildInfoHandler extends ClientHandler {

	@Override
	public void action() {
		getService(ActivityService.class).actBuildInfoRq(this);
	}

}
