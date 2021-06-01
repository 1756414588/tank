package com.game.message.handler.crossmin;

import com.game.message.handler.InnerHandler;
import com.game.pb.CrossMinPb;
import com.game.service.crossmin.CrossMinService;

/**
 * @author yeding
 * @create 2019/4/23 15:13
 * @decs
 */
public class CrossFindTeamHandler extends InnerHandler {
    @Override
    public void action() {
        getService(CrossMinService.class).crossFindTeam(this,msg.getExtension(CrossMinPb.CrossSynTeamInfoRq.ext));
    }
}
