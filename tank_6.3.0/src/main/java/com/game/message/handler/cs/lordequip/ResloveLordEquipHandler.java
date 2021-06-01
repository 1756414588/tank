package com.game.message.handler.cs.lordequip;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5;
import com.game.server.GameServer;
import com.game.service.LordEquipService;

/**
 * @author zhangdh
 * @ClassName: ResloveLordEquipHandler
 * @Description: 军备分解
 * @date 2017/4/25 11:37
 */
public class ResloveLordEquipHandler extends ClientHandler{
    @Override
    public void action() {
        GamePb5.ResloveLordEquipRq req = msg.getExtension(GamePb5.ResloveLordEquipRq.ext);
        GameServer.ac.getBean(LordEquipService.class).resloveLordEquip(req,this);
    }
}
