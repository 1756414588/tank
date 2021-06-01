package com.game.message.handler.cs.lordequip;

import com.game.message.handler.ClientHandler;
import com.game.server.GameServer;
import com.game.service.LordEquipService;

/**
 * @author zhangdh
 * @ClassName: GetLembQueueHandler
 * @Description: 每分钟获取材料队列中的生产进度信息
 * @date 2017/5/16 19:53
 */
public class GetLembQueueHandler extends ClientHandler {
    @Override
    public void action() {
        GameServer.ac.getBean(LordEquipService.class).getLembQueueByMinute(this);
    }
}
