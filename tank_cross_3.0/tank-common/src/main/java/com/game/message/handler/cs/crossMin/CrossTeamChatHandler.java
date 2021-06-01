package com.game.message.handler.cs.crossMin;

import com.game.message.handler.ClientHandler;
import com.game.pb.CrossMinPb;
import com.game.service.crossmin.CrossMinService;

/**
 * @author yeding
 * @create 2019/7/8 13:53
 * @decs
 */
public class CrossTeamChatHandler extends ClientHandler {
    @Override
    public void action() {
        getService(CrossMinService.class).teamChat(msg.getExtension(CrossMinPb.CrossTeamChatRq.ext));

    }
}
