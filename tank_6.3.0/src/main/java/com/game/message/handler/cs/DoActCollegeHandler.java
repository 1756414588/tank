package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5.DoActCollegeRq;
import com.game.service.ActionCenterService;

public class DoActCollegeHandler extends ClientHandler {

	@Override
	public void action() {
		DoActCollegeRq req = msg.getExtension(DoActCollegeRq.ext);
		getService(ActionCenterService.class).doActCollege(req, this);
	}

}
