package com.game.message.handler.cs.teaminstance;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6;
import com.game.service.teaminstance.TeamInstanceService;

/**
 * @author : LiFeng
 * @date :
 * @description :
 */
public class TeamInstanceExchangeHandler extends ClientHandler {
    @Override
    public void action() {

        GamePb6.TeamInstanceExchangeRq req = msg.getExtension(GamePb6.TeamInstanceExchangeRq.ext);
        getService(TeamInstanceService.class).exchange(req, this);
    }
}
