package com.game.message.handler.cs.lordequip;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5;
import com.game.server.GameServer;
import com.game.service.LordEquipService;

/**
 * @author zhangdh
 * @ClassName: CollectLembHandler
 * @Description: 收取生产结束的材料
 * @date 2017/4/27 17:18
 */
public class CollectLembHandler extends ClientHandler {
    @Override
    public void action() {
        GamePb5.CollectLeqMaterialRq req = msg.getExtension(GamePb5.CollectLeqMaterialRq.ext);
        GameServer.ac.getBean(LordEquipService.class).collectMaterial(req, this);
    }
}
