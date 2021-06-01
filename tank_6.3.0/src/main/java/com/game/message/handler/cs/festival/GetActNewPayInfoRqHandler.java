package com.game.message.handler.cs.festival;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6;
import com.game.service.ActivityNewService;

/**
 * @author GuiJie
 * @description 获取新首冲信息
 */
public class GetActNewPayInfoRqHandler extends ClientHandler {
    @Override
    public void action() {
        GamePb6.GetActNewPayInfoRq req = msg.getExtension(GamePb6.GetActNewPayInfoRq.ext);
        getService(ActivityNewService.class).getActNewPayInfoRq(req, this);
    }
}
