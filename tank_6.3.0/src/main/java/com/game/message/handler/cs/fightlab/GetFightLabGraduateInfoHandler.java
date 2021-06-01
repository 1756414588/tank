package com.game.message.handler.cs.fightlab;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6;
import com.game.service.FightLabService;

/**
 * @author GuiJie
 * @description 作战实验室 获取深度研究所信息
 * @created 2017/12/20 16:38
 */
public class GetFightLabGraduateInfoHandler extends ClientHandler {
    @Override
    public void action() {
        GamePb6.GetFightLabGraduateInfoRq req = msg.getExtension(GamePb6.GetFightLabGraduateInfoRq.ext);
        getService(FightLabService.class).getFightLabGraduateInfo(req, this);
    }
}
