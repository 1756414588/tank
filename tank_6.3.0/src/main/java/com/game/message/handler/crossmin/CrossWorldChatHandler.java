package com.game.message.handler.crossmin;

import com.game.message.handler.InnerHandler;
import com.game.pb.CrossMinPb;
import com.game.service.crossmin.CrossMinService;

/**
 * @author yeding
 * @create 2019/4/30 13:50
 * @decs
 */
public class CrossWorldChatHandler extends InnerHandler {
    @Override
    public void action() {
        getService(CrossMinService.class).crossWoldChat(msg.getExtension(CrossMinPb.CrossWorldChatRq.ext));
    }
}
