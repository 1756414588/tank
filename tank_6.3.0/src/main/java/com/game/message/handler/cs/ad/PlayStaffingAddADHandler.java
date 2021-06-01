package com.game.message.handler.cs.ad;

import com.game.message.handler.ClientHandler;
import com.game.service.AdvertisementService;

public class PlayStaffingAddADHandler extends ClientHandler {

    @Override
    public void action() {
        getService(AdvertisementService.class).playStaffingAddAD(this);
    }

}
