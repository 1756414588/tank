package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6.GetTicDialDayAwardRq;
import com.game.service.ActionCenterService;

/**
 * @author yeding
 * @create 2019/4/2 15:56
 * @decs
 */
public class ActTicGetDayAwardHandler extends ClientHandler {
    @Override
    public void action() {
        getService(ActionCenterService.class).getTicDialDayAward(this, msg.getExtension(GetTicDialDayAwardRq.ext));
    }
}
