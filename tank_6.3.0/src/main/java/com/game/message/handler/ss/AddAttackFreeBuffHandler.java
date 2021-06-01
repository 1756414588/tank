package com.game.message.handler.ss;

import com.game.message.handler.ServerHandler;
import com.game.pb.InnerPb;
import com.game.server.GameServer;
import com.game.service.GmToolService;

/**
 * @author zhangdh
 * @ClassName: AddAttackFreeBuffHandler
 * @Description:
 * @date 2017-11-17 16:09
 */
public class AddAttackFreeBuffHandler extends ServerHandler{
    @Override
    public void action() {
        InnerPb.AddAttackFreeBuffRq req = msg.getExtension(InnerPb.AddAttackFreeBuffRq.ext);
        GmToolService service = GameServer.ac.getBean(GmToolService.class);
        service.addAttackFreeBuff(req);
    }
}
