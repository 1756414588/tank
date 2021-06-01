package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.PartyService;

/**
* @author: LiFeng
* @date: 2018年9月15日 上午10:43:16
* @description:
*/
public class DonateAllPartyResHandler extends ClientHandler {

	@Override
	public void action() {
		getService(PartyService.class).donateAllPartyRes(this);
	}

}
