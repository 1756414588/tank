package com.game.message.handler.cs.cross;

import com.game.message.handler.ClientHandler;
import com.game.pb.CrossGamePb.CCGetCrossFormRq;
import com.game.service.cross.fight.CrossService;

public class CCGetCrossFormHandler extends ClientHandler {

  @Override
  public void action() {
    getService(CrossService.class).getCrossForm(msg.getExtension(CCGetCrossFormRq.ext), this);
  }
}
