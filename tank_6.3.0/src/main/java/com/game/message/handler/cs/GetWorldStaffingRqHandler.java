package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6;
import com.game.service.WorldService;

/**
 * 世界矿点编制经验
 */
public class GetWorldStaffingRqHandler extends ClientHandler {

	@Override
	public void action() {
		getService(WorldService.class).getWorldStaffing( msg.getExtension(GamePb6.GetWorldStaffingRq.ext),this);
	}

}
