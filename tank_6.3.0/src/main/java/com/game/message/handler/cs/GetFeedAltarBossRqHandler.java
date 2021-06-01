package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6;
import com.game.service.AltarBossService;

public class GetFeedAltarBossRqHandler extends ClientHandler {
    @Override
    public void action() {
        GamePb6.GetFeedAltarBossRq req = msg.getExtension(GamePb6.GetFeedAltarBossRq.ext);
        getService(AltarBossService.class).getFeedAltarBossRq(req, this);
    }
}
