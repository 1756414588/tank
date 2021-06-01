package com.game.message.handler.cs.activity.medalofhonor;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5;
import com.game.server.GameServer;
import com.game.service.activity.MedalofhonorService;

/**
 * @author zhangdh
 * @ClassName: SearchActMedalofhonorTargetsHandler
 * @Description:
 * @date 2017-10-31 17:40
 */
public class SearchActMedalofhonorTargetsHandler extends ClientHandler {
    @Override
    public void action() {
        GamePb5.SearchActMedalofhonorTargetsRq req = msg.getExtension(GamePb5.SearchActMedalofhonorTargetsRq.ext);
        GameServer.ac.getBean(MedalofhonorService.class).searchActMedalofhonorTargets(req, this);
    }
}
