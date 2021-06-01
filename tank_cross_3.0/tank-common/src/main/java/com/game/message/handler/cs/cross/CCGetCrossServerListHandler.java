package com.game.message.handler.cs.cross;

import com.game.message.handler.ClientHandler;
import com.game.pb.CrossGamePb.CCGetCrossServerListRq;
import com.game.service.cross.fight.CrossService;

public class CCGetCrossServerListHandler extends ClientHandler {

  @Override
  public void action() {
    getService(CrossService.class)
        .getCrossServerList(msg.getExtension(CCGetCrossServerListRq.ext), this);
  }
}
