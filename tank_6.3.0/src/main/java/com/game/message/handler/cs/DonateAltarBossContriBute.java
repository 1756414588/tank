package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6;
import com.game.service.AltarBossService;

public class DonateAltarBossContriBute extends ClientHandler {
    @Override
    public void action() {
        GamePb6.GetFeedAltarContriButeRq req = msg.getExtension(GamePb6.GetFeedAltarContriButeRq.ext);
        getService(AltarBossService.class).donateAllAltarBossRes(req, this);
    }
}
