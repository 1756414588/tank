package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6.DoDrawingCashRq;
import com.game.service.ActionCenterService;

/**
 * @author: LiFeng
 * @date:
 * @description:
 */
public class DoDrawingCashHanlder extends ClientHandler {

	@Override
	public void action() {
		getService(ActionCenterService.class).doDrawingCash(msg.getExtension(DoDrawingCashRq.ext), this);
	}

}
