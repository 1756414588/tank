package com.game.message.handler.cs.lordequip;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5;
import com.game.server.GameServer;
import com.game.service.LordEquipService;

/**
 * @author zhangdh
 * @ClassName: TakeOffLordEquipHandler
 * @Description: 脱下军备
 * @date 2017/4/21 17:20
 */
public class TakeOffLordEquipHandler extends ClientHandler{
    @Override
    public void action() {
        GamePb5.TakeOffEquipRq req = msg.getExtension(GamePb5.TakeOffEquipRq.ext);
        GameServer.ac.getBean(LordEquipService.class).takeOffEquip(req,this);
    }
}
