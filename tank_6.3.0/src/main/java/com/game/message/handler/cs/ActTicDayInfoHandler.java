package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.ActionCenterService;

/**
 * @author yeding
 * @create 2019/4/2 15:55
 * @decs
 */
public class ActTicDayInfoHandler extends ClientHandler {
    @Override
    public void action() {
        getService(ActionCenterService.class).getTicDialDayInfo(this);
    }
}
