package com.game.message.handler.cs.fightlab;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6;
import com.game.service.FightLabService;

/**
 * @author GuiJie
 * @description 作战实验室 科技升级
 * @created 2017/12/20 16:38
 */
public class UpFightLabTechUpLevelHandler extends ClientHandler {
    @Override
    public void action() {
        GamePb6.UpFightLabTechUpLevelRq req = msg.getExtension(GamePb6.UpFightLabTechUpLevelRq.ext);
        getService(FightLabService.class).upFightLabTechUpLevel(req, this);
    }
}
