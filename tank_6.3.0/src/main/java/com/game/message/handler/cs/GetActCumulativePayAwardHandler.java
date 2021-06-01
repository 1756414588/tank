package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb5.GetActCumulativePayAwardRq;
import com.game.server.GameServer;
import com.game.service.ActionCenterService;

/**
 * @ClassName:GetActCumulativePayAwardHandler
 * @author zc
 * @Description:领取连续充值奖励
 * @date 2017年7月5日
 */
public class GetActCumulativePayAwardHandler extends ClientHandler {

	@Override
	public void action() {
		GetActCumulativePayAwardRq req = msg.getExtension(GetActCumulativePayAwardRq.ext);
		GameServer.ac.getBean(ActionCenterService.class).getActCumulativePayAward(req, this);
	}

}
