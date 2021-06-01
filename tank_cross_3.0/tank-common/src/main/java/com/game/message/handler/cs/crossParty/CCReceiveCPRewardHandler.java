package com.game.message.handler.cs.crossParty;

import com.game.message.handler.ClientHandler;
import com.game.pb.CrossGamePb.CCReceiveCPRewardRq;
import com.game.service.cross.party.CrossPartyService;

public class CCReceiveCPRewardHandler extends ClientHandler {

  @Override
  public void action() {
    getService(CrossPartyService.class)
        .receiveCPReward(msg.getExtension(CCReceiveCPRewardRq.ext), this);
  }
}
