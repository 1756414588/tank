package com.game.message.handler.cs.crossMin;

import com.game.message.handler.ClientHandler;
import com.game.pb.CrossMinPb;
import com.game.service.crossmin.CrossMinService;

public class CCMHeartHandler extends ClientHandler {

    @Override
    public void action() {
        getService(CrossMinService.class).crossMinHeart(msg.getExtension(CrossMinPb.CrossMinHeartRq.ext), this);
    }
}