package com.game.message.handler.cs.king;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6;
import com.game.service.ActivityKingService;

public class GetKingRankAwardRqHandler extends ClientHandler {

    @Override
    public void action() {
        getService(ActivityKingService.class).getKingRankAwardRq(msg.getExtension(GamePb6.GetKingRankAwardRq.ext), this);
    }

}
