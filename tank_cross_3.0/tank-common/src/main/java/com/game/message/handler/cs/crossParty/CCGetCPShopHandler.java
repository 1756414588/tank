package com.game.message.handler.cs.crossParty;

import com.game.message.handler.ClientHandler;
import com.game.pb.CrossGamePb.CCGetCPShopRq;
import com.game.service.cross.party.CrossPartyService;

public class CCGetCPShopHandler extends ClientHandler {

  @Override
  public void action() {
    getService(CrossPartyService.class).getCPShop(msg.getExtension(CCGetCPShopRq.ext), this);
  }
}
