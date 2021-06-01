package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6.GetEnergyDialDayAwardRq;
import com.game.service.ActionCenterService;

/**
* @author: LiFeng
* @date:
* @description:
*/
public class GetEnergyDialDayAwardHanlder extends ClientHandler {

	@Override
	public void action() {
		getService(ActionCenterService.class).getEnergyDialDayAward(this, msg.getExtension(GetEnergyDialDayAwardRq.ext));
	}

}
