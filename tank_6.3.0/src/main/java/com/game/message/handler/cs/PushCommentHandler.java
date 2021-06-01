package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb4.PushCommentRq;
import com.game.service.PlayerService;

public class PushCommentHandler extends ClientHandler{

	@Override
	public void action() {
		getService(PlayerService.class).pushComment(msg.getExtension(PushCommentRq.ext),this);
	}

}
