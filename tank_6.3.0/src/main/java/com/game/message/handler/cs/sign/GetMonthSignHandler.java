package com.game.message.handler.cs.sign;

import com.game.message.handler.ClientHandler;
import com.game.server.GameServer;
import com.game.service.SignService;

/**
 * @author zhangdh
 * @ClassName: GetMonthSignHandler
 * @Description: 获取玩家每月签到信息
 * @date 2017/4/17 15:19
 */
public class GetMonthSignHandler extends ClientHandler{
    @Override
    public void action() {
        GameServer.ac.getBean(SignService.class).getMothSignInfo(this);
    }
}
