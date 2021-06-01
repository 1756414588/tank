package com.game.message.handler.cs.crossmine;

import com.game.message.handler.ClientHandler;
import com.game.server.GameServer;
import com.game.service.crossmine.CrossSeniorMineService;

/**
 * @author yeding
 * @create 2019/6/17 16:02
 * @decs
 */
public class CrossMineServerRankHandler extends ClientHandler {
    @Override
    public void action() {
        GameServer.ac.getBean(CrossSeniorMineService.class).checkServerScoreRank(this);
    }
}
