package com.game.message.handler.cs.crossParty;

import com.game.message.handler.ClientHandler;
import com.game.pb.CrossGamePb.CCGetCrossPartyRq;
import com.game.service.cross.party.CrossPartyService;

public class CCGetCrossPartyHandler extends ClientHandler {

  @Override
  public void action() {
    getService(CrossPartyService.class)
        .getCrossPartyHandler(msg.getExtension(CCGetCrossPartyRq.ext), this);
  }
}
