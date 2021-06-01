package com.game.message.handler.cs.cross;

import com.game.message.handler.ClientHandler;
import com.game.pb.CrossGamePb.CCGetCrossReportRq;
import com.game.service.cross.fight.CrossService;

public class CCGetCrossReportHandler extends ClientHandler {

  @Override
  public void action() {
    getService(CrossService.class).getCrossReport(msg.getExtension(CCGetCrossReportRq.ext), this);
  }
}
