package com.game.message.handler.cs.activity;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5;
import com.game.server.GameServer;
import com.game.service.ActionCenterService;

/**
 * @author zhangdh
 * @ClassName: GetActSPMLotteryHandler
 * @Description: 部件淬炼大师活动---氪金淀抽奖
 * @date 2017-06-01 22:24
 */
public class GetActSPMLotteryHandler extends ClientHandler{
    @Override
    public void action() {
        GamePb5.LotteryInSmeltPartMasterRq req = msg.getExtension(GamePb5.LotteryInSmeltPartMasterRq.ext);
        GameServer.ac.getBean(ActionCenterService.class).lotteryInSmeltPartMaster(req, this);
    }
}
