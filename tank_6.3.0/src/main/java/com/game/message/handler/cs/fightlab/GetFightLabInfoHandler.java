package com.game.message.handler.cs.fightlab;

import com.game.message.handler.ClientHandler;
import com.game.service.FightLabService;

/**
 * @author GuiJie
 * @description 作战实验室获取物品信息
 * @created 2017/12/20 16:38
 */
public class GetFightLabInfoHandler extends ClientHandler {
    @Override
    public void action() {
        getService(FightLabService.class).getFightLabInfo(this);
    }
}
