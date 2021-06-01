package com.game.message.handler.cs.activity.medalofhonor;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5;
import com.game.server.GameServer;
import com.game.service.activity.MedalofhonorService;

/**
 * @author zhangdh
 * @ClassName: GetMedalofhonorRankInfoHandler
 * @Description:
 * @date 2017-11-02 14:36
 */
public class GetMedalofhonorRankInfoHandler extends ClientHandler{
    @Override
    public void action() {
        GamePb5.GetActMedalofhonorRankInfoRq req = msg.getExtension(GamePb5.GetActMedalofhonorRankInfoRq.ext);
        GameServer.ac.getBean(MedalofhonorService.class).getRankInfo(req, this);
    }
}
