package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6;
import com.game.service.BoxRewardService;

/**
 * @author GuiJie
 * @description 点击宝箱获得奖励
 * @created 2017/12/20 16:38
 */
public class GetGiftRewardHandler extends ClientHandler {
    @Override
    public void action() {
        GamePb6.GetGiftRewardRq req = msg.getExtension(GamePb6.GetGiftRewardRq.ext);
        getService(BoxRewardService.class).getGiftReward(req, this);
    }
}
