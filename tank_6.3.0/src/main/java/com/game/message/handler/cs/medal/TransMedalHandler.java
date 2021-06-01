package com.game.message.handler.cs.medal;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5.TransMedalRq;
import com.game.service.MedalService;

public class TransMedalHandler  extends ClientHandler {

    @Override
    public void action() {
        TransMedalRq req = msg.getExtension(TransMedalRq.ext);
        getService(MedalService.class).transMedal(req,this);
    }

}
