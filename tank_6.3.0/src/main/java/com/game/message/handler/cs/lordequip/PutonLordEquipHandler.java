package com.game.message.handler.cs.lordequip;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5;
import com.game.server.GameServer;
import com.game.service.LordEquipService;

/**
 * @author zhangdh
 * @ClassName: PutonLordEquipHandler
 * @Description: :
 * @date 2017/4/21 17:19
 */
public class PutonLordEquipHandler extends ClientHandler{
    @Override
    public void action() {
        GamePb5.PutonLordEquipRq req = msg.getExtension(GamePb5.PutonLordEquipRq.ext);
        GameServer.ac.getBean(LordEquipService.class).putonEquip(req,this);
    }
}
