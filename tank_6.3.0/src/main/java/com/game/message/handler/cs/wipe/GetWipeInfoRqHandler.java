package com.game.message.handler.cs.wipe;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6;
import com.game.service.CombatService;
import com.game.service.FriendService;

/**
 * @author ：Liu Gui Jie
 * @date ：Created in 2019/2/15 11:24
 * @description：获取扫荡设置信息
 */
public class GetWipeInfoRqHandler extends ClientHandler {
    @Override
    public void action() {
        GamePb6.GetWipeInfoRq req = msg.getExtension(GamePb6.GetWipeInfoRq.ext);
        getService(CombatService.class).getWipeInfoRq(req, this);
    }
}
