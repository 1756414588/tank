package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.ActionCenterService;

/**
 * @author: LiFeng
 * @date:2018年9月25日 上午9:15:54
 * @description:
 */
public class GetQueAwardStatusHandler extends ClientHandler {

	@Override
	public void action() {
		getService(ActionCenterService.class).getQueAwardStatus(this);
	}

}
