package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb3.RefshEquipCashRq;
import com.game.service.ActionCenterService;

public class RefshEquipCashHandler extends ClientHandler {

	@Override
	public void action() {
		RefshEquipCashRq req = msg.getExtension(RefshEquipCashRq.ext);
		getService(ActionCenterService.class).refshEquipCashRq(req, this);
	}

}
