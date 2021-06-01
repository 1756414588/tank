package com.game.message.handler.cs.wipe;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6;
import com.game.service.CombatService;

/**
 * @author ：Liu Gui Jie
 * @date ：Created in 2019/2/15 11:24
 * @description：扫荡
 */
public class GetWipeRewarRqHandler extends ClientHandler {
    @Override
    public void action() {
        GamePb6.GetWipeRewarRq req = msg.getExtension(GamePb6.GetWipeRewarRq.ext);
        getService(CombatService.class).getWipeRewarRq(req, this);
    }
}
