package com.game.message.handler.cs.lordequip;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5;
import com.game.server.GameServer;
import com.game.service.LordEquipService;

public class LordEquipInheritRqHandler extends ClientHandler{
    @Override
    public void action() {
        GamePb5.LordEquipInheritRq req = msg.getExtension(GamePb5.LordEquipInheritRq.ext);
        GameServer.ac.getBean(LordEquipService.class).lordEquipInheritRq(req, this);
    }
}
