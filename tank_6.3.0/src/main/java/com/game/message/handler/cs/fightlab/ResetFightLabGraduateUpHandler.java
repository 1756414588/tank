package com.game.message.handler.cs.fightlab;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6;
import com.game.service.FightLabService;

/**
 * @author GuiJie
 * @description 作战实验室 深度研究所 重置
 * @created 2017/12/20 16:38
 */
public class ResetFightLabGraduateUpHandler extends ClientHandler {
    @Override
    public void action() {
        GamePb6.ResetFightLabGraduateUpRq req = msg.getExtension(GamePb6.ResetFightLabGraduateUpRq.ext);
        getService(FightLabService.class).resetFightLabGraduateUp(req, this);
    }
}
