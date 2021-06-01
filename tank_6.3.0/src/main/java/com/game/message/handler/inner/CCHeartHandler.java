package com.game.message.handler.inner;

import com.game.message.handler.InnerHandler;
import com.game.service.CrossService;
import com.game.util.LogHelper;
import com.game.util.LogUtil;

public class CCHeartHandler extends InnerHandler {

    @Override
    public void action() {
        CrossService.hertRequestTime = System.currentTimeMillis();
        LogUtil.crossInfo("[跨服战或者跨服军团战] 接收到心跳回复");
    }

}
