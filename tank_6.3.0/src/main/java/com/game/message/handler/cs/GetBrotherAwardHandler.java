package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6;
import com.game.server.GameServer;
import com.game.service.ActionCenterService;

/**
 * @ClassName:GetBrotherAwardHandler
 * @author zc
 * @Description: 领取完成任务奖励
 * @date 2017年9月11日
 */
public class GetBrotherAwardHandler extends ClientHandler {
	@Override
	public void action() {
		GamePb6.GetBrotherAwardRq req = msg.getExtension(GamePb6.GetBrotherAwardRq.ext);
		GameServer.ac.getBean(ActionCenterService.class).getBrotherAward(req.getId(), this);
	}

}
