package com.game.message.handler.cs.activity.monopoly;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5;
import com.game.server.GameServer;
import com.game.service.activity.MonopolyService;

/**
 * @author zhangdh
 * @ClassName: DrawFreeEnergyHandler
 * @Description:
 * @date 2017-12-06 19:19
 */
public class DrawFreeEnergyHandler extends ClientHandler {
    @Override
    public void action() {
        GamePb5.DrawFreeEnergyRq req = msg.getExtension(GamePb5.DrawFreeEnergyRq.ext);
        GameServer.ac.getBean(MonopolyService.class).drawFreeEnergyRq(req, this);
    }
}
