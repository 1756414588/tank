package com.game.message.handler.cs.sign;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5;
import com.game.server.GameServer;
import com.game.service.SignService;

/**
 * @author zhangdh
 * @ClassName: DrawMonthSignExtHandler
 * @Description: 领取每月签到额外奖励
 * @date 2017/4/17 15:22
 */
public class DrawMonthSignExtHandler extends ClientHandler{
    @Override
    public void action() {
        GamePb5.DrawMonthSignExtRq rq = msg.getExtension(GamePb5.DrawMonthSignExtRq.ext);
        GameServer.ac.getBean(SignService.class).drawExtReward(rq, this);
    }
}
