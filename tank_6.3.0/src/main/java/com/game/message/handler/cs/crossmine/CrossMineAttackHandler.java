package com.game.message.handler.cs.crossmine;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6;
import com.game.server.GameServer;
import com.game.service.crossmine.CrossSeniorMineService;

/**
 * @author yeding
 * @create 2019/6/14 13:47
 * @decs
 */
public class CrossMineAttackHandler extends ClientHandler {
    @Override
    public void action() {
        GameServer.ac.getBean(CrossSeniorMineService.class).attack(msg.getExtension(GamePb6.AtkCrossSeniorMineRq.ext), this);
    }
}
