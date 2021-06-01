package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.server.GameServer;
import com.game.service.ActionCenterService;

/**
 * @ClassName:GetActCumulativePayInfoHandler
 * @author zc
 * @Description:查看充值详情
 * @date 2017年7月5日
 */
public class GetActCumulativePayInfoHandler extends ClientHandler {

	@Override
	public void action() {
		GameServer.ac.getBean(ActionCenterService.class).getActCumulativePayInfo(this);
	}

}
