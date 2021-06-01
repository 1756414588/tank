package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5.CollectCharacterCombineRq;
import com.game.service.ActionCenterService;

public class CollectCharacterCombineHandler extends ClientHandler{

	@Override
	public void action() {
		CollectCharacterCombineRq req = msg.getExtension(CollectCharacterCombineRq.ext);
		getService(ActionCenterService.class).collectCharacterCombine(req, this);
	}

}
