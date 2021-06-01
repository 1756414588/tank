package com.game.message.handler.cs.crossParty;

import com.game.message.handler.ClientHandler;
import com.game.pb.CrossGamePb.CCGetCrossPartyStateRq;
import com.game.service.cross.party.CrossPartyService;

public class CCGetCrossPartyStateHandler extends ClientHandler {

  @Override
  public void action() {
    getService(CrossPartyService.class)
        .getCrossPartyState(msg.getExtension(CCGetCrossPartyStateRq.ext), this);
  }
}
