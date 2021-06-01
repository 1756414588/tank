package com.game.message.handler.cs.lord;

import com.game.message.handler.ClientHandler;
import com.game.server.GameServer;
import com.game.service.LordService;

/**
 * @author zhangdh
 * @ClassName: GetMilitaryRankHandler
 * @Description: 获取军衔信息
 * @date 2017-05-26 17:43
 */
public class GetMilitaryRankHandler extends ClientHandler{
    @Override public void action() {
        GameServer.ac.getBean(LordService.class).getMilitaryRankInfo(this);
    }
}
