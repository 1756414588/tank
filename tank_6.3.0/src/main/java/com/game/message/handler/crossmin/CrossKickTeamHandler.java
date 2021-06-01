package com.game.message.handler.crossmin;

import com.game.message.handler.InnerHandler;
import com.game.pb.CrossMinPb;
import com.game.service.crossmin.CrossMinService;

/**
 * @author yeding
 * @create 2019/4/23 16:42
 * @decs
 */
public class CrossKickTeamHandler extends InnerHandler {
    @Override
    public void action() {
        getService(CrossMinService.class).crossKickTeam(this,msg.getExtension(CrossMinPb.CrossSynNotifyKickOutRq.ext));
    }
}
