package com.game.message.handler.cs.cross;

import com.game.message.handler.ClientHandler;
import com.game.pb.CrossGamePb.CCGetCrossShopRq;
import com.game.service.cross.fight.CrossService;

public class CCGetCrossShopHandler extends ClientHandler {

  @Override
  public void action() {
    getService(CrossService.class).getCrossShop(msg.getExtension(CCGetCrossShopRq.ext), this);
  }
}
