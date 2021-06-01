package com.game.message.handler.inner.crossParty;

import com.game.message.handler.InnerHandler;
import com.game.pb.CrossGamePb.CCGetCrossPartyMemberRs;
import com.game.service.CrossPartyService;

public class CCGetCrossPartyMemberHandler extends InnerHandler {

	@Override
	public void action() {
		getService(CrossPartyService.class).getCrossPartyMember(msg.getCode(),msg.getExtension(CCGetCrossPartyMemberRs.ext), this);
	}

}
