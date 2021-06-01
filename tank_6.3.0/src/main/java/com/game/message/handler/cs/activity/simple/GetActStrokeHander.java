package com.game.message.handler.cs.activity.simple;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5;
import com.game.server.GameServer;
import com.game.service.activity.StrokeService;

/**
 * @author zhangdh
 * @ClassName: GetActStrokeHander
 * @Description:
 * @date 2018-01-19 14:23
 */
public class GetActStrokeHander extends ClientHandler{
    @Override
    public void action() {
        GamePb5.GetActStrokeRq req = msg.getExtension(GamePb5.GetActStrokeRq.ext);
        GameServer.ac.getBean(StrokeService.class).getActStrokeRq(req, this);
    }
}
