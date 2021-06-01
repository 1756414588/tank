package com.game.message.handler.cs.lucky;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6;
import com.game.service.ActivityNewService;

/**
 * @author GuiJie
 * @description 幸运奖池单次抽取
 * @created 2018-04-17 16:27:39
 */
public class GetActLuckyRewardRqHandler extends ClientHandler {
    @Override
    public void action() {
        GamePb6.GetActLuckyRewardRq req = msg.getExtension(GamePb6.GetActLuckyRewardRq.ext);
        getService(ActivityNewService.class).getActLuckyReward(req, this);
    }
}
