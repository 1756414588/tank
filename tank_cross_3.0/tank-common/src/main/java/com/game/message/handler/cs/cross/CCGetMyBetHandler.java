package com.game.message.handler.cs.cross;

import com.game.message.handler.ClientHandler;
import com.game.pb.CrossGamePb.CCGetMyBetRq;
import com.game.service.cross.fight.CrossService;

public class CCGetMyBetHandler extends ClientHandler {

  @Override
  public void action() {
    getService(CrossService.class).getMyBet(msg.getExtension(CCGetMyBetRq.ext), this);
  }
}
