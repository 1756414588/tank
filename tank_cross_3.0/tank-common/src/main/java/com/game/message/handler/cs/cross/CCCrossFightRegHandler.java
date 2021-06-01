package com.game.message.handler.cs.cross;

import com.game.message.handler.ClientHandler;
import com.game.pb.CrossGamePb.CCCrossFightRegRq;
import com.game.service.cross.fight.CrossService;

public class CCCrossFightRegHandler extends ClientHandler {

  @Override
  public void action() {
    getService(CrossService.class).crossFightReg(msg.getExtension(CCCrossFightRegRq.ext), this);
  }
}
