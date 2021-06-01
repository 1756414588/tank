package com.game.message.handler.cs.tactics;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6;
import com.game.service.TacticsService;

public class SetTacticsFormRqHandler extends ClientHandler{

	@Override
	public void action() {
		getService(TacticsService.class).setTacticsFormRq(msg.getExtension(GamePb6.SetTacticsFormRq.ext),this);
	}

}
