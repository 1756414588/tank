package com.game.message.handler.cs.activity.redbag;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5;
import com.game.server.GameServer;
import com.game.service.activity.ActRedBagsService;

/**
 * @author zhangdh
 * @ClassName: DrawActRedBagStageAwardHandler
 * @Description:
 * @date 2018-02-03 10:26
 */
public class DrawActRedBagStageAwardHandler extends ClientHandler{
    @Override
    public void action() {
        GamePb5.DrawActRedBagStageAwardRq req = msg.getExtension(GamePb5.DrawActRedBagStageAwardRq.ext);
        GameServer.ac.getBean(ActRedBagsService.class).drawActRedBagStageAward(req, this);
    }
}
