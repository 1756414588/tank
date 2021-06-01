package com.game.message.handler.cs.activity.simple;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5;
import com.game.server.GameServer;
import com.game.service.activity.simple.ActVipCountService;

/**
 * @author zhangdh
 * @ClassName: GetActVipCountInfoHandler
 * @Description:
 * @date 2018-01-17 16:21
 */
public class GetActVipCountInfoHandler extends ClientHandler{
    @Override
    public void action() {
        GamePb5.GetActVipCountInfoRq req = msg.getExtension(GamePb5.GetActVipCountInfoRq.ext);
        GameServer.ac.getBean(ActVipCountService.class).getActVipCountInfo(req, this);
    }
}
