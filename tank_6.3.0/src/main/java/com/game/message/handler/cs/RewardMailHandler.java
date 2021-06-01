package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb1.RewardMailRq;
import com.game.service.MailService;

public class RewardMailHandler extends ClientHandler {

	/**
	 * Overriding: action
	 * 
	 * @see com.game.server.ICommand#action()
	 */
	@Override
	public void action() {
		//Auto-generated method stub
		RewardMailRq req = msg.getExtension(RewardMailRq.ext);
		getService(MailService.class).rewardMailRq(req, this);
	}

}
