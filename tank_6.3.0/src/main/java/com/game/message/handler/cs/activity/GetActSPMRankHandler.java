package com.game.message.handler.cs.activity;

import com.game.message.handler.ClientHandler;
import com.game.server.GameServer;
import com.game.service.ActionCenterService;

/**
 * @author zhangdh
 * @ClassName: GetActSPMRankHandler
 * @Description:
 * @date 2017-06-03 11:19
 */
public class GetActSPMRankHandler extends ClientHandler{
    @Override
    public void action() {
        GameServer.ac.getBean(ActionCenterService.class).getPartSmeltMasterRank(this);
    }
}
