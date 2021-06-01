package com.game.message.handler.cs.activity;

import com.game.message.handler.ClientHandler;
import com.game.server.GameServer;
import com.game.service.ActionCenterService;

/**
 * @author zhangdh
 * @ClassName: GetActSmeltPartMasterHandler
 * @Description:
 * @date 2017-06-01 22:22
 */
public class GetActSmeltPartMasterHandler extends ClientHandler{
    @Override
    public void action() {
        GameServer.ac.getBean(ActionCenterService.class).getSmeltPartMasterActivity(this);
    }
}
