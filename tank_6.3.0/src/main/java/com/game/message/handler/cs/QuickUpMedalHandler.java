package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6.QuickUpMedalRq;
import com.game.service.MedalService;

/**
 * @author: LiFeng
 * @date: 2018年8月14日 下午2:33:48
 * @description:
 */
public class QuickUpMedalHandler extends ClientHandler {

	@Override
	public void action() {
		getService(MedalService.class).quickUpMedal(this, msg.getExtension(QuickUpMedalRq.ext));
	}

}
