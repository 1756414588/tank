package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5.DoPirateLotteryRq;
import com.game.service.ActionCenterService;

public class DoActPirateLotteryHandler extends ClientHandler{
	
	@Override
	public void action() {
		DoPirateLotteryRq req = msg.getExtension(DoPirateLotteryRq.ext);
		getService(ActionCenterService.class).doActPirateLottery(req, this);
	}

}
