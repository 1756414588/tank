package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5.GetPlayerBackAwardsRq;
import com.game.service.ActivityService;

public class GetPlayerBackAwardsHandler extends ClientHandler {

    @Override
    public void action() {
        GetPlayerBackAwardsRq req= msg.getExtension(GetPlayerBackAwardsRq.ext);
        getService(ActivityService.class).getPlayerBackAwards(req,this);
    }

}
