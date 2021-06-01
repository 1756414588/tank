package com.game.message.handler.cs.airship;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5;
import com.game.server.GameServer;
import com.game.service.airship.AirshipTeamService;

/**
 * @author zhangdh
 * @ClassName: GetAirshipTeamListHandler
 * @Description: 获取飞艇战事(队伍)列表
 * @date 2017-06-15 12:32
 */
public class GetAirshipTeamListHandler extends ClientHandler{

    @Override
    public void action() {
        GamePb5.GetAirshipTeamListRq req = msg.getExtension(GamePb5.GetAirshipTeamListRq.ext);
        GameServer.ac.getBean(AirshipTeamService.class).getAirshipTeamList(req, this);
    }
}
