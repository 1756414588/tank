package com.game.message.handler.crossmin;

import com.game.message.handler.InnerHandler;
import com.game.pb.CrossMinPb;
import com.game.service.crossmin.CrossMinService;

/**
 * @author yeding
 * @create 2019/4/25 15:34
 * @decs
 */
public class CrossSynTaskHandler extends InnerHandler {
    @Override
    public void action() {
        getService(CrossMinService.class).crossTask(msg.getExtension(CrossMinPb.CrossSynTaskRq.ext));
    }
}
