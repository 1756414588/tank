package com.game.message.handler.cs.secretWeapon;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6;
import com.game.server.GameServer;
import com.game.service.SecretWeaponService;

/**
 * @author zhangdh
 * @ClassName: GetSecretWeaponInfoHandler
 * @Description:
 * @date 2017-11-14 16:10
 */
public class GetSecretWeaponInfoHandler extends ClientHandler{
    @Override
    public void action() {
        GamePb6.GetSecretWeaponInfoRq req = msg.getExtension(GamePb6.GetSecretWeaponInfoRq.ext);
        GameServer.ac.getBean(SecretWeaponService.class).getSecretWeaponInfo(req, this);
    }
}
