package com.game.message.handler.cs.lordequip;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5;
import com.game.server.GameServer;
import com.game.service.LordEquipService;

/**
 * @author zhangdh
 * @ClassName: ProductLordEquipMatHandler
 * @Description: 生产军备材料
 * @date 2017/4/27 17:16
 */
public class ProductLordEquipMatHandler extends ClientHandler{
    @Override
    public void action() {
        GamePb5.ProductLordEquipMatRq req = msg.getExtension(GamePb5.ProductLordEquipMatRq.ext);
        GameServer.ac.getBean(LordEquipService.class).productMaterial(req, this);
    }
}
