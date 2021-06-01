package com.game.message.handler.cs.activity.simple;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5;
import com.game.server.GameServer;
import com.game.service.activity.simple.ActLotteryExploreService;

/**
 * @author zhangdh
 * @ClassName: GetActLotteryExploreHandler
 * @Description:
 * @date 2018-01-31 10:00
 */
public class GetActLotteryExploreHandler extends ClientHandler {
    @Override
    public void action() {
        GamePb5.GetActLotteryExploreRq req = msg.getExtension(GamePb5.GetActLotteryExploreRq.ext);
        GameServer.ac.getBean(ActLotteryExploreService.class).getActLotteryExplore(req, this);
    }
}
