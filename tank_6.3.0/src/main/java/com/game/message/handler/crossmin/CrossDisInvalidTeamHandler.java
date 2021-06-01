package com.game.message.handler.crossmin;

import com.game.message.handler.InnerHandler;
import com.game.pb.CrossMinPb;
import com.game.service.crossmin.CrossMinService;

/**
 * @author yeding
 * @create 2019/4/25 11:19
 * @decs
 */
public class CrossDisInvalidTeamHandler extends InnerHandler {
    @Override
    public void action() {
        getService(CrossMinService.class).disTeam(this,msg.getExtension(CrossMinPb.CrossSynStageCloseToTeamRq.ext));

    }
}
