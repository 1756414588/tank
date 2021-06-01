package com.game.message.handler.cs.sign;

import com.game.message.handler.ClientHandler;
import com.game.server.GameServer;
import com.game.service.SignService;

/**
 * @author zhangdh
 * @ClassName: MonthSignHandler
 * @Description: :
 * @date 2017/4/17 15:21
 */
public class MonthSignHandler extends ClientHandler{
    @Override
    public void action() {
        GameServer.ac.getBean(SignService.class).monthSign(this);
    }
}
