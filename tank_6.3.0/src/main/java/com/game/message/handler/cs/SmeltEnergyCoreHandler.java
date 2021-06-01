package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6.SmeltCoreEquipRq;
import com.game.service.EnergyCoreService;

/**
 * @author yeding
 * @create 2019/3/28 17:09
 */
public class SmeltEnergyCoreHandler extends ClientHandler {

    @Override
    public void action() {
        getService(EnergyCoreService.class).smeltEquip(this, msg.getExtension(SmeltCoreEquipRq.ext));
    }
}
