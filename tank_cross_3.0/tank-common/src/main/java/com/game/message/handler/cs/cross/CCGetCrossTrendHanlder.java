package com.game.message.handler.cs.cross;

import com.game.message.handler.ClientHandler;
import com.game.pb.CrossGamePb.CCGetCrossTrendRq;
import com.game.service.cross.fight.CrossService;

public class CCGetCrossTrendHanlder extends ClientHandler {

  @Override
  public void action() {
    getService(CrossService.class).getCrossTrend(msg.getExtension(CCGetCrossTrendRq.ext), this);
  }
}
