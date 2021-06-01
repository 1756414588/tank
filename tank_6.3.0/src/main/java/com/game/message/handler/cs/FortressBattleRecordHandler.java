package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb4.FortressBattleRecordRq;
import com.game.service.FortressWarService;

public class FortressBattleRecordHandler extends ClientHandler {

	@Override
	public void action() {
		getService(FortressWarService.class).fortressBattleRecord(msg.getExtension(FortressBattleRecordRq.ext), this);
	}

}
	