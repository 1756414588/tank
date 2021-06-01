package com.game.message.handler.cs.redplan;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6;
import com.game.service.RedPlanService;

/**
 * @author GuiJie
 * @description 描述
 * @created 2018/03/21 14:28
 */
public class GetRedPlanBoxRqHandler extends ClientHandler {
    @Override
    public void action() {
        GamePb6.GetRedPlanBoxRq req = msg.getExtension(GamePb6.GetRedPlanBoxRq.ext);
        getService(RedPlanService.class).getRewardBox(req,this);
    }
}
