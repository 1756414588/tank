package com.game.message.handler.cs.lordequip;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5;
import com.game.server.GameServer;
import com.game.service.LordEquipService;

/**
 * @author zhangdh
 * @ClassName: UseTechnicalHandler
 * @Description: 使用铁匠加速
 * @date 2017/4/25 11:40
 */
public class UseTechnicalHandler extends ClientHandler{
    @Override
    public void action() {
        GamePb5.UseTechnicalRq req = msg.getExtension(GamePb5.UseTechnicalRq.ext);
        GameServer.ac.getBean(LordEquipService.class).useTechnical(req,this);
    }
}
