package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6.GetFortuneDayAwardRq;
import com.game.service.ActionCenterService;

/**
* @author: LiFeng
* @date:
* @description:
*/
public class GetFortuneDayAwardHanlder extends ClientHandler {

	@Override
	public void action() {
		getService(ActionCenterService.class).getActFortuneDayAward(this, msg.getExtension(GetFortuneDayAwardRq.ext));

	}

}
