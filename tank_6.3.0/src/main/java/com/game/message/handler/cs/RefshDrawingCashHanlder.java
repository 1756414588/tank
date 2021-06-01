package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6.RefshDrawingCashRq;
import com.game.service.ActionCenterService;

/**
* @author: LiFeng
* @date:
* @description:
*/
public class RefshDrawingCashHanlder extends ClientHandler {

	@Override
	public void action() {
		getService(ActionCenterService.class).refreshDrawingCash(msg.getExtension(RefshDrawingCashRq.ext), this);

	}

}
