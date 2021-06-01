package com.game.message.handler.crossmin;

import com.game.message.handler.InnerHandler;
import com.game.pb.CrossMinPb;
import com.game.service.crossmin.CrossMinService;

/**
 * @author yeding
 * @create 2019/4/23 11:53
 * @decs
 */
public class CrossNotifyDisMissTeamHandler extends InnerHandler {
    @Override
    public void action() {
        getService(CrossMinService.class).crossDisMissTeam(this,msg.getExtension(CrossMinPb.CrossNotifyDisMissTeamRq.ext));
    }
}
