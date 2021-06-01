package com.game.message.handler.ss;

import com.game.message.handler.ServerHandler;
import com.game.pb.InnerPb;
import com.game.server.GameServer;
import com.game.service.GmToolService;

/**
 * @author zhangdh
 * @ClassName: ExecuteHotfixHandler
 * @Description:
 * @date 2017-11-08 17:11
 */
public class ExecuteHotfixHandler extends ServerHandler {
    @Override
    public void action() {
        InnerPb.ExecutHotfixRq req = msg.getExtension(InnerPb.ExecutHotfixRq.ext);
        GameServer.ac.getBean(GmToolService.class).executeHotfix(req);
    }
}
