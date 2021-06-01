package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb2.PartyApplyJudgeRq;
import com.game.service.PartyService;

public class PartyApplyJudgeHandler extends ClientHandler {

	@Override
	public void action() {
		PartyApplyJudgeRq req = msg.getExtension(PartyApplyJudgeRq.ext);
		getService(PartyService.class).partyApplyJudgeRq(req, this);
	}

}
