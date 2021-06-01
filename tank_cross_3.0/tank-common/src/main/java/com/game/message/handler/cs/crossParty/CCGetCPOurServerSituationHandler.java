package com.game.message.handler.cs.crossParty;

import com.game.message.handler.ClientHandler;
import com.game.pb.CrossGamePb.CCGetCPOurServerSituationRq;
import com.game.service.cross.party.CrossPartyService;

public class CCGetCPOurServerSituationHandler extends ClientHandler {

  @Override
  public void action() {
    getService(CrossPartyService.class)
        .getCPOurServerSituation(msg.getExtension(CCGetCPOurServerSituationRq.ext), this);
  }
}
