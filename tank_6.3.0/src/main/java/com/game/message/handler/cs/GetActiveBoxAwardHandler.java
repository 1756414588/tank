package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6.GetActiveBoxAwardRq;
import com.game.service.PlayerService;

/**
* @author: LiFeng
* @date:
* @description:
*/
public class GetActiveBoxAwardHandler extends ClientHandler {

	@Override
	public void action() {
		getService(PlayerService.class).getActiveBoxAward(this, msg.getExtension(GetActiveBoxAwardRq.ext));
	}

}
