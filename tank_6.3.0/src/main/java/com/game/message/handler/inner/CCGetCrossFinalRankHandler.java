package com.game.message.handler.inner;

import com.game.message.handler.InnerHandler;
import com.game.pb.CrossGamePb.CCGetCrossFinalRankRs;
import com.game.service.CrossService;

public class CCGetCrossFinalRankHandler extends InnerHandler {

	@Override
	public void action() {
		getService(CrossService.class).getCrossFinalRank(msg.getExtension(CCGetCrossFinalRankRs.ext),this);
	}

}
