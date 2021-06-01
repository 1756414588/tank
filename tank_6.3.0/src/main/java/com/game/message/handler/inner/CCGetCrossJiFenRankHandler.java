package com.game.message.handler.inner;

import com.game.message.handler.InnerHandler;
import com.game.pb.CrossGamePb.CCGetCrossJiFenRankRs;
import com.game.service.CrossService;

public class CCGetCrossJiFenRankHandler extends InnerHandler {

	@Override
	public void action() {
		getService(CrossService.class).getCrossJiFenRank(msg.getExtension(CCGetCrossJiFenRankRs.ext),this);
	}

}
