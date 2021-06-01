package com.game.message.handler.cs.lucky;

import com.game.message.handler.ClientHandler;
import com.game.service.ActivityNewService;

/**
 * @author: LiFeng
 * @date:
 * @description:
 */
public class GetActLuckyPoolLogHandler extends ClientHandler{

	@Override
	public void action() {
		  getService(ActivityNewService.class).getLuckyLog( this);
	}

}
