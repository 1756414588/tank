package com.game.message.handler.cs.lordequip;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5;
import com.game.server.GameServer;
import com.game.service.LordEquipService;

/**
 * @author zhangdh
 * @ClassName: ProductEquipHandler
 * @Description: 生产军备
 * @date 2017/4/25 17:39
 */
public class ProductEquipHandler extends ClientHandler{
    @Override
    public void action() {
        GamePb5.ProductEquipRq req = msg.getExtension(GamePb5.ProductEquipRq.ext);
        GameServer.ac.getBean(LordEquipService.class).productEquip(req, this);
    }
}
