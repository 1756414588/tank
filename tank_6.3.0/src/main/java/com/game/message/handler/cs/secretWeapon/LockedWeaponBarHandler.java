package com.game.message.handler.cs.secretWeapon;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6;
import com.game.server.GameServer;
import com.game.service.SecretWeaponService;

/**
 * @author zhangdh
 * @ClassName: LockedWeaponBarHandler
 * @Description:
 * @date 2017-11-14 16:11
 */
public class LockedWeaponBarHandler extends ClientHandler {
    @Override
    public void action() {
        GamePb6.LockedWeaponBarRq req = msg.getExtension(GamePb6.LockedWeaponBarRq.ext);
        GameServer.ac.getBean(SecretWeaponService.class).lockWeaponBar4Study(req, this);
    }
}
