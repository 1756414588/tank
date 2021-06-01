package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.teaminstance.TeamService;

/**
 * @author yeding
 * @create 2019/4/27 17:05
 * @decs
 */
public class QueryCrossServerListHandler extends ClientHandler {
    @Override
    public void action() {
        getService(TeamService.class).queryServerList(this);
    }
}
