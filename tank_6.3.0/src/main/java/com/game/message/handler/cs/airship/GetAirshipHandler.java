package com.game.message.handler.cs.airship;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5;
import com.game.service.airship.AirshipService;

public class GetAirshipHandler extends ClientHandler {

    @Override
    public void action() {
        GamePb5.GetAirshipRq req = msg.getExtension(GamePb5.GetAirshipRq.ext);
        getService(AirshipService.class).getAirship(req, this);
    }

}
