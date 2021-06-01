package com.game.message.handler.cs.cross;

import com.game.message.handler.ClientHandler;
import com.game.pb.CrossGamePb.CCGetCrossFightStateRq;
import com.game.service.cross.fight.CrossService;

public class CCGetCrossFightStateHandler extends ClientHandler {

  @Override
  public void action() {
    getService(CrossService.class)
        .getCrossFightState(msg.getExtension(CCGetCrossFightStateRq.ext), this);
  }
}
