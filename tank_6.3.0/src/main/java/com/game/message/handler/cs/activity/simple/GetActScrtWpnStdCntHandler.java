package com.game.message.handler.cs.activity.simple;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5;
import com.game.server.GameServer;
import com.game.service.activity.simple.ActScrtWpnService;

/**
 * @author zhangdh
 * @ClassName: GetActScrtWpnStdCntHandler
 * @Description:
 * @date 2017-12-19 14:13
 */
public class GetActScrtWpnStdCntHandler extends ClientHandler{
    @Override
    public void action() {
        GamePb5.GetActScrtWpnStdCntRq req = msg.getExtension(GamePb5.GetActScrtWpnStdCntRq.ext);
        GameServer.ac.getBean(ActScrtWpnService.class).getActScrtWpnStdCntRq(req, this);
    }
}
