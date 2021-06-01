package com.game.message.handler.crossmin;

import com.game.message.handler.InnerHandler;
import com.game.pb.CrossMinPb;
import com.game.service.crossmin.CrossMinService;

/**
 * @author yeding
 * @create 2019/4/24 16:39
 * @decs
 */
public class CrossChangeMemberStatusHandler extends InnerHandler {
    @Override
    public void action() {
        getService(CrossMinService.class).crossChangeMemberStatus(this, msg.getExtension(CrossMinPb.CrossSynChangeStatusRq.ext));
    }
}
