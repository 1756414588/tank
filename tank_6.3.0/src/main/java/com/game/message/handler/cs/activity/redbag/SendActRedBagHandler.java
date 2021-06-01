package com.game.message.handler.cs.activity.redbag;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5;
import com.game.server.GameServer;
import com.game.service.activity.ActRedBagsService;

/**
 * @author zhangdh
 * @ClassName: SendActRedBagHandler
 * @Description:
 * @date 2018-02-03 10:46
 */
public class SendActRedBagHandler extends ClientHandler {
    @Override
    public void action() {
        GamePb5.SendActRedBagRq req = msg.getExtension(GamePb5.SendActRedBagRq.ext);
        GameServer.ac.getBean(ActRedBagsService.class).sendActRedBagRq(req, this);
    }
}
