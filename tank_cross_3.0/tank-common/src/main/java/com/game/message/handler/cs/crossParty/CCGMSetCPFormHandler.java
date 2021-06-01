package com.game.message.handler.cs.crossParty;

import com.game.message.handler.ClientHandler;
import com.game.pb.CrossGamePb.CCGMSetCPFormRq;
import com.game.service.cross.party.CrossPartyService;

public class CCGMSetCPFormHandler extends ClientHandler {

  @Override
  public void action() {
    getService(CrossPartyService.class).gMSetCPForm(msg.getExtension(CCGMSetCPFormRq.ext), this);
  }
}
