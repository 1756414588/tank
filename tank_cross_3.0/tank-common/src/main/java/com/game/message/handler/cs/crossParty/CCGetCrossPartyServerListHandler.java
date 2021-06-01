package com.game.message.handler.cs.crossParty;

import com.game.message.handler.ClientHandler;
import com.game.pb.CrossGamePb.CCGetCrossPartyServerListRq;
import com.game.service.cross.party.CrossPartyService;

public class CCGetCrossPartyServerListHandler extends ClientHandler {

  @Override
  public void action() {
    getService(CrossPartyService.class)
        .getCrossPartyServerList(msg.getExtension(CCGetCrossPartyServerListRq.ext), this);
  }
}
