package com.game.message.handler.cs.plugin;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6;
import com.game.server.GameServer;
import com.game.service.plugin.PlugInService;

/**
 * @author zhangdh
 * @ClassName: PlugInScoutMineValidCodeHandler
 * @Description:
 * @date 2017-12-27 15:37
 */
public class PlugInScoutMineValidCodeHandler extends ClientHandler {
    @Override
    public void action() {
        GamePb6.PlugInScoutMineValidCodeRq req = msg.getExtension(GamePb6.PlugInScoutMineValidCodeRq.ext);
        GameServer.ac.getBean(PlugInService.class).plugInScoutMineValidCodeRq(req, this);
    }
}
