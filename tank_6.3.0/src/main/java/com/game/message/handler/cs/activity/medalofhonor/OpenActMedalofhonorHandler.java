package com.game.message.handler.cs.activity.medalofhonor;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5;
import com.game.server.GameServer;
import com.game.service.activity.MedalofhonorService;

/**
 * @author zhangdh
 * @ClassName: OpenActMedalofhonorHandler
 * @Description:
 * @date 2017-10-31 17:39
 */
public class OpenActMedalofhonorHandler extends ClientHandler{
    @Override
    public void action() {
        GamePb5.OpenActMedalofhonorRq req = msg.getExtension(GamePb5.OpenActMedalofhonorRq.ext);
        GameServer.ac.getBean(MedalofhonorService.class).openActMedalofhonor(req, this);
    }
}
