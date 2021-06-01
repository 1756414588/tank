package com.game.message.handler.cs.activity.monopoly;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5;
import com.game.server.GameServer;
import com.game.service.activity.MonopolyService;

/**
 * @author zhangdh
 * @ClassName: GetMonopolyInfoHandler
 * @Description:
 * @date 2017-12-02 10:48
 */
public class GetMonopolyInfoHandler extends ClientHandler {
    @Override
    public void action() {
        GamePb5.GetMonopolyInfoRq req = msg.getExtension(GamePb5.GetMonopolyInfoRq.ext);
        GameServer.ac.getBean(MonopolyService.class).getMonopolyInfo(req, this);
    }
}
