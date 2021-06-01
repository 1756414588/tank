package com.game.message.handler.cs.crossParty;

import com.game.message.handler.ClientHandler;
import com.game.pb.CrossGamePb.CCGetCrossPartyMemberRq;
import com.game.service.cross.party.CrossPartyService;

public class CCGetCrossPartyMemberHandler extends ClientHandler {

  @Override
  public void action() {
    getService(CrossPartyService.class)
        .getCrossPartyMember(msg.getExtension(CCGetCrossPartyMemberRq.ext), this);
  }
}
