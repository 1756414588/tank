package com.game.message.handler.cs.activity.redbag;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5;
import com.game.server.GameServer;
import com.game.service.activity.ActRedBagsService;

/**
 * @author zhangdh
 * @ClassName: GrabRedBagHandler
 * @Description:
 * @date 2018-02-03 10:34
 */
public class GrabRedBagHandler extends ClientHandler{
    @Override
    public void action() {
        GamePb5.GrabRedBagRq req = msg.getExtension(GamePb5.GrabRedBagRq.ext);
        GameServer.ac.getBean(ActRedBagsService.class).grabRedBag(req, this);
    }
}
