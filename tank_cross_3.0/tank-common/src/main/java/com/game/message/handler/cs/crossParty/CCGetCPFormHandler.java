package com.game.message.handler.cs.crossParty;

import com.game.message.handler.ClientHandler;
import com.game.pb.CrossGamePb.CCGetCPFormRq;
import com.game.service.cross.party.CrossPartyService;

public class CCGetCPFormHandler extends ClientHandler {

  @Override
  public void action() {
    getService(CrossPartyService.class).getCPForm(msg.getExtension(CCGetCPFormRq.ext), this);
  }
}
