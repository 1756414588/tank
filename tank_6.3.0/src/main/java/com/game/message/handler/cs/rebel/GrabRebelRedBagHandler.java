package com.game.message.handler.cs.rebel;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6.GrabRebelRedBagRq;
import com.game.service.RebelService;

/**
 * @author: LiFeng
 * @date:
 * @description:
 */
public class GrabRebelRedBagHandler extends ClientHandler {

	@Override
	public void action() {
		
		getService(RebelService.class).grabRedBag(msg.getExtension(GrabRebelRedBagRq.ext), this);
	}

}
