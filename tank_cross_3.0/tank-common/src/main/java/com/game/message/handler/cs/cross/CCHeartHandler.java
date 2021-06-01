package com.game.message.handler.cs.cross;

import com.game.message.handler.ClientHandler;
import com.game.service.cross.fight.CrossService;

public class CCHeartHandler extends ClientHandler {

  @Override
  public void action() {
    getService(CrossService.class).heart(this);
  }
}
