package com.game.message.handler.cs.cross;

import com.game.message.handler.ClientHandler;
import com.game.pb.CrossGamePb.CCGetCrossKnockCompetInfoRq;
import com.game.service.cross.fight.CrossService;

public class CCGetCrossKnockCompetInfoHandler extends ClientHandler {

  @Override
  public void action() {
    getService(CrossService.class)
        .getCrossKnockCompetInfo(msg.getExtension(CCGetCrossKnockCompetInfoRq.ext), this);
  }
}
