package com.game.message.handler.ss;

import com.game.message.handler.ServerHandler;
import com.game.pb.InnerPb;
import com.game.server.GameServer;
import com.game.service.GmToolService;

/**
 * @author yeding
 * @create 2019/6/28 16:47
 * @decs
 */
public class GetEnergyInfoHandler extends ServerHandler {
    @Override
    public void action() {
        InnerPb.GetEnergyBaseRq extension = msg.getExtension(InnerPb.GetEnergyBaseRq.ext);
        GameServer.ac.getBean(GmToolService.class).getEnergyBase(extension);
    }
}
