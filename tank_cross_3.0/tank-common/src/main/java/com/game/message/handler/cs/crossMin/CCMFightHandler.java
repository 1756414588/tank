package com.game.message.handler.cs.crossMin;

import com.game.message.handler.ClientHandler;
import com.game.pb.CrossMinPb;
import com.game.service.crossmin.CrossMinService;

/**
 * @author yeding
 * @create 2019/5/19 1:15
 * @decs 组队跨服战斗
 */
public class CCMFightHandler extends ClientHandler {
    @Override
    public void action() {
        getService(CrossMinService.class).fight(msg.getExtension(CrossMinPb.CrossFightRq.ext).getRoleId(), this);
    }
}
