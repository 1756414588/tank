package com.game.message.handler.cs.activity.monopoly;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5;
import com.game.server.GameServer;
import com.game.service.activity.MonopolyService;

/**
 * @author zhangdh
 * @ClassName: ThrowDiceHandler
 * @Description:
 * @date 2017-12-02 10:49
 */
public class ThrowDiceHandler extends ClientHandler {
    @Override
    public void action() {
        GamePb5.ThrowDiceRq req = msg.getExtension(GamePb5.ThrowDiceRq.ext);
        GameServer.ac.getBean(MonopolyService.class).throwDiceRq(req, this);
    }
}
