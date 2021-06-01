package com.game.message.handler.cs.cross;

import com.game.message.handler.ClientHandler;
import com.game.pb.CrossGamePb.CCGameServerRegRq;
import com.game.service.cross.CrossRegisterService;
/**
 * @Author :GuiJie Liu
 *
 * @date :Create in 2019/3/13 14:15 @Description :java类作用描述
 */
public class CCGameServerRegHandler extends ClientHandler {

  @Override
  public void action() {
    getService(CrossRegisterService.class)
        .gameServerReg(msg.getExtension(CCGameServerRegRq.ext), this);
  }
}
