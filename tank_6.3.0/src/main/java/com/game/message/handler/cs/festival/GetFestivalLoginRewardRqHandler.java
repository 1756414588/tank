package com.game.message.handler.cs.festival;

import com.game.message.handler.ClientHandler;
import com.game.service.ActivityNewService;

/**
 * @author GuiJie
 * @description 假日碎片领取登录奖励
 * @created 2018-04-17 16:27:39
 */
public class GetFestivalLoginRewardRqHandler extends ClientHandler {
    @Override
    public void action() {
        getService(ActivityNewService.class).getFestivalLoginReward(this);
    }
}
