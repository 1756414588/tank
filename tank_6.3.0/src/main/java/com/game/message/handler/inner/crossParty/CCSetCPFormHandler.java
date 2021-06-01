package com.game.message.handler.inner.crossParty;

import com.game.message.handler.InnerHandler;
import com.game.pb.CrossGamePb.CCSetCPFormRs;
import com.game.service.CrossPartyService;

public class CCSetCPFormHandler extends InnerHandler {

	@Override
	public void action() {
		getService(CrossPartyService.class).setCPForm(msg.getCode(), msg.getExtension(CCSetCPFormRs.ext), this);
	}

}
