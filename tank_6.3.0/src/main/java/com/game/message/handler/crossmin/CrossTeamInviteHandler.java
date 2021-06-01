package com.game.message.handler.crossmin;

import com.game.message.handler.InnerHandler;
import com.game.pb.CrossMinPb;
import com.game.service.crossmin.CrossMinService;

/**
 * @author yeding
 * @create 2019/4/25 10:46
 * @decs
 */
public class CrossTeamInviteHandler extends InnerHandler {
    @Override
    public void action() {
        getService(CrossMinService.class).crossTeamInvite(msg.getExtension(CrossMinPb.CrossSynTeamInviteRq.ext));
    }
}
