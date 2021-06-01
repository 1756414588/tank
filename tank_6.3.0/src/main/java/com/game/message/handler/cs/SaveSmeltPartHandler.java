package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5.SaveSmeltPartRq;
import com.game.service.PartService;

public class SaveSmeltPartHandler extends ClientHandler {

	@Override
	public void action() {
		//Auto-generated method stub
		PartService service = getService(PartService.class);
		SaveSmeltPartRq req = msg.getExtension(SaveSmeltPartRq.ext);
		service.saveSmeltPart(req, this);
	}
}
