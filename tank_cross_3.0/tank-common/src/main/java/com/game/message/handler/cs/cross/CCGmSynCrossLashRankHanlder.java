package com.game.message.handler.cs.cross;

import com.game.message.handler.ClientHandler;
import com.game.pb.CrossGamePb.CCGmSynCrossLashRankRq;
import com.game.service.cross.fight.CrossService;
import com.game.service.cross.party.CrossPartyService;

public class CCGmSynCrossLashRankHanlder extends ClientHandler {

  @Override
  public void action() {

    CCGmSynCrossLashRankRq rq = msg.getExtension(CCGmSynCrossLashRankRq.ext);

    int type = 1;
    if (rq.hasType()) {
      type = rq.getType();
    }

    if (type == 1) {
      getService(CrossService.class).synCrossRank();
    } else if (type == 2) {
      getService(CrossPartyService.class).synCpFame();
    }
  }
}
