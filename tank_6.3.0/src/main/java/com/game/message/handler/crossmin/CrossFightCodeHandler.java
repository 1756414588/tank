package com.game.message.handler.crossmin;

import com.game.message.handler.InnerHandler;
import com.game.service.crossmin.CrossMinService;

/**
 * @author yeding
 * @create 2019/5/19 2:02
 * @decs
 */
public class CrossFightCodeHandler extends InnerHandler {
    @Override
    public void action() {
        getService(CrossMinService.class).crossFight(msg, this);
    }
}
