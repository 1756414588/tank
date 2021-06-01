package com.game.message.handler.ss;

import com.game.message.handler.ServerHandler;
import com.game.pb.InnerPb;
import com.game.server.GameServer;
import com.game.service.GmToolService;

/**
 * @Author: ZhouJie
 * @Date: Create in 2017-10-24 15:13
 * @Description:
 * @Modified By:
 */
public class LordRelevanceRqHandler extends ServerHandler {

    @Override
    public void action() {
        InnerPb.LordRelevanceRq req = msg.getExtension(InnerPb.LordRelevanceRq.ext);
        GmToolService toolService = GameServer.ac.getBean(GmToolService.class);
        toolService.lordRelevance(req, this);
    }
}
