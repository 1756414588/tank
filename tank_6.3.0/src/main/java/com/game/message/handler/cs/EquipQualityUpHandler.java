package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5.EquipQualityUpRq;
import com.game.service.EquipService;

public class EquipQualityUpHandler extends ClientHandler {

	@Override
	public void action() {
		EquipQualityUpRq req = msg.getExtension(EquipQualityUpRq.ext);
		getService(EquipService.class).equipQualityUp(req, this);
	}

}
