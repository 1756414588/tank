package com.game.message.handler.cs.festival;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6;
import com.game.service.ActivityNewService;

/**
 * @author GuiJie
 * @description 假日碎片兑换
 * @created 2018-04-17 16:27:39
 */
public class GetFestivalRewardRqHandler extends ClientHandler {
    @Override
    public void action() {
        GamePb6.GetFestivalRewardRq req = msg.getExtension(GamePb6.GetFestivalRewardRq.ext);
        getService(ActivityNewService.class).getFestivalReward(req, this);
    }
}
