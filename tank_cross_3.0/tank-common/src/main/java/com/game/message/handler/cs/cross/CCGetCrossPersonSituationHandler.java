package com.game.message.handler.cs.cross;

import com.game.message.handler.ClientHandler;
import com.game.pb.CrossGamePb.CCGetCrossPersonSituationRq;
import com.game.service.cross.fight.CrossService;

public class CCGetCrossPersonSituationHandler extends ClientHandler {

  @Override
  public void action() {
    getService(CrossService.class)
        .getCrossPersonSituation(msg.getExtension(CCGetCrossPersonSituationRq.ext), this);
  }
}
