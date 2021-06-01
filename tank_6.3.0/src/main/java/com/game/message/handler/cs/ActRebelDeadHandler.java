
package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5.ActRebelIsDeadRq;
import com.game.service.ActionCenterService;


public class ActRebelDeadHandler extends ClientHandler{

	@Override
	public void action() {
		ActRebelIsDeadRq req = msg.getExtension(ActRebelIsDeadRq.ext);
		getService(ActionCenterService.class).actRebelIsDead(req.getPos(),this);
	}

}
