package com.game.message.handler.cs.activity;

import com.game.message.handler.ClientHandler;
import com.game.service.ActionCenterService;

/**
* @author: LiFeng
* @date:
* @description:
*/
public class GetTankConvertInfoHandler extends ClientHandler{

	@Override
	public void action() {
		getService(ActionCenterService.class).getTankConvert(this);
	}

}
