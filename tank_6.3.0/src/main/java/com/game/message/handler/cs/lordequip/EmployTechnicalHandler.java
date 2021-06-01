package com.game.message.handler.cs.lordequip;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5;
import com.game.server.GameServer;
import com.game.service.LordEquipService;

/**
 * @author zhangdh
 * @ClassName: EmployTechnicalHandler
 * @Description: 雇佣铁匠
 * @date 2017/4/25 11:40
 */
public class EmployTechnicalHandler extends ClientHandler {
    @Override
    public void action() {
        GamePb5.EmployTechnicalRq req = msg.getExtension(GamePb5.EmployTechnicalRq.ext);
        GameServer.ac.getBean(LordEquipService.class).employTechnicalRq(req, this);
    }
}
