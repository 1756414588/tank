package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.server.GameServer;
import com.game.service.ActionCenterService;

/**
 * @ClassName:GetActBrotherTaskHandler
 * @author zc
 * @Description: 获取兄弟同心活动界面
 * @date 2017年9月11日
 */
public class GetActBrotherTaskHandler extends ClientHandler {
	@Override
	public void action() {
		GameServer.ac.getBean(ActionCenterService.class).getActBrotherTask(this);
	}

}
