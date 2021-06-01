package com.game.message.handler.cs.redplan;

import com.game.message.handler.ClientHandler;
import com.game.service.RedPlanService;

/**
 * @author GuiJie
 * @description 描述
 * @created 2018/03/21 14:28
 */
public class GetRedPlanInfoHandler extends ClientHandler {
    @Override
    public void action() {
        getService(RedPlanService.class).getRedPlanInfo(this);
    }
}
