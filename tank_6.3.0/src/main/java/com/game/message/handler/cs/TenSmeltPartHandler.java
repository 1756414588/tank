package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5.TenSmeltPartRq;
import com.game.service.PartService;

public class TenSmeltPartHandler extends ClientHandler {

	@Override
	public void action() {
		//Auto-generated method stub
		PartService service = getService(PartService.class);
		TenSmeltPartRq req = msg.getExtension(TenSmeltPartRq.ext);
		service.tenSmeltPart(req, this);
	}
}
