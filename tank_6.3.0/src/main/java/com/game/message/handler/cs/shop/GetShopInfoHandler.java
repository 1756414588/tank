package com.game.message.handler.cs.shop;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5;
import com.game.service.ShopService;

/**
 * @author zhangdh
 * @ClassName: GetShopInfoHandler
 * @Description: 商店信息
 * @date 2017/4/7 11:30
 */
public class GetShopInfoHandler extends ClientHandler {

    @Override
    public void action() {
        GamePb5.GetShopInfoRq req = msg.getExtension(GamePb5.GetShopInfoRq.ext);
        getService(ShopService.class).getShopInfo(req, this);
    }
}
