package com.game.message.handler.crossmine;

import com.game.message.handler.InnerHandler;
import com.game.pb.CrossMinPb;
import com.game.server.GameServer;
import com.game.service.crossmine.CrossSeniorMineService;

/**
 * @author yeding
 * @create 2019/6/15 13:37
 * @decs
 */
public class CrossAttackMineHandler extends InnerHandler {


    @Override
    public void action() {
        GameServer.ac.getBean(CrossSeniorMineService.class).synCrossMine(msg.getExtension(CrossMinPb.CrossMine.ext));
    }
}
