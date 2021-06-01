package com.game.message.handler.cs.lordequip;

import com.game.message.handler.ClientHandler;
import com.game.server.GameServer;
import com.game.service.LordEquipService;

/**
 * @author zhangdh
 * @ClassName: GetLordEquipHandler
 * @Description: 获取军备信息
 * @date 2017/4/21 17:18
 */
public class GetLordEquipHandler extends ClientHandler{
    @Override
    public void action() {
        GameServer.ac.getBean(LordEquipService.class).getLordEquips(this);
    }
}
