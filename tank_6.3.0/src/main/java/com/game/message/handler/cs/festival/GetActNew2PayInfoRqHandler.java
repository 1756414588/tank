package com.game.message.handler.cs.festival;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6;
import com.game.service.ActivityNewService;

/**
 * @author GuiJie
 * @description 获取新首冲信息
 */
public class GetActNew2PayInfoRqHandler extends ClientHandler {
    @Override
    public void action() {
        GamePb6.GetActNew2PayInfoRq req = msg.getExtension(GamePb6.GetActNew2PayInfoRq.ext);
        getService(ActivityNewService.class).getActNew2PayInfoRq(req, this);
    }
}
