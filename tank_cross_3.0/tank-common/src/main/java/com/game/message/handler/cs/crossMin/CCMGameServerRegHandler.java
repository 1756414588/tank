package com.game.message.handler.cs.crossMin;

import com.game.message.handler.ClientHandler;
import com.game.pb.CrossMinPb;
import com.game.service.crossmin.CrossMinService;

/**
 * @Author :GuiJie Liu
 * @date :Create in 2019/3/13 14:15 @Description :java类作用描述
 */
public class CCMGameServerRegHandler extends ClientHandler {

    @Override
    public void action() {
        getService(CrossMinService.class).connectGameServerReg(msg.getExtension(CrossMinPb.CrossMinGameServerRegRq.ext), this);
    }
}
