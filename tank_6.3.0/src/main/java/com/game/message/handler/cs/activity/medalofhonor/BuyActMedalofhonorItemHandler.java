package com.game.message.handler.cs.activity.medalofhonor;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5;
import com.game.server.GameServer;
import com.game.service.activity.MedalofhonorService;

/**
 * @author zhangdh
 * @ClassName: BuyActMedalofhonorItemHandler
 * @Description:
 * @date 2017-10-31 17:41
 */
public class BuyActMedalofhonorItemHandler extends ClientHandler {
    @Override
    public void action() {
        GamePb5.BuyActMedalofhonorItemRq req = msg.getExtension(GamePb5.BuyActMedalofhonorItemRq.ext);
        GameServer.ac.getBean(MedalofhonorService.class).buyItem(req, this);
    }
}
