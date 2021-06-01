package com.game.message.handler.cs.fightlab;

import com.game.message.handler.ClientHandler;
import com.game.service.FightLabService;

/**
 * @author GuiJie
 * @description 作战实验室获取人员信息 科技信息 建筑信息
 * @created 2017/12/20 16:38
 */
public class GetFightLabItemInfoHandler extends ClientHandler {
    @Override
    public void action() {
        getService(FightLabService.class).getFightLabItemInfo(this);
    }
}
