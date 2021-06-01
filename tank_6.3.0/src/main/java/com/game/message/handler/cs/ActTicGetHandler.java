package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6;
import com.game.service.ActionCenterService;

/**
 * @author yeding
 * @create 2019/4/2 15:52
 * @decs
 */
public class ActTicGetHandler extends ClientHandler {
    @Override
    public void action() {
        getService(ActionCenterService.class).doActTicDialRq(this, msg.getExtension(GamePb6.DoActTicDialRq.ext));
    }
}
