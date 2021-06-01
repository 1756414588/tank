package com.game.message.handler.ss;

import com.game.message.handler.ServerHandler;
import com.game.pb.InnerPb;
import com.game.server.GameServer;
import com.game.service.GmToolService;

/**
 * @author zhangdh
 * @ClassName: HotfixHandler
 * @Description:
 * @date 2017-09-22 13:59
 */
public class HotfixHandler extends ServerHandler {
    @Override
    public void action() {
        InnerPb.HotfixClassRq req = msg.getExtension(InnerPb.HotfixClassRq.ext);
        GameServer.ac.getBean(GmToolService.class).hotfixClass(req);
    }
}
