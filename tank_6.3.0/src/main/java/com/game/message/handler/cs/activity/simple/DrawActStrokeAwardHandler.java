package com.game.message.handler.cs.activity.simple;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5;
import com.game.server.GameServer;
import com.game.service.activity.StrokeService;

/**
 * @author zhangdh
 * @ClassName: DrawActStrokeAwardHandler
 * @Description:
 * @date 2018-01-19 14:25
 */
public class DrawActStrokeAwardHandler extends ClientHandler{
    @Override
    public void action() {
        GamePb5.DrawActStrokeAwardRq req = msg.getExtension(GamePb5.DrawActStrokeAwardRq.ext);
        GameServer.ac.getBean(StrokeService.class).drawActStrokeAward(req, this);
    }
}
