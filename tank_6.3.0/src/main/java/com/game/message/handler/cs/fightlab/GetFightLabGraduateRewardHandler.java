package com.game.message.handler.cs.fightlab;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6;
import com.game.service.FightLabService;

/**
 * @author GuiJie
 * @description 作战实验室 获取领取奖励信息
 * @created 2017/12/20 16:38
 */
public class GetFightLabGraduateRewardHandler extends ClientHandler {
    @Override
    public void action() {
        GamePb6.GetFightLabGraduateRewardRq req = msg.getExtension(GamePb6.GetFightLabGraduateRewardRq.ext);
        getService(FightLabService.class).getFightLabGraduateReward(req, this);
    }
}
