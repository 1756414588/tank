package com.game.message.handler.cs.airship;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5;
import com.game.server.GameServer;
import com.game.service.airship.AirshipTeamService;

/**
 * @author zhangdh
 * @ClassName: GetAirshipGuardArmyHandler
 * @Description:
 * @date 2017-06-30 11:00
 */
public class GetAirshipGuardArmyHandler extends ClientHandler {
    @Override
    public void action() {
        GamePb5.GetAirshipGuardArmyRq req = msg.getExtension(GamePb5.GetAirshipGuardArmyRq.ext);
        GameServer.ac.getBean(AirshipTeamService.class).getAirshipGuardArmyInfo(req, this);
    }
}
