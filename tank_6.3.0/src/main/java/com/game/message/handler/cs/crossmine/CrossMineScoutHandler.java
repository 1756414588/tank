package com.game.message.handler.cs.crossmine;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6;
import com.game.server.GameServer;
import com.game.service.crossmine.CrossSeniorMineService;

/**
 * @author yeding
 * @create 2019/6/14 13:46
 * @decs
 */
public class CrossMineScoutHandler extends ClientHandler {
    @Override
    public void action() {
        GamePb6.SctCrossSeniorMineRq rq = msg.getExtension(GamePb6.SctCrossSeniorMineRq.ext);
        GameServer.ac.getBean(CrossSeniorMineService.class).scout(rq.getPos(), this);
    }
}
