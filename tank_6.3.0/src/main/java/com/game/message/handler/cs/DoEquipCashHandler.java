package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb3.DoEquipCashRq;
import com.game.service.ActionCenterService;

public class DoEquipCashHandler extends ClientHandler {

	@Override
	public void action() {
		DoEquipCashRq req = msg.getExtension(DoEquipCashRq.ext);
		getService(ActionCenterService.class).doEquipCashRq(req, this);
	}

}
