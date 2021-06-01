package com.game.message.handler.crossmin;

import com.game.message.handler.InnerHandler;
import com.game.pb.CrossMinPb;
import com.game.service.crossmin.CrossMinService;

/**
 * @author yeding
 * @create 2019/4/24 17:49
 * @decs
 */
public class CrossTeamChatHandler extends InnerHandler {
    @Override
    public void action() {
        getService(CrossMinService.class).crossTeamChat(this,msg.getExtension(CrossMinPb.CrossSynTeamChatRq.ext));
    }
}
