package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb2.AssembleMechaRq;
import com.game.service.ActionCenterService;

public class AssembleMechaHandler extends ClientHandler {

	@Override
	public void action() {
		AssembleMechaRq req = msg.getExtension(AssembleMechaRq.ext);
		getService(ActionCenterService.class).assembleMechaRq(req, this);
	}

}
