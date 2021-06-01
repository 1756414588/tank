package com.game.message.handler.cs.cross;

import com.game.message.handler.ClientHandler;
import com.game.pb.CrossGamePb.CCGMSetCrossFormRq;
import com.game.service.cross.fight.CrossService;

public class CCGMSetCrossFormHanlder extends ClientHandler {

  @Override
  public void action() {
    getService(CrossService.class).gMSetCrossForm(msg.getExtension(CCGMSetCrossFormRq.ext), this);
  }
}
