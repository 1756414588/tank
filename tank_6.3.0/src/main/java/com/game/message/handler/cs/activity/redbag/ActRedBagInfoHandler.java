package com.game.message.handler.cs.activity.redbag;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5;
import com.game.service.activity.ActRedBagsService;

/**
 * @author GuiJie
 * @description 获取红包活动信息
 * @created 2018/02/02 11:14
 */
public class ActRedBagInfoHandler extends ClientHandler {
    @Override
    public void action() {
        GamePb5.GetActRedBagInfoRq req = msg.getExtension(GamePb5.GetActRedBagInfoRq.ext);
        getService(ActRedBagsService.class).getActRedBagInfo(req,this);
    }
}
