package com.game.message.handler.cs.fightlab;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6;
import com.game.service.FightLabService;

/**
 * @author GuiJie
 * @description 作战实验室 领取生产的资源
 * @created 2017/12/20 16:38
 */
public class GetFightLabResourceHandler extends ClientHandler {
    @Override
    public void action() {
        GamePb6.GetFightLabResourceRq req = msg.getExtension(GamePb6.GetFightLabResourceRq.ext);
        getService(FightLabService.class).getFightLabResource(req, this);
    }
}
