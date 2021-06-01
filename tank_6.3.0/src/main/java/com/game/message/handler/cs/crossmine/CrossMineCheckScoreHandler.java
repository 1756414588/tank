package com.game.message.handler.cs.crossmine;

import com.game.message.handler.ClientHandler;
import com.game.server.GameServer;
import com.game.service.crossmine.CrossSeniorMineService;

/**
 * @author yeding
 * @create 2019/6/15 14:38
 * @decs
 */
public class CrossMineCheckScoreHandler extends ClientHandler {

    @Override
    public void action() {
        GameServer.ac.getBean(CrossSeniorMineService.class).checkScoreRank(this);
    }
}
