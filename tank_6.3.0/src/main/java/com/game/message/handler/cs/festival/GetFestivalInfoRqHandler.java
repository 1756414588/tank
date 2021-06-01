package com.game.message.handler.cs.festival;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6;
import com.game.service.ActivityNewService;

/**
 * @author GuiJie
 * @description 获取假日碎片信息
 * @created 2018-04-17 16:27:39
 */
public class GetFestivalInfoRqHandler extends ClientHandler {
    @Override
    public void action() {
        GamePb6.GetFestivalInfoRq req = msg.getExtension(GamePb6.GetFestivalInfoRq.ext);
        getService(ActivityNewService.class).getFestivalInfo(req, this);
    }
}
