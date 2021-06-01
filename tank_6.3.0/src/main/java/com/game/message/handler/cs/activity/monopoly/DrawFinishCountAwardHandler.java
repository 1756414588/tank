package com.game.message.handler.cs.activity.monopoly;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5;
import com.game.server.GameServer;
import com.game.service.activity.MonopolyService;

/**
 * @author zhangdh
 * @ClassName: DrawFinishCountAwardHandler
 * @Description:
 * @date 2017-12-06 19:25
 */
public class DrawFinishCountAwardHandler extends ClientHandler{
    @Override
    public void action() {
        GamePb5.DrawFinishCountAwardRq req = msg.getExtension(GamePb5.DrawFinishCountAwardRq.ext);
        GameServer.ac.getBean(MonopolyService.class).drawFinishCountAward(req, this);
    }
}
