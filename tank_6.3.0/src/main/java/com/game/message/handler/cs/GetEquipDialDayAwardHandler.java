package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6.GetEquipDialDayAwardRq;
import com.game.service.ActionCenterService;

/**
* @author: LiFeng
* @date:
* @description:
*/
public class GetEquipDialDayAwardHandler extends ClientHandler {

	@Override
	public void action() {
		getService(ActionCenterService.class).getActEquipDayAward(this, msg.getExtension(GetEquipDialDayAwardRq.ext));
	}

}
