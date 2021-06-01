package com.game.message.handler.cs.tactics;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6;
import com.game.service.TacticsService;

public class BindTacticsFormRqHandler extends ClientHandler{

	@Override
	public void action() {
		getService(TacticsService.class).bindTacticsFormRq(msg.getExtension(GamePb6.BindTacticsFormRq.ext),this);
	}

}
