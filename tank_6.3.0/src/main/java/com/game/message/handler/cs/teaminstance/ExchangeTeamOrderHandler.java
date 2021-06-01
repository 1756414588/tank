package com.game.message.handler.cs.teaminstance;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6.ExchangeOrderRq;
import com.game.service.teaminstance.TeamService;

/**
* @author: LiFeng
* @date:
* @description:
*/
public class ExchangeTeamOrderHandler extends ClientHandler{

	@Override
	public void action() {
		getService(TeamService.class).exchangeOrder(this, msg.getExtension(ExchangeOrderRq.ext));
	}

}
