package com.game.message.handler.cs.fightlab;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6;
import com.game.service.FightLabService;

/**
 * @author GuiJie
 * @description 作战实验室 获取间谍信息
 * @created 2017/12/20 16:38
 */
public class GetFightLabSpyInfoHandler extends ClientHandler {
    @Override
    public void action() {
        GamePb6.GetFightLabSpyInfoRq req = msg.getExtension(GamePb6.GetFightLabSpyInfoRq.ext);
        getService(FightLabService.class).getSpyInfo(req, this);
    }
}
