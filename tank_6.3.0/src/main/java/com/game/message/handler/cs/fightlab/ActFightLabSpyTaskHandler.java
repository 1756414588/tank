package com.game.message.handler.cs.fightlab;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6;
import com.game.service.FightLabService;

/**
 * @author GuiJie
 * @description 作战实验室 间谍任务派遣
 * @created 2017/12/20 16:38
 */
public class ActFightLabSpyTaskHandler extends ClientHandler {
    @Override
    public void action() {
        GamePb6.ActFightLabSpyTaskRq req = msg.getExtension(GamePb6.ActFightLabSpyTaskRq.ext);
        getService(FightLabService.class).actSpyTask(req, this);
    }
}
