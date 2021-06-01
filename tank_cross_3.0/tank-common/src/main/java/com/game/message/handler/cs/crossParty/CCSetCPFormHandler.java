package com.game.message.handler.cs.crossParty;

import com.game.message.handler.ClientHandler;
import com.game.pb.CrossGamePb.CCSetCPFormRq;
import com.game.service.cross.party.CrossPartyService;

public class CCSetCPFormHandler extends ClientHandler {

  @Override
  public void action() {
    getService(CrossPartyService.class).setCPForm(msg.getExtension(CCSetCPFormRq.ext), this);
  }
}
