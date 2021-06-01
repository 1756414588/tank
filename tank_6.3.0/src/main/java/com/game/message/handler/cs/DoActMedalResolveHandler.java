package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6.DoActMedalResolveRq;
import com.game.service.ActionCenterService;

/**
* @author: LiFeng
* @date:
* @description:
*/
public class DoActMedalResolveHandler extends ClientHandler {

	@Override
	public void action() {
		getService(ActionCenterService.class).doActMedalResolveRq(msg.getExtension(DoActMedalResolveRq.ext), this);
	}

}
