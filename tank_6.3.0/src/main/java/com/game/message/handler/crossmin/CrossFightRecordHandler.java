package com.game.message.handler.crossmin;

import com.game.message.handler.InnerHandler;
import com.game.pb.CrossMinPb;
import com.game.service.crossmin.CrossMinService;

/**
 * @author yeding
 * @create 2019/4/25 16:18
 * @decs
 */
public class CrossFightRecordHandler extends InnerHandler {
    @Override
    public void action() {
        getService(CrossMinService.class).crossRecord(this, msg.getExtension(CrossMinPb.CrossSyncTeamFightBossRq.ext));
    }
}
