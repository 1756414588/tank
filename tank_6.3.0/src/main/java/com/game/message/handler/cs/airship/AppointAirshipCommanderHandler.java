package com.game.message.handler.cs.airship;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5;
import com.game.server.GameServer;
import com.game.service.airship.AirshipService;

/**
 * @author zhangdh
 * @ClassName: AppointAirshipCommanderHandler
 * @Description:
 * @date 2017-05-30 19:57
 */
public class AppointAirshipCommanderHandler extends ClientHandler {
    @Override
    public void action() {
        GamePb5.AppointAirshipCommanderRq req = msg.getExtension(GamePb5.AppointAirshipCommanderRq.ext);
        GameServer.ac.getBean(AirshipService.class).appointAirshipCommander(req, this);
    }
}
