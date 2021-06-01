package com.game.message.handler.cs.airship;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5;
import com.game.server.GameServer;
import com.game.service.airship.AirshipService;

/**
 * @author zhangdh
 * @ClassName: RebuildAirshipHandler
 * @Description: 修复飞艇耐久度
 * @date 2017-06-13 16:52
 */
public class RebuildAirshipHandler extends ClientHandler{
    @Override public void action() {
        GamePb5.RebuildAirshipRq req = msg.getExtension(GamePb5.RebuildAirshipRq.ext);
        GameServer.ac.getBean(AirshipService.class).rebuildAirship(req, this);
    }
}
