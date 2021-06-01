package com.game.message.handler.cs.lucky;

import com.game.message.handler.ClientHandler;
import com.game.service.ActivityNewService;

/**
 * @author GuiJie
 * @description 幸运奖池获取信息
 * @created 2018-04-17 16:27:39
 */
public class GetActLuckyInfoRqHandler extends ClientHandler {
    @Override
    public void action() {
        getService(ActivityNewService.class).getLuckyInfo( this);
    }
}
