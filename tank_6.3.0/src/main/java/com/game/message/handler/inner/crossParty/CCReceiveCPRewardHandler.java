package com.game.message.handler.inner.crossParty;

import com.game.message.handler.InnerHandler;
import com.game.pb.CrossGamePb.CCReceiveCPRewardRs;
import com.game.service.CrossPartyService;

public class CCReceiveCPRewardHandler extends InnerHandler {

	@Override
	public void action() {
		getService(CrossPartyService.class).receiveCPReward(msg.getCode(),msg.getExtension(CCReceiveCPRewardRs.ext), this);
	}

}
