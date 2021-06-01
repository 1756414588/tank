package com.game.message.handler.cs.fightlab;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6;
import com.game.service.FightLabService;

/**
 * @author GuiJie
 * @description 作战实验室 间谍地图激活
 * @created 2017/12/20 16:38
 */
public class ActFightLabSpyAreaHandler extends ClientHandler {
    @Override
    public void action() {
        GamePb6.ActFightLabSpyAreaRq req = msg.getExtension(GamePb6.ActFightLabSpyAreaRq.ext);
        getService(FightLabService.class).actArea(req, this);
    }
}
