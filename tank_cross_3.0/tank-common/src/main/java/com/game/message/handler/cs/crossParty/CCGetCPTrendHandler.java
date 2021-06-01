package com.game.message.handler.cs.crossParty;

import com.game.message.handler.ClientHandler;
import com.game.pb.CrossGamePb.CCGetCPTrendRq;
import com.game.service.cross.party.CrossPartyService;

public class CCGetCPTrendHandler extends ClientHandler {

  @Override
  public void action() {
    getService(CrossPartyService.class).getCPTrend(msg.getExtension(CCGetCPTrendRq.ext), this);
  }
}
