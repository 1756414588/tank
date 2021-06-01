package com.game.message.handler.cs.king;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6;
import com.game.service.ActivityKingService;
import com.game.service.teaminstance.TeamService;

public class GetPsnKillRankRqHandler extends ClientHandler {

    @Override
    public void action() {
        getService(ActivityKingService.class).getPsnKillRankRq(msg.getExtension(GamePb6.GetPsnKillRankRq.ext), this);
    }

}
