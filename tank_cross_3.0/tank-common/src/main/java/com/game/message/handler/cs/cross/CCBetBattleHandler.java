package com.game.message.handler.cs.cross;

import com.game.message.handler.ClientHandler;
import com.game.pb.CrossGamePb.CCBetBattleRq;
import com.game.service.cross.fight.CrossService;

public class CCBetBattleHandler extends ClientHandler {

  @Override
  public void action() {
    getService(CrossService.class).betBattle(msg.getExtension(CCBetBattleRq.ext), this);
  }
}
