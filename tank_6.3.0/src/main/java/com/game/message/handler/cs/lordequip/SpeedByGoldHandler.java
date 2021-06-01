package com.game.message.handler.cs.lordequip;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5;
import com.game.server.GameServer;
import com.game.service.LordEquipService;

/**
 * @author zhangdh
 * @ClassName: SpeedByGoldHandler
 * @Description: 使用金币加速
 * @date 2017/4/25 17:34
 */
public class SpeedByGoldHandler extends ClientHandler{
    @Override
    public void action() {
        GamePb5.LordEquipSpeedByGoldRq req = msg.getExtension(GamePb5.LordEquipSpeedByGoldRq.ext);
        GameServer.ac.getBean(LordEquipService.class).speedByGold(this);
    }
}
