package com.game.message.handler.cs;

import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6;
import com.game.server.GameServer;
import com.game.service.ActionCenterService;

/**
 * @ClassName:DoActChooseGiftHandler
 * @author zc
 * @Description:自选豪礼领奖
 * @date 2017年8月25日
 */
public class DoActChooseGiftHandler extends ClientHandler {

	@Override
	public void action() {
		GamePb6.DoActChooseGiftRq req = msg.getExtension(GamePb6.DoActChooseGiftRq.ext);
		GameServer.ac.getBean(ActionCenterService.class).doActChooseGift(req, this);
	}

}
