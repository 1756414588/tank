package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6.DonateAllPartyScienceRq;
import com.game.service.PartyService;

/**
 * @author: LiFeng
 * @date: 2018年9月15日 上午10:44:05
 * @description:
 */
public class DonateAllPartyScienceHandler extends ClientHandler {

	@Override
	public void action() {
		getService(PartyService.class).donateAllScienceRes(msg.getExtension(DonateAllPartyScienceRq.ext), this);
	}

}
