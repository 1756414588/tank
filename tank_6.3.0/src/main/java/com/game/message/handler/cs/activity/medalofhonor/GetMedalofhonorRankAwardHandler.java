package com.game.message.handler.cs.activity.medalofhonor;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5;
import com.game.server.GameServer;
import com.game.service.activity.MedalofhonorService;

/**
 * @author zhangdh
 * @ClassName: GetMedalofhonorRankAwardHandler
 * @Description:
 * @date 2017-11-02 14:37
 */
public class GetMedalofhonorRankAwardHandler extends ClientHandler{
    @Override
    public void action() {
        GamePb5.GetActMedalofhonorRankAwardRq req = msg.getExtension(GamePb5.GetActMedalofhonorRankAwardRq.ext);
        GameServer.ac.getBean(MedalofhonorService.class).getRankAward(req, this);
    }
}
