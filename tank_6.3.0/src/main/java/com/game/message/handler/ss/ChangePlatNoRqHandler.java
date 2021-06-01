package com.game.message.handler.ss;

import com.game.message.handler.ServerHandler;
import com.game.pb.InnerPb.ChangePlatNoRq;
import com.game.server.GameServer;
import com.game.service.PlayerService;

public class ChangePlatNoRqHandler extends ServerHandler {

    @Override
    public void action() {
        ChangePlatNoRq req = msg.getExtension(ChangePlatNoRq.ext);

        PlayerService playerService = GameServer.ac.getBean(PlayerService.class);
        playerService.changePlatNoRq(req, this);
    }

}
