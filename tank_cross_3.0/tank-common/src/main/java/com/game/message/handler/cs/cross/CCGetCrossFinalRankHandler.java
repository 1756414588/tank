package com.game.message.handler.cs.cross;

import com.game.message.handler.ClientHandler;
import com.game.pb.CrossGamePb.CCGetCrossFinalRankRq;
import com.game.service.cross.fight.CrossService;

public class CCGetCrossFinalRankHandler extends ClientHandler {

  @Override
  public void action() {
    getService(CrossService.class)
        .getCrossFinalRank(msg.getExtension(CCGetCrossFinalRankRq.ext), this);
  }
}
