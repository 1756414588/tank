package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.EnergyCoreService;

/**
 * @author yeding
 * @create 2019/3/28 9:38
 * 能源核心信息
 */
public class EnergyCoreInfoHandler extends ClientHandler {
    @Override
    public void action() {
        getService(EnergyCoreService.class).checkEnergyCore(this);
    }
}
