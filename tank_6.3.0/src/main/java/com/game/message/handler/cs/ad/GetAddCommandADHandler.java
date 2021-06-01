package com.game.message.handler.cs.ad;

import com.game.message.handler.ClientHandler;
import com.game.service.AdvertisementService;

public class GetAddCommandADHandler extends ClientHandler {

    @Override
    public void action() {
        getService(AdvertisementService.class).getAddCommandAD(this);
    }

}
