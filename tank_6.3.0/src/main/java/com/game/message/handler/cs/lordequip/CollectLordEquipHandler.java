package com.game.message.handler.cs.lordequip;

import com.game.message.handler.ClientHandler;
import com.game.server.GameServer;
import com.game.service.LordEquipService;

/**
 * @author zhangdh
 * @ClassName: CollectLordEquipHandler
 * @Description: 收取装备
 * @date 2017/4/26 10:05
 */
public class CollectLordEquipHandler extends ClientHandler{
    @Override
    public void action() {
        GameServer.ac.getBean(LordEquipService.class).collectLordEquipBuiding(this);
    }
}
