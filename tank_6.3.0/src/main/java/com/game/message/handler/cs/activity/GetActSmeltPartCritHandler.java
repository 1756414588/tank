package com.game.message.handler.cs.activity;

import com.game.message.handler.ClientHandler;
import com.game.server.GameServer;
import com.game.service.ActivityService;

/**
 * @author zhangdh
 * @ClassName: GetActSmeltPartCritHandler
 * @Description: 部件淬炼暴击活动
 * @date 2017-05-23 0:16
 */
public class GetActSmeltPartCritHandler extends ClientHandler{
    @Override
    public void action() {
        GameServer.ac.getBean(ActivityService.class).getSmeltPartActivity(this);
    }
}
