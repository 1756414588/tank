package com.game.message.handler.cs.activity.monopoly;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5;
import com.game.server.GameServer;
import com.game.service.activity.MonopolyService;

/**
 * @author zhangdh
 * @ClassName: BuyDiscountGoodsHandler
 * @Description:
 * @date 2017-12-02 10:51
 */
public class BuyDiscountGoodsHandler extends ClientHandler {
    @Override
    public void action() {
        GamePb5.BuyDiscountGoodsRq req = msg.getExtension(GamePb5.BuyDiscountGoodsRq.ext);
        GameServer.ac.getBean(MonopolyService.class).buyDiscountGoods(req, this);
    }
}
