package com.game.message.handler.cs.teaminstance;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6.GetTaskRewardRq;
import com.game.service.teaminstance.TeamInstanceService;

/**
 * @author: LiFeng
 * @date:
 * @description:
 */
public class GetTaskRewardHandler extends ClientHandler{

	@Override
	public void action() {
		getService(TeamInstanceService.class).getTaskReward(this, msg.getExtension(GetTaskRewardRq.ext));
	}
	
}
