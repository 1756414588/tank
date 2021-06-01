package com.game.message.handler.cs.airship;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5;
import com.game.server.GameServer;
import com.game.service.airship.AirshipTeamService;

/**
 * @author zhangdh
 * @ClassName: GetAirshipTeamDetailHandler
 * @Description: 获取飞艇战事(队伍)明细
 * @date 2017-06-15 12:34
 */
public class GetAirshipTeamDetailHandler extends ClientHandler{
    @Override
    public void action() {
        GamePb5.GetAirshipTeamDetailRq req = msg.getExtension(GamePb5.GetAirshipTeamDetailRq.ext);
        GameServer.ac.getBean(AirshipTeamService.class).getAirshipTeamDetail(req, this);
    }
}
