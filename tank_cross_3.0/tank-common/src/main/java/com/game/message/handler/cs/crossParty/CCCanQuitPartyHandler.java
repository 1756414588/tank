package com.game.message.handler.cs.crossParty;

import com.game.message.handler.ClientHandler;
import com.game.pb.CrossGamePb.CCCanQuitPartyRq;
import com.game.service.cross.party.CrossPartyService;

public class CCCanQuitPartyHandler extends ClientHandler {

  @Override
  public void action() {
    getService(CrossPartyService.class).canQuitParty(msg.getExtension(CCCanQuitPartyRq.ext), this);
  }
}
