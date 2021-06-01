package com.game.message.handler.cs.festival;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6;
import com.game.service.ActivityNewService;

public class GetWarActivityInfoRqHandler extends ClientHandler {
    @Override
    public void action() {
        GamePb6.GetWarActivityInfoRq req = msg.getExtension(GamePb6.GetWarActivityInfoRq.ext);
        getService(ActivityNewService.class).getWarActivityInfoRq(req, this);
    }
}
