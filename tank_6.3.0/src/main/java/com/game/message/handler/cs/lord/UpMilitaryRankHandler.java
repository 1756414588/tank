package com.game.message.handler.cs.lord;

import com.game.message.handler.ClientHandler;
import com.game.server.GameServer;
import com.game.service.LordService;

/**
 * @author zhangdh
 * @ClassName: UpMilitaryRankHandler
 * @Description: 升级玩家军衔
 * @date 2017-05-26 17:44
 */
public class UpMilitaryRankHandler extends ClientHandler{
    @Override public void action() {
        GameServer.ac.getBean(LordService.class).upMilitaryRank(this);
    }
}
