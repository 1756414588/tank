package com.game.message.handler.cs.secretWeapon;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6;
import com.game.server.GameServer;
import com.game.service.SecretWeaponService;

/**
 * @author zhangdh
 * @ClassName: UnlockWeaponBarHandler
 * @Description:
 * @date 2017-11-14 16:12
 */
public class UnlockWeaponBarHandler extends ClientHandler {
    @Override
    public void action() {
        GamePb6.UnlockWeaponBarRq req = msg.getExtension(GamePb6.UnlockWeaponBarRq.ext);
        GameServer.ac.getBean(SecretWeaponService.class).unlockWeaponBar(req, this);
    }
}
