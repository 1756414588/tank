package com.game.message.handler.cs.lordequip;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5;
import com.game.pb.GamePb5.LordEquipChangeRq;
import com.game.server.GameServer;
import com.game.service.LordEquipService;

/**
 * 军备锁定
 */
public class LockLordEquipHandler extends ClientHandler {

    @Override
    public void action() {
        GamePb5.LockLordEquipRq req = msg.getExtension(GamePb5.LockLordEquipRq.ext);
        GameServer.ac.getBean(LordEquipService.class).lockLordEquip(req, this);
    }

}
