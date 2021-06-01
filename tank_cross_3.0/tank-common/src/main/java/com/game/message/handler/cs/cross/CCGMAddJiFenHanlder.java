package com.game.message.handler.cs.cross;

import com.game.message.handler.ClientHandler;
import com.game.pb.CrossGamePb.CCGMAddJiFenRq;
import com.game.service.cross.fight.CrossService;

public class CCGMAddJiFenHanlder extends ClientHandler {

  @Override
  public void action() {
    getService(CrossService.class).gMAddJifen(msg.getExtension(CCGMAddJiFenRq.ext), this);
  }
}
