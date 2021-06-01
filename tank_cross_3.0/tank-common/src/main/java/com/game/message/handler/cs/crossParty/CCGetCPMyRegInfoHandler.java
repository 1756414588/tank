package com.game.message.handler.cs.crossParty;

import com.game.message.handler.ClientHandler;
import com.game.pb.CrossGamePb.CCGetCPMyRegInfoRq;
import com.game.service.cross.party.CrossPartyService;

public class CCGetCPMyRegInfoHandler extends ClientHandler {

  @Override
  public void action() {
    getService(CrossPartyService.class)
        .getCPMyRegInfo(msg.getExtension(CCGetCPMyRegInfoRq.ext), this);
  }
}
