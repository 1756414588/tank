package com.game.message.handler.cs.airship;

import com.game.message.handler.ClientHandler;
import com.game.server.GameServer;
import com.game.service.airship.AirshipService;

/**
 * @author zhangdh
 * @ClassName: GetPartyAirshipCommanderHandler
 * @Description:
 * @date 2017-05-30 19:54
 */
public class GetPartyAirshipCommanderHandler extends ClientHandler{
    @Override
    public void action() {
        GameServer.ac.getBean(AirshipService.class).getPartyAirshipCommander(this);
    }
}
