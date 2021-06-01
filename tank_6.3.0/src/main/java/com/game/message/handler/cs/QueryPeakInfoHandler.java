package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.server.GameServer;
import com.game.service.PeakService;

public class QueryPeakInfoHandler extends ClientHandler {


    @Override
    public void action() {
        GameServer.ac.getBean(PeakService.class).queryPeakInfo(this);
    }
}
