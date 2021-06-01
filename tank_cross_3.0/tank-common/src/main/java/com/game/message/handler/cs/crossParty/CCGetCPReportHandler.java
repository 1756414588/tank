package com.game.message.handler.cs.crossParty;

import com.game.message.handler.ClientHandler;
import com.game.pb.CrossGamePb.CCGetCPReportRq;
import com.game.service.cross.party.CrossPartyService;

public class CCGetCPReportHandler extends ClientHandler {

  @Override
  public void action() {
    getService(CrossPartyService.class).getCPReport(msg.getExtension(CCGetCPReportRq.ext), this);
  }
}
