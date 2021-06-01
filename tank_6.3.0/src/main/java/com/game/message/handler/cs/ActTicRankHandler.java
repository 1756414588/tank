package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.ActionCenterService;

/**
 * @author yeding
 * @create 2019/4/2 15:50
 * @decs
 */
public class ActTicRankHandler extends ClientHandler {
    @Override
    public void action() {
        getService(ActionCenterService.class).getActTicDialRankRq(this);
    }
}
