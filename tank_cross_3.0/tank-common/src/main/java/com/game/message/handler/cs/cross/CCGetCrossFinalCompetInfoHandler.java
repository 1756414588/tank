package com.game.message.handler.cs.cross;

import com.game.message.handler.ClientHandler;
import com.game.pb.CrossGamePb.CCGetCrossFinalCompetInfoRq;
import com.game.service.cross.fight.CrossService;

public class CCGetCrossFinalCompetInfoHandler extends ClientHandler {

  @Override
  public void action() {
    getService(CrossService.class)
        .getCrossFinalCompetInfo(msg.getExtension(CCGetCrossFinalCompetInfoRq.ext), this);
  }
}
