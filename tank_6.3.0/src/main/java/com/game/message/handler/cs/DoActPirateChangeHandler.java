package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5.DoPirateChangeRq;
import com.game.service.ActionCenterService;

public class DoActPirateChangeHandler extends ClientHandler{
	
	@Override
	public void action() {
		DoPirateChangeRq req = msg.getExtension(DoPirateChangeRq.ext);
		getService(ActionCenterService.class).doActPirateChange(req, this);
	}

}
