package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6;
import com.game.service.WorldService;

public class VCodeScoutRqHandler extends ClientHandler {
    @Override
    public void action() {
        getService(WorldService.class).vCodeScout(msg.getExtension(GamePb6.VCodeScoutRq.ext), this);
    }

}
