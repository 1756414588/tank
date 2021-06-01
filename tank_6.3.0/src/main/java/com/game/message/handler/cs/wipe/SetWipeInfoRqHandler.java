package com.game.message.handler.cs.wipe;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6;
import com.game.service.CombatService;

/**
 * @author ：Liu Gui Jie
 * @date ：Created in 2019/2/15 11:24
 * @description：设置扫荡信息
 */
public class SetWipeInfoRqHandler extends ClientHandler {
    @Override
    public void action() {
        GamePb6.SetWipeInfoRq req = msg.getExtension(GamePb6.SetWipeInfoRq.ext);
        getService(CombatService.class).setWipeInfoRq(req, this);
    }
}
