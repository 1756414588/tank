package com.game.message.handler.cs.airship;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5.RecvAirshipProduceAwardRq;
import com.game.service.airship.AirshipService;

public class RecvAirshipProduceAwardHandler extends ClientHandler {
	
	@Override
	public void action() {
		RecvAirshipProduceAwardRq req = msg.getExtension(RecvAirshipProduceAwardRq.ext);
		getService(AirshipService.class).recvAirshipProduceAward(req,this);
	}

}
