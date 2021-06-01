package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.service.FightLabService;

/**
 * @author: LiFeng
 * @date: 2018年9月19日 下午4:26:07
 * @description:
 */
public class GetAllSpyTaskRewardHandler extends ClientHandler {

	@Override
	public void action() {
		   getService(FightLabService.class).getSpyTaskAllReward(this);
	}

}
