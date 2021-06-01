package com.game.message.handler.cs.cross;

import com.game.message.handler.ClientHandler;
import com.game.pb.CrossGamePb.CCReceiveRankRwardRq;
import com.game.service.cross.fight.CrossService;

public class CCReceiveRankRwardHandler extends ClientHandler {

  @Override
  public void action() {
    getService(CrossService.class)
        .receiveRankRwardHandler(msg.getExtension(CCReceiveRankRwardRq.ext), this);
  }
}
