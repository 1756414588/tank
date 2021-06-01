package com.game.message.handler.cs.lordequip;

import com.game.message.handler.ClientHandler;
import com.game.server.GameServer;
import com.game.service.LordEquipService;

/**
 * @author zhangdh
 * @ClassName: BuyMaterialProHandler
 * @Description: 购买材料生产位
 * @date 2017/4/27 17:13
 */
public class BuyMaterialProHandler extends ClientHandler{
    @Override
    public void action() {
        GameServer.ac.getBean(LordEquipService.class).buyLembQueue(this);
    }
}
