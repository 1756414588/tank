package com.game.message.handler.cs.cross;

import com.game.message.handler.ClientHandler;
import com.game.pb.CrossGamePb.CCCancelCrossRegRq;
import com.game.service.cross.fight.CrossService;

public class CCCancelCrossRegHandler extends ClientHandler {

  @Override
  public void action() {
    getService(CrossService.class).cancelCrossReg(msg.getExtension(CCCancelCrossRegRq.ext), this);
  }
}
