package com.game.message.handler.cs.crossParty;

import com.game.message.handler.ClientHandler;
import com.game.pb.CrossGamePb.CCCrossPartyRegRq;
import com.game.service.cross.party.CrossPartyService;

public class CCCrossPartyRegHandler extends ClientHandler {

  @Override
  public void action() {
    getService(CrossPartyService.class)
        .crossPartyReg(msg.getExtension(CCCrossPartyRegRq.ext), this);
  }
}
