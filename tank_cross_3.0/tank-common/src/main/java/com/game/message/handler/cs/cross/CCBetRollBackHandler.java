package com.game.message.handler.cs.cross;

import com.game.message.handler.ClientHandler;
import com.game.pb.CrossGamePb.CCBetRollBackRq;
import com.game.service.cross.fight.CrossService;

public class CCBetRollBackHandler extends ClientHandler {

  @Override
  public void action() {
    getService(CrossService.class).betRollBack(msg.getExtension(CCBetRollBackRq.ext), this);
  }
}
