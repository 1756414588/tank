package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.ActionCenterService;

/**
* @author: LiFeng
* @date:
* @description:
*/
public class GetEnergyDialDayInfofoHanlder extends ClientHandler {

	@Override
	public void action() {
		getService(ActionCenterService.class).getEnergyDialDayInfo(this);
	}

}
