package com.game.message.handler.cs.cross;

import com.game.message.handler.ClientHandler;
import com.game.pb.CrossGamePb.CCGetCrossJiFenRankRq;
import com.game.service.cross.fight.CrossService;

public class CCGetCrossJiFenRankHandler extends ClientHandler {

  @Override
  public void action() {
    getService(CrossService.class)
        .getCrossJiFenRank(msg.getExtension(CCGetCrossJiFenRankRq.ext), this);
  }
}
