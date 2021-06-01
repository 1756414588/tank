package com.game.message.handler.cs.crossmine;

import com.game.message.handler.ClientHandler;
import com.game.server.GameServer;
import com.game.service.crossmine.CrossSeniorMineService;

/**
 * @author yeding
 * @create 2019/6/15 15:08
 * @decs
 */
public class CrossMineGetScoreAwardHandler extends ClientHandler {

    @Override
    public void action() {
        GameServer.ac.getBean(CrossSeniorMineService.class).doScoreAward(this);
    }
}
