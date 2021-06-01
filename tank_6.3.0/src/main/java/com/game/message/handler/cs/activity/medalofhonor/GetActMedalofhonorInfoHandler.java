package com.game.message.handler.cs.activity.medalofhonor;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5;
import com.game.server.GameServer;
import com.game.service.activity.MedalofhonorService;

/**
 * @author zhangdh
 * @ClassName: GetActMedalofhonorInfoRsHandler
 * @Description:
 * @date 2017-10-31 17:35
 */
public class GetActMedalofhonorInfoHandler extends ClientHandler {
    @Override
    public void action() {
        GamePb5.GetActMedalofhonorInfoRq req = msg.getExtension(GamePb5.GetActMedalofhonorInfoRq.ext);
        GameServer.ac.getBean(MedalofhonorService.class).getActMedalofhonorInfoRq(req, this);
    }
}
