package com.game.message.handler.cs.airship;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5;
import com.game.server.GameServer;
import com.game.service.airship.AirshipService;

/**
 * @author zhangdh
 * @ClassName: GetAirshipPlayerInfoHandler
 * @Description:
 * @date 2017-06-21 2:06
 */
public class GetAirshipPlayerInfoHandler extends ClientHandler{
    @Override
    public void action() {
        GamePb5.GetAirshipPlayerRq req = msg.getExtension(GamePb5.GetAirshipPlayerRq.ext);
        GameServer.ac.getBean(AirshipService.class).getAirshipPlayerInfo(req, this);
    }
}
