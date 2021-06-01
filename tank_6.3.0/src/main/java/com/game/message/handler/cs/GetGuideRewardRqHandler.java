package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6;
import com.game.service.BoxRewardService;

/**
 * @author GuiJie
 * @description 新手引导获取奖励
 * @created 2017/12/20 16:38
 */
public class GetGuideRewardRqHandler extends ClientHandler {
    @Override
    public void action() {
        GamePb6.GetGuideRewardRq req = msg.getExtension(GamePb6.GetGuideRewardRq.ext);
        getService(BoxRewardService.class).getGuideReward(req, this);
    }
}
