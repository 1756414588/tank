package com.game.message.handler.cs.crossParty;

import com.game.message.handler.ClientHandler;
import com.game.pb.CrossGamePb.CCExchangeCPShopRq;
import com.game.service.cross.party.CrossPartyService;

public class CCExchangeCPShopHandler extends ClientHandler {

  @Override
  public void action() {
    getService(CrossPartyService.class)
        .exchangeCPShop(msg.getExtension(CCExchangeCPShopRq.ext), this);
  }
}
