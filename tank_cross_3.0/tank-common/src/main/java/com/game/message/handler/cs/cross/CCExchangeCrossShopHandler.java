package com.game.message.handler.cs.cross;

import com.game.message.handler.ClientHandler;
import com.game.pb.CrossGamePb.CCExchangeCrossShopRq;
import com.game.service.cross.fight.CrossService;

public class CCExchangeCrossShopHandler extends ClientHandler {

  @Override
  public void action() {
    getService(CrossService.class)
        .exchangeCrossShop(msg.getExtension(CCExchangeCrossShopRq.ext), this);
  }
}
