package com.game.message.handler.cs.crossMin;

import com.game.message.handler.ClientHandler;
import com.game.pb.CrossMinPb;
import com.game.server.GameContext;
import com.game.service.seniormine.CrossSeniorMineService;

/**
 * @author yeding
 * @create 2019/6/14 10:14
 * @decs
 */
public class CrossMineAttackHandler extends ClientHandler {
    @Override
    public void action() {
        GameContext.getAc().getBean(CrossSeniorMineService.class).attackMine(msg.getExtension(CrossMinPb.CrossMineAttack.ext));
    }
}
