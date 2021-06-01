package com.game.message.handler.crossmin;

import com.game.message.handler.ServerHandler;
import com.game.pb.CrossMinPb;
import com.game.pb.InnerPb.NotifyCrossOnLineRq;
import com.game.service.CrossService;
import com.game.service.crossmin.CrossMinService;

public class CrossMinNotifyRqHandler extends ServerHandler {

	@Override
	public void action() {
		getService(CrossMinService.class).crossMinNotifyRq(msg.getExtension(CrossMinPb.CrossMinNotifyRq.ext));
	}

}
