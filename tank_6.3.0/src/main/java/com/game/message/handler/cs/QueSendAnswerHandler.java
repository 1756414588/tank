package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6.QueSendAnswerRq;
import com.game.service.ActionCenterService;

/**
 * @author: LiFeng
 * @date:2018年9月25日 上午9:14:08
 * @description:
 */
public class QueSendAnswerHandler extends ClientHandler {

	@Override
	public void action() {
		getService(ActionCenterService.class).queSendAnswer(this, msg.getExtension(QueSendAnswerRq.ext));
	}

}
