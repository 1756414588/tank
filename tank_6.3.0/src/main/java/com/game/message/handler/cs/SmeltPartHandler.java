package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5.SmeltPartRq;
import com.game.service.PartService;

public class SmeltPartHandler extends ClientHandler {

	@Override
	public void action() {
		//Auto-generated method stub
		PartService service = getService(PartService.class);
		SmeltPartRq req = msg.getExtension(SmeltPartRq.ext);
		service.smeltPart(req, this);
	}
}
