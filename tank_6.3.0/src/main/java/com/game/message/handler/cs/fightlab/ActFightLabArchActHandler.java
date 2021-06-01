package com.game.message.handler.cs.fightlab;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6;
import com.game.service.FightLabService;

/**
 * @author GuiJie
 * @description 作战实验室 建筑激活
 * @created 2017/12/20 16:38
 */
public class ActFightLabArchActHandler extends ClientHandler {
    @Override
    public void action() {
        GamePb6.ActFightLabArchActRq req = msg.getExtension(GamePb6.ActFightLabArchActRq.ext);
        getService(FightLabService.class).actFightLabArchAct(req, this);
    }
}
