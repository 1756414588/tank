package com.game.message.handler.cs.attackEffect;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6;
import com.game.server.GameServer;
import com.game.service.AttackEffectService;

/**
 * @author zhangdh
 * @ClassName: GetAttackEffectHandler
 * @Description:
 * @date 2017-11-29 14:02
 */
public class GetAttackEffectHandler extends ClientHandler {
    @Override
    public void action() {
        GamePb6.GetAttackEffectRq req = msg.getExtension(GamePb6.GetAttackEffectRq.ext);
        GameServer.ac.getBean(AttackEffectService.class).getAttackEffect(req, this);
    }
}
