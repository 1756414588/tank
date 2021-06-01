package com.game.message.handler.cs.cross;

import com.game.message.handler.ClientHandler;
import com.game.pb.CrossGamePb.CCGetCrossRegInfoRq;
import com.game.service.cross.fight.CrossService;

public class CCGetCrossRegInfoHandler extends ClientHandler {

  @Override
  public void action() {
    getService(CrossService.class).getCrossRegInfo(msg.getExtension(CCGetCrossRegInfoRq.ext), this);
  }
}
