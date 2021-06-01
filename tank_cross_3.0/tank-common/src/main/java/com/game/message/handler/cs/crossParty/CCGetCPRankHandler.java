package com.game.message.handler.cs.crossParty;

import com.game.message.handler.ClientHandler;
import com.game.pb.CrossGamePb.CCGetCPRankRq;
import com.game.service.cross.party.CrossPartyService;

public class CCGetCPRankHandler extends ClientHandler {

  @Override
  public void action() {
    getService(CrossPartyService.class).getCPRank(msg.getExtension(CCGetCPRankRq.ext), this);
  }
}
