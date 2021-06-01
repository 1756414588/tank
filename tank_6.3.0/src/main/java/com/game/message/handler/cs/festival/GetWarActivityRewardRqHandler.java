package com.game.message.handler.cs.festival;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6;
import com.game.service.ActivityNewService;

public class GetWarActivityRewardRqHandler extends ClientHandler {
    @Override
    public void action() {
        GamePb6.GetWarActivityRewardRq req = msg.getExtension(GamePb6.GetWarActivityRewardRq.ext);
        getService(ActivityNewService.class).getWarActivityRewardRq(req, this);
    }
}
