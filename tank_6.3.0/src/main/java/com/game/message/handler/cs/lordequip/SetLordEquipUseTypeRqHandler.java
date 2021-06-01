package com.game.message.handler.cs.lordequip;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5;
import com.game.server.GameServer;
import com.game.service.LordEquipService;

public class SetLordEquipUseTypeRqHandler extends ClientHandler{
    @Override
    public void action() {
        GamePb5.SetLordEquipUseTypeRq req = msg.getExtension(GamePb5.SetLordEquipUseTypeRq.ext);
        GameServer.ac.getBean(LordEquipService.class).setLordEquipUseTypeRq(req, this);
    }
}
