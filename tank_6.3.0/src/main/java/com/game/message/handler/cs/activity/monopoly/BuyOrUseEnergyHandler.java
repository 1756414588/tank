package com.game.message.handler.cs.activity.monopoly;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5;
import com.game.server.GameServer;
import com.game.service.activity.MonopolyService;

/**
 * @author zhangdh
 * @ClassName: BuyOrUseEnergyHandler
 * @Description:
 * @date 2017-12-02 10:50
 */
public class BuyOrUseEnergyHandler extends ClientHandler {
    @Override
    public void action() {
        GamePb5.BuyOrUseEnergyRq req = msg.getExtension(GamePb5.BuyOrUseEnergyRq.ext);
        GameServer.ac.getBean(MonopolyService.class).buyOrUseEnergy(req, this);
    }
}
