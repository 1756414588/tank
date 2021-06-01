package com.game.message.handler.cs.fightlab;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6;
import com.game.service.FightLabService;

/**
 * @author GuiJie
 * @description 作战实验室设置人员信息
 * @created 2017/12/20 16:38
 */
public class SetFightLabPersonCountHandler extends ClientHandler {
    @Override
    public void action() {
        GamePb6.SetFightLabPersonCountRq req = msg.getExtension(GamePb6.SetFightLabPersonCountRq.ext);
        getService(FightLabService.class).setFightLabPersonCount(req, this);
    }
}
