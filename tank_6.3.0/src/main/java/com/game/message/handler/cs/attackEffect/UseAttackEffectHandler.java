package com.game.message.handler.cs.attackEffect;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6;
import com.game.server.GameServer;
import com.game.service.AttackEffectService;

/**
 * @author zhangdh
 * @ClassName: UseAttackEffectHandler
 * @Description:
 * @date 2017-11-29 14:04
 */
public class UseAttackEffectHandler extends ClientHandler {
    @Override
    public void action() {
        GamePb6.UseAttackEffectRq req = msg.getExtension(GamePb6.UseAttackEffectRq.ext);
        GameServer.ac.getBean(AttackEffectService.class).useAttackEffect(req, this);
    }
}
