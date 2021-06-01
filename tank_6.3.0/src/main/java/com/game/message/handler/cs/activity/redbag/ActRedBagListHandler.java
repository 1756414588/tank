package com.game.message.handler.cs.activity.redbag;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5;
import com.game.service.activity.ActRedBagsService;

/**
 * @author GuiJie
 * @description 获取红包列表
 * @created 2018/02/02 11:14
 */
public class ActRedBagListHandler extends ClientHandler {
    @Override
    public void action() {
        GamePb5.GetActRedBagListRq  req = msg.getExtension(GamePb5.GetActRedBagListRq.ext);
        getService(ActRedBagsService.class).getActRedBagList(req,this);
    }
}
