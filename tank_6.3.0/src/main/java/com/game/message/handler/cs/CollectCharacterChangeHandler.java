package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5.CollectCharacterChangeRq;
import com.game.service.ActionCenterService;

public class CollectCharacterChangeHandler extends ClientHandler{

	@Override
	public void action() {
		CollectCharacterChangeRq req = msg.getExtension(CollectCharacterChangeRq.ext);
		getService(ActionCenterService.class).collectCharacterChange(req, this);
	}

}
