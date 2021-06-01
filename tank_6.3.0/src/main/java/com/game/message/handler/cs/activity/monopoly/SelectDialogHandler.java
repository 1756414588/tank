package com.game.message.handler.cs.activity.monopoly;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5;
import com.game.server.GameServer;
import com.game.service.activity.MonopolyService;

/**
 * @author zhangdh
 * @ClassName: SelectDialogHandler
 * @Description:
 * @date 2017-12-02 10:52
 */
public class SelectDialogHandler extends ClientHandler {
    @Override
    public void action() {
        GamePb5.SelectDialogRq req = msg.getExtension(GamePb5.SelectDialogRq.ext);
        GameServer.ac.getBean(MonopolyService.class).selectDialog(req, this);
    }
}
