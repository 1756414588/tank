package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.ActionCenterService;

/**
 * @author yeding
 * @create 2019/4/2 15:49
 * @decs
 */
public class ActTicHandler extends ClientHandler {
    @Override
    public void action() {
        getService(ActionCenterService.class).getActTicStoneDialRq(this);
    }
}
