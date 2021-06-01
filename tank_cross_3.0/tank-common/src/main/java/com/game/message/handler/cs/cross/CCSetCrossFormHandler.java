package com.game.message.handler.cs.cross;

import com.game.message.handler.ClientHandler;
import com.game.pb.CrossGamePb.CCSetCrossFormRq;
import com.game.service.cross.fight.CrossService;

public class CCSetCrossFormHandler extends ClientHandler {

  @Override
  public void action() {
    getService(CrossService.class).setCrossForm(msg.getExtension(CCSetCrossFormRq.ext), this);
  }
}
