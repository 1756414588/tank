package com.game.message.handler.cs.shop;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5;
import com.game.service.ShopService;

/**
 * @author zhangdh
 * @ClassName: BuyShopGoodsHandler
 * @Description: 商品购买
 * @date 2017/4/7 11:30
 */
public class BuyShopGoodsHandler extends ClientHandler {
    @Override
    public void action() {
        GamePb5.BuyShopGoodsRq req = msg.getExtension(GamePb5.BuyShopGoodsRq.ext);
        getService(ShopService.class).buyShopGoods(req,this);
    }
}
